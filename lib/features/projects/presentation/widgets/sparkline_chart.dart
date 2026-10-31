import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SparklineChart extends StatelessWidget {
  const SparklineChart({required this.values, this.height = 66, super.key});

  final List<double> values;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Weekly views trend',
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 850),
          curve: Curves.easeOutCubic,
          builder: (context, progress, child) {
            return CustomPaint(
              painter: _SparklinePainter(
                values: values,
                progress: progress,
                endpointColor: context.ds.textPrimary,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.progress,
    required this.endpointColor,
  });

  final List<double> values;
  final double progress;
  final Color endpointColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || size.width <= 0 || size.height <= 0) {
      return;
    }

    final safeValues = values.length == 1
        ? [values.first, values.first]
        : values;
    final maxValue = safeValues.reduce((a, b) => a > b ? a : b);
    final minValue = safeValues.reduce((a, b) => a < b ? a : b);
    final range = (maxValue - minValue).abs() < 0.001
        ? 1.0
        : maxValue - minValue;

    const horizontalPadding = 2.0;
    const verticalPadding = 8.0;
    final chartWidth = size.width - horizontalPadding * 2;
    final chartHeight = size.height - verticalPadding * 2;

    final points = <Offset>[
      for (var i = 0; i < safeValues.length; i++)
        Offset(
          horizontalPadding + (chartWidth * i / (safeValues.length - 1)),
          verticalPadding +
              chartHeight -
              ((safeValues[i] - minValue) / range) * chartHeight,
        ),
    ];

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final controlX = (previous.dx + current.dx) / 2;
      linePath.cubicTo(
        controlX,
        previous.dy,
        controlX,
        current.dy,
        current.dx,
        current.dy,
      );
    }

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * progress, size.height));

    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x2E2EE0C8), Color(0x002EE0C8)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    final glowPaint = Paint()
      ..color = AppColors.teal.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawPath(linePath, glowPaint);

    final linePaint = Paint()
      ..color = AppColors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    if (progress > 0.97) {
      canvas.drawCircle(points.last, 3, Paint()..color = endpointColor);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.values != values;
  }
}
