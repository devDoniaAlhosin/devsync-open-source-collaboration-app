import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_avatar.dart';
import '../../../../core/widgets/ds_button.dart';
import '../../../../core/widgets/ds_card.dart';
import '../../../../core/widgets/ds_chip.dart';
import '../../../../core/widgets/ds_empty_state.dart';
import '../../../../core/widgets/ds_icon_button.dart';
import '../../../../core/widgets/ds_score_meter.dart';
import '../../domain/entities/match_item.dart';

String _fitLabel(double score) {
  if (score >= 85) return 'Strong fit';
  if (score >= 65) return 'Good fit';
  return 'Potential fit';
}

String _initialsFor(String projectName) => projectName
    .split(RegExp(r'[/\s-]'))
    .where((part) => part.isNotEmpty)
    .take(2)
    .map((part) => part[0])
    .join();

String _repositoryHost(String value) {
  final uri = Uri.tryParse(value);
  return uri?.host.isNotEmpty == true ? uri!.host : value;
}

double? _skillCoverage(List<String> neededSkills, List<String> userSkills) {
  if (neededSkills.isEmpty) return null;
  final normalizedSkills = userSkills
      .map((skill) => skill.trim().toLowerCase())
      .toSet();
  final matches = neededSkills
      .where((skill) => normalizedSkills.contains(skill.trim().toLowerCase()))
      .length;
  return matches / neededSkills.length * 100;
}

class ProjectDetailsArguments {
  final MatchItem match;

  final List<String> currentUserSkills;
  const ProjectDetailsArguments({
    required this.match,
    this.currentUserSkills = const [],
  });
}

class ProjectDetailsScreen extends StatelessWidget {
  final ProjectDetailsArguments? arguments;

  const ProjectDetailsScreen({super.key, this.arguments});

  @override
  Widget build(BuildContext context) {
    final details = arguments;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        leadingWidth: 68,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xl),
          child: DsIconButton(
            icon: AppIcons.back,
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        titleSpacing: 0,
        title: const _DetailsHeader(),
      ),
      body: details == null
          ? const DsEmptyState(
              icon: AppIcons.projects,
              title: 'No project selected',
              message:
                  'Open project details from a match to see its workspace.',
            )
          : _ProjectDetailsBody(arguments: details),
      bottomNavigationBar: details == null
          ? null
          : _CollaborationAction(match: details.match),
    );
  }
}

class _AboutText extends StatelessWidget {
  final String description;

  const _AboutText({required this.description});

  @override
  Widget build(BuildContext context) {
    final text = description.trim();
    return Text(
      text.isEmpty ? 'No project description is available.' : text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: text.isEmpty ? context.ds.textMuted : context.ds.textPrimary,
      ),
    );
  }
}

class _CollaborationAction extends StatelessWidget {
  final MatchItem match;

  const _CollaborationAction({required this.match});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.ds.background,
        border: Border(top: BorderSide(color: context.ds.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: DsButton(
            label: 'Request to collaborate',
            icon: AppIcons.requests,
            onPressed: () => Navigator.of(
              context,
            ).pushNamed(AppRoutes.requests, arguments: match),
          ),
        ),
      ),
    );
  }
}

class _DetailsHeader extends StatelessWidget {
  const _DetailsHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WORKSPACE',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: context.ds.accentText,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          'Project details',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _Fact {
  final String value;

  final String label;
  const _Fact(this.value, this.label);
}

class _FactCard extends StatelessWidget {
  final _Fact fact;

  const _FactCard({required this.fact});

  @override
  Widget build(BuildContext context) {
    return DsCard(
      borderRadius: AppSpacing.radiusLg,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        children: [
          Text(
            fact.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.teal,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            fact.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: context.ds.textMuted),
          ),
        ],
      ),
    );
  }
}

class _MatchFacts extends StatelessWidget {
  final MatchItem match;

  const _MatchFacts({required this.match});

  @override
  Widget build(BuildContext context) {
    final facts = [
      _Fact('${match.score.round()}%', 'Match score'),
      _Fact('${match.neededSkills.length}', 'Skills needed'),
      _Fact(match.isFallback ? 'Skills' : 'AI', 'Match source'),
    ];

    return Row(
      children: [
        for (var index = 0; index < facts.length; index++) ...[
          Expanded(child: _FactCard(fact: facts[index])),
          if (index < facts.length - 1) const SizedBox(width: AppSpacing.md),
        ],
      ],
    );
  }
}

class _MatchSummary extends StatelessWidget {
  final MatchItem match;

  final List<String> currentUserSkills;
  const _MatchSummary({required this.match, required this.currentUserSkills});

  @override
  Widget build(BuildContext context) {
    final skillCoverage = _skillCoverage(match.neededSkills, currentUserSkills);
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
                      _fitLabel(match.score),
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
          _ScoreLine(label: 'Overall match', score: match.score),
          if (skillCoverage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _ScoreLine(label: 'Skill coverage', score: skillCoverage),
          ],
        ],
      ),
    );
  }
}

class _ProjectDetailsBody extends StatelessWidget {
  final ProjectDetailsArguments arguments;

  const _ProjectDetailsBody({required this.arguments});

  @override
  Widget build(BuildContext context) {
    final match = arguments.match;
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) => Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.xxl,
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
                    _ProjectIdentity(match: match),
                    const SizedBox(height: AppSpacing.xl),
                    _MatchSummary(
                      match: match,
                      currentUserSkills: arguments.currentUserSkills,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _SectionTitle('About'),
                    const SizedBox(height: AppSpacing.sm),
                    _AboutText(description: match.description),
                    const SizedBox(height: AppSpacing.xl),
                    _SectionTitle('Skills needed'),
                    const SizedBox(height: AppSpacing.sm),
                    _SkillsNeeded(
                      skills: match.neededSkills,
                      currentUserSkills: arguments.currentUserSkills,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _MatchFacts(match: match),
                    if (match.githubUrl.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xl),
                      DsButton(
                        label: 'Preview project workspace',
                        icon: AppIcons.forward,
                        variant: DsButtonVariant.quiet,
                        onPressed: () => _showWorkspacePreview(context, match),
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

  void _showWorkspacePreview(BuildContext context, MatchItem match) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.ds.surface,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Project workspace',
              style: Theme.of(sheetContext).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              match.githubUrl,
              style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                color: sheetContext.ds.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            DsButton(
              label: 'Copy repository link',
              icon: AppIcons.github,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: match.githubUrl));
                if (!sheetContext.mounted) return;
                Navigator.of(sheetContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Repository link copied')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectIdentity extends StatelessWidget {
  final MatchItem match;

  const _ProjectIdentity({required this.match});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DsProjectAvatar(label: _initialsFor(match.projectName), large: true),
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
                  _repositoryHost(match.githubUrl),
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

class _ScoreLine extends StatelessWidget {
  final String label;

  final double score;
  const _ScoreLine({required this.label, required this.score});

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

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
  );
}

class _SkillsNeeded extends StatelessWidget {
  final List<String> skills;

  final List<String> currentUserSkills;
  const _SkillsNeeded({required this.skills, required this.currentUserSkills});

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) {
      return Text(
        'This project has not listed any required skills.',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: context.ds.textMuted),
      );
    }

    final userSkills = currentUserSkills
        .map((skill) => skill.trim().toLowerCase())
        .toSet();
    final hasMatchedSkill = skills.any(
      (skill) => userSkills.contains(skill.trim().toLowerCase()),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final skill in skills)
              DsChip(
                label: skill,
                variant: userSkills.contains(skill.trim().toLowerCase())
                    ? DsChipVariant.selected
                    : DsChipVariant.muted,
              ),
          ],
        ),
        if (hasMatchedSkill) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Teal chips are already on your profile.',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: context.ds.textMuted),
          ),
        ],
      ],
    );
  }
}
