import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../console/live_session.dart';

/// History is capped at this many points or [statsMaxAge], whichever comes
/// first.
const statsMaxPoints = 300;
const statsMaxAge = Duration(hours: 1);

/// Readings that arrive this close together become one point, because the
/// stats, heap and tick streams each report on their own.
const statsMergeWindow = Duration(seconds: 1);

/// One sample of the live stats. A null reading has not been reported yet,
/// or its stream is unavailable for this server.
@immutable
class StatsPoint {
  const StatsPoint({required this.t, this.memoryMb, this.heapBytes, this.tickMs, this.tps});

  final DateTime t;
  final double? memoryMb;
  final int? heapBytes;
  final double? tickMs;
  final double? tps;

  /// A point from the `stats` stream's memory usage in bytes.
  factory StatsPoint.memory(DateTime t, int usageBytes) => StatsPoint(t: t, memoryMb: usageBytes / (1024 * 1024));

  /// A point from the `heap` stream.
  factory StatsPoint.heap(DateTime t, int bytes) => StatsPoint(t: t, heapBytes: bytes);

  /// A point from the `tick` stream's average tick time.
  factory StatsPoint.tick(DateTime t, double ms) => StatsPoint(t: t, tickMs: ms);

  /// A point from a `tps` field, when the payload has one.
  factory StatsPoint.tps(DateTime t, double tps) => StatsPoint(t: t, tps: tps);

  /// This point with [newer]'s readings laid over it. [t] is kept when
  /// [keepTime] is set, for readings merged into one point.
  StatsPoint _over(StatsPoint newer, {required bool keepTime}) => StatsPoint(
    t: keepTime ? t : newer.t,
    memoryMb: newer.memoryMb ?? memoryMb,
    heapBytes: newer.heapBytes ?? heapBytes,
    tickMs: newer.tickMs ?? tickMs,
    tps: newer.tps ?? tps,
  );
}

/// Adds [point] to [history] and returns the new list, oldest first.
///
/// A point within [mergeWindow] of the last one is merged into it. Otherwise
/// it is appended with the last known value of each reading it lacks, so
/// every chart line stays continuous. The result is then trimmed to
/// [maxPoints] and to points no older than [maxAge] before [point].
List<StatsPoint> appendStatsPoint(
  List<StatsPoint> history,
  StatsPoint point, {
  int maxPoints = statsMaxPoints,
  Duration maxAge = statsMaxAge,
  Duration mergeWindow = statsMergeWindow,
}) {
  final List<StatsPoint> next;
  final last = history.lastOrNull;
  if (last != null && point.t.difference(last.t).abs() < mergeWindow) {
    next = [...history.take(history.length - 1), last._over(point, keepTime: true)];
  } else {
    next = [...history, if (last == null) point else last._over(point, keepTime: false)];
  }
  final cutoff = point.t.subtract(maxAge);
  var start = next.length > maxPoints ? next.length - maxPoints : 0;
  while (start < next.length - 1 && next[start].t.isBefore(cutoff)) {
    start++;
  }
  return start == 0 ? next : next.sublist(start);
}

/// Live stats history of one server, kept while its detail is open. It
/// listens to the socket of [liveSessionProvider] and opens none of its own.
final statsHistoryProvider = NotifierProvider.autoDispose.family<StatsHistory, List<StatsPoint>, String>(
  StatsHistory.new,
);

class StatsHistory extends Notifier<List<StatsPoint>> {
  StatsHistory(this.serverId);
  final String serverId;

  @override
  List<StatsPoint> build() {
    final session = ref.watch(liveSessionProvider(serverId));
    if (session == null) return const [];
    final socket = session.socket;
    final subs = <StreamSubscription<dynamic>>[
      socket.memory.listen((m) => add(StatsPoint.memory(DateTime.now(), m.usage))),
      socket.heap.listen((h) => add(StatsPoint.heap(DateTime.now(), h))),
      socket.tick.listen((ms) => add(StatsPoint.tick(DateTime.now(), ms))),
      socket.tps.listen((v) => add(StatsPoint.tps(DateTime.now(), v))),
    ];
    ref.onDispose(() {
      for (final s in subs) {
        s.cancel();
      }
    });
    return const [];
  }

  void add(StatsPoint point) => state = appendStatsPoint(state, point);
}
