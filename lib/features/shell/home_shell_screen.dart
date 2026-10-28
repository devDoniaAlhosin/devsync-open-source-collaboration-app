import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/icons/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/ds_card.dart';
import '../../core/widgets/ds_icon.dart';
import '../../core/widgets/ds_icon_button.dart';
import '../../core/widgets/ds_logo.dart';
import '../../core/widgets/ds_section_header.dart';
import '../matching/presentation/screens/match_feed_screen.dart';

/// Bottom-nav shell with stub destinations for each feature area.
class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  int _index = 0;

  static const _destinations = [
    _Dest('Feed', AppIcons.feed, AppRoutes.feed, 'Emad'),
    _Dest('Projects', AppIcons.projects, AppRoutes.projects, 'Bishay'),
    _Dest('Requests', AppIcons.requests, AppRoutes.requests, 'Yousef'),
    _Dest('Profile', AppIcons.profile, AppRoutes.profile, 'Saga'),
  ];

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return Scaffold(
      appBar: _index == 0
          ? null
          : AppBar(
              title: const DsLogo(height: 28),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: DsIconButton(
                    icon: AppIcons.designSystem,
                    tooltip: 'Design system',
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.designSystem),
                  ),
                ),
              ],
            ),
      body: IndexedStack(
        index: _index,
        children: [
          // Feed tab — owns its top appbar and header
          const MatchFeedScreen(embedded: true),
          // Remaining tabs — stub cards until their screens are ready
          for (final d in _destinations.skip(1))
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DsSectionHeader(
                    title: d.label,
                    subtitle: 'Stub — owned by ${d.owner}',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DsCard(
                    onTap: () => Navigator.of(context).pushNamed(d.route),
                    child: Row(
                      children: [
                        DsIcon(d.icon, color: AppColors.teal),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'Open ${d.label} screen stub',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        DsIcon(AppIcons.chevronRight, color: ds.textMuted),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: ds.background,
        indicatorColor: AppColors.teal,
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: DsIcon(d.icon, color: ds.textMuted),
              selectedIcon: DsIcon(d.icon, color: AppColors.onTeal),
              label: d.label,
            ),
        ],
      ),
    );
  }
}

class _Dest {
  const _Dest(this.label, this.icon, this.route, this.owner);
  final String label;
  final IconData icon;
  final String route;
  final String owner;
}
