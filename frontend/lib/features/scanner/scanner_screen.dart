import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_client.dart';
import '../../shared/providers/markets_provider.dart';
import '../../shared/widgets/market_card.dart';
import '../../shared/widgets/status_views.dart';

/// Market scanner: filterable, sortable list of scored markets.
class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

/// Horizon filter options shown in the app bar. `null` means no cap (today's
/// default — every market regardless of how far out it closes).
const _horizonOptions = <int?>[null, 7, 30, 90, 365];

String _horizonLabel(int? days) => days == null ? 'Any' : '≤ ${days}d';

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  String? _category;
  MarketSort _sort = MarketSort.edge;
  int? _maxDaysToClose;

  @override
  Widget build(BuildContext context) {
    final markets = ref.watch(marketsProvider(
      category: _category,
      sort: _sort,
      maxDaysToClose: _maxDaysToClose,
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner'),
        actions: [
          PopupMenuButton<int?>(
            tooltip: 'Closing within',
            icon: const Icon(Icons.hourglass_bottom_outlined),
            initialValue: _maxDaysToClose,
            onSelected: (value) => setState(() => _maxDaysToClose = value),
            itemBuilder: (context) => [
              for (final days in _horizonOptions)
                PopupMenuItem(
                  value: days,
                  child: Text('Closing within: ${_horizonLabel(days)}'),
                ),
            ],
          ),
          PopupMenuButton<MarketSort>(
            tooltip: 'Sort',
            icon: const Icon(Icons.sort),
            initialValue: _sort,
            onSelected: (value) => setState(() => _sort = value),
            itemBuilder: (context) => const [
              PopupMenuItem(
                  value: MarketSort.edge, child: Text('Sort by edge')),
              PopupMenuItem(
                  value: MarketSort.confidence,
                  child: Text('Sort by confidence')),
              PopupMenuItem(
                  value: MarketSort.volume, child: Text('Sort by volume')),
              PopupMenuItem(
                  value: MarketSort.close,
                  child: Text('Sort by time to close')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: scannerCategories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = scannerCategories[index];
                return FilterChip(
                  label: Text(category ?? 'All'),
                  selected: _category == category,
                  onSelected: (_) => setState(() => _category = category),
                );
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(
                marketsProvider(
                  category: _category,
                  sort: _sort,
                  maxDaysToClose: _maxDaysToClose,
                ).future,
              ),
              child: switch (markets) {
                AsyncData(:final value) when value.isEmpty =>
                  _scrollable(const EmptyStateView(
                    icon: Icons.radar_outlined,
                    title: 'No markets found',
                    subtitle:
                        'No liquid markets match this filter right now. '
                        'Try another category or pull to refresh.',
                  )),
                AsyncData(:final value) => ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: value.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final market = value[index];
                      return MarketCard(
                        market: market,
                        onTap: () =>
                            context.push('/market/${market.ticker}'),
                      );
                    },
                  ),
                AsyncError(:final error) => _scrollable(ErrorView(
                    message: '$error',
                    onRetry: () => ref.invalidate(marketsProvider(
                      category: _category,
                      sort: _sort,
                      maxDaysToClose: _maxDaysToClose,
                    )),
                  )),
                _ => const LoadingView(),
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Wraps a non-list state so pull-to-refresh still works.
  Widget _scrollable(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(height: constraints.maxHeight, child: child),
      ),
    );
  }
}
