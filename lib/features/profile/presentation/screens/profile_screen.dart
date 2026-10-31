import 'package:devsync_open_source_collaboration_app/app/app_routes.dart';
import 'package:devsync_open_source_collaboration_app/core/di/injection.dart';
import 'package:devsync_open_source_collaboration_app/core/navigation/open_host_drawer.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_colors.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_spacing.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_app_bar.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_bottom_nav.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_button.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_chip.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_empty_state.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_fade_switch.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_item_enter.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_page_fade.dart';
import 'package:devsync_open_source_collaboration_app/core/icons/app_icons.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/domain/entities/profile.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/screens/insights_screen.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/widgets/contribution_heatmap.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/widgets/language_breakdown.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/widgets/profile_identity.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/widgets/profile_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.onMenuPressed});

  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..load(),
      child: _ProfileView(onMenuPressed: onMenuPressed),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({this.onMenuPressed});

  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DsAppBar(
        title: 'Your profile',
        eyebrow: 'ACCOUNT',
        showMenu: true,
        onMenu: () {
          if (onMenuPressed != null) {
            onMenuPressed!();
            return;
          }
          openHostDrawer(context);
        },
        onNotifications: () {
          Navigator.of(context).pushNamed(AppRoutes.notifications);
        },
        notificationBadge: true,
        onSettings: () {
          Navigator.of(context).pushNamed(AppRoutes.settings);
        },
      ),
      body: DsPageFade(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return switch (state) {
              ProfileInitial() || ProfileLoading() => const Center(
                child: CircularProgressIndicator(color: AppColors.teal),
              ),
              ProfileFailure(:final message) => DsEmptyState(
                icon: AppIcons.error,
                title: 'Could not load profile',
                message: message,
                actionLabel: 'Retry',
                onAction: () => context.read<ProfileCubit>().load(),
              ),
              ProfileLoaded(:final profile) ||
              ProfileSaving(:final profile) => _ProfileBody(
                profile: profile,
                saving: state is ProfileSaving,
              ),
            };
          },
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.profile, required this.saving});

  final Profile profile;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

    final sections = <Widget>[
      ProfileIdentity(
        name: profile.name,
        githubUrl: profile.githubUrl,
        completion: profile.completion,
      ),
      Text(
        profile.bio,
        style: textTheme.bodyMedium?.copyWith(color: ds.textMuted),
      ),
      Row(
        children: [
          Expanded(
            child: ProfileStatCard(value: profile.repos, label: 'Repos'),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: ProfileStatCard(value: profile.commits, label: 'Commits'),
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
      ContributionHeatmap(activity: profile.activity),
      LanguageBreakdown(languages: profile.languages),
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [for (final s in profile.skills) DsChip(label: s)],
      ),
      Row(
        children: [
          Expanded(
            child: DsButton(
              label: saving ? 'Saving…' : 'Edit profile',
              variant: DsButtonVariant.quiet,
              onPressed: saving
                  ? null
                  : () async {
                      final result = await Navigator.of(context)
                          .push<EditProfileResult>(
                            DsFadePageRoute(
                              builder: (_) => EditProfileScreen(data: profile),
                            ),
                          );
                      if (result != null && context.mounted) {
                        await context.read<ProfileCubit>().save(
                          bio: result.bio,
                          skills: result.skills,
                        );
                      }
                    },
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: DsButton(
              label: 'Insights',
              variant: DsButtonVariant.primary,
              onPressed: () => Navigator.of(context).push(
                DsFadePageRoute(builder: (_) => InsightsScreen()),
              ),
            ),
          ),
        ],
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.lg,
        AppSpacing.screenPadding,
        AppSpacing.xxxl + DsBottomNav.bodyClearance,
      ),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == sections.length - 1 ? 0 : AppSpacing.lg,
          ),
          child: DsItemEnter(index: index, child: sections[index]),
        );
      },
    );
  }
}
