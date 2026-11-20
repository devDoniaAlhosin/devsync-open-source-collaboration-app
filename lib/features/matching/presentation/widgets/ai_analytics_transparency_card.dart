import 'package:flutter/material.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_card.dart';
import '../../../../core/widgets/ds_icon.dart';

class AiAnalyticsTransparencyCard extends StatelessWidget {
  const AiAnalyticsTransparencyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return DsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const DsIcon(AppIcons.shield, color: AppColors.teal, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Scoring breakdown',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'The matching service considers your skills, GitHub activity, and prompt preferences. These insights summarize your likes and skips; changing a priority does not reorder the current feed or change its scores.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: ds.textPrimary,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
