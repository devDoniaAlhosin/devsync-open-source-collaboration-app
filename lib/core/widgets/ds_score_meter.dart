import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/app_animations.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Linear fit bar (prototype `.fb`).
class DsScoreMeter extends StatelessWidget {
  const DsScoreMeter({
    super.key,
    required this.score,
    this.showLabel = false,
    this.height = 8,
    this.animate = true,
  });

  /// Score in `0..100`.
  final double score;
  final bool showLabel;
  final double height;
  final bool animate;

  double get _fraction => score.clamp(0, 100) / 100;

  @override
  Widget build(BuildContext context) {
    final track = context.ds.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showLabel)
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${score.round()}%',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.teal,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        if (showLabel) const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: SizedBox(
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: track),
                if (animate)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: _fraction),
                    duration: AppAnimations.score,
                    curve: AppAnimations.emphasized,
                    builder: (context, value, _) {
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: value.clamp(0.0, 1.0),
                        child: const ColoredBox(color: AppColors.teal),
                      );
                    },
                  )
                else
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _fraction,
                    child: const ColoredBox(color: AppColors.teal),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Circular fit ring (prototype `.rg` / `.ring`).
class DsScoreRing extends StatelessWidget {
  const DsScoreRing({
    super.key,
    required this.score,
    this.size = 64,
    this.strokeWidth,
  });

  final double score;
  final double size;
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    final fraction = score.clamp(0, 100) / 100;
    final stroke = strokeWidth ?? (size > 90 ? 8.0 : 6.0);

    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: fraction),
        duration: AppAnimations.score,
        curve: AppAnimations.emphasized,
        builder: (context, value, _) {
          return CustomPaint(
            painter: _RingPainter(
              progress: value,
              strokeWidth: stroke,
              trackColor: context.ds.border,
              progressColor: AppColors.teal,
            ),
            child: Center(
              child: Text(
                '${score.round()}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: context.ds.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: size > 90 ? 30 : 17,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
  });

  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final value = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      value,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.strokeWidth != strokeWidth;
}
