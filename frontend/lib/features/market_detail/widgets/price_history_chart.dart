import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../shared/models/price_point.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/formatters.dart';

/// Yes-price history line chart. Callers should not render this when the
/// history list is empty.
class PriceHistoryChart extends StatelessWidget {
  const PriceHistoryChart({super.key, required this.history});

  final List<PricePoint> history;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final points = [...history]..sort((a, b) => a.ts.compareTo(b.ts));
    final spots = [
      for (final p in points)
        FlSpot(p.ts.millisecondsSinceEpoch.toDouble(), p.yesPrice),
    ];
    final minX = spots.first.x;
    final maxX = spots.last.x;
    final xSpan = (maxX - minX).abs() < 1 ? 1.0 : maxX - minX;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Yes price history', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 1,
                  minX: minX,
                  maxX: maxX == minX ? minX + 1 : maxX,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 0.25,
                    getDrawingHorizontalLine: (_) => const FlLine(
                      color: AppColors.border,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 0.25,
                        reservedSize: 42,
                        getTitlesWidget: (value, meta) => Text(
                          formatPercent(value),
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: xSpan / 3,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final dt = DateTime.fromMillisecondsSinceEpoch(
                              value.toInt(),
                              isUtc: true);
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              formatShortDate(dt),
                              style: theme.textTheme.labelSmall?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: false,
                      barWidth: 2,
                      color: AppColors.accent,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.accent.withValues(alpha: 0.10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
