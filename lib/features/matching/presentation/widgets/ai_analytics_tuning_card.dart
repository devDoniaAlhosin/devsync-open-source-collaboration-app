import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_button.dart';
import '../../../../core/widgets/ds_card.dart';
import '../../../../core/widgets/ds_chip.dart';
import '../../domain/entities/matching_priority.dart';

/// Card for selecting recommendation prioritization and refining the prompt.
class AiAnalyticsTuningCard extends StatelessWidget {
  const AiAnalyticsTuningCard({
    super.key,
    required this.selectedPriority,
    required this.onPrioritySelected,
    required this.onRefinePrompt,
  });

  final MatchingPriority selectedPriority;
  final ValueChanged<MatchingPriority> onPrioritySelected;
  final VoidCallback onRefinePrompt;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return DsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tune your recommendations',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'What should the next match prioritize?',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ds.textMuted,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final p in MatchingPriority.values)
                DsChip(
                  label: p.label,
                  selected: selectedPriority == p,
                  onTap: () => onPrioritySelected(p),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          DsButton(
            label: 'Refine AI prompt',
            onPressed: onRefinePrompt,
          ),
        ],
      ),
    );
  }
}
