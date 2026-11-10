import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:exaton/app/app_info.dart';
import 'package:exaton/core/exaroton/models.dart';
import 'package:exaton/core/storage/database.dart';
import 'package:exaton/features/charts/time_series_chart.dart';
import 'package:exaton/features/credits/credits.dart';
import 'package:exaton/features/credits/estimate.dart';
import 'package:exaton/features/debug/probe.dart';
import 'package:exaton/features/servers/logs_tab.dart';
import 'package:exaton/features/servers/recent_servers.dart';
import 'package:exaton/features/servers/stats_history.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final t0 = DateTime(2026, 11, 10, 12);

  group('stats history', () {
    test('each stream maps to its own reading', () {
      expect(StatsPoint.memory(t0, 512 * 1024 * 1024).memoryMb, 512);
      expect(StatsPoint.heap(t0, 1234).heapBytes, 1234);
      expect(StatsPoint.tick(t0, 48.5).tickMs, 48.5);
      expect(StatsPoint.tps(t0, 19.8).tps, 19.8);
      expect(StatsPoint.tick(t0, 48.5).memoryMb, isNull);
    });

    test('readings within the merge window become one point', () {
      var h = appendStatsPoint(const [], StatsPoint.memory(t0, 100 * 1024 * 1024));
      h = appendStatsPoint(h, StatsPoint.tick(t0.add(const Duration(milliseconds: 300)), 20));
      expect(h, hasLength(1));
      expect((h.single.memoryMb, h.single.tickMs, h.single.t), (100, 20, t0));
    });

    test('a later point carries the readings it lacks', () {
      var h = appendStatsPoint(const [], StatsPoint.memory(t0, 100 * 1024 * 1024));
      h = appendStatsPoint(h, StatsPoint.tick(t0.add(const Duration(seconds: 2)), 20));
      expect(h, hasLength(2));
      expect(h.first.tickMs, isNull, reason: 'history is not rewritten');
      expect((h.last.memoryMb, h.last.tickMs), (100, 20));
    });

    test('caps at the point limit, keeping the newest', () {
      var h = const <StatsPoint>[];
      for (var i = 0; i < statsMaxPoints + 50; i++) {
        h = appendStatsPoint(h, StatsPoint.tick(t0.add(Duration(seconds: 2 * i)), i.toDouble()));
      }
      expect(h, hasLength(statsMaxPoints));
      expect(h.first.tickMs, 50);
      expect(h.last.tickMs, statsMaxPoints + 49);
    });

    test('trims points older than the age limit', () {
      var h = const <StatsPoint>[];
      for (var i = 0; i < 5; i++) {
        h = appendStatsPoint(h, StatsPoint.tick(t0.add(Duration(minutes: 20 * i)), i.toDouble()));
      }
      // Points at 0, 20, 40, 60, 80 min; the last is at 80, so 0 is too old.
      expect(h.map((p) => p.tickMs), [1, 2, 3, 4]);
    });

    test('a point after a long gap keeps itself', () {
      var h = appendStatsPoint(const [], StatsPoint.tick(t0, 1));
      h = appendStatsPoint(h, StatsPoint.tick(t0.add(const Duration(hours: 5)), 2));
      expect(h.map((p) => p.tickMs), [2]);
    });
  });

  group('chart range', () {
    test('pads the data range and never goes below zero for positive data', () {
      final (lo, hi) = TimeSeriesChart.rangeFor([10, 20]);
      expect(lo, 9);
      expect(hi, 21);
      expect(TimeSeriesChart.rangeFor([0.5, 10]).$1, 0);
    });

    test('a flat or empty series still has height', () {
      final (lo, hi) = TimeSeriesChart.rangeFor([100, 100]);
      expect(hi, greaterThan(lo));
      expect(TimeSeriesChart.rangeFor(const []), (0, 1));
    });

    test('fixed bounds win', () {
      expect(TimeSeriesChart.rangeFor([5, 6], minY: 0, maxY: 20), (0, 20));
    });
  });

  group('recent servers', () {
    RecentServer r(String id, String account, int minute) => RecentServer(
      id: id,
      name: 'Server $id',
      address: '$id.exaroton.me',
      accountId: account,
      visitedAt: t0.add(Duration(minutes: minute)),
    );

    test('a new visit moves the server to the front without duplicating it', () {
      var all = [r('a', 'acc1', 0), r('b', 'acc1', 1)];
      all = upsertRecent(all, r('a', 'acc1', 5));
      expect(all.map((x) => x.id), ['a', 'b']);
      expect(all.first.visitedAt, t0.add(const Duration(minutes: 5)));
    });

    test('keeps the newest 12 per account', () {
      var all = <RecentServer>[];
      for (var i = 0; i < 15; i++) {
        all = upsertRecent(all, r('s$i', 'acc1', i));
      }
      expect(all, hasLength(maxRecentServers));
      expect(all.first.id, 's14');
      expect(all.last.id, 's3');
    });

    test('accounts do not see or evict each other', () {
      var all = <RecentServer>[r('x', 'acc2', 0)];
      for (var i = 0; i < 15; i++) {
        all = upsertRecent(all, r('s$i', 'acc1', i + 1));
      }
      expect(recentFor(all, 'acc2').map((x) => x.id), ['x']);
      expect(recentFor(all, 'acc1'), hasLength(maxRecentServers));
      // The same server opened by two accounts is two entries.
      all = upsertRecent(all, r('x', 'acc1', 60));
      expect(recentFor(all, 'acc2'), hasLength(1));
      expect(recentFor(all, 'acc1').first.id, 'x');
    });

    test('remove forgets one account\'s visit only', () {
      final all = [r('a', 'acc1', 0), r('a', 'acc2', 1)];
      expect(removeRecent(all, 'acc1', 'a').single.accountId, 'acc2');
    });

    test('survives a round trip through the kv table and skips bad entries', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await db.writeJson(recentServersKey, encodeRecent([r('a', 'acc1', 0), r('b', 'acc1', 1)]));
      final back = decodeRecent(await db.readJson(recentServersKey));
      expect(back.map((x) => (x.id, x.name, x.address, x.accountId)), [
        ('a', 'Server a', 'a.exaroton.me', 'acc1'),
        ('b', 'Server b', 'b.exaroton.me', 'acc1'),
      ]);
      expect(back.first.visitedAt, t0);
      expect(
        decodeRecent({
          'items': [
            {'id': 'a'},
            'junk',
            r('c', 'acc1', 2).toJson(),
          ],
        }).single.id,
        'c',
      );
      expect(decodeRecent(null), isEmpty);
    });
  });

  group('credit graph', () {
    final samples = [
      BalanceSample(t0.subtract(const Duration(hours: 30)), 100),
      BalanceSample(t0.subtract(const Duration(hours: 2)), 80),
      BalanceSample(t0.subtract(const Duration(hours: 10)), 90),
      BalanceSample(t0, 79),
    ];

    test('window filter keeps the range and orders oldest first', () {
      expect(samplesInWindow(samples, BalanceRange.sixHours.window, now: t0).map((s) => s.credits), [80, 79]);
      expect(samplesInWindow(samples, BalanceRange.day.window, now: t0).map((s) => s.credits), [90, 80, 79]);
      expect(samplesInWindow(samples, BalanceRange.week.window, now: t0).map((s) => s.credits), [100, 90, 80, 79]);
    });

    test('the longest range is the sample retention', () {
      expect(BalanceRange.week.window, sampleRetention);
    });

    test('samples come back in time order and clear removes one owner only', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final now = DateTime.now();
      await db.addSample('acc1', 50, at: now.subtract(const Duration(minutes: 10)));
      await db.addSample('acc1', 60, at: now.subtract(const Duration(minutes: 40)));
      await db.addSample('acc1:pool1', 300, at: now.subtract(const Duration(minutes: 5)));
      expect((await db.samples('acc1', window: sampleRetention)).map((s) => s.credits), [60, 50]);

      await db.clearSamples('acc1');
      expect(await db.samples('acc1', window: sampleRetention), isEmpty);
      expect((await db.samples('acc1:pool1', window: sampleRetention)).single.credits, 300);
    });
  });

  group('logs', () {
    test('a short log is shown whole, without trailing blank lines', () {
      final r = tailLines('one\r\ntwo\nthree\n\n');
      expect(r.lines, ['one', 'two', 'three']);
      expect(r.hidden, 0);
    });

    test('a long log shows its end and counts what is hidden', () {
      final r = tailLines(List.generate(2500, (i) => 'line $i').join('\n'));
      expect(r.lines, hasLength(logMaxLines));
      expect(r.hidden, 500);
      expect(r.lines.first, 'line 500');
      expect(r.lines.last, 'line 2499');
    });

    test('an empty log has no lines', () {
      expect(tailLines('').lines, isEmpty);
      expect(tailLines('\n\n').lines, isEmpty);
    });

    test('the shared log link is taken from the response', () {
      final log = SharedLog.fromJson({
        'id': 'abc123',
        'url': 'https://mclo.gs/abc123',
        'raw': 'https://api.mclo.gs/1/raw/abc123',
      });
      expect(sharedLogUri(log).toString(), 'https://mclo.gs/abc123');
    });

    test('a missing or unsafe link is not opened', () {
      expect(sharedLogUri(SharedLog.fromJson(const {})), isNull);
      expect(sharedLogUri(const SharedLog(id: '', url: 'javascript:alert(1)', raw: '')), isNull);
      expect(sharedLogUri(const SharedLog(id: '', url: 'mclo.gs/abc', raw: '')), isNull);
    });
  });

  group('debug probe', () {
    Response<dynamic> res(int status, Object? body) => Response<dynamic>(
      requestOptions: RequestOptions(path: '/'),
      statusCode: status,
      data: body,
    );

    test('a 2xx envelope passes the authenticated probe', () async {
      final r = await runProbe(() async => res(200, '{"success":true,"error":null,"data":{}}'), passes: envelopeOk);
      expect(r.outcome, ProbeOutcome.passed);
      expect(r.statusCode, 200);
      expect(r.summary, startsWith('Passed - HTTP 200'));
    });

    test('an API error fails with its text', () async {
      final r = await runProbe(
        () async => res(401, '{"success":false,"error":"Invalid API token","data":null}'),
        passes: envelopeOk,
      );
      expect(r.outcome, ProbeOutcome.failed);
      expect(r.detail, 'Invalid API token');
      expect(r.summary, contains('HTTP 401'));
    });

    test('the anonymous probe passes on any answer below 500', () async {
      expect((await runProbe(() async => res(401, '{"success":false}'), passes: reachedApi)).passed, isTrue);
      expect((await runProbe(() async => res(404, '<html>'), passes: reachedApi)).passed, isTrue);
      expect((await runProbe(() async => res(503, ''), passes: reachedApi)).passed, isFalse);
    });

    test('a slow call is a timeout', () async {
      final r = await runProbe(
        () => Future.delayed(const Duration(milliseconds: 200), () => res(200, '')),
        passes: reachedApi,
        timeout: const Duration(milliseconds: 20),
      );
      expect(r.outcome, ProbeOutcome.timeout);
      expect(r.statusCode, isNull);
    });

    test('transport errors map to failed or timeout, never throw', () async {
      DioException ex(DioExceptionType type) => DioException(
        requestOptions: RequestOptions(path: '/'),
        type: type,
        message: 'boom',
      );
      final down = await runProbe(() async => throw ex(DioExceptionType.connectionError), passes: reachedApi);
      expect((down.outcome, down.detail), (ProbeOutcome.failed, 'boom'));
      expect(down.summary, 'Failed - boom');
      final slow = await runProbe(() async => throw ex(DioExceptionType.connectionTimeout), passes: reachedApi);
      expect(slow.outcome, ProbeOutcome.timeout);
      final odd = await runProbe(() async => throw StateError('x'), passes: reachedApi);
      expect(odd.outcome, ProbeOutcome.failed);
    });
  });

  test('app_info matches the version in pubspec.yaml', () {
    final line = File('pubspec.yaml').readAsLinesSync().firstWhere((l) => l.startsWith('version:'));
    expect(line.split(':').last.trim(), '$appVersionName+$appVersionCode');
  });
}
