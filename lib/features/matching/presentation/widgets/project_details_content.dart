import 'package:flutter/material.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_avatar.dart';
import '../../../../core/widgets/ds_button.dart';
import '../../../../core/widgets/ds_card.dart';
import '../../../../core/widgets/ds_score_meter.dart';
import '../../domain/entities/match_item.dart';
import '../../../../core/utils/project_details_utils.dart';
import 'project_details_information.dart';

class ProjectDetailsContent extends StatelessWidget {
  const ProjectDetailsContent({
    super.key,
    required this.match,
    required this.currentUserSkills,
    required this.onPreviewWorkspace,
  });

  final MatchItem match;
  final List<String> currentUserSkills;
  final VoidCallback onPreviewWorkspace;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) => Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              // Clearance for floating CollaborationAction (md + button + lg).
              AppSpacing.md + AppSpacing.buttonHeight + AppSpacing.lg,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth > 560
                      ? 560
                      : constraints.maxWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProjectIdentity(match: match),
                    const SizedBox(height: AppSpacing.xl),
                    MatchSummary(
                      match: match,
                      currentUserSkills: currentUserSkills,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const DetailsSectionTitle('About'),
                    const SizedBox(height: AppSpacing.sm),
                    ProjectAbout(description: match.description),
                    const SizedBox(height: AppSpacing.xl),
                    const DetailsSectionTitle('Skills needed'),
                    const SizedBox(height: AppSpacing.sm),
                    ProjectSkills(
                      skills: match.neededSkills,
                      currentUserSkills: currentUserSkills,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    MatchFacts(match: match),
                    if (match.githubUrl.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xl),
                      DsButton(
                        label: 'Preview project workspace',
                        icon: AppIcons.forward,
                        variant: DsButtonVariant.quiet,
                        onPressed: onPreviewWorkspace,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProjectIdentity extends StatelessWidget {
  const ProjectIdentity({super.key, required this.match});

  final MatchItem match;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DsProjectAvatar(label: projectInitials(match.projectName), large: true),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                match.projectName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (match.githubUrl.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  repositoryHost(match.githubUrl),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: context.ds.textMuted),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class MatchSummary extends StatelessWidget {
  const MatchSummary({
    super.key,
    required this.match,
    required this.currentUserSkills,
  });

  final MatchItem match;
  final List<String> currentUserSkills;

  @override
  Widget build(BuildContext context) {
    final skillCoverage = skillCoverageFor(
      neededSkills: match.neededSkills,
      currentUserSkills: currentUserSkills,
    );
    return DsCard(
      borderRadius: AppSpacing.radiusXl,
      child: Column(
        children: [
          Row(
            children: [
              DsScoreRing(score: match.score, size: 88),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fitLabelForScore(match.score),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (match.reason.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        match.reason,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.ds.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ScoreLine(label: 'Overall match', score: match.score),
          if (skillCoverage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            ScoreLine(label: 'Skill coverage', score: skillCoverage),
          ],
        ],
      ),
    );
  }
}

class ScoreLine extends StatelessWidget {
  const ScoreLine({super.key, required this.label, required this.score});

  final String label;
  final double score;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: context.ds.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: DsScoreMeter(score: score, height: 7, animate: false)),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '${score.round()}%',
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: context.ds.textMuted),
        ),
      ],
    );
  }
}
