import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ds_icon_button.dart';
import '../data/project_repository.dart';
import '../models/project_model.dart';
import '../widgets/devsync_bottom_nav.dart';
import '../widgets/project_background.dart';
import '../widgets/project_top_bar.dart';
import 'add_or_edit_project_screen.dart';
import 'discover_projects_screen.dart';
import 'my_projects_screen.dart';

class ProjectsShell extends StatefulWidget {
  const ProjectsShell({super.key});

  @override
  State<ProjectsShell> createState() => _ProjectsShellState();
}

class _ProjectsShellState extends State<ProjectsShell> {
  final List<ProjectModel> _projects = ProjectRepository.projects();
  int _selectedIndex = 0;

  String get _title {
    switch (_selectedIndex) {
      case 0:
        return 'Projects';
      case 1:
        return 'My projects';
      case 2:
        return 'Inbox';
      default:
        return 'Profile';
    }
  }

  void _openProject(ProjectModel project) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.projectDetail, arguments: project);
  }

  Future<void> _openEditor([ProjectModel? initialProject]) async {
    final wasEditing = initialProject != null;
    final result = await Navigator.of(context).push<ProjectModel>(
      MaterialPageRoute<ProjectModel>(
        builder: (context) =>
            AddOrEditProjectScreen(initialProject: initialProject),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      final existingIndex = _projects.indexWhere(
        (project) => project.id == result.id,
      );
      if (existingIndex == -1) {
        _projects.insert(0, result);
        _selectedIndex = 1;
      } else {
        _projects[existingIndex] = result;
      }
    });

    _showSnackBar(
      wasEditing ? 'Project updated.' : 'Project published to Discover.',
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showMenu() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: context.ds.surfaceAlt,
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(color: context.ds.border),
                        ),
                        child: const Icon(
                          Icons.terminal_rounded,
                          color: AppColors.teal,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DEVSYNC',
                            style: Theme.of(context).textTheme.labelSmall
                                .copyWith(color: AppColors.teal),
                          ),
                          Text(
                            'Build in the open.',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _MenuTile(
                  icon: Icons.auto_awesome_outlined,
                  label: 'Discover projects',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    setState(() => _selectedIndex = 0);
                  },
                ),
                _MenuTile(
                  icon: Icons.folder_outlined,
                  label: 'My projects',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    setState(() => _selectedIndex = 1);
                  },
                ),
                _MenuTile(
                  icon: Icons.add_rounded,
                  label: 'List a project',
                  accent: true,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _openEditor();
                  },
                ),
                const Divider(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'An atmospheric workspace for open-source builders.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.ds.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNotifications() {
    _showSnackBar('You are all caught up.');
  }

  @override
  Widget build(BuildContext context) {
    final topBarActions = [
      DsIconButton(
        icon: Icons.notifications_none_rounded,
        tooltip: 'Notifications',
        onPressed: _showNotifications,
      ),
      DsIconButton(
        icon: Icons.arrow_outward_rounded,
        tooltip: 'List a project',
        active: true,
        onPressed: _openEditor,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: ProjectBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              ProjectTopBar(
                eyebrow: 'DEVSYNC',
                title: _title,
                onLeadingPressed: _showMenu,
                actions: topBarActions,
              ),
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    DiscoverProjectsScreen(
                      projects: _projects,
                      onOpenProject: _openProject,
                    ),
                    MyProjectsScreen(
                      projects: _projects,
                      onOpenProject: _openProject,
                      onEditProject: (project) => _openEditor(project),
                      onCreateProject: _openEditor,
                    ),
                    const _PlaceholderTab(
                      icon: Icons.inbox_outlined,
                      eyebrow: 'WORKSPACE',
                      title: 'Your inbox is clear',
                      description:
                          'Collaboration requests and project invites will '
                          'appear here.',
                    ),
                    const _PlaceholderTab(
                      icon: Icons.person_outline_rounded,
                      eyebrow: 'DEVELOPER PROFILE',
                      title: 'Build your signal',
                      description:
                          'Showcase your skills, contributions and the '
                          'projects you care about.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: DevSyncBottomNav(
        selectedIndex: _selectedIndex,
        onSelected: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          child: Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: accent ? AppColors.teal : context.ds.textMuted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: accent ? AppColors.teal : context.ds.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: accent
                    ? AppColors.teal
                    : context.ds.textMuted.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: context.ds.surface.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: context.ds.border),
                ),
                child: Icon(icon, size: 30, color: AppColors.teal),
              ),
              const SizedBox(height: 20),
              Text(
                eyebrow,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall.copyWith(color: AppColors.teal),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.ds.textMuted,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 46),
            ],
          ),
        ),
      ),
    );
  }
}
