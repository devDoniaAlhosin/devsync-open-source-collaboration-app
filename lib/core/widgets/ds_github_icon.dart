import 'package:flutter/material.dart';

/// GitHub mark (Lucide no longer ships brand icons).
class DsGithubIcon extends StatelessWidget {
  const DsGithubIcon({
    super.key,
    this.size = 18,
    this.color,
  });

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GithubMarkPainter(
          color: color ?? IconTheme.of(context).color ?? Colors.black,
        ),
      ),
    );
  }
}

class _GithubMarkPainter extends CustomPainter {
  _GithubMarkPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    // Octocat silhouette scaled to [size].
    final path = Path()
      ..moveTo(12, 0.3)
      ..cubicTo(5.4, 0.3, 0, 5.7, 0, 12.3)
      ..cubicTo(0, 17.6, 3.4, 22.1, 8.2, 23.7)
      ..cubicTo(8.8, 23.8, 9, 23.4, 9, 23.1)
      ..cubicTo(9, 22.8, 9, 22, 9, 21)
      ..cubicTo(5.7, 21.7, 5, 19.5, 5, 19.5)
      ..cubicTo(4.5, 18.1, 3.7, 17.7, 3.7, 17.7)
      ..cubicTo(2.5, 16.9, 3.8, 16.9, 3.8, 16.9)
      ..cubicTo(5.1, 17, 5.8, 18.3, 5.8, 18.3)
      ..cubicTo(7, 20.2, 8.9, 19.7, 9.5, 19.4)
      ..cubicTo(9.6, 18.6, 9.9, 18.1, 10.3, 17.8)
      ..cubicTo(7.5, 17.5, 4.6, 16.4, 4.6, 11.7)
      ..cubicTo(4.6, 10.4, 5.1, 9.3, 5.8, 8.5)
      ..cubicTo(5.7, 8.2, 5.3, 6.9, 6, 5.3)
      ..cubicTo(6, 5.3, 7.1, 5, 9, 6.3)
      ..cubicTo(10, 6, 11, 5.9, 12, 5.9)
      ..cubicTo(13, 5.9, 14, 6, 15, 6.3)
      ..cubicTo(16.9, 5, 18, 5.3, 18, 5.3)
      ..cubicTo(18.7, 6.9, 18.3, 8.2, 18.2, 8.5)
      ..cubicTo(19, 9.3, 19.4, 10.4, 19.4, 11.7)
      ..cubicTo(19.4, 16.4, 16.5, 17.5, 13.7, 17.8)
      ..cubicTo(14.2, 18.2, 14.6, 19, 14.6, 20.2)
      ..cubicTo(14.6, 22, 14.6, 22.7, 14.6, 23.1)
      ..cubicTo(14.6, 23.4, 14.8, 23.8, 15.4, 23.7)
      ..cubicTo(20.2, 22.1, 23.6, 17.6, 23.6, 12.3)
      ..cubicTo(23.6, 5.7, 18.2, 0.3, 12, 0.3)
      ..close();

    final scale = size.shortestSide / 24;
    canvas
      ..save()
      ..scale(scale)
      ..drawPath(path, paint)
      ..restore();
  }

  @override
  bool shouldRepaint(covariant _GithubMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}
