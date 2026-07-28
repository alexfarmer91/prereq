import 'package:flutter/material.dart';

/// Nocturne — Prereq's design system, expressed as Flutter theme data.
///
/// Every value here comes from the Nocturne token sheet. Do not hard-code a
/// colour, radius or spacing at a call site; reach for [AppColors], [AppRadius]
/// or `AppSpace` (app_spacing.dart) instead.
///
/// Direction: a near-neutral blue-grey ground, Inter at weight 500, soft 8px
/// radii, and one blurple accent used as a line and a glow — never as a flood.
/// Primary actions are accent *outlines* on transparent, not filled buttons.
abstract final class AppColors {
  // ── Ground and surfaces ────────────────────────────────────────────────
  /// `--color-bg`
  static const background = Color(0xFF161826);

  /// `--color-surface`
  static const surface = Color(0xFF232532);

  /// Surface lifted one step. Nocturne draws elevation as an edge plus
  /// ambient darkness, so this stays close to [surface].
  static const surfaceHigh = Color(0xFF2C2E3C);

  /// `--color-neutral-800`
  static const border = Color(0xFF3F424D);

  // ── Text ───────────────────────────────────────────────────────────────
  /// `--color-text`
  static const textPrimary = Color(0xFFE9E9ED);

  /// `--color-neutral-500`
  static const textSecondary = Color(0xFF9397AB);

  /// `--color-neutral-600` — for the third tier: axis labels, timestamps.
  static const textTertiary = Color(0xFF75798C);

  // ── Accent ─────────────────────────────────────────────────────────────
  /// `--color-accent`. 3:1 against [background] — good for icons, large text
  /// and chrome. For accent-coloured *body* copy use [accentText].
  static const accent = Color(0xFF9184D9);

  /// `--color-accent-400` — hover / pressed one step past the base on a dark
  /// ground.
  static const accentHover = Color(0xFFB5ABFC);

  /// `--color-accent-300` — accent at paragraph sizes.
  static const accentText = Color(0xFFD2CEFD);

  /// `--color-accent-800` — tinted fills, selected rows, chart bands.
  static const accentFill = Color(0xFF423A6A);

  /// `--color-accent-600` — the accent on a *light* ground (print, exports).
  static const accentOnLight = Color(0xFF796CBF);

  // ── Neutral ramp ───────────────────────────────────────────────────────
  static const neutral100 = Color(0xFFF3F5FE);
  static const neutral200 = Color(0xFFE4E7F5);
  static const neutral300 = Color(0xFFCFD3E5);
  static const neutral400 = Color(0xFFB2B6CA);
  static const neutral500 = Color(0xFF9397AB);
  static const neutral600 = Color(0xFF75798C);
  static const neutral700 = Color(0xFF595D6C);
  static const neutral800 = Color(0xFF3F424D);
  static const neutral900 = Color(0xFF292B31);

  // ── Signal colours ─────────────────────────────────────────────────────
  // Re-derived on Nocturne's perceptual lightness scale at the accent's own
  // chroma range, so edge colours read as signal without shouting past the
  // accent. Never use the raw crypto-terminal greens and reds here.
  /// Positive edge.
  static const green = Color(0xFF5FBD97);

  /// Negative edge.
  static const red = Color(0xFFD97B6F);

  /// Caution: stale data, thin volume, imminent close.
  static const amber = Color(0xFFCBA05E);

  /// Green for positive edge, red for negative, muted for zero/unknown.
  static Color edgeColor(double? edge) {
    if (edge == null) return textSecondary;
    if (edge > 0) return green;
    if (edge < 0) return red;
    return textSecondary;
  }

  /// A signal colour as a subtle fill — Nocturne never floods saturation.
  static Color tint(Color c) => c.withValues(alpha: 0.14);
}

/// `--radius-sm | -md | -lg`
abstract final class AppRadius {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 14;
}

abstract final class AppTheme {
  /// Inter. Bundle the variable font as an asset (see INSTALL.md) — the name
  /// must match the `family:` key in pubspec.yaml.
  static const String fontFamily = 'Inter';

  static const List<String> _fallback = <String>[
    'SF Pro Text',
    'Segoe UI',
    'Roboto',
  ];

  /// Tabular figures — use on every price, edge, percentage and countdown so
  /// digits do not jitter as they tick.
  static const List<FontFeature> tabular = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColors.background,
      primaryContainer: AppColors.accentFill,
      onPrimaryContainer: AppColors.accentText,
      secondary: AppColors.accent,
      onSecondary: AppColors.background,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerLowest: AppColors.background,
      surfaceContainer: AppColors.surface,
      surfaceContainerHighest: AppColors.surfaceHigh,
      onSurfaceVariant: AppColors.textSecondary,
      error: AppColors.red,
      onError: AppColors.background,
      outline: AppColors.border,
      outlineVariant: AppColors.neutral900,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: fontFamily,
      fontFamilyFallback: _fallback,
      splashFactory: InkSparkle.splashFactory,
    );

    // Hierarchy here is size and space, never weight past 500.
    final text = base.textTheme
        .apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        )
        .copyWith(
          displayLarge: const TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: -1.6,
            height: 1.02,
          ),
          displayMedium: const TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: -1.2,
            height: 1.05,
          ),
          headlineLarge: const TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: -0.8,
            height: 1.1,
          ),
          headlineMedium: const TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: -0.6,
            height: 1.12,
          ),
          headlineSmall: const TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: -0.4,
            height: 1.16,
          ),
          titleLarge: const TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: -0.3,
          ),
          titleMedium: const TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
          titleSmall: const TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: -0.1,
          ),
          bodyLarge: const TextStyle(height: 1.5),
          bodyMedium: const TextStyle(height: 1.5),
          bodySmall: const TextStyle(height: 1.45),
          labelSmall: const TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: 1.1,
          ),
        );

    // Outlined primary — an accent border on transparent, in every state.
    final outlinedStyle = ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return AppColors.neutral600;
        if (states.contains(WidgetState.pressed)) return AppColors.accentText;
        if (states.contains(WidgetState.hovered)) return AppColors.accentHover;
        return AppColors.accent;
      }),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return AppColors.accent.withValues(alpha: 0.18);
        }
        if (states.contains(WidgetState.hovered)) {
          return AppColors.accent.withValues(alpha: 0.10);
        }
        return Colors.transparent;
      }),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return const BorderSide(color: AppColors.neutral800);
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.pressed)) {
          return const BorderSide(color: AppColors.accentHover);
        }
        return const BorderSide(color: AppColors.accent);
      }),
      elevation: const WidgetStatePropertyAll(0),
      shadowColor: const WidgetStatePropertyAll(Colors.transparent),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(fontWeight: FontWeight.w500, letterSpacing: 0),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 16.8, vertical: 11.2),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
      ),
      minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
    );

    final ghostStyle = outlinedStyle.copyWith(
      side: const WidgetStatePropertyAll(BorderSide.none),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return AppColors.neutral600;
        if (states.contains(WidgetState.pressed)) return AppColors.accentText;
        if (states.contains(WidgetState.hovered)) return AppColors.accentHover;
        return AppColors.textPrimary;
      }),
    );

    return base.copyWith(
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      // Nocturne's tags: tinted from the ramps, never filled with accent.
      chipTheme: base.chipTheme.copyWith(
        side: const BorderSide(color: AppColors.border),
        backgroundColor: AppColors.surfaceHigh,
        selectedColor: AppColors.accentFill,
        checkmarkColor: AppColors.accentText,
        labelStyle: text.labelMedium?.copyWith(color: AppColors.textSecondary),
        secondaryLabelStyle:
            text.labelMedium?.copyWith(color: AppColors.accentText),
        padding: const EdgeInsets.symmetric(horizontal: 8.4, vertical: 2.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        indicatorColor: AppColors.accentFill,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? AppColors.accent
                : AppColors.textSecondary,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return text.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        indicatorColor: AppColors.accentFill,
        selectedIconTheme:
            const IconThemeData(color: AppColors.accent, size: 22),
        unselectedIconTheme:
            const IconThemeData(color: AppColors.textSecondary, size: 22),
        selectedLabelTextStyle:
            text.labelMedium?.copyWith(color: AppColors.textPrimary),
        unselectedLabelTextStyle:
            text.labelMedium?.copyWith(color: AppColors.textSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceHigh,
        hintStyle: text.bodyMedium?.copyWith(color: AppColors.textTertiary),
        labelStyle: text.labelLarge?.copyWith(color: AppColors.textSecondary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 11.2, vertical: 11.2),
        border: _fieldBorder(AppColors.border),
        enabledBorder: _fieldBorder(AppColors.border),
        focusedBorder: _fieldBorder(AppColors.accent, width: 2),
        errorBorder: _fieldBorder(AppColors.red),
        focusedErrorBorder: _fieldBorder(AppColors.red, width: 2),
        disabledBorder: _fieldBorder(AppColors.neutral900),
      ),
      filledButtonTheme: FilledButtonThemeData(style: outlinedStyle),
      elevatedButtonTheme: ElevatedButtonThemeData(style: outlinedStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(style: outlinedStyle),
      textButtonTheme: TextButtonThemeData(style: ghostStyle),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return AppColors.accentHover;
            }
            return AppColors.textSecondary;
          }),
          overlayColor:
              WidgetStatePropertyAll(AppColors.accent.withValues(alpha: 0.12)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.accent
                : AppColors.neutral500),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.accentFill
                : AppColors.neutral900),
        trackOutlineColor:
            const WidgetStatePropertyAll(AppColors.border),
      ),
      sliderTheme: base.sliderTheme.copyWith(
        activeTrackColor: AppColors.accent,
        inactiveTrackColor: AppColors.neutral800,
        thumbColor: AppColors.accent,
        overlayColor: AppColors.accent.withValues(alpha: 0.14),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
        linearTrackColor: AppColors.neutral900,
        circularTrackColor: AppColors.neutral900,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.neutral700),
        ),
        textStyle: text.bodySmall?.copyWith(color: AppColors.textPrimary),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.neutral700),
        ),
        titleTextStyle: text.headlineSmall,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfaceHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceHigh,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
        ),
        actionTextColor: AppColors.accent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.neutral700),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.accent,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.border,
        labelStyle: text.titleSmall,
        unselectedLabelStyle: text.titleSmall,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.accent,
        selectionColor: AppColors.accent.withValues(alpha: 0.28),
        selectionHandleColor: AppColors.accent,
      ),
    );
  }

  static OutlineInputBorder _fieldBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  /// Nocturne is dark-first. This exists only so light-mode platform chrome
  /// (print, share sheets) has somewhere to land — the app should not offer it
  /// as a user setting.
  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: AppColors.accentOnLight,
      secondary: AppColors.accentOnLight,
      surface: AppColors.neutral100,
      onSurface: AppColors.background,
      error: AppColors.red,
      outline: AppColors.neutral300,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      fontFamily: fontFamily,
      fontFamilyFallback: _fallback,
      scaffoldBackgroundColor: AppColors.neutral100,
    );
  }
}
