import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/ds_chip.dart';

/// Avatar with completion ring + name, GitHub handle and completion chip.
class ProfileIdentity extends StatelessWidget {
  const ProfileIdentity({
    super.key,
    required this.name,
    required this.githubUrl,
    required this.completion,
    this.imageUrl,
  });

  final String name;
  final String githubUrl;

  /// `0..100`
  final int completion;
  final String? imageUrl;

  static const double _ringSize = 84;
  static const double _stroke = 5;

  String get _initial =>
      name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

    return Row(
      children: [
        Semantics(
          label: 'Profile $completion% complete',
          child: SizedBox(
            width: _ringSize,
            height: _ringSize,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: completion / 100),
              duration: AppAnimations.score,
              curve: AppAnimations.emphasized,
              builder: (_, value, child) => CustomPaint(
                painter: _RingPainter(
                  progress: value,
                  track: ds.surfaceAlt,
                  color: AppColors.teal,
                  stroke: _stroke,
                ),
                child: child,
              ),
              child: Padding(
                padding: const EdgeInsets.all(_stroke + 5),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ds.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: ds.border),
                    image: imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageUrl != null
                      ? null
                      : Text(
                          _initial,
                          style: textTheme.headlineSmall?.copyWith(
                            color: AppColors.teal,
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.headlineMedium?.copyWith(
                  color: ds.textPrimary,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                githubUrl,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(color: ds.textMuted),
              ),
              const SizedBox(height: AppSpacing.sm),
              DsChip(
                label: 'Profile $completion% complete',
                variant: DsChipVariant.selected,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.track,
    required this.color,
    required this.stroke,
  });

  final double progress;
  final Color track;
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    canvas.drawArc(arcRect, 0, math.pi * 2, false, trackPaint);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.track != track || old.color != color;
}
