import 'package:flutter/material.dart';

import '../models/market.dart';
import '../theme/app_theme.dart';

/// Small pill naming the model's self-rated confidence. One neutral colour
/// for every level: a self-rating is not measured reliability, and it must
/// never read as a directional or quality signal.
class ConfidenceBadge extends StatelessWidget {
  const ConfidenceBadge({super.key, required this.confidence});

  final ScoreConfidence confidence;

  @override
  Widget build(BuildContext context) {
    const color = AppColors.textSecondary;
    final label = switch (confidence) {
      ScoreConfidence.high => 'Self-rated high',
      ScoreConfidence.medium => 'Self-rated med',
      ScoreConfidence.low => 'Self-rated low',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
