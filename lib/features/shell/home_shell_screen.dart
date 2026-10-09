import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/ds_card.dart';
import '../../core/widgets/ds_logo.dart';
import '../../core/widgets/ds_section_header.dart';

/// Bottom-nav shell with stub destinations for each feature area.
class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  int _index = 0;

  static const _destinations = [
    _Dest('Feed', Icons.auto_awesome_outlined, AppRoutes.feed, 'Emad'),
    _Dest('Projects', Icons.folder_outlined, AppRoutes.projects, 'Bishay'),
    _Dest('Requests', Icons.handshake_outlined, AppRoutes.requests, 'Yousef'),
    _Dest('Profile', Icons.person_outline, AppRoutes.profile, 'Saga'),
  ];

  @override
  Widget build(BuildContext context) {
    final dest = _destinations[_index];

    return Scaffold(
      appBar: AppBar(
        title: const DsLogo(height: 28),
        actions: [
          IconButton(
            tooltip: 'Design system',
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.designSystem),
            icon: const Icon(Icons.palette_outlined),
          ),
        ],
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
                  Icon(dest.icon, color: AppColors.teal),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Open ${dest.label} screen stub',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.muted),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            DsCard(
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.tasks),
              child: Row(
                children: [
                  const Icon(Icons.view_kanban_outlined, color: AppColors.teal),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Tasks board (if-time · Donia)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.muted),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.line,
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon),
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
