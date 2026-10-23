import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/project_repository.dart';
import '../models/project_model.dart';
import '../project_layout.dart';
import '../widgets/project_action_button.dart';
import '../widgets/metric_tile.dart';
import '../widgets/owner_project_card.dart';

class MyProjectsScreen extends StatelessWidget {
  const MyProjectsScreen({
    required this.projects,
    required this.onOpenProject,
    required this.onEditProject,
    required this.onCreateProject,
    super.key,
  });

  final List<ProjectModel> projects;
  final ValueChanged<ProjectModel> onOpenProject;
  final ValueChanged<ProjectModel> onEditProject;
  final VoidCallback onCreateProject;

  @override
  Widget build(BuildContext context) {
    final owned = projects.where((project) => project.isOwner).toList();
    final views = owned.fold<int>(
      0,
      (sum, project) => sum + project.viewsCount,
    );
    final requests = owned.fold<int>(
      0,
      (sum, project) => sum + project.requestsCount,
    );

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
                  Text(
                    '${owned.length} listed',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: context.ds.textMuted,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'My projects',
                    style: Theme.of(
                      context,
                    ).textTheme.displaySmall?.copyWith(fontSize: 30),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: MetricTile(value: '$views', label: 'Views'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: MetricTile(
                          value: '$requests',
                          label: 'Requests',
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: MetricTile(
                          value: '${ProjectRepository.joinedContributors}',
                          label: 'Joined',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (owned.isEmpty)
                    _EmptyOwnedState(onCreate: onCreateProject)
                  else
                    LayoutBuilder(
                      builder: (context, listConstraints) {
                        if (listConstraints.maxWidth >= 860) {
                          final cardWidth = (listConstraints.maxWidth - 16) / 2;
                          return Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              for (final project in owned)
                                SizedBox(
                                  width: cardWidth,
                                  child: _card(project),
                                ),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            for (final project in owned) ...[
                              _card(project),
                              if (project != owned.last)
                                const SizedBox(height: 14),
                            ],
                          ],
                        );
                      },
                    ),
                  const SizedBox(height: 18),
                  const _CommunityCallout(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _card(ProjectModel project) {
    return OwnerProjectCard(
      project: project,
      weeklyViews: ProjectRepository.statsFor(project.id).weeklyViews,
      onTap: () => onOpenProject(project),
      onEdit: () => onEditProject(project),
    );
  }
}

class _EmptyOwnedState extends StatelessWidget {
  const _EmptyOwnedState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: context.ds.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.ds.border),
      ),
      child: Column(
        children: [
          Icon(Icons.folder_open_rounded, size: 36, color: AppColors.teal),
          const SizedBox(height: 12),
          Text(
            'Your workspace is quiet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'List an open-source project and find collaborators.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: context.ds.textMuted),
          ),
          const SizedBox(height: 18),
          ProjectActionButton(
            label: 'List a project',
            icon: Icons.add_rounded,
            expand: false,
            compact: true,
            onPressed: onCreate,
          ),
        ],
      ),
    );
  }
}

class _CommunityCallout extends StatelessWidget {
  const _CommunityCallout();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Community events are coming soon.'),
              ),
            );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: context.ds.surfaceAlt.withValues(alpha: 0.56),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.ds.border),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.diversity_3_rounded,
                  color: AppColors.teal,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Community events',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: context.ds.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 17,
                color: context.ds.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
