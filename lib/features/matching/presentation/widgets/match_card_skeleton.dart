import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Shared content lazy-loading card: avatar, title lines, circle, hero bar, text.
class MatchCardSkeleton extends StatelessWidget {
  const MatchCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading matches',
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.ds.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const _Bone(width: 48, height: 48, radius: 16),
                    const SizedBox(width: AppSpacing.md),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Bone(height: 14),
                          SizedBox(height: AppSpacing.sm),
                          FractionallySizedBox(
                            widthFactor: 0.55,
                            alignment: Alignment.centerLeft,
                            child: _Bone(height: 10),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const _Bone(width: 48, height: 48, radius: 24),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const _Bone(height: 48, radius: 16),
                const SizedBox(height: AppSpacing.md),
                const _Bone(height: 10),
                const SizedBox(height: AppSpacing.md),
                const FractionallySizedBox(
                  widthFactor: 0.7,
                  alignment: Alignment.centerLeft,
                  child: _Bone(height: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Bone extends StatelessWidget {
  const _Bone({
    this.width,
    this.height = 12,
    this.radius = 8,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.ds.border.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}
