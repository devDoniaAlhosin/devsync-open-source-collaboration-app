import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/project_model.dart';
import '../project_layout.dart';
import '../widgets/discover_project_card.dart';
import '../widgets/project_filter_bar.dart';
import '../widgets/project_search_field.dart';

class DiscoverProjectsScreen extends StatefulWidget {
  const DiscoverProjectsScreen({
    required this.projects,
    required this.onOpenProject,
    super.key,
  });

  final List<ProjectModel> projects;
  final ValueChanged<ProjectModel> onOpenProject;

  @override
  State<DiscoverProjectsScreen> createState() => _DiscoverProjectsScreenState();
}

class _DiscoverProjectsScreenState extends State<DiscoverProjectsScreen> {
  final _searchController = TextEditingController();
  final _requested = <String>{};
  ProjectFilter _filter = ProjectFilter.forYou;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProjectModel> get _visibleProjects {
    final query = _query.trim().toLowerCase();
    final projects = widget.projects.where((project) {
      if (project.isOwner) {
        return false;
      }
      if (_filter == ProjectFilter.beginnerFriendly &&
          !project.isBeginnerFriendly) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final searchable = [
        project.title,
        project.description,
        project.githubUrl,
        ...project.techStack,
      ].join(' ').toLowerCase();
      return searchable.contains(query);
    }).toList();

    switch (_filter) {
      case ProjectFilter.forYou:
        projects.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
      case ProjectFilter.trending:
        projects.sort((a, b) => b.viewsCount.compareTo(a.viewsCount));
      case ProjectFilter.newest:
        projects.sort((a, b) => b.id.compareTo(a.id));
      case ProjectFilter.beginnerFriendly:
        projects.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
    }

    return projects;
  }

  void _requestToJoin(ProjectModel project) {
    setState(() => _requested.add(project.id));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Request sent to ${project.title}.'),
          action: SnackBarAction(
            label: 'Undo',
            textColor: AppColors.teal,
            onPressed: () {
              if (mounted) {
                setState(() => _requested.remove(project.id));
              }
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final projects = _visibleProjects;

    return LayoutBuilder(
      builder: (context, constraints) {
        final gutter = ProjectLayout.gutterFor(constraints.maxWidth);
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            gutter,
            18,
            gutter,
            ProjectLayout.bottomNavSpace,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: ProjectLayout.maxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProjectSearchField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  const SizedBox(height: 14),
                  ProjectFilterBar(
                    selected: _filter,
                    onSelected: (filter) => setState(() => _filter = filter),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${projects.length} listed',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: context.ds.textMuted,
                                    fontSize: 11.5,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _filter == ProjectFilter.forYou
                                  ? 'Projects for you'
                                  : _filter.label,
                              style: Theme.of(
                                context,
                              ).textTheme.displaySmall?.copyWith(fontSize: 28),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: context.ds.surface.withValues(alpha: 0.58),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: context.ds.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              size: 13,
                              color: AppColors.teal,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Smart match',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    fontSize: 11,
                                    color: context.ds.textPrimary,
                                    letterSpacing: 0,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (projects.isEmpty)
                    _EmptyDiscoverState(
                      hasQuery: _query.trim().isNotEmpty,
                      onReset: () {
                        _searchController.clear();
                        setState(() {
                          _query = '';
                          _filter = ProjectFilter.forYou;
                        });
                      },
                    )
                  else
                    LayoutBuilder(
                      builder: (context, listConstraints) {
                        if (listConstraints.maxWidth >= 860) {
                          final cardWidth = (listConstraints.maxWidth - 16) / 2;
                          return Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              for (final project in projects)
                                SizedBox(
                                  width: cardWidth,
                                  child: _card(project),
                                ),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            for (final project in projects) ...[
                              _card(project),
                              if (project != projects.last)
                                const SizedBox(height: 14),
                            ],
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _card(ProjectModel project) {
    return DiscoverProjectCard(
      project: project,
      requested: _requested.contains(project.id),
      onTap: () => widget.onOpenProject(project),
      onRequest: () => _requestToJoin(project),
    );
  }
}

class _EmptyDiscoverState extends StatelessWidget {
  const _EmptyDiscoverState({required this.hasQuery, required this.onReset});

  final bool hasQuery;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 44),
      decoration: BoxDecoration(
        color: context.ds.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.ds.border),
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: context.ds.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.ds.border),
            ),
            child: const Icon(
              Icons.travel_explore_rounded,
              color: AppColors.teal,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No projects found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            hasQuery
                ? 'Try a different title, skill or repository.'
                : 'There are no projects in this filter yet.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: context.ds.textMuted),
          ),
          const SizedBox(height: 18),
          TextButton(
            onPressed: onReset,
            child: const Text(
              'Clear filters',
              style: TextStyle(color: AppColors.teal),
            ),
          ),
        ],
      ),
    );
  }
}
