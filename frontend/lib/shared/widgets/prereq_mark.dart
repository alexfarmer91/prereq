import 'package:flutter/widgets.dart';

import '../theme/app_theme.dart';

/// The Prereq mark — four unequal outcomes with the market's threshold drawn
/// straight through them.
///
/// Geometry lives on a 128-unit grid and scales from there, so the mark is
/// identical at every size. Below [compactBreakpoint] it swaps to the compact
/// three-bar cut automatically; the four-bar mark closes up below ~28px.
///
///   PrereqMark(size: 24)                       // nav / app bar
///   PrereqMark(size: 96)                       // splash
///   PrereqMark(size: 20, monochrome: true)     // single-ink contexts
class PrereqMark extends StatelessWidget {
  const PrereqMark({
    super.key,
    this.size = 32,
    this.monochrome = false,
    this.color,
    this.ruleColor,
  });

  /// Width and height in logical pixels.
  final double size;

  /// Collapse the tonal steps to one solid colour — engraving, embroidery,
  /// single-ink print, and any context where the ramp cannot survive.
  final bool monochrome;

  /// Overrides the bar colours. In monochrome this is the whole mark.
  final Color? color;

  /// Overrides the threshold rule. Defaults to the accent, or to [color] in
  /// monochrome.
  final Color? ruleColor;

  /// At or below this size, the compact three-bar mark is used.
  static const double compactBreakpoint = 26;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _PrereqMarkPainter(
          compact: size <= compactBreakpoint,
          monochrome: monochrome,
          color: color,
          ruleColor: ruleColor,
        ),
        isComplex: false,
      ),
    );
  }
}

class _PrereqMarkPainter extends CustomPainter {
  const _PrereqMarkPainter({
    required this.compact,
    required this.monochrome,
    this.color,
    this.ruleColor,
  });

  final bool compact;
  final bool monochrome;
  final Color? color;
  final Color? ruleColor;

  // ── 128-unit grid ──────────────────────────────────────────────────────
  static const double _grid = 128;
  static const double _baseline = 104;
  static const double _threshold = 64;

  // Four bars: x centre, top. Deliberately non-monotonic — a distribution,
  // not a growth chart.
  static const List<List<double>> _bars = [
    [28, 80],
    [52, 56],
    [76, 68],
    [100, 34],
  ];
  static const double _barStem = 14;
  static const double _ruleStem = 4;

  static const List<List<double>> _barsCompact = [
    [26, 78],
    [64, 54],
    [102, 32],
  ];
  static const double _barStemCompact = 20;
  static const double _ruleStemCompact = 9;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / _grid;
    final bars = compact ? _barsCompact : _bars;
    final stem = (compact ? _barStemCompact : _barStem) * k;
    final ruleStem = (compact ? _ruleStemCompact : _ruleStem) * k;

    final solid = color ?? AppColors.textPrimary;
    // Light to heavy, so the tallest bar carries the most value.
    final shades = monochrome
        ? List<Color>.filled(bars.length, solid)
        : (compact
            ? const [
                AppColors.neutral500,
                AppColors.neutral400,
                AppColors.textPrimary,
              ]
            : const [
                AppColors.neutral600,
                AppColors.neutral400,
                AppColors.neutral500,
                AppColors.textPrimary,
              ]);

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = stem;

    for (var i = 0; i < bars.length; i++) {
      paint.color = color != null && monochrome ? solid : shades[i];
      canvas.drawLine(
        Offset(bars[i][0] * k, _baseline * k),
        Offset(bars[i][0] * k, bars[i][1] * k),
        paint,
      );
    }

    // The threshold overshoots the bars on both sides: the price extends past
    // what it can actually see.
    canvas.drawLine(
      Offset(6 * k, _threshold * k),
      Offset(122 * k, _threshold * k),
      paint
        ..strokeWidth = ruleStem
        ..color = ruleColor ?? (monochrome ? solid : AppColors.accent),
    );
  }

  @override
  bool shouldRepaint(_PrereqMarkPainter old) =>
      old.compact != compact ||
      old.monochrome != monochrome ||
      old.color != color ||
      old.ruleColor != ruleColor;
}

/// Mark plus wordmark. Horizontal is the default lockup; [stacked] is for
/// square placements (splash, empty states, share cards).
class PrereqLockup extends StatelessWidget {
  const PrereqLockup({
    super.key,
    this.markSize = 24,
    this.stacked = false,
    this.color,
  });

  final double markSize;
  final bool stacked;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final mark = PrereqMark(size: markSize, color: color);
    // Wordmark tracks the mark: cap height ≈ 0.8 of the mark box.
    final word = Text(
      'prereq',
      style: TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: markSize * 0.82,
        fontWeight: FontWeight.w500,
        letterSpacing: markSize * -0.033,
        height: 1,
        color: color ?? AppColors.textPrimary,
      ),
    );

    // Clear space: one bar-width, ≈ 20% of the mark.
    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [mark, SizedBox(height: markSize * 0.22), word],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [mark, SizedBox(width: markSize * 0.4), word],
    );
  }
}
