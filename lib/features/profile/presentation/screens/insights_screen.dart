import 'package:devsync_open_source_collaboration_app/app/app_routes.dart';
import 'package:devsync_open_source_collaboration_app/core/di/injection.dart';
import 'package:devsync_open_source_collaboration_app/core/icons/app_icons.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_colors.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_spacing.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_app_bar.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_empty_state.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_page_fade.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_staggered_entrance.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/data/models/insights_data.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/cubit/insights_cubit.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/widgets/insights/activity_bar_chart.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/widgets/insights/analytics_explorer_card.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/widgets/insights/milestones_card.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/widgets/profile_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<InsightsCubit>()..load(),
      child: const _InsightsView(),
    );
  }
}

class _InsightsView extends StatefulWidget {
  const _InsightsView();

  @override
  State<_InsightsView> createState() => _InsightsViewState();
}

class _InsightsViewState extends State<_InsightsView> {
  InsightsPeriod _period = InsightsPeriod.days7;

  void _setPeriod(InsightsPeriod p) {
    if (p != _period) setState(() => _period = p);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DsAppBar(
        title: 'Insights',
        eyebrow: 'DEVSYNC',
        showBack: true,
        onBack: () => Navigator.of(context).maybePop(),
        onNotifications: () {
          Navigator.of(context).pushNamed(AppRoutes.notifications);
        },
        notificationBadge: true,
      ),
      body: DsPageFade(
        child: BlocBuilder<InsightsCubit, InsightsState>(
          builder: (context, state) {
            return switch (state) {
              InsightsInitial() || InsightsLoading() => const Center(
                child: CircularProgressIndicator(color: AppColors.teal),
              ),
              InsightsFailure(:final message) => DsEmptyState(
                icon: AppIcons.error,
                title: 'Could not load insights',
                message: message,
                actionLabel: 'Retry',
                onAction: () => context.read<InsightsCubit>().load(),
              ),
              InsightsLoaded(:final data) => _InsightsBody(
                data: data,
                period: _period,
                onPeriodChanged: _setPeriod,
              ),
            };
          },
        ),
      ),
    );
  }
}

class _InsightsBody extends StatelessWidget {
  const _InsightsBody({
    required this.data,
    required this.period,
    required this.onPeriodChanged,
  });

  final InsightsData data;
  final InsightsPeriod period;
  final ValueChanged<InsightsPeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;
    final stats = data.statsFor(period);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.lg,
        AppSpacing.screenPadding,
        100,
      ),
      children: [
        DsStagger(
          spacing: AppSpacing.lg,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONTRIBUTION REPORT',
                  style: textTheme.labelSmall?.copyWith(
                    color: ds.accentText,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Your impact',
                  style: textTheme.headlineLarge?.copyWith(
                    color: ds.textPrimary,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Your public GitHub activity over the last 90 days.',
                  style: textTheme.bodyMedium?.copyWith(color: ds.textMuted),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ProfileStatCard(
                    value: data.summaryPrs,
                    label: 'PRs merged',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ProfileStatCard(
                    value: data.summaryCommits,
                    label: 'Commits',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ProfileStatCard(
                    value: data.summaryProjects,
                    label: 'Projects',
                  ),
                ),
              ],
            ),
            AnalyticsExplorerCard(
              period: period,
              stats: stats,
              onPeriodChanged: onPeriodChanged,
            ),
            ActivityBarChart(
              period: period,
              bars: stats.bars,
              onPeriodChanged: onPeriodChanged,
            ),
            MilestonesCard(milestones: data.milestones),
          ],
        ),
      ],
    );
  }
}
