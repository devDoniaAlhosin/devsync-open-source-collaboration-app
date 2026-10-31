import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class MatchBadge extends StatelessWidget {
  const MatchBadge({required this.percentage, super.key});

  final int percentage;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$percentage percent match',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.teal.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.teal.withValues(alpha: 0.32)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.teal,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$percentage% match',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.teal,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
