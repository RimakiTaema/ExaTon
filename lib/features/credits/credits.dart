import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderOrFamily;

import '../../core/exaroton/client.dart';
import '../../core/exaroton/models.dart';
import '../../core/storage/database.dart';
import '../accounts/accounts.dart';
import '../servers/servers.dart';
import '../settings/settings.dart';
import 'estimate.dart';

/// Sample owner key for the account balance or one pool.
String sampleOwner(String accountId, [String? poolId]) => poolId == null ? accountId : '$accountId:$poolId';

/// How often balances are sampled while the app is open.
const sampleInterval = Duration(minutes: 15);

/// Refreshes account and pool balances every 15 minutes while watched.
final creditsTickerProvider = Provider<void>((ref) {
  final t = Timer.periodic(sampleInterval, (_) => refreshCredits(ref.invalidate));
  ref.onDispose(t.cancel);
});

/// Pass `ref.invalidate` from a provider or a widget.
void refreshCredits(void Function(ProviderOrFamily) invalidate) {
  invalidate(accountInfoProvider);
  invalidate(poolsProvider);
  invalidate(poolServersProvider);
}

/// Account balance, recording a sample on each fetch.
final accountCreditsProvider = FutureProvider<(Account, DateTime)>((ref) async {
  final account = await ref.watch(accountInfoProvider.future);
  final id = ref.read(activeAccountProvider)?.id;
  if (id != null) await ref.read(databaseProvider).addSample(sampleOwner(id), account.credits);
  return (account, DateTime.now());
});

final poolsProvider = FutureProvider<List<CreditPool>>((ref) async {
  final pools = await requireClient(ref).getPools();
  final id = ref.read(activeAccountProvider)?.id;
  final db = ref.read(databaseProvider);
  if (id != null) {
    for (final p in pools) {
      await db.addSample(sampleOwner(id, p.id), p.credits);
    }
  }
  return pools;
});

// ── Balance history ────────────────────────────────────────────────────

/// Time ranges of the balance graph. Samples are kept for [sampleRetention],
/// so that is the longest.
enum BalanceRange {
  sixHours('6 h', Duration(hours: 6)),
  day('24 h', Duration(hours: 24)),
  week('7 d', sampleRetention);

  const BalanceRange(this.label, this.window);
  final String label;
  final Duration window;
}

/// [samples] no older than [window] before [now], oldest first.
List<BalanceSample> samplesInWindow(List<BalanceSample> samples, Duration window, {required DateTime now}) {
  final from = now.subtract(window);
  return samples.where((s) => !s.time.isBefore(from)).toList()..sort((a, b) => a.time.compareTo(b.time));
}

/// Every kept sample of one owner (see [sampleOwner]), oldest first. Reloads
/// when a balance fetch records a new sample.
final balanceHistoryProvider = FutureProvider.autoDispose.family<List<BalanceSample>, String>((ref, owner) async {
  ref.watch(accountCreditsProvider);
  ref.watch(poolsProvider);
  return ref.read(databaseProvider).samples(owner, window: sampleRetention);
});

/// Deletes one owner's samples. The Recent usage estimate uses the same
/// samples, so it starts over too.
Future<void> clearBalanceHistory(WidgetRef ref, String owner) async {
  await ref.read(databaseProvider).clearSamples(owner);
  ref.invalidate(balanceHistoryProvider(owner));
  ref.invalidate(creditsOverviewProvider);
}

final poolServersProvider = FutureProvider.family<List<Server>, String>(
  (ref, poolId) => requireClient(ref).getPoolServers(poolId),
);

/// Throws [ExarotonException] with 403 without the "View members" permission.
final poolMembersProvider = FutureProvider.family<List<PoolMember>, String>(
  (ref, poolId) => requireClient(ref).getPoolMembers(poolId),
);

// ── RAM cache ──────────────────────────────────────────────────────────

/// Each server's RAM in GB, cached in SQLite and refetched when the user
/// changes it.
final ramCacheProvider = AsyncNotifierProvider<RamCache, Map<String, int>>(RamCache.new);

class RamCache extends AsyncNotifier<Map<String, int>> {
  final _failed = <String>{};

  @override
  Future<Map<String, int>> build() => ref.read(databaseProvider).ramCache();

  /// Fetches RAM for [ids] not in the cache. Servers the account cannot read
  /// (403) stay unknown, and their payer falls back to Recent usage.
  Future<Map<String, int>> ensure(Iterable<String> ids) async {
    final cache = {...(await future)};
    final client = ref.read(clientProvider);
    if (client == null) return cache;
    final missing = ids.where((id) => !cache.containsKey(id) && !_failed.contains(id)).toSet();
    for (final id in missing) {
      try {
        final gb = await client.getRam(id);
        cache[id] = gb;
        await ref.read(databaseProvider).setRam(id, gb);
      } catch (_) {
        _failed.add(id);
      }
    }
    if (missing.isNotEmpty) state = AsyncData(cache);
    return cache;
  }

  Future<void> set(String id, int gb) async {
    await ref.read(databaseProvider).setRam(id, gb);
    state = AsyncData({...(state.value ?? {}), id: gb});
  }
}

// ── Overview ───────────────────────────────────────────────────────────

@immutable
class PayerSummary {
  const PayerSummary({
    required this.poolId,
    required this.name,
    required this.credits,
    required this.estimate,
    required this.low,
  });

  /// Null for the account.
  final String? poolId;
  final String name;
  final double credits;
  final Estimate? estimate;

  /// Under the alert threshold or credit floor.
  final bool low;
}

@immutable
class RunningRow {
  const RunningRow({required this.server, required this.payerName, required this.creditsPerHour});
  final Server server;
  final String payerName;
  final double? creditsPerHour;
}

@immutable
class CreditsOverview {
  const CreditsOverview({
    required this.account,
    required this.accountSummary,
    required this.pools,
    required this.poolSummaries,
    required this.payerOf,
    required this.running,
    this.stored = const {},
    required this.updated,
  });

  final Account account;
  final PayerSummary accountSummary;
  final List<CreditPool> pools;
  final Map<String, PayerSummary> poolSummaries;

  /// Server ID to pool ID, for servers in a pool.
  final Map<String, String> payerOf;
  final List<RunningRow> running;

  /// Servers each payer keeps, for the storage price. Null key: the account.
  final Map<String?, int> stored;
  final DateTime updated;

  List<PayerSummary> get lowPools => poolSummaries.values.where((p) => p.low).toList();
}

final creditsOverviewProvider = FutureProvider<CreditsOverview>((ref) async {
  final accountId = ref.watch(activeAccountProvider)?.id;
  if (accountId == null) throw StateError('No account');
  final (account, updated) = await ref.watch(accountCreditsProvider.future);
  final pools = await ref.watch(poolsProvider.future);
  final settings = ref.watch(settingsProvider);
  final myServers = ref.watch(serversProvider).value ?? const <Server>[];
  final db = ref.read(databaseProvider);

  final poolServers = <String, List<Server>>{};
  for (final p in pools) {
    try {
      poolServers[p.id] = await ref.watch(poolServersProvider(p.id).future);
    } catch (_) {
      poolServers[p.id] = const [];
    }
  }

  final result = await computeOverview(
    accountId: accountId,
    account: account,
    pools: pools,
    poolServers: poolServers,
    myServers: myServers,
    settings: settings,
    db: db,
    ram: (ids) => ref.read(ramCacheProvider.notifier).ensure(ids),
    updated: updated,
  );
  ref.watch(ramCacheProvider);
  return result;
});

/// Shared by the UI and the Android background check.
Future<CreditsOverview> computeOverview({
  required String accountId,
  required Account account,
  required List<CreditPool> pools,
  required Map<String, List<Server>> poolServers,
  required List<Server> myServers,
  required AppSettings settings,
  required AppDatabase db,
  required Future<Map<String, int>> Function(Iterable<String> ids) ram,
  DateTime? updated,
  DateTime? now,
}) async {
  final at = now ?? DateTime.now();
  final live = {for (final s in myServers) s.id: s};

  final payerOf = <String, String>{};
  for (final e in poolServers.entries) {
    for (final s in e.value) {
      payerOf[s.id] = e.key;
    }
  }

  // Billed servers with the freshest status we have. A running server in
  // no pool is charged to the account. Shared servers are paid by their
  // owner, so they are not counted against this account.
  final billed = <String, Server>{};
  for (final list in poolServers.values) {
    for (final s in list) {
      final fresh = live[s.id] ?? s;
      if (fresh.status.isBilled) billed[s.id] = fresh;
    }
  }
  for (final s in myServers) {
    if (s.status.isBilled && !s.shared) billed[s.id] = s;
  }

  final ramGb = await ram(billed.keys);
  final costs = [for (final s in billed.values) RunningCost(serverId: s.id, ramGb: ramGb[s.id], payer: payerOf[s.id])];

  // Every server is charged storage, running or not: pool servers to their
  // pool, the account's own servers to the account. Shared ones are the
  // owner's.
  final stored = <String?, int>{
    null: myServers.where((s) => !s.shared && !payerOf.containsKey(s.id)).length,
    for (final e in poolServers.entries) e.key: e.value.length,
  };

  Future<PayerSummary> summarise(String? poolId, String name, double credits) async {
    final samples = await db.samples(sampleOwner(accountId, poolId));
    final est = estimate(
      preferred: settings.estimateMethod,
      credits: credits,
      payer: poolId,
      running: costs,
      samples: samples,
      now: at,
      storedServers: stored[poolId] ?? 0,
    );
    final decision = decideAlert(
      estimate: est,
      credits: credits,
      thresholdDays: settings.alertThresholdDays,
      creditFloor: settings.creditFloor,
      alreadyAlerted: false,
    );
    return PayerSummary(poolId: poolId, name: name, credits: credits, estimate: est, low: decision.low);
  }

  final poolNames = {for (final p in pools) p.id: p.name};
  return CreditsOverview(
    account: account,
    accountSummary: await summarise(null, account.name, account.credits),
    pools: pools,
    poolSummaries: {for (final p in pools) p.id: await summarise(p.id, p.name, p.credits)},
    payerOf: payerOf,
    running: [
      for (final s in billed.values)
        RunningRow(
          server: s,
          payerName: payerOf[s.id] == null ? 'your account' : (poolNames[payerOf[s.id]] ?? 'a pool'),
          creditsPerHour: ramGb[s.id] == null ? null : ramGb[s.id]! * creditsPerGbHour,
        ),
    ],
    stored: stored,
    updated: updated ?? at,
  );
}
