import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/icons/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/ds_button.dart';
import '../../core/widgets/ds_icon.dart';
import '../../core/widgets/ds_icon_button.dart';
import '../../core/widgets/ds_logo.dart';

/// Prototype sidebar — Workspace, Intelligence, Account. No team/ownership.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, this.onSelectTab});

  /// Maps sidebar items that already exist on the home bottom nav.
  final ValueChanged<int>? onSelectTab;

  void _close(BuildContext context) => Navigator.of(context).pop();

  void _openRoute(BuildContext context, String route) {
    _close(context);
    Navigator.of(context).pushNamed(route);
  }

  void _openTab(BuildContext context, int index) {
    _close(context);
    onSelectTab?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      backgroundColor: ds.background,
      width: 316,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 8, 15, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 7, 0, 18),
                child: Row(
                  children: [
                    const DsLogo(variant: DsLogoVariant.icon, height: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DevSync',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            'Developer workspace',
                            style: textTheme.bodySmall?.copyWith(
                              color: ds.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DsIconButton(
                      icon: AppIcons.close,
                      tooltip: 'Close menu',
                      onPressed: () => _close(context),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: ds.border),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 8),
                  children: [
                    const _Group('Workspace'),
                    _Link(
                      icon: AppIcons.heart,
                      label: 'My matches',
                      onTap: () => _openTab(context, 0),
                    ),
                    _Link(
                      icon: AppIcons.sparkle,
                      label: 'Discover projects',
                      onTap: () => _openTab(context, 1),
                    ),
                    _Link(
                      icon: AppIcons.projects,
                      label: 'My projects',
                      onTap: () => _openTab(context, 2),
                    ),
                    _Link(
                      icon: AppIcons.inbox,
                      label: 'Collaboration requests',
                      onTap: () => _openTab(context, 3),
                    ),
                    _Link(
                      icon: AppIcons.success,
                      label: 'Task board',
                      onTap: () => _openRoute(context, AppRoutes.tasks),
                    ),
                    const _Group('Intelligence & community'),
                    _Link(
                      icon: AppIcons.sparkle,
                      label: 'AI Prompt Studio',
                      onTap: () => _openRoute(context, AppRoutes.aiStudio),
                    ),
                    _Link(
                      icon: AppIcons.chart,
                      label: 'AI analytics',
                      onTap: () => _openRoute(context, AppRoutes.aiInsights),
                    ),
                    _Link(
                      icon: AppIcons.chart,
                      label: 'Contribution insights',
                      onTap: () => _openRoute(context, AppRoutes.insights),
                    ),
                    _Link(
                      icon: AppIcons.profile,
                      label: 'Community',
                      onTap: () => _openRoute(context, AppRoutes.community),
                    ),
                    _Link(
                      icon: AppIcons.notifications,
                      label: 'Notifications',
                      onTap: () => _openRoute(context, AppRoutes.notifications),
                    ),
                    const _Group('Account'),
                    _Link(
                      icon: AppIcons.profile,
                      label: 'My profile',
                      onTap: () => _openTab(context, 4),
                    ),
                    _Link(
                      icon: AppIcons.settings,
                      label: 'Settings',
                      onTap: () => _openRoute(context, AppRoutes.settings),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 13),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: ds.surface,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: ds.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Build with the right people',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Explore matches, join a team and make your next contribution count.',
                      style: textTheme.bodySmall?.copyWith(
                        color: ds.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DsButton(
                      label: 'Try AI matching →',
                      compact: true,
                      onPressed: () =>
                          _openRoute(context, AppRoutes.aiStudio),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 2),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.ds.textMuted,
              fontWeight: FontWeight.w800,
              fontSize: 10,
              letterSpacing: 1.3,
            ),
      ),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusIcon),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 47),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                DsIcon(icon, size: 19, color: ds.accentText),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
