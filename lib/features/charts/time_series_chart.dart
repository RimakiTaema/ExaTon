import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../ui/tokens.dart';

/// One reading on a [TimeSeriesChart].
typedef ChartPoint = ({DateTime t, double value});

/// Area chart of one value over time, drawn with fl_chart in theme tokens.
///
/// The y range and the time span are labelled at the edges, and a touch or
/// hover shows the exact reading. Callers show their own empty state:
/// with no points this draws only the frame.
class TimeSeriesChart extends StatelessWidget {
  const TimeSeriesChart({
    super.key,
    required this.points,
    required this.formatValue,
    required this.semanticLabel,
    this.color,
    this.minY,
    this.maxY,
    this.height = 120,
    this.showDate = false,
  });

  /// Oldest first.
  final List<ChartPoint> points;
  final String Function(double value) formatValue;
  final String semanticLabel;

  /// Line colour. Defaults to the theme's primary.
  final Color? color;

  /// Fixed bounds. When null the range follows the data, with some headroom.
  final double? minY;
  final double? maxY;
  final double height;

  /// Labels times with the day as well, for spans over a day.
  final bool showDate;

  /// The y range drawn for [values]: the data's own range padded by a tenth,
  /// widened when flat so the line does not sit on an edge. Fixed bounds win.
  static (double, double) rangeFor(Iterable<double> values, {double? minY, double? maxY}) {
    if (values.isEmpty) return (minY ?? 0, maxY ?? 1);
    var lo = values.reduce((a, b) => a < b ? a : b);
    var hi = values.reduce((a, b) => a > b ? a : b);
    final pad = hi == lo ? (hi.abs() < 1 ? 1.0 : hi.abs() * 0.1) : (hi - lo) * 0.1;
    lo = minY ?? (lo - pad < 0 && lo >= 0 ? 0 : lo - pad);
    hi = maxY ?? hi + pad;
    if (hi <= lo) hi = lo + 1;
    return (lo, hi);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final line = color ?? t.primary;
    final muted = TextStyle(color: t.onSurfaceMuted, fontSize: 12, fontFeatures: const [FontFeature.tabularFigures()]);
    final (lo, hi) = rangeFor(points.map((p) => p.value), minY: minY, maxY: maxY);
    final time = showDate ? DateFormat.MMMd().add_Hm() : DateFormat.Hms();
    final spots = [for (final p in points) FlSpot(p.t.millisecondsSinceEpoch.toDouble(), p.value.clamp(lo, hi))];
    // A lone point has no line to draw, so it gets a dot.
    final single = spots.length == 1;

    return Semantics(
      label: points.isEmpty ? semanticLabel : '$semanticLabel, latest ${formatValue(points.last.value)}',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: height,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(formatValue(hi), style: muted),
                    Text(formatValue(lo), style: muted),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LineChart(
                    duration: Duration.zero,
                    LineChartData(
                      minY: lo,
                      maxY: hi,
                      minX: single ? spots.first.x - 1 : null,
                      maxX: single ? spots.first.x + 1 : null,
                      clipData: const FlClipData.all(),
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        horizontalInterval: (hi - lo) / 2,
                        getDrawingHorizontalLine: (_) => FlLine(color: t.outline, strokeWidth: 1),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          top: BorderSide(color: t.outline),
                          bottom: BorderSide(color: t.outline),
                        ),
                      ),
                      titlesData: const FlTitlesData(show: false),
                      lineTouchData: LineTouchData(
                        enabled: points.isNotEmpty,
                        getTouchedSpotIndicator: (_, indexes) => [
                          for (final _ in indexes)
                            TouchedSpotIndicatorData(
                              FlLine(color: t.outlineStrong, strokeWidth: 1),
                              FlDotData(
                                getDotPainter: (_, _, _, _) =>
                                    FlDotCirclePainter(radius: 4, color: line, strokeWidth: 2, strokeColor: t.surface),
                              ),
                            ),
                        ],
                        touchTooltipData: LineTouchTooltipData(
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          maxContentWidth: 200,
                          getTooltipColor: (_) => t.background,
                          tooltipBorder: BorderSide(color: t.outlineStrong),
                          getTooltipItems: (touched) => [
                            for (final s in touched)
                              LineTooltipItem(
                                '${formatValue(s.y)}\n',
                                TextStyle(color: t.onSurface, fontWeight: FontWeight.w700, fontSize: 14),
                                children: [
                                  TextSpan(
                                    text: time.format(DateTime.fromMillisecondsSinceEpoch(s.x.round())),
                                    style: TextStyle(
                                      color: t.onSurfaceMuted,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          color: line,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          isStrokeJoinRound: true,
                          dotData: FlDotData(
                            show: single,
                            getDotPainter: (_, _, _, _) => FlDotCirclePainter(radius: 3, color: line, strokeWidth: 0),
                          ),
                          belowBarData: BarAreaData(show: true, color: line.withValues(alpha: 0.14)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (points.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(time.format(points.first.t), style: muted),
                if (!single) Text(time.format(points.last.t), style: muted),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
