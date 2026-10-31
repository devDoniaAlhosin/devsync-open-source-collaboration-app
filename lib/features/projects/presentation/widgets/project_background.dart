import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ProjectBackground extends StatelessWidget {
  const ProjectBackground({
    required this.child,
    this.showStars = true,
    super.key,
  });

  final Widget child;
  final bool showStars;

  @override
  Widget build(BuildContext context) {
    final palette = context.ds;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.background, palette.surface, palette.canvas],
          stops: const [0, 0.5, 1],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -230,
            right: -170,
            child: IgnorePointer(
              child: _AccentGlow(color: AppColors.teal.withValues(alpha: 0.10)),
            ),
          ),
          Positioned(
            bottom: -300,
            left: -210,
            child: IgnorePointer(
              child: _AccentGlow(
                color: AppColors.teal.withValues(alpha: 0.055),
              ),
            ),
          ),
          if (showStars)
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _StarFieldPainter(color: palette.textMuted),
                  ),
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class _AccentGlow extends StatelessWidget {
  const _AccentGlow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 560,
      height: 560,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

class _StarFieldPainter extends CustomPainter {
  const _StarFieldPainter({required this.color});

  final Color color;
  static const _starCount = 72;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(19);
    final paint = Paint();

    for (var i = 0; i < _starCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 0.35 + random.nextDouble() * 0.95;
      final alpha = 0.035 + random.nextDouble() * 0.14;
      paint.color = color.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    final sparklePaint = Paint()
      ..color = AppColors.teal.withValues(alpha: 0.18)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 5; i++) {
      final center = Offset(
        30 + random.nextDouble() * math.max(size.width - 60, 1),
        30 + random.nextDouble() * math.max(size.height - 60, 1),
      );
      const arm = 3.0;
      canvas.drawLine(
        center.translate(-arm, 0),
        center.translate(arm, 0),
        sparklePaint,
      );
      canvas.drawLine(
        center.translate(0, -arm),
        center.translate(0, arm),
        sparklePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarFieldPainter oldDelegate) =>
      color != oldDelegate.color;
}
