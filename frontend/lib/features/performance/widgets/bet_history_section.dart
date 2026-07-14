import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/bet.dart';
import '../../../shared/providers/bets_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/status_views.dart';

const _perPage = 25;

/// Paginated, outcome-filterable bet history with actions to resolve pending
/// bets as win/loss.
class BetHistorySection extends ConsumerStatefulWidget {
  const BetHistorySection({super.key});

  @override
  ConsumerState<BetHistorySection> createState() => _BetHistorySectionState();
}

class _BetHistorySectionState extends ConsumerState<BetHistorySection> {
  BetOutcome? _outcome;
  int _page = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final betsAsync = ref
        .watch(betsProvider(outcome: _outcome, page: _page, perPage: _perPage));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bet history', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final (label, outcome) in [
                  ('All', null),
                  ('Pending', BetOutcome.pending),
                  ('Wins', BetOutcome.win),
                  ('Losses', BetOutcome.loss),
                ])
                  FilterChip(
                    label: Text(label),
                    selected: _outcome == outcome,
                    onSelected: (_) => setState(() {
                      _outcome = outcome;
                      _page = 1;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            switch (betsAsync) {
              AsyncData(:final value) when value.bets.isEmpty => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No bets here yet.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
              AsyncData(:final value) => Column(
                  children: [
                    for (final bet in value.bets) _BetRow(bet: bet),
                    const SizedBox(height: 8),
                    _Pager(
                      page: value.page,
                      total: value.total,
                      perPage: value.perPage,
                      onPage: (p) => setState(() => _page = p),
                    ),
                  ],
                ),
              AsyncError(:final error) => ErrorView(
                  message: '$error',
                  onRetry: () => ref.invalidate(betsProvider),
                ),
              _ => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: LoadingView(),
                ),
            },
          ],
        ),
      ),
    );
  }
}

class _BetRow extends ConsumerWidget {
  const _BetRow({required this.bet});

  final Bet bet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sideColor = bet.side == BetSide.yes ? AppColors.green : AppColors.red;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bet.marketTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium),
                Text(
                  '${bet.marketTicker} · '
                  '${formatShortDate(bet.placedAt)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              bet.side.name.toUpperCase(),
              style: theme.textTheme.labelLarge?.copyWith(color: sideColor),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${bet.contracts} @ ${formatPrice(bet.entryPriceDollars)}',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  'est. ${formatPercent(bet.yourProbability)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          SizedBox(width: 120, child: _OutcomeCell(bet: bet)),
        ],
      ),
    );
  }
}

class _OutcomeCell extends ConsumerStatefulWidget {
  const _OutcomeCell({required this.bet});

  final Bet bet;

  @override
  ConsumerState<_OutcomeCell> createState() => _OutcomeCellState();
}

class _OutcomeCellState extends ConsumerState<_OutcomeCell> {
  bool _busy = false;

  Future<void> _resolve(BetOutcome outcome) async {
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(betActionsProvider.notifier).resolveBet(
            widget.bet.id,
            outcome: outcome,
            exitPriceDollars: outcome == BetOutcome.win ? 1.0 : 0.0,
          );
      messenger.showSnackBar(
          SnackBar(content: Text('Marked as ${outcome.name}')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Failed: $e')));
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bet = widget.bet;
    if (bet.outcome == BetOutcome.pending) {
      if (_busy) {
        return const Center(
          child: SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 2)),
        );
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            tooltip: 'Mark win',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.check_circle_outline,
                color: AppColors.green, size: 20),
            onPressed: () => _resolve(BetOutcome.win),
          ),
          IconButton(
            tooltip: 'Mark loss',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.cancel_outlined,
                color: AppColors.red, size: 20),
            onPressed: () => _resolve(BetOutcome.loss),
          ),
        ],
      );
    }

    final win = bet.outcome == BetOutcome.win;
    final color = win ? AppColors.green : AppColors.red;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          win ? 'WIN' : 'LOSS',
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _Pager extends StatelessWidget {
  const _Pager({
    required this.page,
    required this.total,
    required this.perPage,
    required this.onPage,
  });

  final int page;
  final int total;
  final int perPage;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) {
    final pageCount = (total / perPage).ceil().clamp(1, 1 << 31);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Page $page of $pageCount · $total bets',
            style: Theme.of(context).textTheme.labelSmall),
        IconButton(
          tooltip: 'Previous page',
          icon: const Icon(Icons.chevron_left),
          onPressed: page > 1 ? () => onPage(page - 1) : null,
        ),
        IconButton(
          tooltip: 'Next page',
          icon: const Icon(Icons.chevron_right),
          onPressed: page < pageCount ? () => onPage(page + 1) : null,
        ),
      ],
    );
  }
}
