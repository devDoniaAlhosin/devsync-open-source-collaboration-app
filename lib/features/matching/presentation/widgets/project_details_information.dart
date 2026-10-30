import 'package:flutter/material.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_card.dart';
import '../../../../core/widgets/ds_chip.dart';
import '../../../../core/widgets/ds_icon.dart';
import '../../domain/entities/match_item.dart';
import '../../../../core/utils/project_details_utils.dart';

class DetailsSectionTitle extends StatelessWidget {
  const DetailsSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
  );
}

class ProjectAbout extends StatelessWidget {
  const ProjectAbout({super.key, required this.description});

  final String description;

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

class ProjectSkills extends StatelessWidget {
  const ProjectSkills({
    super.key,
    required this.skills,
    required this.currentUserSkills,
  });

  final List<String> skills;
  final List<String> currentUserSkills;

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

    final userSkills = normalizedSkills(currentUserSkills);
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
              _skillChip(
                skill,
                matched: userSkills.contains(skill.trim().toLowerCase()),
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

  Widget _skillChip(String skill, {required bool matched}) {
    return DsChip(
      label: skill,
      variant: matched ? DsChipVariant.selected : DsChipVariant.muted,
      leading: matched
          ? const DsIcon(
              AppIcons.success,
              size: 14,
              color: AppColors.onTeal,
            )
          : null,
    );
  }
}

class MatchFacts extends StatelessWidget {
  const MatchFacts({super.key, required this.match});

  final MatchItem match;

  @override
  Widget build(BuildContext context) {
    final facts = [
      MatchFact('${match.score.round()}%', 'Match score'),
      MatchFact('${match.neededSkills.length}', 'Skills needed'),
      MatchFact(match.isFallback ? 'Skills' : 'AI', 'Match source'),
    ];
    return Row(
      children: [
        for (var index = 0; index < facts.length; index++) ...[
          Expanded(child: MatchFactCard(fact: facts[index])),
          if (index < facts.length - 1) const SizedBox(width: AppSpacing.md),
        ],
      ],
    );
  }
}

class MatchFact {
  const MatchFact(this.value, this.label);

  final String value;
  final String label;
}

class MatchFactCard extends StatelessWidget {
  const MatchFactCard({super.key, required this.fact});

  final MatchFact fact;

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
              color: Theme.of(context).colorScheme.primary,
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
