import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/models/watchlist_item.dart';
import '../../shared/models/ws_message.dart';
import '../../shared/providers/watchlist_provider.dart';
import '../../shared/providers/ws_providers.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/market_card.dart';
import '../../shared/widgets/status_views.dart';

/// Watchlist: watched markets with edge delta since add, per-item alert
/// thresholds, swipe-to-remove, and live prices via WebSocket.
class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlist = ref.watch(watchlistControllerProvider);
    final livePrices = ref.watch(livePricesProvider);
    final arbCount = ref.watch(arbCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
        actions: [
          if (arbCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.green),
                  ),
                  child: Text(
                    '$arbCount arb${arbCount == 1 ? '' : 's'} live',
                    style: const TextStyle(
                        color: AppColors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(watchlistControllerProvider.future),
        child: switch (watchlist) {
          AsyncData(:final value) when value.isEmpty => _scrollable(
              context,
              EmptyStateView(
                icon: Icons.bookmarks_outlined,
                title: 'Nothing on your watchlist',
                subtitle:
                    'Add markets from the scanner to track their edge and '
                    'get live prices here.',
                actionLabel: 'Browse markets',
                onAction: () => context.go('/scanner'),
              )),
          AsyncData(:final value) => ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: value.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) =>
                  _WatchlistTile(item: value[index], livePrices: livePrices),
            ),
          AsyncError(:final error) => _scrollable(
              context,
              ErrorView(
                message: '$error',
                onRetry: () => ref.invalidate(watchlistControllerProvider),
              )),
          _ => const LoadingView(),
        },
      ),
    );
  }

  Widget _scrollable(BuildContext context, Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(height: constraints.maxHeight, child: child),
      ),
    );
  }
}

class _WatchlistTile extends ConsumerWidget {
  const _WatchlistTile({required this.item, required this.livePrices});

  final WatchlistItem item;
  final Map<String, WsPriceUpdate> livePrices;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final market = item.market;
    final live = livePrices[item.marketTicker];

    final child = market == null
        ? Card(
            child: ListTile(
              title: Text(item.marketTicker),
              subtitle: const Text('Market data unavailable'),
              trailing: _AlertButton(item: item),
            ),
          )
        : MarketCard(
            market: market,
            liveYesBid: live?.yesBid,
            liveYesAsk: live?.yesAsk,
            edgeDelta: (market.score != null && item.edgeAtAdd != null)
                ? market.score!.edge - item.edgeAtAdd!
                : null,
            trailing: _AlertButton(item: item),
            onTap: () => context.push('/market/${item.marketTicker}'),
          );

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.red.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.red),
      ),
      onDismissed: (_) async {
        final messenger = ScaffoldMessenger.of(context);
        try {
          await ref
              .read(watchlistControllerProvider.notifier)
              .remove(item.marketTicker);
          messenger.showSnackBar(SnackBar(
              content: Text('${item.marketTicker} removed from watchlist')));
        } catch (e) {
          messenger
              .showSnackBar(SnackBar(content: Text('Failed to remove: $e')));
        }
      },
      child: child,
    );
  }
}

/// Bell icon showing/editing the per-market alert edge threshold.
class _AlertButton extends ConsumerWidget {
  const _AlertButton({required this.item});

  final WatchlistItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasThreshold = item.alertEdgeThreshold != null;
    return Tooltip(
      message: hasThreshold
          ? 'Alert when edge > ${formatPercent(item.alertEdgeThreshold!, decimals: 1)}'
          : 'Set edge alert',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _editThreshold(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasThreshold
                    ? Icons.notifications_active
                    : Icons.notifications_none,
                size: 20,
                color: hasThreshold ? AppColors.amber : null,
              ),
              if (hasThreshold)
                Text(
                  formatPercent(item.alertEdgeThreshold!, decimals: 0),
                  style:
                      const TextStyle(fontSize: 10, color: AppColors.amber),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editThreshold(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(
      text: item.alertEdgeThreshold == null
          ? ''
          : (item.alertEdgeThreshold! * 100).toStringAsFixed(1),
    );

    final result = await showDialog<(bool, double?)>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edge alert threshold'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Alert when the AI edge on ${item.marketTicker} exceeds '
                'this percentage.'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Threshold',
                suffixText: '%',
                hintText: 'e.g. 5',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          if (item.alertEdgeThreshold != null)
            TextButton(
              onPressed: () => Navigator.of(context).pop((true, null)),
              child: const Text('Clear alert'),
            ),
          FilledButton(
            onPressed: () {
              final pct = double.tryParse(controller.text);
              if (pct == null || pct <= 0) return;
              Navigator.of(context).pop((true, pct / 100));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == null || !result.$1 || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(watchlistControllerProvider.notifier)
          .setAlertThreshold(item.marketTicker, result.$2);
      messenger.showSnackBar(SnackBar(
          content: Text(result.$2 == null
              ? 'Alert cleared'
              : 'Alert set at ${formatPercent(result.$2!, decimals: 1)} edge')));
    } catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text('Failed to update alert: $e')));
    }
  }
}
