import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/console/ansi.dart';
import '../../core/console/ring_buffer.dart';
import '../../core/exaroton/client.dart';
import '../../core/exaroton/models.dart';
import '../../core/exaroton/websocket.dart';
import '../../core/storage/database.dart';
import '../accounts/accounts.dart';
import '../servers/servers.dart';
import '../settings/settings.dart';

const consoleCapacity = 5000;

class ConsoleLine {
  ConsoleLine(this.raw, {this.isCommand = false}) : plain = stripAnsi(raw);
  final String raw;
  final String plain;
  final bool isCommand;

  List<AnsiSpan>? _spans;
  List<AnsiSpan> get spans => _spans ??= parseAnsi(raw);
}

class ActivityEvent {
  const ActivityEvent(this.text, this.time);
  final String text;
  final DateTime time;
}

/// Socket, console buffer and live stats for the server on screen. Created
/// when a console or overview view watches it and closed when the user
/// leaves, which keeps sockets, memory and battery use low.
class LiveSession extends ChangeNotifier {
  LiveSession({
    required Server initial,
    required String token,
    required ExarotonClient client,
    required AppDatabase db,
    required void Function(Server) onStatus,
    SocketConnector? connector,
  }) : server = initial,
       _client = client,
       _db = db,
       _onStatus = onStatus,
       socket = ServerSocket(serverId: initial.id, token: token, connector: connector) {
    _subs = [
      socket.states.listen((s) {
        socketState = s;
        notifyListeners();
      }),
      socket.statuses.listen(_status),
      socket.consoleLines.listen(_line),
      socket.memory.listen((m) {
        memory = m;
        notifyListeners();
      }),
      socket.heap.listen((h) {
        heap = h;
        notifyListeners();
      }),
      socket.tick.listen((t) {
        tick = t;
        notifyListeners();
      }),
    ];
    final sw = server.software;
    socket.want({
      LiveStream.console,
      LiveStream.stats,
      if (sw == null || sw.supportsTick) LiveStream.tick,
      if (sw == null || sw.isJava) LiveStream.heap,
    });
    socket.seedStatus(server.status);
    socket.connect();
    _loadHistory();
  }

  final ServerSocket socket;
  final ExarotonClient _client;
  final AppDatabase _db;
  final void Function(Server) _onStatus;
  late final List<StreamSubscription<dynamic>> _subs;

  Server server;
  SocketState socketState = SocketState.connecting;
  MemoryStats? memory;
  int? heap;
  double? tick;

  final lines = RingBuffer<ConsoleLine>(consoleCapacity);

  /// Bumped on every console change. The console listens to this alone, so
  /// stats updates do not rebuild it and vice versa.
  final linesVersion = ValueNotifier<int>(0);

  final activity = <ActivityEvent>[];
  List<String> history = const [];
  bool commandInFlight = false;

  static final _joined = RegExp(r'\]: (\w{2,16}) joined the game');
  static final _left = RegExp(r'\]: (\w{2,16}) left the game');

  void _status(Server s) {
    final before = server.status;
    server = s;
    if (before != s.status) {
      switch (s.status) {
        case ServerStatus.online:
          _activity('Server started');
        case ServerStatus.offline:
          _activity('Server stopped');
          // Readings come from streams that end with the server.
          memory = null;
          heap = null;
          tick = null;
        case ServerStatus.crashed:
          _activity('Server crashed');
        default:
          break;
      }
    }
    _onStatus(s);
    notifyListeners();
  }

  void _line(String raw) {
    // A message can hold several lines.
    for (final part in raw.split('\n')) {
      if (part.isEmpty) continue;
      final line = ConsoleLine(part);
      lines.add(line);
      final j = _joined.firstMatch(line.plain);
      if (j != null) _activity('${j.group(1)} joined');
      final l = _left.firstMatch(line.plain);
      if (l != null) _activity('${l.group(1)} left');
    }
    linesVersion.value++;
  }

  void _activity(String text) {
    activity.insert(0, ActivityEvent(text, DateTime.now()));
    if (activity.length > 30) activity.removeLast();
  }

  Future<void> _loadHistory() async {
    history = await _db.commands(server.id);
    notifyListeners();
  }

  /// Sends over the socket, or `POST /command/` when it is down. Send is
  /// disabled while a command is in flight.
  Future<void> sendCommand(String command) async {
    final cmd = command.trim();
    if (cmd.isEmpty || commandInFlight) return;
    commandInFlight = true;
    notifyListeners();
    try {
      if (!socket.sendCommand(cmd)) {
        await _client.sendCommand(server.id, cmd);
      }
      lines.add(ConsoleLine('> $cmd', isCommand: true));
      linesVersion.value++;
      await _db.addCommand(server.id, cmd);
      history = [cmd, ...history.where((h) => h != cmd)].take(AppDatabase.historyLimit).toList();
    } finally {
      commandInFlight = false;
      notifyListeners();
    }
  }

  /// Empties the buffer only.
  void clear() {
    lines.clear();
    linesVersion.value++;
  }

  Future<SharedLog> shareLog() => _client.shareLog(server.id);

  bool _disposed = false;

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    for (final s in _subs) {
      s.cancel();
    }
    socket.close();
    linesVersion.dispose();
    super.dispose();
  }
}

/// Overridable in tests with a fake websocket server.
final socketConnectorProvider = Provider<SocketConnector?>((ref) => null);

final liveSessionProvider = Provider.autoDispose.family<LiveSession?, String>((ref, id) {
  final account = ref.watch(activeAccountProvider);
  final client = ref.watch(clientProvider);
  // Rebuild once the server list has it, but not on every status change.
  ref.watch(serverByIdProvider(id).select((s) => s != null));
  final initial = ref.read(serverByIdProvider(id));
  if (account == null || client == null || initial == null) return null;
  final session = LiveSession(
    initial: initial,
    token: account.token,
    client: client,
    db: ref.read(databaseProvider),
    connector: ref.read(socketConnectorProvider),
    onStatus: (s) {
      ref.read(serversProvider.notifier).applyStatus(s);
      ref.read(serverActionsProvider.notifier).observe(s);
    },
  );
  ref.onDispose(session.dispose);
  return session;
});
