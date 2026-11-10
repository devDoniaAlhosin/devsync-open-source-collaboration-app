import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ds_app_bar.dart';
import '../../../../core/widgets/ds_icon_button.dart';
import '../../../../core/widgets/ds_page_fade.dart';
import '../../../requests/presentation/collaboration_request_flow.dart';
import '../../../requests/presentation/widgets/request_join_sheet.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_stats.dart';
import '../../project_layout.dart';
import '../cubit/projects_cubit.dart';
import '../project_formatters.dart';
import '../widgets/match_gauge.dart';
import '../widgets/metric_tile.dart';
import '../widgets/project_action_button.dart';
import '../widgets/project_avatar.dart';
import '../widgets/project_background.dart';
import '../widgets/project_identity.dart';
import '../widgets/skill_alignment_bar.dart';
import '../widgets/tech_tag.dart';

class ProjectDetailsScreen extends StatelessWidget {
  const ProjectDetailsScreen({required this.project, this.stats, super.key});

  final Project project;

  /// Optional preloaded stats (e.g. from a cached card). When null the cubit
  /// loads them, including live GitHub metrics.
  final ProjectStats? stats;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ProjectsCubit>()..loadProject(project, initialStats: stats),
      child: _ProjectDetailsView(project: project),
    );
  }
}

class _ProjectDetailsView extends StatefulWidget {
  const _ProjectDetailsView({required this.project});

  final Project project;

  @override
  State<_ProjectDetailsView> createState() => _ProjectDetailsViewState();
}

class _ProjectDetailsViewState extends State<_ProjectDetailsView> {
  bool _requesting = false;

  Future<void> _requestCollaboration(
    Project project,
    ProjectStats stats,
  ) async {
    if (_requesting) return;
    setState(() => _requesting = true);

    RequestJoinResult? details;
    final sent = await presentCollaborationRequestFlow(
      context,
      projectName: project.title,
      maintainerName: stats.ownerName,
      initials: project.initials,
      matchPercent: project.matchPercentage,
      onSent: (result) => details = result,
    );
    if (!mounted) return;

    if (!sent) {
      setState(() => _requesting = false);
      return;
    }

    final error = await context.read<ProjectsCubit>().requestToCollaborate(
      project,
      message: details?.message,
    );
    if (!mounted) return;

    setState(() => _requesting = false);
    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void _previewWorkspace() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Project workspace preview is coming next.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectsCubit, ProjectsState>(
      listenWhen: (previous, current) =>
          current is ProjectOperationSuccess &&
          (previous is! ProjectOperationSuccess ||
              previous.operationId != current.operationId),
      listener: (context, state) {
        if (state is ProjectOperationSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: BlocBuilder<ProjectsCubit, ProjectsState>(
        builder: (context, state) {
          final loaded = state is ProjectsLoaded ? state : null;
          final project =
              loaded?.projectById(widget.project.id) ?? widget.project;
          final stats = loaded?.statsFor(widget.project.id);

          final Widget body;
          if (state is ProjectsFailure) {
            body = _DetailsError(
              message: state.message,
              onRetry: () =>
                  context.read<ProjectsCubit>().loadProject(widget.project),
            );
          } else if (stats != null) {
            body = _buildContent(project, stats);
          } else {
            body = const Center(child: CircularProgressIndicator());
          }

          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: DsAppBar(
              title: 'Project details',
              eyebrow: 'WORKSPACE',
              onNotifications: () {
                Navigator.of(context).pushNamed(AppRoutes.notifications);
              },
            ),
            body: ProjectBackground(child: body),
            bottomNavigationBar: _DetailsActionBar(
              requested: project.hasPendingRequest,
              isOwner: project.isOwner,
              isLoading: _requesting,
              onRequest: stats == null
                  ? null
                  : () => _requestCollaboration(project, stats),
              onClose: () => Navigator.of(context).maybePop(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(Project project, ProjectStats stats) {
    return DsPageFade(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gutter = ProjectLayout.gutterFor(constraints.maxWidth);
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(gutter, 20, gutter, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: ProjectLayout.detailsWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProjectIdentity(project: project, stats: stats),
                    const SizedBox(height: 20),
                    _buildMatchCard(project, stats),
                    const SizedBox(height: 26),
                    _SectionHeading(
                      title: 'About',
                      trailing: Text(
                        'Open source',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: AppColors.teal,
                              fontSize: 11,
                              letterSpacing: 0,
                            ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      project.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.ds.textPrimary.withValues(alpha: 0.87),
                        height: 1.65,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 26),
                    _buildSkills(project, stats),
                    const SizedBox(height: 24),
                    _buildRepoMetrics(stats),
                    const SizedBox(height: 20),
                    _buildOwnerCard(stats),
                    const SizedBox(height: 18),
                    ProjectActionButton(
                      label: 'Preview project workspace',
                      trailingIcon: AppIcons.forward,
                      variant: ProjectActionButtonVariant.secondary,
                      onPressed: _previewWorkspace,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMatchCard(Project project, ProjectStats stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gaugeSize = constraints.maxWidth < 310 ? 84.0 : 98.0;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.ds.surface.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.ds.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MatchGauge(
                    percentage: project.matchPercentage,
                    size: gaugeSize,
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _fitLabel(project.matchPercentage),
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(fontSize: 21),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          stats.matchSummary,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: context.ds.textMuted,
                                fontSize: 12.5,
                                height: 1.5,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              for (final alignment in stats.alignments)
                SkillAlignmentBar(
                  label: alignment.label,
                  score: alignment.score,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkills(Project project, ProjectStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(title: 'Skills needed'),
        const SizedBox(height: 11),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final skill in project.techStack)
              TechTag(
                label: skill,
                selected: stats.matchedSkills.contains(skill),
                showCheck: stats.matchedSkills.contains(skill),
              ),
          ],
        ),
        const SizedBox(height: 9),
        Text(
          'Teal chips are skills you already list.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.ds.textMuted,
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }

  Widget _buildRepoMetrics(ProjectStats stats) {
    return Row(
      children: [
        Expanded(
          child: MetricTile(value: formatNumber(stats.stars), label: 'Stars'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: MetricTile(
            value: '${stats.contributors}',
            label: 'Contributors',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: MetricTile(value: '${stats.openTasks}', label: 'Open tasks'),
        ),
      ],
    );
  }

  Widget _buildOwnerCard(ProjectStats stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.ds.surfaceAlt.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.ds.border),
      ),
      child: Row(
        children: [
          ProjectAvatar(initials: initialsFromTitle(stats.ownerName), size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stats.ownerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: context.ds.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stats.ownerResponseTime,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.ds.textMuted,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(AppIcons.clock, size: 19, color: context.ds.textMuted),
        ],
      ),
    );
  }

  String _fitLabel(int percentage) {
    if (percentage >= 90) {
      return 'Strong fit';
    }
    if (percentage >= 75) {
      return 'Good fit';
    }
    return 'Worth exploring';
  }
}

class _DetailsError extends StatelessWidget {
  const _DetailsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'Retry',
                style: TextStyle(color: AppColors.teal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontSize: 20),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _DetailsActionBar extends StatelessWidget {
  const _DetailsActionBar({
    required this.requested,
    required this.isOwner,
    required this.isLoading,
    required this.onRequest,
    required this.onClose,
  });

  final bool requested;
  final bool isOwner;
  final bool isLoading;
  final VoidCallback? onRequest;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final disabled = requested || isOwner || isLoading;

    return Material(
      color: context.ds.background,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: SizedBox(
          height: 56,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: ProjectLayout.detailsWidth,
              ),
              child: Row(
                children: [
                  DsIconButton(
                    icon: AppIcons.close,
                    onPressed: onClose,
                    tooltip: 'Close project',
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ProjectActionButton(
                      label: isOwner
                          ? 'You own this project'
                          : requested
                          ? 'Request sent'
                          : 'Request to collaborate',
                      icon: requested
                          ? AppIcons.success
                          : (isOwner ? AppIcons.projects : null),
                      variant: disabled
                          ? ProjectActionButtonVariant.secondary
                          : ProjectActionButtonVariant.primary,
                      isLoading: isLoading,
                      onPressed: disabled ? null : onRequest,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
