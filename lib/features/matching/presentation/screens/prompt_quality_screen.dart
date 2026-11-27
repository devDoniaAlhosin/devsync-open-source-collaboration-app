import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/result/result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_app_bar.dart';
import '../../../../core/widgets/ds_button.dart';
import '../../../../core/widgets/ds_card.dart';
import '../../../../core/widgets/ds_empty_state.dart';
import '../../../../core/widgets/ds_toast.dart';
import '../../data/datasources/prompt_version_preference.dart';
import '../../domain/entities/prompt_quality_metrics.dart';
import '../../domain/usecases/get_prompt_quality_metrics.dart';
import '../widgets/prompt_quality_trend.dart';

class PromptQualityScreen extends StatefulWidget {
  final PromptQualityMetrics? metrics;

  const PromptQualityScreen({super.key, this.metrics});

  @override
  State<PromptQualityScreen> createState() => _PromptQualityScreenState();
}

class _PromptQualityScreenState extends State<PromptQualityScreen> {
  PromptQualityMetrics? _metrics;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _metrics = widget.metrics;
    if (_metrics == null) {
      _load();
    }
  }

  Future<void> _load() async {
    if (!getIt.isRegistered<GetPromptQualityMetrics>()) {
      setState(() {
        _metrics = null;
        _loading = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await getIt<GetPromptQualityMetrics>()();
    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        setState(() {
          _metrics = data;
          _loading = false;
        });
      case FailureResult(:final failure):
        setState(() {
          _metrics = null;
          _loading = false;
          _error = failure.message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: context.ds.background,
        appBar: DsAppBar(
          title: 'Prompt quality',
          eyebrow: 'DEVSYNC',
          showBack: true,
          onBack: () => Navigator.of(context).maybePop(),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final metrics = _metrics;
    if (metrics == null || metrics.versions.isEmpty) {
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
            child: DsEmptyState(
              icon: AppIcons.info,
              title: 'No data yet',
              message:
                  _error ??
                  'Like or skip matches after generating a feed to build relevance by prompt version.',
            ),
          ),
        ),
      );
    }

    final showTiming =
        metrics.averageMatchTime != null ||
        metrics.timelyAlertsPercentage != null;

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
                if (showTiming) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      if (metrics.averageMatchTime != null)
                        Expanded(
                          child: _MetricCard(
                            label: 'Avg match time',
                            value:
                                '${metrics.averageMatchTime!.inSeconds}s',
                          ),
                        ),
                      if (metrics.averageMatchTime != null &&
                          metrics.timelyAlertsPercentage != null)
                        const SizedBox(width: AppSpacing.md),
                      if (metrics.timelyAlertsPercentage != null)
                        Expanded(
                          child: _MetricCard(
                            label: 'Timely alerts',
                            value:
                                '${metrics.timelyAlertsPercentage!.toStringAsFixed(0)}%',
                          ),
                        ),
                    ],
                  ),
                ],
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
                      PromptQualityTrend(metrics: metrics),
                    ],
                  ),
                ),
                if (metrics.bestVersion != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  DsButton(
                    label:
                        'Use best version (${metrics.bestVersion!.label})',
                    onPressed: () => _applyBest(metrics.bestVersion!.label),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _applyBest(String version) async {
    if (getIt.isRegistered<PromptVersionPreference>()) {
      await getIt<PromptVersionPreference>().write(version);
    }
    if (!mounted) return;
    showDsToast(
      context,
      'Matching will prefer prompt $version on the next feed load.',
      tone: DsToastTone.success,
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
            ).textTheme.labelMedium?.copyWith(color: context.ds.textMuted),
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
