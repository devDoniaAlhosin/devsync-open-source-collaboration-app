import 'package:material_ui/material_ui.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_card.dart';
import '../../../../core/widgets/ds_icon_button.dart';
import '../models/prompt_quality_metrics.dart';
import '../widgets/prompt_quality_trend.dart';

/// Read-only prompt evaluation snapshot. Uses demo metrics until supplied.
class PromptQualityScreen extends StatelessWidget {
  final PromptQualityMetrics? metrics;

  const PromptQualityScreen({super.key, this.metrics});

  @override
  Widget build(BuildContext context) {
    final data = metrics ?? PromptQualityMetrics.demo;
    return Scaffold(
      backgroundColor: context.ds.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Column(
              children: [
                const _QualityHeader(),
                Divider(height: 1, color: context.ds.border),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    children: [
                      _RelevanceCard(metrics: data),
                      const SizedBox(height: AppSpacing.md),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final stacked =
                              constraints.maxWidth < 280 ||
                              MediaQuery.textScalerOf(context).scale(14) > 21;
                          final cards = [
                            _QualityMetric(
                              value:
                                  '${_formatSeconds(data.averageMatchTime)}s',
                              label: 'Avg match time',
                            ),
                            _QualityMetric(
                              value: '${data.timelyAlertsPercentage.round()}%',
                              label: 'Alerts within 10 s',
                            ),
                          ];
                          return stacked
                              ? Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    cards.first,
                                    const SizedBox(height: AppSpacing.md),
                                    cards.last,
                                  ],
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: cards.first),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(child: cards.last),
                                  ],
                                );
                        },
                      ),
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

  String _formatSeconds(Duration duration) {
    final seconds = duration.inMilliseconds / 1000;
    return seconds == seconds.roundToDouble()
        ? seconds.toStringAsFixed(0)
        : seconds.toStringAsFixed(1);
  }
}

class _QualityHeader extends StatelessWidget {
  const _QualityHeader();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppSpacing.lg),
    child: Row(
      children: [
        SizedBox(
          width: AppSpacing.minTouchTarget,
          height: AppSpacing.minTouchTarget,
          child: DsIconButton(
            icon: AppIcons.back,
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WORKSPACE',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context.ds.textMuted,
                  letterSpacing: 1.4,
                  fontSize: 10,
                ),
              ),
              Text(
                'Prompt quality',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: context.ds.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _QualityMetric extends StatelessWidget {
  final String value;

  final String label;
  const _QualityMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => DsCard(
    borderRadius: AppSpacing.radiusMd,
    padding: const EdgeInsets.all(AppSpacing.md),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: context.ds.accentText,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: context.ds.textMuted),
        ),
      ],
    ),
  );
}

class _RelevanceCard extends StatelessWidget {
  final PromptQualityMetrics metrics;

  const _RelevanceCard({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final improvement = metrics.improvementPercentage;
    return DsCard(
      borderRadius: AppSpacing.radiusMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Top-5 rated relevant',
            style: textTheme.bodySmall?.copyWith(color: context.ds.textMuted),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            children: [
              Text(
                metrics.latestRelevance == null
                    ? '—'
                    : '${metrics.latestRelevance!.round()}%',
                style: textTheme.displayLarge?.copyWith(
                  color: context.ds.accentText,
                  fontWeight: FontWeight.w800,
                  fontSize: 48,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Target ${metrics.relevanceTarget.round()}%',
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.onTeal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (metrics.versions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: Text(
                'No prompt evaluations yet.',
                style: textTheme.bodyMedium?.copyWith(
                  color: context.ds.textMuted,
                ),
              ),
            )
          else
            PromptQualityTrend(metrics: metrics),
          if (improvement != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text:
                        '${metrics.versions.first.label} to ${metrics.versions.last.label}: ',
                  ),
                  TextSpan(
                    text:
                        '${improvement >= 0 ? '+' : ''}${improvement.round()}% relevance. ',
                    style: TextStyle(color: context.ds.accentText),
                  ),
                  TextSpan(
                    text: 'Target was +${metrics.improvementTarget.round()}%.',
                  ),
                ],
              ),
              style: textTheme.bodySmall?.copyWith(color: context.ds.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
