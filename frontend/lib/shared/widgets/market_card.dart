import 'package:flutter/material.dart';

import '../models/market.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'category_badge.dart';

/// Card used in the scanner and watchlist lists.
///
/// Shows title, category badge, yes price, color-coded edge, 24h volume and
/// time to close. [liveYesBid]/[liveYesAsk] override the market's prices when
/// live WebSocket updates arrive. [edgeDelta] (watchlist) shows the change in
/// edge since the market was added. [trailing] allows extra actions.
class MarketCard extends StatelessWidget {
  const MarketCard({
    super.key,
    required this.market,
    this.onTap,
    this.liveYesBid,
    this.liveYesAsk,
    this.edgeDelta,
    this.trailing,
  });

  final Market market;
  final VoidCallback? onTap;
  final double? liveYesBid;
  final double? liveYesAsk;
  final double? edgeDelta;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final edge = market.score?.edge;
    final edgeColor = AppColors.edgeColor(edge);
    final yesBid = liveYesBid ?? market.yesBid;
    final yesAsk = liveYesAsk ?? market.yesAsk;
    final yesPrice = (yesBid + yesAsk) / 2;
    final isLive = liveYesBid != null || liveYesAsk != null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      market.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CategoryBadge(category: market.category),
                  if (trailing != null) ...[
                    const SizedBox(width: 4),
                    trailing!,
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Metric(
                    label: 'YES',
                    value: formatPrice(yesPrice),
                    valueColor:
                        isLive ? AppColors.accent : AppColors.textPrimary,
                  ),
                  _Metric(
                    label: 'EDGE',
                    value: edge == null ? '—' : formatEdge(edge),
                    valueColor: edgeColor,
                    secondary: edgeDelta == null
                        ? null
                        : '${edgeDelta! >= 0 ? '▲' : '▼'} '
                            '${formatEdge(edgeDelta!)} since added',
                    secondaryColor: AppColors.edgeColor(edgeDelta),
                  ),
                  _Metric(label: 'VOL 24H', value: formatVolume(market.volume24h)),
                  _Metric(
                    label: 'CLOSES',
                    value: formatTimeToClose(market.timeToClose),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.valueColor,
    this.secondary,
    this.secondaryColor,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final String? secondary;
  final Color? secondaryColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: valueColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (secondary != null)
            Text(
              secondary!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: secondaryColor ?? theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
