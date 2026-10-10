import 'package:flutter/material.dart';

import '../icons/app_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'ds_avatar.dart';
import 'ds_button.dart';
import 'ds_card.dart';
import 'ds_chip.dart';
import 'ds_icon.dart';
import 'ds_score_meter.dart';

/// Match feed card composed from shared atoms (brand guide + prototype `.mc`).
class DsMatchCard extends StatelessWidget {
  const DsMatchCard({
    super.key,
    required this.projectName,
    required this.subtitle,
    required this.score,
    required this.reason,
    required this.skills,
    this.onRequest,
    this.onSkip,
    this.projectInitials,
  });

  final String projectName;
  final String subtitle;
  final double score;
  final String reason;
  final List<String> skills;
  final VoidCallback? onRequest;
  final VoidCallback? onSkip;
  final String? projectInitials;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final initials = projectInitials ??
        projectName
            .split(RegExp(r'[/\s-]'))
            .where((p) => p.isNotEmpty)
            .take(2)
            .map((p) => p[0])
            .join();

    return DsCard(
      borderRadius: AppSpacing.radiusMatch,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              DsProjectAvatar(label: initials),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      projectName,
                      style: textTheme.headlineSmall?.copyWith(fontSize: 17),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: context.ds.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                '${score.round()}%',
                style: textTheme.headlineSmall?.copyWith(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          DsScoreMeter(score: score),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const DsIcon(
                      AppIcons.sparkle,
                      size: 16,
                      color: AppColors.teal,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Why this match',
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.teal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  reason,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.darkText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final skill in skills) DsChip(label: skill),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: DsButton(
                  label: 'Request',
                  icon: AppIcons.requests,
                  onPressed: onRequest,
                  compact: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DsButton(
                  label: 'Skip',
                  variant: DsButtonVariant.quiet,
                  onPressed: onSkip,
                  compact: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
