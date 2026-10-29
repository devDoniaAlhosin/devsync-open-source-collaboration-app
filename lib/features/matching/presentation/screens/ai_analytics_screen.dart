import 'package:flutter/material.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_icon_button.dart';
import '../../data/datasources/matching_local_data_source.dart';
import '../../data/datasources/matching_remote_data_source.dart';
import '../../data/repositories/matching_repository_impl.dart';
import '../../domain/entities/matching_priority.dart';
import '../controllers/matching_controller.dart';
import '../widgets/ai_analytics_stat_card.dart';
import '../widgets/ai_analytics_transparency_card.dart';
import '../widgets/ai_analytics_trend_chart.dart';
import '../widgets/ai_analytics_tuning_card.dart';

/// Screen displaying AI model quality analytics, recommendation insights,
/// and priority tuning controls.
class AiAnalyticsScreen extends StatefulWidget {
  final MatchingController? controller;

  const AiAnalyticsScreen({super.key, this.controller});

  @override
  State<AiAnalyticsScreen> createState() => _AiAnalyticsScreenState();
}

class _AiAnalyticsScreenState extends State<AiAnalyticsScreen> {
  late final MatchingController _controller;
  late final bool _ownsController;
  late MatchingPriority _selectedPriority;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.lg,
            bottom: AppSpacing.sm,
            top: AppSpacing.sm,
          ),
          child: DsIconButton(
            icon: AppIcons.back,
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DEVSYNC',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: ds.textMuted,
                letterSpacing: 1.4,
              ),
            ),
            Text(
              'AI Analytics',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                final analytics = _controller.analytics;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MODEL TRANSPARENCY',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.lightAccentText,
                                  letterSpacing: 1.2,
                                ),
                          ),
                          Text(
                            'Recommendation insights',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: ds.textPrimary,
                                  fontSize: 24,
                                  letterSpacing: -0.3,
                                ),
                          ),
                        ],
                      ),
                      Text(
                        'Understand your feedback and matching trends.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: ds.textMuted),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: AiAnalyticsStatCard(
                              value: '${analytics.matchesRated}',
                              label: 'Matches rated',
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: AiAnalyticsStatCard(
                              value: '${analytics.positiveSignalsPercentage}%',
                              label: 'Positive signals',
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: AiAnalyticsStatCard(
                              value: '${analytics.skillsMatchedCount}',
                              label: 'Skills matched',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AiAnalyticsTrendChart(
                        trendValues: analytics.relevanceTrend,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AiAnalyticsTuningCard(
                        selectedPriority: _selectedPriority,
                        onPrioritySelected: (p) =>
                            setState(() => _selectedPriority = p),
                        onRefinePrompt: _handleRefinePrompt,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const AiAnalyticsTransparencyCard(),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      final repository = MatchingRepositoryImpl(
        remoteDataSource: MockMatchingRemoteDataSource(),
        localDataSource: InMemoryMatchingLocalDataSource(),
      );
      _controller = MatchingController(repository: repository);
      _ownsController = true;
      _controller.loadInitialData();
    }
    _selectedPriority = _controller.preferences.priority;
  }

  void _handleRefinePrompt() {
    _controller.refinePromptWithPriority(_selectedPriority);
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text('Demo prompt refined for ${_selectedPriority.label}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).maybePop(true);
  }
}
