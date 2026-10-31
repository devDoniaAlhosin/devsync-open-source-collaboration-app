import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_app_bar.dart';
import '../../../../core/widgets/ds_staggered_entrance.dart';
import '../../domain/entities/matching_priority.dart';
import '../cubit/matching_cubit.dart';
import '../widgets/ai_analytics_stat_card.dart';
import '../widgets/ai_analytics_transparency_card.dart';
import '../widgets/ai_analytics_trend_chart.dart';
import '../widgets/ai_analytics_tuning_card.dart';

/// Screen displaying AI model quality analytics and priority tuning.
class AiAnalyticsScreen extends StatefulWidget {
  final MatchingCubit? cubit;

  const AiAnalyticsScreen({super.key, this.cubit});

  @override
  State<AiAnalyticsScreen> createState() => _AiAnalyticsScreenState();
}

class _AiAnalyticsScreenState extends State<AiAnalyticsScreen> {
  late final MatchingCubit _cubit;
  late final bool _ownsCubit;
  late MatchingPriority _selectedPriority;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
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
                builder: (context, state) {
                  final analytics = state.analytics;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    child: DsStagger(
                      spacing: AppSpacing.lg,
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
                            Text(
                              'Understand your feedback and matching trends.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: ds.textMuted),
                            ),
                          ],
                        ),
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
                        AiAnalyticsTrendChart(
                          trendValues: analytics.relevanceTrend,
                        ),
                        AiAnalyticsTuningCard(
                          selectedPriority: _selectedPriority,
                          onPrioritySelected: (p) =>
                              setState(() => _selectedPriority = p),
                          onRefinePrompt: _handleRefinePrompt,
                        ),
                        const AiAnalyticsTransparencyCard(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_ownsCubit) {
      _cubit.close();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _ownsCubit = widget.cubit == null;
    _cubit = widget.cubit ?? getIt<MatchingCubit>();
    if (_ownsCubit) _cubit.loadInitialData();
    _selectedPriority = _cubit.state.preferences.priority;
  }

  void _handleRefinePrompt() {
    _cubit.refinePromptWithPriority(_selectedPriority);
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text('Demo prompt refined for ${_selectedPriority.label}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).maybePop(true);
  }
}
