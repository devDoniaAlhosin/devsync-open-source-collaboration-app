import 'package:flutter/material.dart';

import '../../../core/icons/app_icons.dart';
import '../../../core/theme/app_colors.dart';

class TechTag extends StatelessWidget {
  const TechTag({
    required this.label,
    this.selected = false,
    this.showCheck = false,
    this.onTap,
    this.compact = false,
    super.key,
  });

  final String label;
  final bool selected;
  final bool showCheck;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final background = selected
        ? AppColors.teal
        : context.ds.surfaceAlt.withValues(alpha: 0.55);
    final foreground = selected ? AppColors.onTeal : context.ds.textPrimary;

    final chip = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 13,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected ? AppColors.teal : context.ds.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showCheck) ...[
            Icon(AppIcons.success, size: 14, color: foreground),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              fontSize: compact ? 11.5 : 12.5,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return chip;
    }

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: chip,
        ),
      ),
    );
  }
}
