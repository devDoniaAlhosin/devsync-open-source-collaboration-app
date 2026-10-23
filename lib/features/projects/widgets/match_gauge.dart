import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class MatchGauge extends StatelessWidget {
  const MatchGauge({required this.percentage, this.size = 106, super.key});

  final int percentage;
  final double size;

  @override
  Widget build(BuildContext context) {
    final normalized = (percentage / 100).clamp(0.0, 1.0);

    return Semantics(
      label: '$percentage percent match',
      child: SizedBox(
        width: size,
        height: size,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: normalized),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          builder: (context, progress, child) {
            return CustomPaint(
              painter: _GaugePainter(
                progress: progress,
                trackColor: context.ds.border,
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$percentage%',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: 31,
                      letterSpacing: -1.2,
                      color: context.ds.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.progress, required this.trackColor});

  final double progress;
  final Color trackColor;

  static const _start = -math.pi / 2 + 0.44;
  static const _sweep = math.pi * 2 - 0.88;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final strokeWidth = size.width * 0.09;
    final radius = (size.width - strokeWidth) / 2;
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor.withValues(alpha: 0.82)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arcRect, _start, _sweep, false, trackPaint);

    if (progress <= 0) {
      return;
    }

    final glowPaint = Paint()
      ..color = AppColors.teal.withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawArc(arcRect, _start, _sweep * progress, false, glowPaint);

    final progressPaint = Paint()
      ..shader = const SweepGradient(
        colors: [Color(0xFF7CF3E4), AppColors.teal, Color(0xFF21B9A5)],
        transform: GradientRotation(_start),
      ).createShader(arcRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arcRect, _start, _sweep * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
