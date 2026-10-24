import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/icons/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/ds_app_bar.dart';
import '../../core/widgets/ds_bottom_nav.dart';
import '../../core/widgets/ds_card.dart';
import '../../core/widgets/ds_icon.dart';
import '../../core/widgets/ds_section_header.dart';
import 'app_drawer.dart';

/// Bottom-nav shell with stub destinations for each feature area.
class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _index = 0;

  static const _destinations = [
    _Dest('Matches', 'For you', AppIcons.feed, AppRoutes.feed, 'Emad'),
    _Dest(
      'Discover',
      'Discover',
      AppIcons.sparkle,
      AppRoutes.discover,
      'Bishay',
      prominent: true,
    ),
    _Dest(
      'Projects',
      'Projects',
      AppIcons.projects,
      AppRoutes.projects,
      'Bishay',
    ),
    _Dest(
      'Requests',
      'Requests',
      AppIcons.inbox,
      AppRoutes.requests,
      'Yousef',
      showBadge: true,
    ),
    _Dest(
      'Profile',
      'Your profile',
      AppIcons.profile,
      AppRoutes.profile,
      'Saga',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final dest = _destinations[_index];
    final ds = context.ds;
    final isProfile = _index == 4;

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        onSelectTab: (i) => setState(() => _index = i),
      ),
      appBar: DsAppBar(
        title: dest.title,
        showMenu: true,
        onMenu: () => _scaffoldKey.currentState?.openDrawer(),
        onNotifications: () {
          Navigator.of(context).pushNamed(AppRoutes.notifications);
        },
        notificationBadge: true,
        onSettings: isProfile
            ? () => Navigator.of(context).pushNamed(AppRoutes.settings)
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DsSectionHeader(
              title: dest.label,
              subtitle: 'Stub — owned by ${dest.owner}',
            ),
            const SizedBox(height: AppSpacing.md),
            DsCard(
              onTap: () => Navigator.of(context).pushNamed(dest.route),
              child: Row(
                children: [
                  DsIcon(dest.icon, color: AppColors.teal),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Open ${dest.title} screen stub',
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
      bottomNavigationBar: DsBottomNav(
        index: _index,
        onChanged: (i) => setState(() => _index = i),
        items: [
          for (final d in _destinations)
            DsBottomNavItem(
              icon: d.icon,
              label: d.label,
              prominent: d.prominent,
              showBadge: d.showBadge,
            ),
        ],
      ),
    );
  }
}

class _Dest {
  const _Dest(
    this.label,
    this.title,
    this.icon,
    this.route,
    this.owner, {
    this.prominent = false,
    this.showBadge = false,
  });

  final String label;
  final String title;
  final IconData icon;
  final String route;
  final String owner;
  final bool prominent;
  final bool showBadge;
}
