import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../shared/models/performance.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/formatters.dart';

/// Calibration chart: predicted-probability bucket midpoints vs actual win
/// rate, with the perfect-calibration diagonal as a dashed reference line.
class CalibrationChart extends StatelessWidget {
  const CalibrationChart({super.key, required this.buckets});

  final List<CalibrationBucket> buckets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sorted = [...buckets]
      ..sort((a, b) => a.bucketMin.compareTo(b.bucketMin));
    final spots = [
      for (final b in sorted)
        FlSpot((b.bucketMin + b.bucketMax) / 2, b.actualWinRate),
    ];

    Widget axisLabel(double value, TitleMeta meta) => Text(
          formatPercent(value),
          style: theme.textTheme.labelSmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calibration', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Predicted probability vs. actual win rate — points on the '
              'dashed line are perfectly calibrated.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 260,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 1,
                  minY: 0,
                  maxY: 1,
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 0.25,
                    verticalInterval: 0.25,
                    getDrawingHorizontalLine: (_) => const FlLine(
                        color: AppColors.border, strokeWidth: 1),
                    getDrawingVerticalLine: (_) => const FlLine(
                        color: AppColors.border, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      axisNameWidget: Text('Actual win rate',
                          style: theme.textTheme.labelSmall),
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 0.25,
                        reservedSize: 42,
                        getTitlesWidget: axisLabel,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      axisNameWidget: Text('Predicted probability',
                          style: theme.textTheme.labelSmall),
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 0.25,
                        reservedSize: 26,
                        getTitlesWidget: (value, meta) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: axisLabel(value, meta),
                        ),
                      ),
                    ),
                  ),
                  lineBarsData: [
                    // Perfect-calibration diagonal.
                    LineChartBarData(
                      spots: const [FlSpot(0, 0), FlSpot(1, 1)],
                      color: AppColors.textSecondary,
                      barWidth: 1,
                      dashArray: [6, 4],
                      dotData: const FlDotData(show: false),
                    ),
                    // Actual calibration.
                    LineChartBarData(
                      spots: spots,
                      color: AppColors.accent,
                      barWidth: 2,
                      isCurved: false,
                      dotData: const FlDotData(show: true),
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
