import 'package:flutter/material.dart';

import '../../../core/icons/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/ds_card.dart';
import '../../../core/widgets/ds_icon.dart';
import '../models/insights_data.dart';

class MilestonesCard extends StatelessWidget {
  const MilestonesCard({super.key, required this.milestones});

  final List<Milestone> milestones;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

    return DsCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppSpacing.radiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your milestones',
            style: textTheme.titleMedium?.copyWith(
              color: ds.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < milestones.length; i++) ...[
            _MilestoneRow(milestone: milestones[i]),
            if (i < milestones.length - 1)
              Padding(
                padding: const EdgeInsets.only(
                  left: 34 + AppSpacing.md,
                  top: AppSpacing.md,
                  bottom: AppSpacing.md,
                ),
                child: Divider(
                  height: 1,
                  color: AppColors.teal.withValues(alpha: 0.25),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({required this.milestone});

  final Milestone milestone;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;
    final done = milestone.achieved;

    return Semantics(
      label: '${milestone.title}, ${done ? 'achieved' : 'locked'}',
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: done ? AppColors.teal : ds.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: done
                ? DsIcon(AppIcons.success, size: 18, color: ds.surface)
                : Text(
                    '${milestone.number}',
                    style: textTheme.labelLarge?.copyWith(
                      color: ds.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.title,
                  style: textTheme.titleSmall?.copyWith(
                    color: ds.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  milestone.subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: done ? ds.accentText : ds.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
