import 'package:devsync_open_source_collaboration_app/core/theme/app_colors.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_spacing.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_card.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/domain/entities/profile.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/widgets/contribution_heatmap.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/widgets/profile_stat_card.dart';
import 'package:flutter/material.dart';

/// Mobile sheet for a tapped language — share, estimated stats, activity.
class LanguageDetailSheet extends StatelessWidget {
  const LanguageDetailSheet({
    super.key,
    required this.language,
    required this.profile,
  });

  final LanguageShare language;
  final Profile profile;

  static Future<void> show(
    BuildContext context, {
    required LanguageShare language,
    required Profile profile,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.ds.surface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => LanguageDetailSheet(
        language: language,
        profile: profile,
      ),
    );
  }

  int get _estRepos =>
      ((profile.repos * language.percent) / 100).round().clamp(0, profile.repos);

  int get _estCommits => ((profile.commits * language.percent) / 100)
      .round()
      .clamp(0, profile.commits);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;
    final color = Color(language.colorArgb);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          0,
          AppSpacing.screenPadding,
          AppSpacing.lg + bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      language.name,
                      style: textTheme.titleLarge?.copyWith(
                        color: ds.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    '${language.percent}%',
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Estimated from your public GitHub mix on DevSync.',
                style: textTheme.bodySmall?.copyWith(color: ds.textMuted),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: ProfileStatCard(
                      value: _estRepos,
                      label: 'Repos (est.)',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ProfileStatCard(
                      value: _estCommits,
                      label: 'Commits (est.)',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ProfileStatCard(
                      value: language.percent,
                      label: 'Share',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              DsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile',
                      style: textTheme.titleSmall?.copyWith(
                        color: ds.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      profile.name.trim().isEmpty ? 'Developer' : profile.name,
                      style: textTheme.bodyLarge?.copyWith(
                        color: ds.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (profile.githubUrl.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        profile.githubUrl,
                        style: textTheme.bodySmall?.copyWith(
                          color: ds.textMuted,
                        ),
                      ),
                    ],
                    if (profile.bio.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        profile.bio,
                        style: textTheme.bodyMedium?.copyWith(
                          color: ds.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ContributionHeatmap(
                activity: profile.activity,
                title: 'Activity',
                commits: _estCommits,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
