import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../app/devsync_app.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_button.dart';
import '../../../../core/widgets/ds_card.dart';
import '../../../../core/widgets/ds_icon.dart';
import '../../../matching/presentation/widgets/setup_scaffold.dart';
import '../widgets/auth_gate.dart';

/// Optional post-auth hint. Never blocks home — GitHub / profile stay optional.
class ChoosePathScreen extends StatelessWidget {
  const ChoosePathScreen({super.key});

  void _goHome(BuildContext context, {int tab = 0}) {
    navigateToHome(context, tabIndex: tab);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

    return SetupScaffold(
      eyebrow: 'Quick start',
      title: 'How will you start?',
      stepLabel: 'Optional',
      onThemeToggle: DevSyncApp.toggleTheme,
      onBack: () => _goHome(context),
      bottom: DsButton(
        label: 'Explore the app',
        variant: DsButtonVariant.quiet,
        onPressed: () => _goHome(context),
      ),
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
            'You can explore freely. Connect GitHub or add a project whenever you are ready.',
            style: textTheme.bodyMedium?.copyWith(color: ds.textMuted),
          ),
          const SizedBox(height: AppSpacing.xl),
          _PathCard(
            icon: AppIcons.feed,
            title: 'Find projects',
            subtitle: 'Browse matches. Connect GitHub later from Profile if you want.',
            onTap: () => _goHome(context),
          ),
          const SizedBox(height: AppSpacing.md),
          _PathCard(
            icon: AppIcons.projects,
            title: 'Publish a project',
            subtitle: 'Open Projects and add a listing when you are ready.',
            onTap: () => _goHome(context, tab: 2),
          ),
          const SizedBox(height: AppSpacing.md),
          _PathCard(
            icon: AppIcons.github,
            title: 'Connect GitHub',
            subtitle: 'Optional — scan repos and languages for better matches.',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.connectGithub),
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
