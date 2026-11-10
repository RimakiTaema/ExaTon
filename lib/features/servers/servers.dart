import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/exaroton/client.dart';
import '../../core/exaroton/models.dart';
import '../accounts/accounts.dart';
import 'recent_servers.dart';

/// List refresh. The docs state no rate limits, so poll slowly and lean on
/// the status stream of the open server.
const listPollIdle = Duration(seconds: 60);
const listPollBusy = Duration(seconds: 10);
const actionPoll = Duration(seconds: 3);
const actionTimeout = Duration(minutes: 3);

final serversProvider = AsyncNotifierProvider<ServersNotifier, List<Server>>(ServersNotifier.new);

/// When the list last loaded, whether a refresh is running, and the last
/// failure. A failed refresh keeps the old list and sets [error], so the UI
/// can say the data is stale instead of hiding it.
@immutable
class ServersSync {
  const ServersSync({this.updated, this.error, this.refreshing = false});
  final DateTime? updated;
  final Object? error;
  final bool refreshing;
}

final serversSyncProvider = NotifierProvider<ServersSyncNotifier, ServersSync>(ServersSyncNotifier.new);

class ServersSyncNotifier extends Notifier<ServersSync> {
  @override
  ServersSync build() {
    ref.watch(clientProvider); // Reset on account switch.
    return const ServersSync();
  }

  void started() => state = ServersSync(updated: state.updated, error: state.error, refreshing: true);
  void ok() => state = ServersSync(updated: DateTime.now());
  void failed(Object e) => state = ServersSync(updated: state.updated, error: e);
}

class ServersNotifier extends AsyncNotifier<List<Server>> {
  Timer? _timer;
  DateTime? lastRefreshed;

  @override
  Future<List<Server>> build() async {
    final client = requireClient(ref);
    ref.onDispose(() => _timer?.cancel());
    final List<Server> list;
    try {
      list = await client.getServers();
    } catch (e) {
      Future.microtask(() => ref.read(serversSyncProvider.notifier).failed(e));
      rethrow;
    }
    lastRefreshed = DateTime.now();
    Future.microtask(() => ref.read(serversSyncProvider.notifier).ok());
    _schedule(list);
    return list;
  }

  void _schedule(List<Server> list) {
    _timer?.cancel();
    final busy = list.any((s) => s.status.group == StatusGroup.busy);
    _timer = Timer(busy ? listPollBusy : listPollIdle, () => refresh());
  }

  Future<void> refresh() async {
    final client = ref.read(clientProvider);
    if (client == null) return;
    final sync = ref.read(serversSyncProvider.notifier)..started();
    try {
      final list = await client.getServers();
      lastRefreshed = DateTime.now();
      state = AsyncData(list);
      sync.ok();
      _schedule(list);
    } catch (e, st) {
      if (state.value == null) state = AsyncError(e, st);
      sync.failed(e);
      _schedule(state.value ?? const []);
    }
  }

  /// Merges a status-stream or single-server update into the list.
  void applyStatus(Server s) {
    final list = state.value;
    if (list == null) return;
    final i = list.indexWhere((x) => x.id == s.id);
    if (i < 0) return;
    state = AsyncData([...list]..[i] = s);
  }
}

final serverByIdProvider = Provider.family<Server?, String>((ref, id) {
  final list = ref.watch(serversProvider).value;
  if (list == null) return null;
  for (final s in list) {
    if (s.id == id) return s;
  }
  return null;
});

// ── Start / stop / restart ─────────────────────────────────────────────

enum ServerAction { start, stop, restart }

@immutable
class PendingAction {
  const PendingAction(this.action, this.from, this.since);
  final ServerAction action;
  final ServerStatus from;
  final DateTime since;
}

/// Tracks actions until the status confirms the change. The button for a
/// server shows a loading state and stays disabled while it is pending.
final serverActionsProvider = NotifierProvider<ServerActionsNotifier, Map<String, PendingAction>>(
  ServerActionsNotifier.new,
);

class ServerActionsNotifier extends Notifier<Map<String, PendingAction>> {
  final _timers = <String, Timer>{};

  @override
  Map<String, PendingAction> build() {
    ref.watch(clientProvider); // Reset on account switch.
    ref.onDispose(() {
      for (final t in _timers.values) {
        t.cancel();
      }
      _timers.clear();
    });
    ref.listen(serversProvider, (_, next) {
      final list = next.value;
      if (list == null) return;
      for (final s in list) {
        final p = state[s.id];
        if (p != null && s.status != p.from) _resolve(s.id);
      }
    });
    return const {};
  }

  /// Returns a message for the user when the server was already in that
  /// state (HTTP 208), otherwise null. Throws [ExarotonException].
  Future<String?> run(Server server, ServerAction action, {bool useOwnCredits = false}) async {
    final client = ref.read(clientProvider);
    if (client == null || state.containsKey(server.id)) return null;
    state = {...state, server.id: PendingAction(action, server.status, DateTime.now())};
    try {
      final result = switch (action) {
        ServerAction.start => await client.start(server.id, useOwnCredits: useOwnCredits),
        ServerAction.stop => await client.stop(server.id),
        ServerAction.restart => await client.restart(server.id),
      };
      _watch(server.id);
      if (result == ActionResult.alreadyInProgress) {
        return action == ServerAction.start ? 'Already starting' : 'Already stopping';
      }
      return null;
    } catch (_) {
      _resolve(server.id);
      rethrow;
    }
  }

  void _watch(String id) {
    _timers[id]?.cancel();
    _timers[id] = Timer.periodic(actionPoll, (t) async {
      final p = state[id];
      if (p == null || DateTime.now().difference(p.since) > actionTimeout) {
        _resolve(id);
        return;
      }
      try {
        final s = await ref.read(clientProvider)?.getServer(id);
        if (s != null) ref.read(serversProvider.notifier).applyStatus(s);
      } catch (_) {}
    });
  }

  /// Called by the open server's status stream too.
  void observe(Server s) {
    final p = state[s.id];
    if (p != null && s.status != p.from) _resolve(s.id);
  }

  void _resolve(String id) {
    _timers.remove(id)?.cancel();
    if (state.containsKey(id)) state = {...state}..remove(id);
  }
}

// ── Selection, search and filter ───────────────────────────────────────

final selectedServerProvider = NotifierProvider<SelectedServer, String?>(SelectedServer.new);

class SelectedServer extends Notifier<String?> {
  @override
  String? build() {
    ref.watch(clientProvider); // Clear on account switch.
    return null;
  }

  /// [record] adds the server to the recent list. Pass false for a
  /// selection the user did not make, such as the default on wide windows.
  void select(String? id, {bool record = true}) {
    state = id;
    if (id == null || !record) return;
    final server = ref.read(serverByIdProvider(id));
    if (server != null) ref.read(recentServersControllerProvider).visit(server);
  }
}

/// [recent] lists the servers this account opened, newest first.
enum ServerFilter { all, online, offline, recent }

final serverQueryProvider = NotifierProvider<ServerQuery, (String, ServerFilter)>(ServerQuery.new);

class ServerQuery extends Notifier<(String, ServerFilter)> {
  @override
  (String, ServerFilter) build() => ('', ServerFilter.all);

  void setText(String text) => state = (text, state.$2);
  void setFilter(ServerFilter f) => state = (state.$1, f);
}

/// [recentIds] is the recent list, newest first; only [ServerFilter.recent]
/// uses it, and its result follows that order.
List<Server> filterServers(List<Server> list, String text, ServerFilter filter, {List<String> recentIds = const []}) {
  final q = text.trim().toLowerCase();
  if (filter == ServerFilter.recent) {
    final byId = {for (final s in list) s.id: s};
    list = [for (final id in recentIds) ?byId[id]];
  }
  return list.where((s) {
    final matches = q.isEmpty || s.name.toLowerCase().contains(q) || s.address.toLowerCase().contains(q);
    final inFilter = switch (filter) {
      ServerFilter.all || ServerFilter.recent => true,
      ServerFilter.online => s.status == ServerStatus.online,
      ServerFilter.offline => s.status == ServerStatus.offline || s.status == ServerStatus.crashed,
    };
    return matches && inFilter;
  }).toList();
}
