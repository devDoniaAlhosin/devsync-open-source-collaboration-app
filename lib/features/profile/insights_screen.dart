import 'package:flutter/material.dart';

import '../../core/icons/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/ds_icon_button.dart';
import '../profile/widgets/profile_stat_card.dart';
import 'models/insights_data.dart';
import 'widgets/activity_bar_chart.dart';
import 'widgets/analytics_explorer_card.dart';
import 'widgets/milestones_card.dart';

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
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.md,
            AppSpacing.screenPadding,
            100,
          ),
          children: [
            // Header
            Row(
              children: [
                DsIconButton(
                  icon: canPop ? AppIcons.back : AppIcons.menu,
                  tooltip: canPop ? 'Back' : 'Menu',
                  onPressed: () {
                    if (canPop) Navigator.of(context).maybePop();
                  },
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DEVSYNC',
                        style: textTheme.labelSmall?.copyWith(
                          color: ds.textMuted,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          letterSpacing: 1.6,
                        ),
                      ),
                      Text(
                        'Insights',
                        style: textTheme.headlineSmall?.copyWith(
                          color: ds.textPrimary,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                DsIconButton(
                  icon: AppIcons.notifications,
                  tooltip: 'Notifications',
                  showBadge: true,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Divider(height: 1, color: ds.border),
            const SizedBox(height: AppSpacing.lg),

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
            const SizedBox(height: AppSpacing.lg),

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
            const SizedBox(height: AppSpacing.lg),

            AnalyticsExplorerCard(
              period: _period,
              stats: stats,
              onPeriodChanged: _setPeriod,
            ),
            const SizedBox(height: AppSpacing.lg),
            ActivityBarChart(
              period: _period,
              bars: stats.bars,
              onPeriodChanged: _setPeriod,
            ),
            const SizedBox(height: AppSpacing.lg),
            MilestonesCard(milestones: _data.milestones),
          ],
        ),
      ),
    );
  }
}
