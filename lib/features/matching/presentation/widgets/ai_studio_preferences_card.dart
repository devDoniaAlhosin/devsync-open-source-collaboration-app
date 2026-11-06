import 'package:flutter/material.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_button.dart';
import '../../../../core/widgets/ds_card.dart';
import '../../../../core/widgets/ds_chip.dart';

/// Card for customizing natural language matching preferences and quick skill tags.
class AiStudioPreferencesCard extends StatelessWidget {
  final List<String> availableTags;
  final TextEditingController promptController;
  final Set<String> selectedTags;
  final ValueChanged<String> onTagToggled;
  final VoidCallback onGenerateMatches;
  final bool isGenerating;

  const AiStudioPreferencesCard({
    super.key,
    required this.promptController,
    required this.selectedTags,
    required this.onTagToggled,
    required this.onGenerateMatches,
    this.availableTags = const [],
    this.isGenerating = false,
  });

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
                  'Match\npreferences',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: ds.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  border: Border.all(color: ds.border),
                ),
                child: Text(
                  'Personalized',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: ds.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Describe the kind of open-source work you want to do.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: ds.textMuted),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: promptController,
            maxLength: 1000,
            enabled: !isGenerating,
            maxLines: 4,
            minLines: 3,
            textAlignVertical: TextAlignVertical.top,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.5),
            decoration: InputDecoration(
              filled: true,
              fillColor: ds.surfaceAlt,
              contentPadding: const EdgeInsets.all(AppSpacing.md),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: ds.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: const BorderSide(color: AppColors.teal, width: 1.8),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final tag in availableTags.take(30))
                DsChip(
                  label: tag,
                  selected: selectedTags.contains(tag),
                  onTap: isGenerating ? null : () => onTagToggled(tag),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          DsButton(
            label: 'Generate matches',
            icon: AppIcons.sparkle,
            isLoading: isGenerating,
            onPressed: isGenerating ? null : onGenerateMatches,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Uses your saved skills and public GitHub profile to rank available projects.',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: ds.textMuted),
          ),
        ],
      ),
    );
  }
}
