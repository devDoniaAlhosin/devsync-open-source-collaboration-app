import 'package:flutter/material.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_icon.dart';
import 'match_card_skeleton.dart';

/// Reusable loading content whose phase comes from the caller's operation.
class MatchingProgressContent extends StatelessWidget {
  final MatchingProgressPhase phase;

  final int? repositoryCount;
  final int? languageCount;
  final int? projectCount;
  const MatchingProgressContent({
    super.key,
    this.phase = MatchingProgressPhase.readActivity,
    this.repositoryCount,
    this.languageCount,
    this.projectCount,
  }) : assert(repositoryCount == null || repositoryCount >= 0),
       assert(languageCount == null || languageCount >= 0),
       assert(projectCount == null || projectCount >= 0);

  String get _activityDetail {
    final repositories = repositoryCount;
    final languages = languageCount;
    if (repositories == null || languages == null) {
      return 'Public repositories and languages';
    }
    return '$repositories repos, $languages languages';
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = phase == MatchingProgressPhase.complete;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Matching',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: context.ds.textMuted),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isComplete ? 'Your matches are ready' : 'Finding your fit...',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: context.ds.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _ProgressSurface(
            child: Column(
              children: [
                _ProgressStep(
                  title: phase.index > 0
                      ? 'Read your GitHub activity'
                      : 'Reading your GitHub activity',
                  detail: _activityDetail,
                  isComplete: phase.index > 0,
                  isCurrent: phase == MatchingProgressPhase.readActivity,
                ),
                Divider(height: 1, color: context.ds.border),
                _ProgressStep(
                  title: phase.index > 1
                      ? projectCount == null
                            ? 'Compared projects'
                            : 'Compared $projectCount projects'
                      : 'Comparing projects',
                  detail: 'Skills, topics, activity',
                  isComplete: phase.index > 1,
                  isCurrent: phase == MatchingProgressPhase.compareProjects,
                ),
                Divider(height: 1, color: context.ds.border),
                _ProgressStep(
                  title: isComplete
                      ? 'Your reasons are ready'
                      : 'Writing your reasons',
                  detail: isComplete
                      ? 'Ready to explore'
                      : 'Preparing match explanations',
                  isComplete: isComplete,
                  isCurrent: phase == MatchingProgressPhase.writeReasons,
                ),
              ],
            ),
          ),
          if (!isComplete) ...[
            const SizedBox(height: AppSpacing.lg),
            const MatchCardSkeleton(),
          ],
        ],
      ),
    );
  }
}

enum MatchingProgressPhase {
  readActivity,
  compareProjects,
  writeReasons,
  complete,
}

class _ProgressStep extends StatelessWidget {
  final String title;

  final String detail;
  final bool isComplete;
  final bool isCurrent;
  const _ProgressStep({
    required this.title,
    required this.detail,
    required this.isComplete,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final status = isComplete
        ? 'Complete'
        : isCurrent
        ? 'In progress'
        : 'Pending';
    return Semantics(
      label: '$title. $detail. $status',
      liveRegion: isCurrent,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isComplete ? AppColors.teal : context.ds.surfaceAlt,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: isComplete
                  ? const DsIcon(
                      AppIcons.success,
                      color: AppColors.onTeal,
                      size: 20,
                    )
                  : Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? context.ds.border
                            : context.ds.surfaceAlt,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.ds.border),
                      ),
                    ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.ds.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    detail,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.ds.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressSurface extends StatelessWidget {
  final Widget child;

  const _ProgressSurface({required this.child});

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.ds.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: child,
    ),
  );
}
