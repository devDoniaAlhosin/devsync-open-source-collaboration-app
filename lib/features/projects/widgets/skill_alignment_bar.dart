import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class SkillAlignmentBar extends StatelessWidget {
  const SkillAlignmentBar({
    required this.label,
    required this.score,
    super.key,
  });

  final String label;
  final int score;

  @override
  Widget build(BuildContext context) {
    final normalized = (score / 100).clamp(0.0, 1.0).toDouble();

    return Semantics(
      label: '$label alignment $score percent',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 78,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontSize: 13,
                  color: context.ds.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 12,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: normalized),
                  duration: const Duration(milliseconds: 950),
                  curve: Curves.easeOutCubic,
                  builder: (context, progress, child) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final fillWidth = constraints.maxWidth * progress;
                        return Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: context.ds.border.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            if (fillWidth > 0)
                              Container(
                                width: fillWidth,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF72EFDF), AppColors.teal],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.teal.withValues(
                                        alpha: 0.28,
                                      ),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 30,
              child: Text(
                '$score',
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontSize: 13,
                  color: context.ds.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
