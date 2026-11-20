import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_app_bar.dart';
import '../../../../core/widgets/ds_empty_state.dart';
import '../../domain/entities/matching_priority.dart';
import '../cubit/matching_cubit.dart';
import '../widgets/ai_analytics_stat_card.dart';
import '../widgets/ai_analytics_transparency_card.dart';
import '../widgets/ai_analytics_trend_chart.dart';
import '../widgets/ai_analytics_tuning_card.dart';

class AiAnalyticsScreen extends StatefulWidget {
  const AiAnalyticsScreen({super.key, this.cubit});
  final MatchingCubit? cubit;

  @override
  State<AiAnalyticsScreen> createState() => _AiAnalyticsScreenState();
}

class _AiAnalyticsScreenState extends State<AiAnalyticsScreen> {
  late final MatchingCubit _cubit;
  late final bool _ownsCubit;
  late MatchingPriority _selectedPriority;

  @override
  void initState() {
    super.initState();
    _ownsCubit = widget.cubit == null;
    _cubit = widget.cubit ?? getIt<MatchingCubit>();
    _selectedPriority = _cubit.state.preferences.priority;
    _cubit.loadAnalytics();
  }

  @override
  void dispose() {
    if (_ownsCubit) _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: DsAppBar(
      title: 'AI Analytics',
      eyebrow: 'DEVSYNC',
      showBack: true,
      onBack: () => Navigator.of(context).maybePop(),
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: BlocBuilder<MatchingCubit, MatchingState>(
            bloc: _cubit,
            builder: (context, state) {
              if (state.isLoadingAnalytics) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.analyticsErrorMessage != null) {
                return DsEmptyState(
                  icon: AppIcons.error,
                  title: 'Could not load insights',
                  message: state.analyticsErrorMessage,
                  actionLabel: 'Retry',
                  onAction: _cubit.loadAnalytics,
                );
              }

              final analytics = state.analytics;
              if (analytics.isEmpty) {
                return const DsEmptyState(
                  icon: AppIcons.info,
                  title: 'Rate matches to see insights',
                  message:
                      'Swipe or rate projects in your feed to see your matching trends and model transparency.',
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'MODEL TRANSPARENCY',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.lightAccentText,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Recommendation insights',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: context.ds.textPrimary,
                            fontSize: 24,
                            letterSpacing: -0.3,
                          ),
                    ),
                    Text(
                      'Understand your feedback and matching trends.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.ds.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: AiAnalyticsStatCard(
                            value: '${analytics.ratedCount}',
                            label: 'Matches rated',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: AiAnalyticsStatCard(
                            value: analytics.positivePercentage == null
                                ? '—'
                                : '${analytics.positivePercentage}%',
                            label: 'Positive signals',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: AiAnalyticsStatCard(
                            value:
                                analytics.skillsMatchedCount?.toString() ?? '—',
                            label: 'Skills matched',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AiAnalyticsTrendChart(
                      trendValues: analytics.trendValues,
                      isDemo: analytics.isDemo,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AiAnalyticsTuningCard(
                      selectedPriority: _selectedPriority,
                      onPrioritySelected: (priority) {
                        setState(() => _selectedPriority = priority);
                        _cubit.setPriority(priority);
                      },
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

  void _handleRefinePrompt() {
    _cubit.refinePromptWithPriority(_selectedPriority);
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text('Prompt refined for ${_selectedPriority.label}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
