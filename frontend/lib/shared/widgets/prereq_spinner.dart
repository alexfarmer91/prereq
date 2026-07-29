import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A rotating arc with a violet/lilac gradient sweep — Nocturne's spinner for
/// full-screen loading states (splash, auth restore), in place of the plain
/// Material [CircularProgressIndicator] used inline within cards.
class PrereqSpinner extends StatefulWidget {
  const PrereqSpinner({super.key, this.size = 40});

  final double size;

  @override
  State<PrereqSpinner> createState() => _PrereqSpinnerState();
}

class _PrereqSpinnerState extends State<PrereqSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _SpinnerPainter(turns: _controller.value),
        ),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  const _SpinnerPainter({required this.turns});

  final double turns;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.shortestSide * 0.09;
    final rect = Offset.zero & size;
    final ringRect = rect.deflate(strokeWidth / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        transform: GradientRotation(turns * 2 * math.pi),
        startAngle: 0,
        endAngle: 2 * math.pi,
        colors: const [
          Colors.transparent,
          AppColors.accentFill,
          AppColors.accent,
          AppColors.accentHover,
        ],
        stops: const [0.0, 0.35, 0.75, 1.0],
      ).createShader(ringRect);

    canvas.drawArc(ringRect, 0, 2 * math.pi * 0.85, false, paint);
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) => old.turns != turns;
}
