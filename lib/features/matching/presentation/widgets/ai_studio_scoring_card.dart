import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_card.dart';
import '../../../../core/widgets/ds_score_meter.dart';

/// Card displaying the multi-dimensional scoring breakdown and analytics CTA.
class AiStudioScoringCard extends StatelessWidget {
  const AiStudioScoringCard({
    super.key,
    required this.breakdown,
    required this.onExploreAnalytics,
  });

  final Map<String, int> breakdown;
  final VoidCallback onExploreAnalytics;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

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
          const SizedBox(height: AppSpacing.lg),
          for (final entry in breakdown.entries) ...[
            _ScoreRow(label: entry.key, score: entry.value),
            const SizedBox(height: AppSpacing.md),
          ],
          Text(
            'Illustrative explanations, not real model scores.',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: ds.textMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: TextButton(
              onPressed: onExploreAnalytics,
              child: Text(
                'Explore AI quality analytics',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.label, required this.score});

  final String label;
  final int score;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: ds.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: DsScoreMeter(score: score.toDouble(), height: 6)),
        const SizedBox(width: AppSpacing.md),
        SizedBox(
          width: 32,
          child: Text(
            '$score',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: ds.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
