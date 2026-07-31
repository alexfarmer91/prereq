import 'package:flutter/material.dart';

import '../models/market.dart';
import '../theme/app_theme.dart';

/// Small pill naming a score's confidence level. Distinct from the edge
/// green/red so it never reads as a directional signal.
class ConfidenceBadge extends StatelessWidget {
  const ConfidenceBadge({super.key, required this.confidence});

  final ScoreConfidence confidence;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (confidence) {
      ScoreConfidence.high => (AppColors.green, 'High'),
      ScoreConfidence.medium => (AppColors.amber, 'Medium'),
      ScoreConfidence.low => (AppColors.textSecondary, 'Low'),
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
