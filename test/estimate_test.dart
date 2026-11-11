import 'package:exaton/features/credits/estimate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 10, 12);
  DateTime ago(int minutes) => now.subtract(Duration(minutes: minutes));

  group('Running servers', () {
    test('a 4 GB server costs 4 credits per hour', () {
      final e = estimateFromRunning(
        credits: 312,
        payer: 'pool',
        running: const [RunningCost(serverId: 'a', ramGb: 4, payer: 'pool')],
      )!;
      expect(e.creditsPerHour, 4);
      expect(e.timeLeft, const Duration(hours: 78));
      expect(e.label, 'Based on running servers');
    });

    test('only servers paid by this payer count', () {
      final e = estimateFromRunning(
        credits: 100,
        payer: null,
        running: const [
          RunningCost(serverId: 'a', ramGb: 4, payer: 'pool'),
          RunningCost(serverId: 'b', ramGb: 2),
        ],
      )!;
      expect(e.creditsPerHour, 2);
      expect(e.timeLeft, const Duration(hours: 50));
    });

    test('nothing running: no time left, but still an estimate', () {
      final e = estimateFromRunning(credits: 100, payer: null, running: const [])!;
      expect(e.creditsPerHour, 0);
      expect(e.timeLeft, isNull);
    });

    test('storage is 10 credits per server per month, running or not', () {
      final e = estimateFromRunning(credits: 10, payer: null, running: const [], storedServers: 1)!;
      expect(e.creditsPerHour, closeTo(10 / 720, 1e-12));
      expect(e.timeLeft, const Duration(days: 30));
    });

    test('storage adds to the running cost', () {
      final e = estimateFromRunning(
        credits: 312,
        payer: 'pool',
        running: const [RunningCost(serverId: 'a', ramGb: 4, payer: 'pool')],
        storedServers: 3,
      )!;
      expect(e.creditsPerHour, closeTo(4 + 30 / 720, 1e-12));
    });

    test('unknown RAM returns null so the caller falls back', () {
      expect(
        estimateFromRunning(credits: 100, payer: null, running: const [RunningCost(serverId: 'a', ramGb: null)]),
        isNull,
      );
    });
  });

  group('Recent usage', () {
    test('fall per hour over the window', () {
      final e = estimateFromSamples(
        credits: 90,
        now: now,
        samples: [BalanceSample(ago(120), 100), BalanceSample(ago(60), 95), BalanceSample(ago(0), 90)],
      )!;
      expect(e.creditsPerHour, closeTo(5, 1e-9));
      expect(e.timeLeft, const Duration(hours: 18));
      expect(e.label, 'Based on recent usage');
    });

    test('intervals where the balance rose are dropped as deposits', () {
      final e = estimateFromSamples(
        credits: 195,
        now: now,
        samples: [
          BalanceSample(ago(120), 100),
          BalanceSample(ago(90), 98), // -2 over 30 min
          BalanceSample(ago(60), 198), // deposit, dropped
          BalanceSample(ago(30), 196), // -2 over 30 min
          BalanceSample(ago(0), 195), // -1 over 30 min
        ],
      )!;
      // 5 credits over 90 kept minutes.
      expect(e.creditsPerHour, closeTo(5 / 1.5, 1e-9));
    });

    test('needs at least 30 minutes of samples', () {
      expect(
        estimateFromSamples(credits: 90, now: now, samples: [BalanceSample(ago(29), 100), BalanceSample(ago(0), 90)]),
        isNull,
      );
      expect(
        estimateFromSamples(credits: 90, now: now, samples: [BalanceSample(ago(30), 100), BalanceSample(ago(0), 90)]),
        isNotNull,
      );
    });

    test('no fall means no estimate', () {
      expect(
        estimateFromSamples(credits: 100, now: now, samples: [BalanceSample(ago(60), 100), BalanceSample(ago(0), 100)]),
        isNull,
      );
    });

    test('samples older than 6 hours are ignored', () {
      final e = estimateFromSamples(
        credits: 90,
        now: now,
        samples: [
          BalanceSample(ago(60 * 7), 500), // outside window
          BalanceSample(ago(60), 95),
          BalanceSample(ago(0), 90),
        ],
      )!;
      expect(e.creditsPerHour, closeTo(5, 1e-9));
    });

    test('unsorted samples are sorted first', () {
      final e = estimateFromSamples(
        credits: 90,
        now: now,
        samples: [BalanceSample(ago(0), 90), BalanceSample(ago(60), 95)],
      )!;
      expect(e.creditsPerHour, closeTo(5, 1e-9));
    });
  });

  group('estimate()', () {
    final samples = [BalanceSample(ago(60), 100), BalanceSample(ago(0), 97)];

    test('default Running servers, falling back to Recent usage', () {
      final fallback = estimate(
        preferred: EstimateMethod.runningServers,
        credits: 97,
        payer: null,
        running: const [RunningCost(serverId: 'a', ramGb: null)],
        samples: samples,
        now: now,
      )!;
      expect(fallback.method, EstimateMethod.recentUsage);

      final direct = estimate(
        preferred: EstimateMethod.runningServers,
        credits: 97,
        payer: null,
        running: const [RunningCost(serverId: 'a', ramGb: 2)],
        samples: samples,
        now: now,
      )!;
      expect(direct.method, EstimateMethod.runningServers);
    });

    test('Recent usage when chosen', () {
      final e = estimate(
        preferred: EstimateMethod.recentUsage,
        credits: 97,
        payer: null,
        running: const [RunningCost(serverId: 'a', ramGb: 2)],
        samples: samples,
        now: now,
      )!;
      expect(e.method, EstimateMethod.recentUsage);
      expect(e.creditsPerHour, closeTo(3, 1e-9));
    });
  });

  group('rounding', () {
    test('nearest hour under 2 days', () {
      expect(roundTimeLeft(const Duration(hours: 5, minutes: 29)), const Duration(hours: 5));
      expect(roundTimeLeft(const Duration(hours: 5, minutes: 30)), const Duration(hours: 6));
      expect(roundTimeLeft(const Duration(hours: 47, minutes: 10)), const Duration(hours: 47));
    });

    test('nearest half day from 2 days', () {
      expect(roundTimeLeft(const Duration(hours: 78)), const Duration(hours: 84)); // 3.25 d -> 3.5 d
      expect(roundTimeLeft(const Duration(hours: 77)), const Duration(hours: 72)); // 3.2 d -> 3 d
      expect(roundTimeLeft(const Duration(days: 2)), const Duration(days: 2));
    });

    test('formatting', () {
      expect(formatTimeLeft(const Duration(minutes: 20)), 'under 1 hour');
      expect(formatTimeLeft(const Duration(hours: 1)), '~1 hour');
      expect(formatTimeLeft(const Duration(hours: 18)), '~18 hours');
      expect(formatTimeLeft(const Duration(hours: 72)), '~3 days');
      expect(formatTimeLeft(const Duration(hours: 84)), '~3.5 days');
      expect(formatTimeLeft(const Duration(days: 21)), '~3 weeks');
    });
  });

  group('alerts', () {
    Estimate days(int d) => Estimate(
      method: EstimateMethod.runningServers,
      creditsPerHour: 1,
      timeLeft: Duration(days: d),
    );

    test('fires once under the threshold, then again only after recovery', () {
      var alerted = false;
      AlertDecision step(int d) {
        final r = decideAlert(
          estimate: days(d),
          credits: 100,
          thresholdDays: 5,
          creditFloor: null,
          alreadyAlerted: alerted,
        );
        if (r.shouldNotify) alerted = true;
        if (!r.low) alerted = false;
        return r;
      }

      expect(step(6).shouldNotify, isFalse);
      expect(step(4).shouldNotify, isTrue);
      expect(step(3).shouldNotify, isFalse, reason: 'already alerted');
      expect(step(7).shouldNotify, isFalse);
      expect(step(2).shouldNotify, isTrue, reason: 'recovered, so it can fire again');
    });

    test('credit floor triggers even with no estimate', () {
      final r = decideAlert(estimate: null, credits: 40, thresholdDays: 5, creditFloor: 50, alreadyAlerted: false);
      expect(r.low, isTrue);
      expect(r.shouldNotify, isTrue);
    });
  });
}
