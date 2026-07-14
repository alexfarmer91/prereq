import 'package:flutter/material.dart';

import '../../../shared/models/market.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/formatters.dart';

/// AI score card: fair probability, edge, EV, confidence, rationale,
/// signals, and risks. Handles `score == null` with a "Not yet scored" state.
class ScoreCard extends StatelessWidget {
  const ScoreCard({super.key, required this.score});

  final Score? score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = this.score;

    if (score == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.auto_awesome,
                  color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Not yet scored', style: theme.textTheme.titleMedium),
                    Text(
                      'The AI scoring engine has not evaluated this market '
                      'yet. Check back shortly.',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final confidenceColor = switch (score.confidence) {
      ScoreConfidence.high => AppColors.green,
      ScoreConfidence.medium => AppColors.amber,
      ScoreConfidence.low => AppColors.textSecondary,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome,
                    color: AppColors.accent, size: 20),
                const SizedBox(width: 8),
                Text('AI score', style: theme.textTheme.titleMedium),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: confidenceColor),
                  ),
                  child: Text(
                    '${score.confidence.name.toUpperCase()} CONFIDENCE',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: confidenceColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 28,
              runSpacing: 12,
              children: [
                _ScoreStat(
                    'Fair probability',
                    formatPercent(score.fairProbability, decimals: 1),
                    AppColors.textPrimary),
                _ScoreStat('Edge', formatEdge(score.edge),
                    AppColors.edgeColor(score.edge)),
                _ScoreStat('EV / \$1', formatEdge(score.evPerDollar),
                    AppColors.edgeColor(score.evPerDollar)),
              ],
            ),
            const SizedBox(height: 16),
            Text(score.rationale, style: theme.textTheme.bodyMedium),
            if (score.signals.isNotEmpty) ...[
              const SizedBox(height: 14),
              _BulletList(
                title: 'Signals',
                icon: Icons.trending_up,
                color: AppColors.green,
                items: score.signals,
              ),
            ],
            if (score.risks.isNotEmpty) ...[
              const SizedBox(height: 12),
              _BulletList(
                title: 'Risks',
                icon: Icons.warning_amber_rounded,
                color: AppColors.red,
                items: score.risks,
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Scored ${formatDateTimeUtc(score.scoredAt)}',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreStat extends StatelessWidget {
  const _ScoreStat(this.label, this.value, this.color);

  final String label;
  final String value;
  final Color color;

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
            style: theme.textTheme.titleLarge?.copyWith(color: color)),
      ],
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(title,
                style: theme.textTheme.labelLarge?.copyWith(color: color)),
          ],
        ),
        const SizedBox(height: 4),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(left: 22, bottom: 2),
            child: Text('• $item', style: theme.textTheme.bodySmall),
          ),
      ],
    );
  }
}
