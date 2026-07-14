import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/bet.dart';
import '../../shared/models/market.dart';
import '../../shared/providers/bets_provider.dart';
import '../../shared/providers/profile_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/utils/kelly.dart';

enum _KellyVariant {
  full('Full', 1.0),
  half('Half', 0.5),
  quarter('Quarter', 0.25);

  const _KellyVariant(this.label, this.multiplier);
  final String label;
  final double multiplier;
}

/// Kelly position sizer. Embedded in the market detail screen (with [market]
/// prefilled) and used standalone on `/sizer` (manual ticker/title entry for
/// bet logging).
class KellySizer extends ConsumerStatefulWidget {
  const KellySizer({super.key, this.market});

  final Market? market;

  @override
  ConsumerState<KellySizer> createState() => _KellySizerState();
}

class _KellySizerState extends ConsumerState<KellySizer> {
  final _bankrollController = TextEditingController();
  final _priceController = TextEditingController();
  final _tickerController = TextEditingController();
  final _titleController = TextEditingController();

  BetSide _side = BetSide.yes;
  double _probability = 0.5;
  _KellyVariant _variant = _KellyVariant.half;
  bool _bankrollPrefilled = false;
  bool _logging = false;

  bool get _embedded => widget.market != null;

  @override
  void initState() {
    super.initState();
    final market = widget.market;
    if (market != null) {
      _probability = market.score?.fairProbability ?? 0.5;
      _priceController.text = market.yesAsk.toStringAsFixed(2);
    } else {
      _priceController.text = '0.50';
    }
  }

  @override
  void dispose() {
    _bankrollController.dispose();
    _priceController.dispose();
    _tickerController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _onSideChanged(BetSide side) {
    setState(() {
      _side = side;
      final market = widget.market;
      if (market != null) {
        _priceController.text = (side == BetSide.yes
                ? market.yesAsk
                : market.noAsk)
            .toStringAsFixed(2);
      }
    });
  }

  double get _bankroll =>
      double.tryParse(_bankrollController.text.replaceAll(',', '')) ?? 0;

  double get _price => double.tryParse(_priceController.text) ?? 0;

  Future<void> _saveBankroll() async {
    final value = _bankroll;
    try {
      await ref.read(profileProvider.notifier).saveBankroll(value);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bankroll saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not save: $e')));
      }
    }
  }

  Future<void> _logBet(KellySizing sizing) async {
    final market = widget.market;
    final ticker = market?.ticker ?? _tickerController.text.trim();
    final title = market?.title ?? _titleController.text.trim();
    final fraction = sizing.fullFraction * _variant.multiplier;
    final contracts = sizing.contractsFor(fraction);

    setState(() => _logging = true);
    try {
      await ref.read(betActionsProvider.notifier).logBet(
            marketTicker: ticker,
            marketTitle: title,
            side: _side,
            entryPriceDollars: _price,
            contracts: contracts,
            yourProbability: _probability,
            kellyFraction: fraction,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Logged $contracts ${_side.name.toUpperCase()} '
                  '@ ${formatPrice(_price)}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not log bet: $e')));
      }
    } finally {
      if (mounted) setState(() => _logging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(profileProvider);

    // Prefill bankroll once the profile loads (without stomping user edits).
    profile.whenData((value) {
      if (!_bankrollPrefilled) {
        _bankrollPrefilled = true;
        _bankrollController.text = value.bankrollDollars.toStringAsFixed(2);
      }
    });

    final sizing = KellySizing(
      probability: _probability,
      price: _price,
      bankroll: _bankroll,
    );
    final selectedFraction = sizing.fullFraction * _variant.multiplier;
    final selectedContracts = sizing.contractsFor(selectedFraction);
    final canLog = !_logging &&
        _price > 0 &&
        _price < 1 &&
        _bankroll > 0 &&
        selectedContracts > 0 &&
        (_embedded ||
            (_tickerController.text.trim().isNotEmpty &&
                _titleController.text.trim().isNotEmpty));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calculate_outlined, size: 20),
                const SizedBox(width: 8),
                Text('Kelly position sizer',
                    style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            if (!_embedded) ...[
              TextField(
                controller: _tickerController,
                decoration: const InputDecoration(
                  labelText: 'Market ticker',
                  hintText: 'KXHIGHNY-26MAY18-T84',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Market title',
                  hintText: 'Will the high temp in NYC…',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _bankrollController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Bankroll (\$)',
                      helperText: profile.isLoading
                          ? 'Loading from profile…'
                          : 'Synced with your profile',
                      suffixIcon: IconButton(
                        tooltip: 'Save bankroll to profile',
                        icon: const Icon(Icons.save_outlined, size: 20),
                        onPressed: _saveBankroll,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: InputDecoration(
                      labelText: '${_side.name.toUpperCase()} price (\$)',
                      helperText: _embedded
                          ? 'Prefilled from market ask'
                          : 'Contract price, 0–1',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SegmentedButton<BetSide>(
                  segments: const [
                    ButtonSegment(value: BetSide.yes, label: Text('YES')),
                    ButtonSegment(value: BetSide.no, label: Text('NO')),
                  ],
                  selected: {_side},
                  onSelectionChanged: (set) => _onSideChanged(set.first),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your probability ${_side.name.toUpperCase()} wins: '
                        '${formatPercent(_probability)}',
                        style: theme.textTheme.bodySmall,
                      ),
                      Slider(
                        value: _probability,
                        onChanged: (v) => setState(() => _probability = v),
                        min: 0,
                        max: 1,
                        divisions: 100,
                        label: formatPercent(_probability),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (sizing.isAggressive)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.amber.withValues(alpha: 0.6)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: AppColors.amber, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Full Kelly exceeds 15% of bankroll — consider half '
                        'or quarter Kelly to reduce variance.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                for (final variant in _KellyVariant.values) ...[
                  Expanded(
                    child: _KellyOption(
                      variant: variant,
                      sizing: sizing,
                      selected: _variant == variant,
                      onTap: () => setState(() => _variant = variant),
                    ),
                  ),
                  if (variant != _KellyVariant.values.last)
                    const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: canLog ? () => _logBet(sizing) : null,
                icon: _logging
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.playlist_add_check),
                label: Text(
                  selectedContracts > 0
                      ? 'Log this bet — $selectedContracts contracts '
                          '(${formatDollars(sizing.dollarsFor(selectedFraction))})'
                      : 'Log this bet',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KellyOption extends StatelessWidget {
  const _KellyOption({
    required this.variant,
    required this.sizing,
    required this.selected,
    required this.onTap,
  });

  final _KellyVariant variant;
  final KellySizing sizing;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = sizing.fullFraction * variant.multiplier;
    final dollars = sizing.dollarsFor(fraction);
    final contracts = sizing.contractsFor(fraction);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
            width: selected ? 2 : 1,
          ),
          color: selected
              ? AppColors.accent.withValues(alpha: 0.10)
              : Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(variant.label,
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(
              formatPercent(fraction, decimals: 1),
              style: theme.textTheme.titleMedium?.copyWith(
                color: fraction > 0
                    ? AppColors.green
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${formatDollars(dollars)} · $contracts ct',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
