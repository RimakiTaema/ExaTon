import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/exaroton/models.dart';
import '../accounts/accounts.dart';
import '../settings/settings.dart';

/// Same key as ExaTon 1.3's localStorage entry, now in the `kv` table.
const recentServersKey = 'exaton_recent_servers';

/// How many recent servers are kept per account.
const maxRecentServers = 12;

/// A server the user opened. The status is not stored; it comes from the
/// live server list.
@immutable
class RecentServer {
  const RecentServer({
    required this.id,
    required this.name,
    required this.address,
    required this.accountId,
    required this.visitedAt,
  });

  final String id;
  final String name;
  final String address;

  /// The saved account it was opened with. 1.3 keyed this by email; 1.6
  /// keeps no email on the device, so it is the account's local ID.
  final String accountId;
  final DateTime visitedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'accountId': accountId,
    'visitedAt': visitedAt.millisecondsSinceEpoch,
  };

  /// Null for an entry that is missing a required field.
  static RecentServer? fromJson(Object? j) {
    if (j is! Map) return null;
    final id = j['id'], name = j['name'], account = j['accountId'], at = j['visitedAt'];
    if (id is! String || name is! String || account is! String || at is! num) return null;
    return RecentServer(
      id: id,
      name: name,
      address: j['address'] is String ? j['address'] as String : '',
      accountId: account,
      visitedAt: DateTime.fromMillisecondsSinceEpoch(at.toInt()),
    );
  }
}

/// Puts [entry] first, replacing an older visit of the same server by the
/// same account, and keeps the newest [max] per account. Other accounts'
/// entries are untouched. Newest first.
List<RecentServer> upsertRecent(List<RecentServer> all, RecentServer entry, {int max = maxRecentServers}) {
  final merged = [entry, ...all.where((r) => !(r.id == entry.id && r.accountId == entry.accountId))]
    ..sort((a, b) => b.visitedAt.compareTo(a.visitedAt));
  final kept = <String, int>{};
  return merged.where((r) => (kept[r.accountId] = (kept[r.accountId] ?? 0) + 1) <= max).toList();
}

/// [all] without one account's visit of [serverId].
List<RecentServer> removeRecent(List<RecentServer> all, String accountId, String serverId) =>
    all.where((r) => !(r.id == serverId && r.accountId == accountId)).toList();

/// One account's entries, newest first.
List<RecentServer> recentFor(List<RecentServer> all, String accountId) =>
    all.where((r) => r.accountId == accountId).toList()..sort((a, b) => b.visitedAt.compareTo(a.visitedAt));

List<RecentServer> decodeRecent(Map<String, dynamic>? json) {
  final items = json?['items'];
  return items is List ? items.map(RecentServer.fromJson).nonNulls.toList() : const [];
}

Map<String, dynamic> encodeRecent(List<RecentServer> all) => {
  'items': [for (final r in all) r.toJson()],
};

/// Every account's recent servers, as stored.
final _allRecentProvider = AsyncNotifierProvider<_AllRecent, List<RecentServer>>(_AllRecent.new);

class _AllRecent extends AsyncNotifier<List<RecentServer>> {
  @override
  Future<List<RecentServer>> build() async => decodeRecent(await ref.read(databaseProvider).readJson(recentServersKey));

  Future<void> change(List<RecentServer> Function(List<RecentServer> all) edit) async {
    final next = edit(await future);
    state = AsyncData(next);
    await ref.read(databaseProvider).writeJson(recentServersKey, encodeRecent(next));
  }
}

/// The active account's recent servers, newest first.
final recentServersProvider = Provider<List<RecentServer>>((ref) {
  final accountId = ref.watch(activeAccountProvider.select((a) => a?.id));
  final all = ref.watch(_allRecentProvider).value;
  if (accountId == null || all == null) return const [];
  return recentFor(all, accountId);
});

/// Records and forgets visits for the active account.
final recentServersControllerProvider = Provider<RecentServersController>(RecentServersController.new);

class RecentServersController {
  RecentServersController(this._ref);
  final Ref _ref;

  Future<void> visit(Server server, {DateTime? at}) async {
    final accountId = _ref.read(activeAccountProvider)?.id;
    if (accountId == null) return;
    final entry = RecentServer(
      id: server.id,
      name: server.name,
      address: server.address,
      accountId: accountId,
      visitedAt: at ?? DateTime.now(),
    );
    await _ref.read(_allRecentProvider.notifier).change((all) => upsertRecent(all, entry));
  }

  Future<void> forget(String serverId) async {
    final accountId = _ref.read(activeAccountProvider)?.id;
    if (accountId == null) return;
    await _ref.read(_allRecentProvider.notifier).change((all) => removeRecent(all, accountId, serverId));
  }
}
