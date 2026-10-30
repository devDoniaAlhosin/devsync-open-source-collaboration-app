import 'package:flutter/material.dart';

import 'package:devsync_open_source_collaboration_app/app/app_routes.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_colors.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_spacing.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_app_bar.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_page_fade.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_staggered_entrance.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/widgets/profile_stat_card.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/data/models/insights_data.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/widgets/insights/activity_bar_chart.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/widgets/insights/analytics_explorer_card.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/widgets/insights/milestones_card.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key, this.data});

  final InsightsData? data;

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  late final InsightsData _data = widget.data ?? InsightsData.sample();
  InsightsPeriod _period = InsightsPeriod.days7;

  void _setPeriod(InsightsPeriod p) {
    if (p != _period) setState(() => _period = p);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;
    final stats = _data.statsFor(_period);

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
        child: ListView(
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
                    'A snapshot of your open-source journey.',
                    style: textTheme.bodyMedium?.copyWith(color: ds.textMuted),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: ProfileStatCard(
                      value: _data.summaryPrs,
                      label: 'PRs merged',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ProfileStatCard(
                      value: _data.summaryCommits,
                      label: 'Commits',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ProfileStatCard(
                      value: _data.summaryProjects,
                      label: 'Projects',
                    ),
                  ),
                ],
              ),
              AnalyticsExplorerCard(
                period: _period,
                stats: stats,
                onPeriodChanged: _setPeriod,
              ),
              ActivityBarChart(
                period: _period,
                bars: stats.bars,
                onPeriodChanged: _setPeriod,
              ),
              MilestonesCard(milestones: _data.milestones),
            ],
          ),
          ],
        ),
      ),
    );
  }
}
