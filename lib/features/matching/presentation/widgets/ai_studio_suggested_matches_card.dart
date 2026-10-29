import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_card.dart';
import '../../../../core/widgets/ds_score_meter.dart';
import '../../domain/entities/match_item.dart';

/// Card presenting ranked matches with AI scoring bars and action links.
class AiStudioSuggestedMatchesCard extends StatelessWidget {
  const AiStudioSuggestedMatchesCard({
    super.key,
    required this.matches,
    required this.onViewProjectDetails,
  });

  final List<MatchItem> matches;
  final ValueChanged<MatchItem> onViewProjectDetails;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return DsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Suggested\nmatches',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Text(
                  '${matches.length} matches',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onTeal,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (matches.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: Text(
                  'No matches generated yet. Tap "Generate matches" above.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: ds.textMuted),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            for (var i = 0; i < matches.length; i++) ...[
              if (i > 0) Divider(height: AppSpacing.xxl, color: ds.border),
              _MatchRow(
                match: matches[i],
                onTap: () => onViewProjectDetails(matches[i]),
              ),
            ],
        ],
      ),
    );
  }
}

class _MatchRow extends StatelessWidget {
  const _MatchRow({required this.match, required this.onTap});

  final MatchItem match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                match.projectName,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '${match.score.round()}%',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.teal,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          match.description,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: ds.textMuted, height: 1.5),
        ),
        const SizedBox(height: AppSpacing.sm),
        DsScoreMeter(score: match.score, height: 6, animate: true),
        const SizedBox(height: AppSpacing.xs),
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View project details →',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
