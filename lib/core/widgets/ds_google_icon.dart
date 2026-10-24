import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Official-style four-color Google “G”.
class DsGoogleIcon extends StatelessWidget {
  const DsGoogleIcon({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _red = Color(0xFFEA4335);
  static const _yellow = Color(0xFFFBBC05);
  static const _green = Color(0xFF34A853);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    canvas
      ..save()
      ..scale(s / 24, s / 24);

    final ring = Rect.fromCircle(center: const Offset(12, 12), radius: 8.15);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.35
      ..strokeCap = StrokeCap.butt;

    stroke.color = _red;
    canvas.drawArc(ring, -math.pi * 0.92, math.pi * 0.72, false, stroke);

    stroke.color = _yellow;
    canvas.drawArc(ring, math.pi * 0.72, math.pi * 0.55, false, stroke);

    stroke.color = _green;
    canvas.drawArc(ring, math.pi * 0.28, math.pi * 0.5, false, stroke);

    stroke.color = _blue;
    canvas.drawArc(ring, -math.pi * 0.22, math.pi * 0.42, false, stroke);

    canvas.drawRRect(
      RRect.fromLTRBR(12, 9.85, 21.4, 14.15, const Radius.circular(0.4)),
      Paint()..color = _blue,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
