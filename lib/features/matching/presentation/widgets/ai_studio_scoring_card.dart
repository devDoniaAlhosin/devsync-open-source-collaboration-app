import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_card.dart';
import '../../domain/entities/match_item.dart';

class AiStudioScoringCard extends StatelessWidget {
  const AiStudioScoringCard({
    super.key,
    required this.onExploreAnalytics,
    this.source,
  });

  final VoidCallback onExploreAnalytics;
  final MatchSource? source;

  @override
  Widget build(BuildContext context) {
    final isFallback = source == MatchSource.fallback;

    return DsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How scoring works',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isFallback
                ? 'Heuristic skill matching calculates deterministic overlap between your declared skills and project requirements.'
                : 'Recommendations are scored by the AI matching service based on your skills, GitHub history, and prompt preferences.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: context.ds.textMuted),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: context.ds.surfaceAlt,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(color: context.ds.border),
            ),
            child: Text(
              isFallback
                  ? 'Scoring method: Heuristic (Deterministic Fallback)'
                  : 'Scoring method: AI Model',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isFallback ? context.ds.textMuted : AppColors.teal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: onExploreAnalytics,
            child: const Text('Explore match insights'),
          ),
        ],
      ),
    );
  }
}
