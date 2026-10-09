import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/widgets.dart';

/// Visual checklist of shared components for the team.
class DesignSystemGalleryScreen extends StatelessWidget {
  const DesignSystemGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Design system')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          const Center(child: DsLogo(height: 48)),
          const SizedBox(height: AppSpacing.xl),
          Text('Color', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: const [
              _Swatch('Teal', AppColors.teal, AppColors.onTeal),
              _Swatch('Forest', AppColors.forest, AppColors.mint),
              _Swatch('Mint', AppColors.mint, AppColors.forest),
              _Swatch('Surface', AppColors.surface, AppColors.mint),
              _Swatch('Line', AppColors.line, AppColors.mint),
              _Swatch('Muted', AppColors.muted, AppColors.forest),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Typography', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          Text('Bricolage Grotesque', style: textTheme.displayMedium),
          Text('Figtree body — readable UI copy.', style: textTheme.bodyLarge),
          Text('Muted helper text', style: textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xl),
          Text('Buttons', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              DsButton(label: 'Primary', onPressed: () {}),
              DsButton(
                label: 'Secondary',
                variant: DsButtonVariant.secondary,
                onPressed: () {},
              ),
              DsButton(
                label: 'Ghost',
                variant: DsButtonVariant.ghost,
                onPressed: () {},
              ),
              const DsButton(label: 'Disabled'),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Card + score + chips', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          DsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Open Source Match', style: textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Strong fit on Flutter and Firebase.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const DsScoreMeter(score: 92),
                const SizedBox(height: AppSpacing.md),
                const Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    DsChip(label: 'Flutter'),
                    DsChip(label: 'Firebase'),
                    DsChip(label: 'Dart'),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: DsButton(
                        label: 'Like',
                        icon: Icons.thumb_up_outlined,
                        expanded: true,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: DsButton(
                        label: 'Skip',
                        variant: DsButtonVariant.secondary,
                        icon: Icons.skip_next_outlined,
                        expanded: true,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Empty state', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          const SizedBox(
            height: 220,
            child: DsCard(
              child: DsEmptyState(
                title: 'No matches yet',
                message: 'Complete your profile to get ranked projects.',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.name, this.color, this.onColor);

  final String name;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: AppSpacing.minTouchTarget + 24,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            name,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: onColor,
                ),
          ),
        ],
      ),
    );
  }
}
