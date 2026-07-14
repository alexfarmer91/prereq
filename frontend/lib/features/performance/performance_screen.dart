import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/models/performance.dart';
import '../../shared/providers/performance_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/status_views.dart';
import 'widgets/bet_history_section.dart';
import 'widgets/calibration_chart.dart';

/// Performance dashboard: calibration chart, P&L summary, streaks, and the
/// paginated bet history.
class PerformanceScreen extends ConsumerWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final performance = ref.watch(performanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance'),
        actions: [
          IconButton(
            tooltip: 'Position sizer',
            icon: const Icon(Icons.calculate_outlined),
            onPressed: () => context.push('/sizer'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(performanceProvider.future),
        child: switch (performance) {
          AsyncData(:final value) when value.pnl.betCount == 0 =>
            LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: EmptyStateView(
                    icon: Icons.insights_outlined,
                    title: 'No bets logged yet',
                    subtitle:
                        'Log your first bet from a market page or the '
                        'position sizer to start tracking calibration '
                        'and P&L.',
                    actionLabel: 'Open position sizer',
                    onAction: () => context.push('/sizer'),
                  ),
                ),
              ),
            ),
          AsyncData(:final value) => _Dashboard(data: value),
          AsyncError(:final error) => LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: ErrorView(
                    message: '$error',
                    onRetry: () => ref.invalidate(performanceProvider),
                  ),
                ),
              ),
            ),
          _ => const LoadingView(),
        },
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.data});

  final PerformanceData data;

  @override
  Widget build(BuildContext context) {
    final pnl = data.pnl;
    final profit = pnl.totalReturned - pnl.totalWagered;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            // P&L summary cards.
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 640 ? 4 : 2;
                final width =
                    (constraints.maxWidth - (columns - 1) * 10) / columns;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _StatCard(
                      width: width,
                      label: 'Total wagered',
                      value: formatDollars(pnl.totalWagered),
                    ),
                    _StatCard(
                      width: width,
                      label: 'Total returned',
                      value: formatDollars(pnl.totalReturned),
                      subtitle:
                          '${profit >= 0 ? '+' : ''}${formatDollars(profit)} P/L',
                      valueColor: AppColors.edgeColor(profit),
                    ),
                    _StatCard(
                      width: width,
                      label: 'ROI',
                      value: formatSignedPercent(pnl.roi),
                      valueColor: AppColors.edgeColor(pnl.roi),
                    ),
                    _StatCard(
                      width: width,
                      label: 'Win rate',
                      value: formatPercent(pnl.winRate, decimals: 1),
                      subtitle: '${pnl.betCount} bets',
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            // Streaks.
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department,
                        color: AppColors.amber),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Current win streak: '
                        '${data.streaks.currentWinStreak}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      'Longest: ${data.streaks.longestWinStreak}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            if (data.calibration.isNotEmpty) ...[
              const SizedBox(height: 12),
              CalibrationChart(buckets: data.calibration),
            ],
            const SizedBox(height: 12),
            const BetHistorySection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.width,
    required this.label,
    required this.value,
    this.subtitle,
    this.valueColor,
  });

  final double width;
  final String label;
  final String value;
  final String? subtitle;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              Text(value,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(color: valueColor)),
              if (subtitle != null)
                Text(subtitle!,
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}
