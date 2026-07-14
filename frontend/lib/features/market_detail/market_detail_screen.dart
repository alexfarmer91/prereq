import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/models/market.dart';
import '../../shared/providers/markets_provider.dart';
import '../../shared/providers/watchlist_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/category_badge.dart';
import '../../shared/widgets/status_views.dart';
import '../position_sizer/kelly_sizer.dart';
import 'widgets/price_history_chart.dart';
import 'widgets/score_card.dart';

/// Full market view: info, rules, price history, AI score, strike variants,
/// embedded Kelly sizer, watchlist toggle.
class MarketDetailScreen extends ConsumerWidget {
  const MarketDetailScreen({super.key, required this.ticker});

  final String ticker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(marketDetailProvider(ticker));

    return Scaffold(
      appBar: AppBar(
        title: Text(ticker),
        actions: [_WatchlistButton(ticker: ticker)],
      ),
      body: switch (detail) {
        AsyncData(:final value) => _DetailBody(
            market: value.market,
            eventMarkets: value.eventMarkets,
          ),
        AsyncError(:final error) => ErrorView(
            message: '$error',
            onRetry: () => ref.invalidate(marketDetailProvider(ticker)),
          ),
        _ => const LoadingView(),
      },
    );
  }
}

class _WatchlistButton extends ConsumerWidget {
  const _WatchlistButton({required this.ticker});

  final String ticker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watched = ref.watch(isWatchedProvider(ticker));
    if (watched == null) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
            width: 18, height: 18,
            child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return IconButton(
      tooltip: watched ? 'Remove from watchlist' : 'Add to watchlist',
      icon: Icon(
        watched ? Icons.bookmark_added : Icons.bookmark_add_outlined,
        color: watched ? AppColors.accent : null,
      ),
      onPressed: () async {
        final controller = ref.read(watchlistControllerProvider.notifier);
        final messenger = ScaffoldMessenger.of(context);
        try {
          if (watched) {
            await controller.remove(ticker);
            messenger.showSnackBar(
                const SnackBar(content: Text('Removed from watchlist')));
          } else {
            await controller.add(ticker);
            messenger.showSnackBar(
                const SnackBar(content: Text('Added to watchlist')));
          }
        } catch (e) {
          messenger.showSnackBar(SnackBar(content: Text('Failed: $e')));
        }
      },
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.market, required this.eventMarkets});

  final Market market;
  final List<Market> eventMarkets;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(marketHistoryProvider(market.ticker));
    final variants =
        eventMarkets.where((m) => m.ticker != market.ticker).toList();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _HeaderCard(market: market),
            const SizedBox(height: 12),
            ScoreCard(score: market.score),
            // Price history: hidden gracefully when empty or unavailable.
            ...switch (history) {
              AsyncData(:final value) when value.isNotEmpty => [
                  const SizedBox(height: 12),
                  PriceHistoryChart(history: value),
                ],
              AsyncLoading() => [
                  const SizedBox(height: 12),
                  const Card(
                    child: SizedBox(
                      height: 120,
                      child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                  ),
                ],
              _ => const <Widget>[],
            },
            if (market.rulesPrimary?.isNotEmpty ?? false) ...[
              const SizedBox(height: 12),
              Card(
                child: ExpansionTile(
                  shape: const Border(),
                  title: const Text('Resolution rules'),
                  leading: const Icon(Icons.gavel_outlined, size: 20),
                  childrenPadding:
                      const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(market.rulesPrimary!),
                    ),
                  ],
                ),
              ),
            ],
            if (variants.isNotEmpty) ...[
              const SizedBox(height: 12),
              _VariantsCard(variants: variants),
            ],
            const SizedBox(height: 12),
            KellySizer(market: market),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.market});

  final Market market;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(market.title,
                      style: theme.textTheme.titleLarge),
                ),
                const SizedBox(width: 8),
                CategoryBadge(category: market.category),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Closes ${formatDateTimeUtc(market.closeTime)} · '
              '${formatTimeToClose(market.timeToClose)} left',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _Stat('YES bid / ask',
                    '${formatPrice(market.yesBid)} / ${formatPrice(market.yesAsk)}',
                    color: AppColors.green),
                _Stat('NO bid / ask',
                    '${formatPrice(market.noBid)} / ${formatPrice(market.noAsk)}',
                    color: AppColors.red),
                _Stat('Mid', formatPrice(market.midPrice)),
                _Stat('Spread', formatPrice(market.spread)),
                _Stat('Volume 24h', formatVolume(market.volume24h)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, {this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(value,
            style: theme.textTheme.titleSmall?.copyWith(color: color)),
      ],
    );
  }
}

class _VariantsCard extends StatelessWidget {
  const _VariantsCard({required this.variants});

  final List<Market> variants;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text('Other strikes in this event',
                  style: theme.textTheme.titleMedium),
            ),
            for (final variant in variants)
              ListTile(
                dense: true,
                title: Text(variant.title,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(variant.ticker),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(formatPrice(variant.midPrice),
                        style: theme.textTheme.titleSmall),
                    const SizedBox(width: 12),
                    Text(
                      variant.score == null
                          ? '—'
                          : formatEdge(variant.score!.edge),
                      style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.edgeColor(variant.score?.edge)),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, size: 18),
                  ],
                ),
                onTap: () => context.push('/market/${variant.ticker}'),
              ),
          ],
        ),
      ),
    );
  }
}
