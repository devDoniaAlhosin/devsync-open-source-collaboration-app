import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ds_item_enter.dart';
import '../../../../core/widgets/ds_page_header.dart';
import '../../../requests/presentation/collaboration_request_flow.dart';
import '../../domain/entities/project.dart';
import '../../project_layout.dart';
import '../cubit/projects_cubit.dart';
import '../widgets/discover_project_card.dart';
import '../widgets/project_filter_bar.dart';
import '../widgets/project_search_field.dart';

class DiscoverProjectsScreen extends StatefulWidget {
  const DiscoverProjectsScreen({required this.onOpenProject, super.key});

  final ValueChanged<Project> onOpenProject;

  @override
  State<DiscoverProjectsScreen> createState() => _DiscoverProjectsScreenState();
}

class _DiscoverProjectsScreenState extends State<DiscoverProjectsScreen> {
  final _searchController = TextEditingController();
  ProjectFilter _filter = ProjectFilter.forYou;
  String _query = '';
  bool _hasEntered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProjectsCubit>().load(silent: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Project> _visibleProjects(List<Project> source) {
    final tokens = _query
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList(growable: false);

    final projects = source.where((project) {
      if (project.isOwner) {
        return false;
      }
      if (_filter == ProjectFilter.beginnerFriendly &&
          !project.isBeginnerFriendly) {
        return false;
      }
      if (tokens.isEmpty) {
        return true;
      }
      final searchable = [
        project.title,
        project.description,
        project.githubUrl,
        project.cleanGithubUrl,
        project.ownerName,
        ...project.techStack,
      ].join(' ').toLowerCase();
      return tokens.every(searchable.contains);
    }).toList();

    switch (_filter) {
      case ProjectFilter.forYou:
        projects.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
      case ProjectFilter.trending:
        projects.sort((a, b) => b.viewsCount.compareTo(a.viewsCount));
      case ProjectFilter.newest:
        projects.sort((a, b) {
          final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final byDate = bDate.compareTo(aDate);
          return byDate != 0 ? byDate : b.id.compareTo(a.id);
        });
      case ProjectFilter.beginnerFriendly:
        projects.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
    }

    return projects;
  }

  Future<void> _requestToJoin(Project project) async {
    final sent = await presentCollaborationRequestFlow(
      context,
      projectName: project.title,
      maintainerName: project.ownerName.isEmpty
          ? 'the maintainer'
          : project.ownerName,
      initials: project.initials,
      projectId: project.id,
      ownerId: project.ownerId,
      matchPercent: project.matchPercentage,
    );
    if (!mounted || !sent) return;

    context.read<ProjectsCubit>().markRequestPending(project.id);
  }

  void _markEntered() {
    if (!_hasEntered) _hasEntered = true;
  }

  Widget _listItem(Project project, int index) {
    final card = KeyedSubtree(key: ValueKey(project.id), child: _card(project));
    if (!_hasEntered) {
      return DsItemEnter(
        key: ValueKey('enter-${project.id}'),
        index: index,
        child: card,
      );
    }
    return card;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectsCubit, ProjectsState>(
      builder: (context, state) {
        final source = state is ProjectsLoaded
            ? state.discoverProjects
            : const <Project>[];
        final projects = _visibleProjects(source);
        final gutter = ProjectLayout.gutterFor(MediaQuery.sizeOf(context).width);
        final bottomPad =
            ProjectLayout.bottomNavSpace +
            MediaQuery.viewInsetsOf(context).bottom;

        return CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(gutter, 18, gutter, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DsPageHeader(
                      style: DsPageHeaderStyle.page,
                      title: 'Discover',
                      eyebrow: '${projects.length} listed',
                      trailing: Container(
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
                              AppIcons.sparkle,
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
                    ),
                    const SizedBox(height: 16),
                    ProjectSearchField(
                      controller: _searchController,
                      onChanged: (value) => setState(() {
                        _markEntered();
                        _query = value;
                      }),
                    ),
                    const SizedBox(height: 14),
                    ProjectFilterBar(
                      selected: _filter,
                      onSelected: (filter) => setState(() {
                        _markEntered();
                        _filter = filter;
                      }),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            if (projects.isEmpty)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(gutter, 0, gutter, bottomPad),
                sliver: SliverToBoxAdapter(
                  child: _EmptyDiscoverState(
                    hasQuery: _query.trim().isNotEmpty,
                    onReset: () {
                      _searchController.clear();
                      setState(() {
                        _query = '';
                        _filter = ProjectFilter.forYou;
                      });
                    },
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(gutter, 0, gutter, bottomPad),
                sliver: SliverList.separated(
                  itemCount: projects.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    return _listItem(projects[index], index);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _card(Project project) {
    return DiscoverProjectCard(
      project: project,
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
            child: const Icon(AppIcons.search, color: AppColors.teal),
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
            child: Text(
              'Clear filters',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppColors.teal),
            ),
          ),
        ],
      ),
    );
  }
}
