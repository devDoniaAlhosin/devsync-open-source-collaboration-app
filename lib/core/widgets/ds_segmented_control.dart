import 'package:flutter/material.dart';

import '../theme/app_animations.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Sliding segmented control (prototype `.seg2`).
class DsSegmentedControl extends StatelessWidget {
  const DsSegmentedControl({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    assert(labels.length >= 2);
    final ds = context.ds;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ds.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: ds.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / labels.length;

          return Stack(
            children: [
              AnimatedPositioned(
                duration: AppAnimations.slow,
                curve: AppAnimations.emphasized,
                left: segmentWidth * index,
                top: 0,
                bottom: 0,
                width: segmentWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < labels.length; i++)
                    Expanded(
                      child: InkWell(
                        onTap: () => onChanged(i),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          alignment: Alignment.center,
                          constraints: const BoxConstraints(minHeight: 44),
                          child: AnimatedDefaultTextStyle(
                            duration: AppAnimations.slow,
                            curve: AppAnimations.emphasized,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(
                                  color: i == index
                                      ? AppColors.onTeal
                                      : ds.textMuted,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                            child: Text(
                              labels[i],
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
