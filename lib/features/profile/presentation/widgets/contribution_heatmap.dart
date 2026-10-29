import 'package:flutter/material.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_colors.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_spacing.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_card.dart';

class ContributionHeatmap extends StatelessWidget {
  const ContributionHeatmap({
    super.key,
    required this.activity,
    this.title = 'Activity',
    this.caption = 'Last 20 weeks',
  });

  final List<List<int>> activity;
  final String title;
  final String caption;

  static const double _gap = 4;

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

    return DsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    color: ds.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                caption,
                style: textTheme.bodySmall?.copyWith(color: ds.textMuted),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Semantics(
            label: '$title, $caption',
            child: LayoutBuilder(
              builder: (context, constraints) {
                final weeks = activity.length;
                final cell =
                    (constraints.maxWidth - _gap * (weeks - 1)) / weeks;

                return Row(
                  children: [
                    for (var w = 0; w < weeks; w++) ...[
                      if (w > 0) const SizedBox(width: _gap),
                      Column(
                        children: [
                          for (var d = 0; d < activity[w].length; d++) ...[
                            if (d > 0) const SizedBox(height: _gap),
                            Container(
                              width: cell,
                              height: cell,
                              decoration: BoxDecoration(
                                color: _colorFor(activity[w][d], ds),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
