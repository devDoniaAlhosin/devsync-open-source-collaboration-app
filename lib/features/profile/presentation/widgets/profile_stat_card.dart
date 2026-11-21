import 'package:flutter/material.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_animations.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_colors.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_spacing.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_card.dart';

class ProfileStatCard extends StatelessWidget {
  const ProfileStatCard({
    super.key,
    required this.value,
    required this.label,
    this.onTap,
  });

  final int value;
  final String label;

  /// When set, the card is tappable (e.g. open a GitHub stats list).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;
    final tappable = onTap != null;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: value),
          duration: AppAnimations.score,
          curve: AppAnimations.emphasized,
          builder: (_, v, _) => Text(
            '$v',
            style: textTheme.headlineMedium?.copyWith(
              color: AppColors.teal,
              fontWeight: FontWeight.w800,
              fontSize: 26,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: ds.textMuted,
            decoration: tappable ? TextDecoration.underline : null,
            decorationColor: ds.border,
          ),
        ),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: DsCard(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.xl,
            horizontal: AppSpacing.sm,
          ),
          borderRadius: AppSpacing.radiusXl,
          child: content,
        ),
      ),
    );
  }
}
