import 'package:devsync_open_source_collaboration_app/core/theme/app_colors.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/edit_profile_screen.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/insights_screen.dart';
import 'package:flutter/material.dart';

import '../../core/icons/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/ds_button.dart';
import '../../core/widgets/ds_chip.dart';
import '../../core/widgets/ds_icon_button.dart';
import 'models/profile_data.dart';
import 'widgets/contribution_heatmap.dart';
import 'widgets/language_breakdown.dart';
import 'widgets/profile_identity.dart';
import 'widgets/profile_stat_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.data});

  /// Inject real data later; falls back to mock.
  final ProfileData? data;

  @override
  Widget build(BuildContext context) {
    final profile = data ?? ProfileData.sample();
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.md,
            AppSpacing.screenPadding,
            AppSpacing.xxxl,
          ),
          children: [
            // Header
            Row(
              children: [
                DsIconButton(
                  icon: AppIcons.menu,
                  tooltip: 'Menu',
                  onPressed: () {},
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DEVSYNC',
                        style: textTheme.labelSmall?.copyWith(
                          color: ds.textMuted,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          letterSpacing: 1.6,
                        ),
                      ),
                      Text(
                        'Your profile',
                        style: textTheme.headlineMedium?.copyWith(
                          color: ds.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                DsIconButton(
                  icon: AppIcons.notifications,
                  tooltip: 'Notifications',
                  showBadge: true,
                  onPressed: () {},
                ),
                const SizedBox(width: AppSpacing.sm),
                DsIconButton(
                  icon: AppIcons.settings,
                  tooltip: 'Settings',
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Divider(height: 1, color: ds.border),
            const SizedBox(height: AppSpacing.lg),

            //Identity
            ProfileIdentity(
              name: profile.name,
              githubUrl: profile.githubUrl,
              completion: profile.completion,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Bio
            Text(
              profile.bio,
              style: textTheme.bodyMedium?.copyWith(color: ds.textMuted),
            ),
            const SizedBox(height: AppSpacing.lg),

            //  Stats
            Row(
              children: [
                Expanded(
                  child: ProfileStatCard(value: profile.repos, label: 'Repos'),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ProfileStatCard(
                    value: profile.commits,
                    label: 'Commits',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ProfileStatCard(
                    value: profile.languageCount,
                    label: 'Languages',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Activity + languages
            ContributionHeatmap(activity: profile.activity),
            const SizedBox(height: AppSpacing.lg),
            LanguageBreakdown(languages: profile.languages),
            const SizedBox(height: AppSpacing.lg),

            // Skill
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [for (final s in profile.skills) DsChip(label: s)],
            ),
            const SizedBox(height: AppSpacing.xl),

            //Actions
            DsButton(
              label: 'Edit profile',
              variant: DsButtonVariant.quiet,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(data: profile),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            DsButton(
              label: 'View contribution insights →',
              variant: DsButtonVariant.quiet,
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => InsightsScreen())),
            ),
          ],
        ),
      ),
    );
  }
}
