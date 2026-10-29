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
import '../profile/presentation/screens/profile_screen.dart';
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
    _Dest(
      label: 'Matches',
      title: 'Matches',
      eyebrow: 'FOR YOU',
      icon: AppIcons.feed,
      route: AppRoutes.feed,
      owner: 'Emad',
    ),
    _Dest(
      label: 'Discover',
      title: 'Discover',
      eyebrow: 'EXPLORE',
      icon: AppIcons.sparkle,
      route: AppRoutes.discover,
      owner: 'Bishay',
      prominent: true,
    ),
    _Dest(
      label: 'Projects',
      title: 'Projects',
      eyebrow: 'YOURS',
      icon: AppIcons.projects,
      route: AppRoutes.projects,
      owner: 'Bishay',
    ),
    _Dest(
      label: 'Requests',
      title: 'Requests',
      eyebrow: 'INBOX',
      icon: AppIcons.inbox,
      route: AppRoutes.requests,
      owner: 'Yousef',
      showBadge: true,
    ),
    _Dest(
      label: 'Profile',
      title: 'Profile',
      eyebrow: 'ACCOUNT',
      icon: AppIcons.profile,
      route: AppRoutes.profile,
      owner: 'Saga',
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
      appBar: isProfile
          ? null
          : DsAppBar(
              title: dest.title,
              eyebrow: dest.eyebrow,
              showMenu: true,
              onMenu: () => _scaffoldKey.currentState?.openDrawer(),
              onNotifications: () {
                Navigator.of(context).pushNamed(AppRoutes.notifications);
              },
              notificationBadge: true,
            ),
      body: isProfile
          ? const ProfileScreen()
          : Padding(
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
  const _Dest({
    required this.label,
    required this.title,
    required this.eyebrow,
    required this.icon,
    required this.route,
    required this.owner,
    this.prominent = false,
    this.showBadge = false,
  });

  final String label;
  final String title;
  final String eyebrow;
  final IconData icon;
  final String route;
  final String owner;
  final bool prominent;
  final bool showBadge;
}
