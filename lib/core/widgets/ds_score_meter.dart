import 'package:flutter/material.dart';

import '../theme/app_animations.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Fit-score meter + numeric label for match cards (0–100).
class DsScoreMeter extends StatelessWidget {
  const DsScoreMeter({
    super.key,
    required this.score,
    this.showLabel = true,
    this.height = 8,
  });

  /// Score in `0..100`. Values outside the range are clamped.
  final double score;
  final bool showLabel;
  final double height;

  double get _fraction => (score.clamp(0, 100) / 100);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showLabel)
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${score.round()}%',
              style: textTheme.headlineSmall?.copyWith(
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
                const ColoredBox(color: AppColors.line),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: _fraction),
                  duration: AppAnimations.slow,
                  curve: AppAnimations.standard,
                  builder: (context, value, _) {
                    return FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: value.clamp(0.0, 1.0),
                      child: const ColoredBox(color: AppColors.teal),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
