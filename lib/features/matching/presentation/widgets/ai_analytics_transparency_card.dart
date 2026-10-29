import 'package:flutter/material.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_card.dart';
import '../../../../core/widgets/ds_icon.dart';

/// Card displaying data policy and privacy guarantees.
class AiAnalyticsTransparencyCard extends StatelessWidget {
  const AiAnalyticsTransparencyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return DsCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DsIcon(AppIcons.shield, color: AppColors.teal, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Matching should use public GitHub activity and your declared skills only. Scores here are sample data.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ds.textPrimary,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
