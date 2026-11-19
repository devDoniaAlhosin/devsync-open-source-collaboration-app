import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_app_bar.dart';
import '../../../../core/widgets/ds_card.dart';
import '../../../../core/widgets/ds_empty_state.dart';
import '../models/prompt_quality_metrics.dart';
import '../widgets/prompt_quality_trend.dart';

/// Read-only prompt evaluation snapshot.
class PromptQualityScreen extends StatelessWidget {
  final PromptQualityMetrics? metrics;

  const PromptQualityScreen({super.key, this.metrics});

  @override
  Widget build(BuildContext context) {
    if (metrics == null) {
      return Scaffold(
        backgroundColor: context.ds.background,
        appBar: DsAppBar(
          title: 'Prompt quality',
          eyebrow: 'DEVSYNC',
          showBack: true,
          onBack: () => Navigator.of(context).maybePop(),
        ),
        body: const SafeArea(
          child: Center(
            child: DsEmptyState(
              title: 'No prompt metrics yet',
              message:
                  'Prompt quality metrics will be displayed here once prompt evaluation is configured.',
            ),
          ),
        ),
      );
    }

    final data = metrics!;
    return Scaffold(
      backgroundColor: context.ds.background,
      appBar: DsAppBar(
        title: 'Prompt quality',
        eyebrow: 'DEVSYNC',
        showBack: true,
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              children: [
                Text(
                  'Snapshot',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: context.ds.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'How well prompt recommendations perform against project requirements over time.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: context.ds.textMuted),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        label: 'Avg match time',
                        value: '${data.averageMatchTime.inSeconds}s',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _MetricCard(
                        label: 'Timely alerts',
                        value:
                            '${data.timelyAlertsPercentage.toStringAsFixed(0)}%',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                DsCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Relevance by prompt version',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.ds.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      PromptQualityTrend(metrics: data),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;

  const _MetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return DsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: context.ds.textMuted),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: context.ds.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
