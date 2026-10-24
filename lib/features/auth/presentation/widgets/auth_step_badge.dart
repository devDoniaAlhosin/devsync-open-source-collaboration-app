import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Prototype `.auth-step`: teal numbered pill + muted label.
class AuthStepBadge extends StatelessWidget {
  const AuthStepBadge({super.key, required this.step, required this.label});

  final int step;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

    return Row(
      children: [
        Container(
          width: 23,
          height: 23,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.teal,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$step',
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.onTeal,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: ds.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
