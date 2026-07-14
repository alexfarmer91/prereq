import 'package:flutter/material.dart';

/// Financial-terminal palette. Dark-first; a light theme is provided but the
/// app defaults to dark.
abstract final class AppColors {
  // Dark surfaces
  static const background = Color(0xFF0A0E14);
  static const surface = Color(0xFF111722);
  static const surfaceHigh = Color(0xFF1A2230);
  static const border = Color(0xFF232D3F);

  // Signal colors
  static const green = Color(0xFF16C784);
  static const red = Color(0xFFEA3943);
  static const amber = Color(0xFFF3A712);
  static const accent = Color(0xFF3D8BFF);

  static const textPrimary = Color(0xFFE6EDF3);
  static const textSecondary = Color(0xFF8B98A9);

  /// Green for positive edge, red for negative, muted for zero/unknown.
  static Color edgeColor(double? edge) {
    if (edge == null) return textSecondary;
    if (edge > 0) return green;
    if (edge < 0) return red;
    return textSecondary;
  }
}

abstract final class AppTheme {
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.accent,
      secondary: AppColors.green,
      surface: AppColors.surface,
      surfaceContainerHighest: AppColors.surfaceHigh,
      error: AppColors.red,
      onPrimary: Colors.white,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border),
      chipTheme: base.chipTheme.copyWith(
        side: const BorderSide(color: AppColors.border),
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.accent.withValues(alpha: 0.22),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.accent.withValues(alpha: 0.22),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.accent.withValues(alpha: 0.22),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceHigh,
        contentTextStyle: TextStyle(color: AppColors.textPrimary),
      ),
    );
  }

  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: AppColors.accent,
      secondary: AppColors.green,
      error: AppColors.red,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
    );
  }
}
