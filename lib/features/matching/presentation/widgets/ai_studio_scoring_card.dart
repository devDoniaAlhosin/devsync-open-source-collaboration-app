import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_card.dart';

/// Displays an overview of how matching scores are calculated.
class AiStudioScoringCard extends StatelessWidget {
  const AiStudioScoringCard({super.key, required this.onExploreAnalytics});

  final VoidCallback onExploreAnalytics;

  @override
  Widget build(BuildContext context) => DsCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How scoring works',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Each project includes a score and explanation from the matching service. '
          'Skill-based matches are labeled when AI scoring is unavailable.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: context.ds.textMuted),
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
