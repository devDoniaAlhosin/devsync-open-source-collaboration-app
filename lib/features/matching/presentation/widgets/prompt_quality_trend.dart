import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../models/prompt_quality_metrics.dart';

class PromptQualityTrend extends StatelessWidget {
  const PromptQualityTrend({super.key, required this.metrics});

  final PromptQualityMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final mutedStyle = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(color: context.ds.textMuted);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label:
              'Relevance trend. Target ${metrics.relevanceTarget.round()} percent. '
              '${metrics.versions.map((v) => '${v.label}: ${v.relevance.round()} percent').join(', ')}.',
          child: SizedBox(
            height: 140,
            child: CustomPaint(
              painter: _TrendPainter(
                versions: metrics.versions,
                target: metrics.relevanceTarget,
                color: context.ds.accentText,
                surface: context.ds.surface,
                guide: context.ds.border,
                targetStyle:
                    mutedStyle ?? TextStyle(color: context.ds.textMuted),
                textDirection: Directionality.of(context),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.sm,
          children: [
            for (final version in metrics.versions)
              Text(
                '${version.label} · ${version.relevance.round()}%',
                style: mutedStyle,
              ),
          ],
        ),
      ],
    );
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({
    required this.versions,
    required this.target,
    required this.color,
    required this.surface,
    required this.guide,
    required this.targetStyle,
    required this.textDirection,
  });

  final List<PromptQualityVersion> versions;
  final double target;
  final Color color;
  final Color surface;
  final Color guide;
  final TextStyle targetStyle;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    if (versions.isEmpty) return;
    const inset = 8.0;
    final values = [target, ...versions.map((version) => version.relevance)];
    final lower = math.max(0.0, values.reduce(math.min) - 5);
    final upper = math.min(100.0, values.reduce(math.max) + 5);
    final range = math.max(1.0, upper - lower);
    double y(double value) =>
        size.height -
        inset -
        (value - lower) / range * (size.height - inset * 2);

    final guidePaint = Paint()
      ..color = guide
      ..strokeWidth = 1;
    final targetY = y(target);
    for (var x = inset; x < size.width - inset; x += 9) {
      canvas.drawLine(
        Offset(x, targetY),
        Offset(math.min(x + 4, size.width - inset), targetY),
        guidePaint,
      );
    }
    final label = TextPainter(
      text: TextSpan(text: 'Target', style: targetStyle),
      textDirection: textDirection,
    )..layout(maxWidth: size.width);
    label.paint(
      canvas,
      Offset(size.width - label.width, math.max(0, targetY - label.height - 5)),
    );

    final points = [
      for (var index = 0; index < versions.length; index++)
        Offset(
          versions.length == 1
              ? size.width / 2
              : inset +
                    (size.width - inset * 2) * index / (versions.length - 1),
          y(versions[index].relevance),
        ),
    ];
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var index = 1; index < points.length; index++) {
      final previous = points[index - 1];
      final point = points[index];
      final middleX = (previous.dx + point.dx) / 2;
      path.cubicTo(middleX, previous.dy, middleX, point.dy, point.dx, point.dy);
    }
    canvas.drawPath(path, linePaint);
    for (final point in points) {
      canvas.drawCircle(point, 5, Paint()..color = surface);
      canvas.drawCircle(point, 5, linePaint..strokeWidth = 2.5);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      versions != oldDelegate.versions ||
      target != oldDelegate.target ||
      color != oldDelegate.color ||
      surface != oldDelegate.surface ||
      guide != oldDelegate.guide ||
      targetStyle != oldDelegate.targetStyle ||
      textDirection != oldDelegate.textDirection;
}
