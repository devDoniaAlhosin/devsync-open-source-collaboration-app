import 'package:flutter/material.dart';

import '../theme/app_animations.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Prototype `.tog` — 54×32 pill, teal when on.
class DsToggle extends StatelessWidget {
  const DsToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return Semantics(
      button: true,
      toggled: value,
      label: semanticLabel,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 54,
          height: AppSpacing.minTouchTarget,
          child: Center(
            child: AnimatedContainer(
              duration: AppAnimations.normal,
              width: 54,
              height: 32,
              decoration: BoxDecoration(
                color: value ? AppColors.teal : ds.border,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
              child: AnimatedAlign(
                duration: AppAnimations.slow,
                curve: AppAnimations.emphasized,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: value ? AppColors.onTeal : ds.textPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
