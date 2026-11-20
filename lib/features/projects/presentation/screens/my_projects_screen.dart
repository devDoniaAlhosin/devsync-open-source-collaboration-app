import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_button.dart';
import '../../../../core/widgets/ds_icon.dart';
import '../../../../core/widgets/ds_item_enter.dart';
import '../../../../core/widgets/ds_page_header.dart';
import '../../../../core/widgets/ds_toast.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_stats.dart';
import '../../project_layout.dart';
import '../cubit/projects_cubit.dart';
import '../widgets/project_action_button.dart';
import '../widgets/metric_tile.dart';
import '../widgets/owner_project_card.dart';

class MyProjectsScreen extends StatelessWidget {
  const MyProjectsScreen({
    required this.onOpenProject,
    required this.onEditProject,
    required this.onCreateProject,
    super.key,
  });

  final ValueChanged<Project> onOpenProject;
  final ValueChanged<Project> onEditProject;
  final VoidCallback onCreateProject;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectsCubit, ProjectsState>(
      builder: (context, state) {
        final loaded = state is ProjectsLoaded ? state : null;
        final owned = loaded?.ownedProjects ?? const <Project>[];
        final stats = loaded?.stats ?? const <String, ProjectStats>{};
        final joinedContributors = loaded?.joinedContributors ?? 0;

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
                      DsPageHeader(
                        style: DsPageHeaderStyle.page,
                        title: 'Projects',
                        eyebrow: '${owned.length} listed',
                      ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: MetricTile(
                                value: '$views',
                                label: 'Views',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: MetricTile(
                                value: '$requests',
                                label: 'Requests',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: MetricTile(
                                value: '$joinedContributors',
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
                                final cardWidth =
                                    (listConstraints.maxWidth - 16) / 2;
                                return Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: [
                                    for (final project in owned)
                                      SizedBox(
                                        width: cardWidth,
                                        child: _card(context, project, stats),
                                      ),
                                  ],
                                );
                              }
                              return Column(
                                children: [
                                  for (var i = 0; i < owned.length; i++) ...[
                                    if (i > 0) const SizedBox(height: 14),
                                    DsItemEnter(
                                      index: i,
                                      child: _card(context, owned[i], stats),
                                    ),
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
      },
    );
  }

  Widget _card(
    BuildContext context,
    Project project,
    Map<String, ProjectStats> stats,
  ) {
    return OwnerProjectCard(
      project: project,
      weeklyViews:
          stats[project.id]?.weeklyViews ?? const [0, 0, 0, 0, 0, 0, 0],
      onTap: () => onOpenProject(project),
      onEdit: () => onEditProject(project),
      onDelete: () => _confirmDelete(context, project),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Project project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x9E050F0E),
      builder: (_) => _DeleteProjectDialog(title: project.title),
    );
    if (confirmed != true || !context.mounted) return;

    final error = await context.read<ProjectsCubit>().delete(project.id);
    if (!context.mounted) return;
    if (error != null) {
      showDsToast(context, error, tone: DsToastTone.error);
    }
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
          const Icon(AppIcons.projects, size: 36, color: AppColors.teal),
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
            icon: AppIcons.plus,
            expand: false,
            compact: true,
            onPressed: onCreate,
          ),
        ],
      ),
    );
  }
}

class _DeleteProjectDialog extends StatelessWidget {
  const _DeleteProjectDialog({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: ds.background,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMatch),
        side: BorderSide(color: ds.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: ds.danger,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              alignment: Alignment.center,
              child: DsIcon(AppIcons.trash, color: AppColors.forest),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Delete this project?',
              style: textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '"$title" will be removed from Discover. This can’t be undone.',
              style: textTheme.bodyMedium?.copyWith(color: ds.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            DsButton(
              label: 'Delete project',
              variant: DsButtonVariant.dangerFilled,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: AppSpacing.sm),
            DsButton(
              label: 'Keep project',
              variant: DsButtonVariant.quiet,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}

