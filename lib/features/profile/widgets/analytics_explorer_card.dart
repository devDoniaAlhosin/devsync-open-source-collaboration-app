import 'package:flutter/material.dart';

import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/ds_card.dart';
import '../../../core/widgets/ds_chip.dart';
import '../models/insights_data.dart';

class AnalyticsExplorerCard extends StatelessWidget {
  const AnalyticsExplorerCard({
    super.key,
    required this.period,
    required this.stats,
    required this.onPeriodChanged,
  });

  final InsightsPeriod period;
  final PeriodStats stats;
  final ValueChanged<InsightsPeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

    return DsCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppSpacing.radiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore your analytics',
            style: textTheme.titleMedium?.copyWith(
              color: ds.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select a period to compare your contributions.',
            style: textTheme.bodySmall?.copyWith(color: ds.textMuted),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final p in InsightsPeriod.values)
                DsChip(
                  label: p.chipLabel,
                  selected: p == period,
                  onTap: () => onPeriodChanged(p),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  value: stats.prsMerged,
                  label: 'Pull requests merged',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _MetricTile(
                  value: stats.commits,
                  label: 'Commits pushed',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  value: stats.reviews,
                  label: 'Reviews completed',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _MetricTile(
                  value: stats.activeProjects,
                  label: 'Active projects',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Demo activity · ${period.longLabel}',
            style: textTheme.bodySmall?.copyWith(color: ds.textMuted),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: ds.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: AppAnimations.score,
            curve: AppAnimations.emphasized,
            builder: (_, v, __) => Text(
              '$v',
              style: textTheme.headlineMedium?.copyWith(
                color: AppColors.teal,
                fontWeight: FontWeight.w800,
                fontSize: 26,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(color: ds.textMuted),
          ),
        ],
      ),
    );
  }
}
