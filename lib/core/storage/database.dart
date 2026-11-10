import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../features/credits/estimate.dart';

/// Local SQLite store (drift) for balance samples, command history, the RAM
/// cache and settings.
///
/// Uses drift's SQL API without code generation, so the app builds without a
/// build_runner step. Secrets never go here; tokens live in secure storage.
class AppDatabase extends GeneratedDatabase {
  AppDatabase(super.executor);

  factory AppDatabase.open() => AppDatabase(driftDatabase(name: 'exaton'));

  @override
  int get schemaVersion => 1;

  @override
  Iterable<TableInfo<Table, dynamic>> get allTables => const [];

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await customStatement(
        'CREATE TABLE IF NOT EXISTS samples ('
        'owner TEXT NOT NULL, t INTEGER NOT NULL, credits REAL NOT NULL)',
      );
      await customStatement('CREATE INDEX IF NOT EXISTS samples_owner_t ON samples(owner, t)');
      await customStatement(
        'CREATE TABLE IF NOT EXISTS history ('
        'server TEXT NOT NULL, cmd TEXT NOT NULL, t INTEGER NOT NULL)',
      );
      await customStatement('CREATE INDEX IF NOT EXISTS history_server_t ON history(server, t)');
      await customStatement('CREATE TABLE IF NOT EXISTS ram_cache (server TEXT PRIMARY KEY, gb INTEGER NOT NULL)');
      await customStatement('CREATE TABLE IF NOT EXISTS kv (k TEXT PRIMARY KEY, v TEXT NOT NULL)');
    },
  );

  // ── Balance samples ───────────────────────────────────────────────────

  /// [owner] is `accountId` for the account balance or `accountId:poolId`.
  Future<void> addSample(String owner, double credits, {DateTime? at}) async {
    final now = at ?? DateTime.now();
    await customInsert(
      'INSERT INTO samples (owner, t, credits) VALUES (?, ?, ?)',
      variables: [Variable.withString(owner), Variable.withInt(now.millisecondsSinceEpoch), Variable.withReal(credits)],
    );
    final cutoff = now.subtract(sampleRetention).millisecondsSinceEpoch;
    await customStatement('DELETE FROM samples WHERE t < ?', [cutoff]);
  }

  Future<List<BalanceSample>> samples(String owner, {Duration window = recentUsageWindow}) async {
    final from = DateTime.now().subtract(window).millisecondsSinceEpoch;
    final rows = await customSelect(
      'SELECT t, credits FROM samples WHERE owner = ? AND t >= ? ORDER BY t',
      variables: [Variable.withString(owner), Variable.withInt(from)],
    ).get();
    return [
      for (final r in rows)
        BalanceSample(DateTime.fromMillisecondsSinceEpoch(r.read<int>('t')), r.read<double>('credits')),
    ];
  }

  /// Deletes every sample of one [owner]. The Recent usage estimate starts
  /// over, because it is worked out from the same samples.
  Future<void> clearSamples(String owner) => customStatement('DELETE FROM samples WHERE owner = ?', [owner]);

  // ── Command history ───────────────────────────────────────────────────

  static const historyLimit = 100;

  Future<void> addCommand(String serverId, String cmd) async {
    await customInsert(
      'INSERT INTO history (server, cmd, t) VALUES (?, ?, ?)',
      variables: [
        Variable.withString(serverId),
        Variable.withString(cmd),
        Variable.withInt(DateTime.now().microsecondsSinceEpoch),
      ],
    );
    await customStatement(
      'DELETE FROM history WHERE server = ? AND rowid NOT IN '
      '(SELECT rowid FROM history WHERE server = ? ORDER BY t DESC LIMIT $historyLimit)',
      [serverId, serverId],
    );
  }

  /// Newest first.
  Future<List<String>> commands(String serverId) async {
    final rows = await customSelect(
      'SELECT cmd FROM history WHERE server = ? ORDER BY t DESC LIMIT $historyLimit',
      variables: [Variable.withString(serverId)],
    ).get();
    return [for (final r in rows) r.read<String>('cmd')];
  }

  // ── RAM cache ─────────────────────────────────────────────────────────

  Future<Map<String, int>> ramCache() async {
    final rows = await customSelect('SELECT server, gb FROM ram_cache').get();
    return {for (final r in rows) r.read<String>('server'): r.read<int>('gb')};
  }

  Future<void> setRam(String serverId, int gb) => customStatement(
    'INSERT INTO ram_cache (server, gb) VALUES (?, ?) ON CONFLICT(server) DO UPDATE SET gb = excluded.gb',
    [serverId, gb],
  );

  // ── Key-value settings ────────────────────────────────────────────────

  Future<Map<String, dynamic>?> readJson(String key) async {
    final row = await customSelect(
      'SELECT v FROM kv WHERE k = ?',
      variables: [Variable.withString(key)],
    ).getSingleOrNull();
    if (row == null) return null;
    try {
      final v = jsonDecode(row.read<String>('v'));
      return v is Map ? v.cast<String, dynamic>() : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> writeJson(String key, Map<String, dynamic> value) => customStatement(
    'INSERT INTO kv (k, v) VALUES (?, ?) ON CONFLICT(k) DO UPDATE SET v = excluded.v',
    [key, jsonEncode(value)],
  );
}
