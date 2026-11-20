import 'package:flutter/material.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_icon.dart';

/// Privacy / transparency note shown at the bottom of the AI analytics screen.
///
/// Matches the mockup: teal check icon + small italic note text in a row,
/// no card background — just an inline row on the page background.
class AiAnalyticsTransparencyCard extends StatelessWidget {
  const AiAnalyticsTransparencyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DsIcon(AppIcons.shield, color: AppColors.teal, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Matching uses public GitHub activity and your declared skills only. '
            'Scores here are sample data.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: ds.textMuted, height: 1.5),
          ),
        ),
      ],
    );
  }
}
