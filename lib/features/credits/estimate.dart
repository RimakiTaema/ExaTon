// Time-left estimates for the account and credit pools.
//
// The API has no rate or cost fields, so the app works this out itself, in
// one of two ways (spec "Credits and estimates"). Pure Dart, no Flutter.

/// Credits per GB of RAM per hour. One value, so a price change needs no
/// code change. Source: exaroton pricing page, Nov 2026.
const double creditsPerGbHour = 1.0;

/// Window and minimum span for the Recent usage method.
const recentUsageWindow = Duration(hours: 6);
const recentUsageMinSpan = Duration(minutes: 30);

/// How long balance samples are kept.
const sampleRetention = Duration(days: 7);

enum EstimateMethod {
  runningServers('Based on running servers'),
  recentUsage('Based on recent usage');

  const EstimateMethod(this.label);
  final String label;
}

class BalanceSample {
  const BalanceSample(this.time, this.credits);
  final DateTime time;
  final double credits;
}

class Estimate {
  const Estimate({required this.method, required this.creditsPerHour, required this.timeLeft});

  final EstimateMethod method;
  final double creditsPerHour;

  /// Null when nothing is being spent.
  final Duration? timeLeft;

  String get label => method.label;
}

/// A server that is billed right now, with what it costs.
class RunningCost {
  const RunningCost({required this.serverId, required this.ramGb, this.payer});
  final String serverId;

  /// Null when the RAM is not known yet.
  final int? ramGb;

  /// Pool ID, or null when the account pays.
  final String? payer;

  double? get creditsPerHour => ramGb == null ? null : ramGb! * creditsPerGbHour;
}

/// Running servers: credits divided by the hourly cost of running servers.
///
/// Returns null when any running server that this [payer] pays for has an
/// unknown RAM, so the caller can fall back to Recent usage.
Estimate? estimateFromRunning({
  required double credits,
  required String? payer,
  required Iterable<RunningCost> running,
}) {
  var perHour = 0.0;
  for (final r in running.where((r) => r.payer == payer)) {
    final c = r.creditsPerHour;
    if (c == null) return null;
    perHour += c;
  }
  return Estimate(
    method: EstimateMethod.runningServers,
    creditsPerHour: perHour,
    timeLeft: perHour > 0 ? _hours(credits / perHour) : null,
  );
}

/// Recent usage: balance divided by the fall per hour over the last 6 hours.
///
/// Intervals where the balance rose are dropped, because that is a deposit.
/// Returns null until the kept intervals span at least 30 minutes and show a
/// fall above zero.
Estimate? estimateFromSamples({required double credits, required List<BalanceSample> samples, required DateTime now}) {
  final from = now.subtract(recentUsageWindow);
  final inWindow = samples.where((s) => !s.time.isBefore(from) && !s.time.isAfter(now)).toList()
    ..sort((a, b) => a.time.compareTo(b.time));
  if (inWindow.length < 2) return null;

  var fall = 0.0;
  var span = Duration.zero;
  for (var i = 1; i < inWindow.length; i++) {
    final a = inWindow[i - 1], b = inWindow[i];
    final delta = b.credits - a.credits;
    if (delta > 0) continue; // Deposit.
    fall += -delta;
    span += b.time.difference(a.time);
  }
  if (span < recentUsageMinSpan || fall <= 0) return null;

  final perHour = fall / (span.inSeconds / 3600);
  return Estimate(method: EstimateMethod.recentUsage, creditsPerHour: perHour, timeLeft: _hours(credits / perHour));
}

/// Picks the method the user chose, falling back to Recent usage when the
/// Running servers cost cannot be worked out.
Estimate? estimate({
  required EstimateMethod preferred,
  required double credits,
  required String? payer,
  required Iterable<RunningCost> running,
  required List<BalanceSample> samples,
  required DateTime now,
}) {
  Estimate? fromSamples() => estimateFromSamples(credits: credits, samples: samples, now: now);
  if (preferred == EstimateMethod.recentUsage) return fromSamples();
  return estimateFromRunning(credits: credits, payer: payer, running: running) ?? fromSamples();
}

Duration _hours(double h) => Duration(seconds: (h * 3600).round());

/// Rounds to the nearest hour under 2 days and the nearest half day above.
Duration roundTimeLeft(Duration d) {
  if (d < const Duration(days: 2)) {
    return Duration(hours: (d.inMinutes / 60).round());
  }
  final halfDays = (d.inMinutes / (12 * 60)).round();
  return Duration(hours: halfDays * 12);
}

/// "~5 hours", "~3 days", "~2.5 days", "~3 weeks".
String formatTimeLeft(Duration d) {
  final r = roundTimeLeft(d);
  if (r < const Duration(hours: 1)) return 'under 1 hour';
  if (r < const Duration(days: 2)) {
    final h = r.inHours;
    return '~$h ${h == 1 ? 'hour' : 'hours'}';
  }
  final days = r.inHours / 24;
  if (days >= 14) {
    final w = (days / 7).round();
    return '~$w weeks';
  }
  final s = days == days.roundToDouble() ? days.toStringAsFixed(0) : days.toStringAsFixed(1);
  return '~$s days';
}

/// Alert state for one payer. Fires once when time left drops under the
/// threshold or credits under the floor, and again only after it recovers.
class AlertDecision {
  const AlertDecision({required this.low, required this.shouldNotify});
  final bool low;
  final bool shouldNotify;
}

AlertDecision decideAlert({
  required Estimate? estimate,
  required double credits,
  required int thresholdDays,
  required double? creditFloor,
  required bool alreadyAlerted,
}) {
  final t = estimate?.timeLeft;
  final lowTime = t != null && t < Duration(days: thresholdDays);
  final lowCredits = creditFloor != null && credits < creditFloor;
  final low = lowTime || lowCredits;
  return AlertDecision(low: low, shouldNotify: low && !alreadyAlerted);
}
