import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/icons/app_icons.dart';
import '../../core/widgets/ds_app_bar.dart';
import '../../core/widgets/ds_bottom_nav.dart';
import '../../core/widgets/ds_tab_switcher.dart';
import '../matching/presentation/screens/match_feed_screen.dart';
import '../profile/presentation/screens/profile_screen.dart';
import '../projects/presentation/screens/projects_shell.dart';
import '../requests/presentation/screens/requests_screen.dart';
import 'app_drawer.dart';

/// Bottom-nav shell with feature destinations.
class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key, this.initialIndex = 0});

  /// Bottom-nav index (0 Matches … 3 Requests … 4 Profile).
  final int initialIndex;

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late int _index;

  static const _destinations = [
    _Dest(
      label: 'Matches',
      title: 'Matches',
      eyebrow: 'FOR YOU',
      brandMark: true,
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

  /// Discover (1) and Projects (2) share one kept-alive [ProjectsShell] pane.
  int get _paneIndex => switch (_index) {
    0 => 0,
    1 || 2 => 1,
    3 => 2,
    _ => 3,
  };

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, _destinations.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final dest = _destinations[_index];
    final isMatches = _index == 0;
    final isProjectsArea = _index == 1 || _index == 2;
    final isRequests = _index == 3;
    final isProfile = _index == 4;
    final hideShellAppBar =
        isMatches || isProjectsArea || isRequests || isProfile;

    final media = MediaQuery.of(context);
    final paddedMedia = media.copyWith(
      padding: media.padding.copyWith(
        bottom: media.padding.bottom + DsBottomNav.bodyClearance,
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      drawer: AppDrawer(
        onSelectTab: (i) => setState(() => _index = i),
      ),
      appBar: hideShellAppBar
          ? null
          : DsAppBar(
              title: dest.title,
              eyebrow: dest.eyebrow,
              showMenu: true,
              onMenu: _openDrawer,
              onNotifications: () {
                Navigator.of(context).pushNamed(AppRoutes.notifications);
              },
              notificationBadge: true,
            ),
      body: MediaQuery(
        data: paddedMedia,
        child: DsTabSwitcher(
          index: _paneIndex,
          children: [
            MatchFeedScreen(
              onMenuPressed: _openDrawer,
              onOpenProfile: () => setState(() => _index = 4),
            ),
            ProjectsShell(
              showBottomNav: false,
              initialTab: _index == 2 ? 1 : 0,
              onMenuPressed: _openDrawer,
            ),
            RequestsScreen(onMenuPressed: _openDrawer),
            ProfileScreen(onMenuPressed: _openDrawer),
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
              brandMark: d.brandMark,
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
    this.icon,
    this.brandMark = false,
    required this.route,
    required this.owner,
    this.prominent = false,
    this.showBadge = false,
  }) : assert(icon != null || brandMark, 'Provide an icon or brandMark');

  final String label;
  final String title;
  final String eyebrow;
  final IconData? icon;
  final bool brandMark;
  final String route;
  final String owner;
  final bool prominent;
  final bool showBadge;
}
