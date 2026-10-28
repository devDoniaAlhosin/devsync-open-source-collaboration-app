import 'package:flutter/material.dart';
import 'package:devsync_open_source_collaboration_app/core/icons/app_icons.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_animations.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_colors.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_spacing.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_card.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_icon.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/github_scan_result.dart';

class GithubScanSummaryCard extends StatelessWidget {
  const GithubScanSummaryCard({super.key, required this.result});

  final GithubScanResult result;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return DsCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      borderRadius: AppSpacing.radiusXl,
      child: Column(
        children: [
          _ScanRow(
            icon: AppIcons.projects,
            title: 'Repositories',
            subtitle: 'Public only',
            value: result.publicRepos,
          ),
          Divider(height: 1, color: ds.border),
          _ScanRow(
            icon: AppIcons.code,
            title: 'Languages',
            subtitle: result.languagesSummary,
            value: result.languageCount,
          ),
          Divider(height: 1, color: ds.border),
          _ScanRow(
            icon: AppIcons.github,
            title: 'Commits, last year',
            subtitle: 'Weekly activity',
            value: result.commitsLastYear,
          ),
        ],
      ),
    );
  }
}

class _ScanRow extends StatelessWidget {
  const _ScanRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final int value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ds.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ds.border),
            ),
            child: DsIcon(icon, color: AppColors.teal, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    color: ds.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(color: ds.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: AppAnimations.score,
            curve: AppAnimations.emphasized,
            builder: (_, v, _) => Text(
              '$v',
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.teal,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
