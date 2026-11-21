import 'package:flutter/material.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_colors.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_spacing.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_card.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_chip.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/domain/entities/profile.dart';

enum ActivityPeriod { last20Weeks, thisYear }

class ContributionHeatmap extends StatefulWidget {
  const ContributionHeatmap({
    super.key,
    required this.activity,
    this.title = 'Activity',
    this.commits,
  });

  final List<List<int>> activity;
  final String title;

  /// Optional total used in the header (GitHub-style “N contributions”).
  final int? commits;

  @override
  State<ContributionHeatmap> createState() => _ContributionHeatmapState();
}

class _ContributionHeatmapState extends State<ContributionHeatmap> {
  ActivityPeriod _period = ActivityPeriod.last20Weeks;

  static const double _gap = 4;
  static const double _yearCell = 11;

  List<List<int>> get _visible {
    final all = widget.activity;
    if (all.isEmpty) {
      return List.generate(
        Profile.weeks,
        (_) => List.filled(Profile.days, 0),
      );
    }
    if (_period == ActivityPeriod.thisYear || all.length <= Profile.weeks) {
      return all;
    }
    return all.sublist(all.length - Profile.weeks);
  }

  int get _activeDays {
    var n = 0;
    for (final week in _visible) {
      for (final day in week) {
        if (day > 0) n++;
      }
    }
    return n;
  }

  Color _colorFor(int level, DevSyncPalette ds) {
    return switch (level) {
      0 => ds.surfaceAlt,
      1 => AppColors.teal.withValues(alpha: 0.35),
      2 => AppColors.teal.withValues(alpha: 0.6),
      3 => AppColors.teal.withValues(alpha: 0.82),
      _ => AppColors.teal,
    };
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;
    final year = DateTime.now().year;
    final scrollYear = _period == ActivityPeriod.thisYear &&
        _visible.length > Profile.weeks;
    final headline = widget.commits != null && widget.commits! > 0
        ? '${widget.commits} commits · $_activeDays active days'
        : '$_activeDays active days';

    return DsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: textTheme.titleSmall?.copyWith(
              color: ds.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            headline,
            style: textTheme.bodySmall?.copyWith(color: ds.textMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                DsChip(
                  label: 'Last 20 weeks',
                  selected: _period == ActivityPeriod.last20Weeks,
                  onTap: () => setState(
                    () => _period = ActivityPeriod.last20Weeks,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                DsChip(
                  label: '$year',
                  selected: _period == ActivityPeriod.thisYear,
                  onTap: () =>
                      setState(() => _period = ActivityPeriod.thisYear),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Semantics(
            label: '${widget.title}, ${_period == ActivityPeriod.last20Weeks ? 'Last 20 weeks' : year}',
            child: scrollYear
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _HeatmapGrid(
                      activity: _visible,
                      cellSize: _yearCell,
                      gap: _gap,
                      colorFor: (level) => _colorFor(level, ds),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final weeks = _visible.length.clamp(1, 999);
                      final cell =
                          (constraints.maxWidth - _gap * (weeks - 1)) / weeks;
                      return _HeatmapGrid(
                        activity: _visible,
                        cellSize: cell,
                        gap: _gap,
                        colorFor: (level) => _colorFor(level, ds),
                      );
                    },
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                'Less',
                style: textTheme.labelSmall?.copyWith(color: ds.textMuted),
              ),
              const SizedBox(width: AppSpacing.sm),
              for (var level = 0; level <= 4; level++) ...[
                if (level > 0) const SizedBox(width: 3),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _colorFor(level, ds),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
              const SizedBox(width: AppSpacing.sm),
              Text(
                'More',
                style: textTheme.labelSmall?.copyWith(color: ds.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeatmapGrid extends StatelessWidget {
  const _HeatmapGrid({
    required this.activity,
    required this.cellSize,
    required this.gap,
    required this.colorFor,
  });

  final List<List<int>> activity;
  final double cellSize;
  final double gap;
  final Color Function(int level) colorFor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var w = 0; w < activity.length; w++) ...[
          if (w > 0) SizedBox(width: gap),
          Column(
            children: [
              for (var d = 0; d < activity[w].length; d++) ...[
                if (d > 0) SizedBox(height: gap),
                Container(
                  width: cellSize,
                  height: cellSize,
                  decoration: BoxDecoration(
                    color: colorFor(activity[w][d]),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
