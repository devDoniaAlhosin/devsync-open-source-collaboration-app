import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Compact skill / tag chip used on project and match cards.
class DsChip extends StatelessWidget {
  const DsChip({
    super.key,
    required this.label,
    this.onDeleted,
  });

  final String label;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.md - 2,
        right: onDeleted != null ? AppSpacing.xs : AppSpacing.md - 2,
        top: AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.line,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.mint,
                ),
          ),
          if (onDeleted != null)
            SizedBox(
              width: AppSpacing.minTouchTarget / 2,
              height: AppSpacing.minTouchTarget / 2,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 16,
                onPressed: onDeleted,
                icon: const Icon(Icons.close, color: AppColors.muted),
                tooltip: 'Remove $label',
              ),
            ),
        ],
      ),
    );
  }
}
