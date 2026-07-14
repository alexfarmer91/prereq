import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

const _categoryColors = <String, Color>{
  'Sports': Color(0xFF3D8BFF),
  'Economics': Color(0xFFF3A712),
  'Politics': Color(0xFFB067F7),
  'Weather': Color(0xFF2BC8C8),
};

/// Small colored pill naming the market's category.
class CategoryBadge extends StatelessWidget {
  const CategoryBadge({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final color = _categoryColors[category] ?? AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
