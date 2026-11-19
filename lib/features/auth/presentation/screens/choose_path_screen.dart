import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../app/devsync_app.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_card.dart';
import '../../../../core/widgets/ds_icon.dart';
import '../../../matching/presentation/widgets/setup_scaffold.dart';
import '../../../profile/presentation/screens/edit_profile_entry.dart';

/// Post-auth choice: find projects (match) vs publish a project (maintainer).
class ChoosePathScreen extends StatelessWidget {
  const ChoosePathScreen({super.key});

  void _findProjects(BuildContext context) {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.connectGithub, (route) => false);
  }

  void _publishProject(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.editProfile,
      (route) => false,
      arguments: const EditProfileRouteArgs(
        asOnboarding: true,
        homeTabIndex: 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

    return SetupScaffold(
      eyebrow: 'Account setup',
      title: 'How will you start?',
      stepLabel: '01 / 03',
      onThemeToggle: DevSyncApp.toggleTheme,
      onBack: () => Navigator.of(context).maybePop(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Pick a starting path',
            style: textTheme.headlineMedium?.copyWith(
              color: ds.textPrimary,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'You can do both later. Connect GitHub is optional if you only want to publish.',
            style: textTheme.bodyMedium?.copyWith(color: ds.textMuted),
          ),
          const SizedBox(height: AppSpacing.xl),
          _PathCard(
            icon: AppIcons.feed,
            title: 'Find projects',
            subtitle: 'Match with open-source work that fits your skills.',
            onTap: () => _findProjects(context),
          ),
          const SizedBox(height: AppSpacing.md),
          _PathCard(
            icon: AppIcons.projects,
            title: 'Publish a project',
            subtitle: 'List your repo and invite collaborators. No GitHub scan required.',
            onTap: () => _publishProject(context),
          ),
        ],
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  const _PathCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: DsCard(
          tone: DsCardTone.inset,
          borderRadius: AppSpacing.radiusLg,
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                alignment: Alignment.center,
                child: DsIcon(icon, color: AppColors.teal, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        color: ds.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: ds.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              DsIcon(AppIcons.chevronRight, color: ds.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
