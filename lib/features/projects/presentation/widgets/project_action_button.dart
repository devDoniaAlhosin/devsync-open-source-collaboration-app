import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ds_button.dart';

enum ProjectActionButtonVariant { primary, secondary, ghost }

class ProjectActionButton extends StatelessWidget {
  const ProjectActionButton({
    required this.label,
    this.onPressed,
    this.icon,
    this.trailingIcon,
    this.variant = ProjectActionButtonVariant.primary,
    this.expand = true,
    this.isLoading = false,
    this.compact = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final ProjectActionButtonVariant variant;
  final bool expand;
  final bool isLoading;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final dsVariant = switch (variant) {
      ProjectActionButtonVariant.primary => DsButtonVariant.primary,
      ProjectActionButtonVariant.secondary => DsButtonVariant.secondary,
      ProjectActionButtonVariant.ghost => DsButtonVariant.quiet,
    };

    final button = DsButton(
      label: label,
      onPressed: onPressed,
      variant: dsVariant,
      icon: icon,
      expanded: expand,
      isLoading: isLoading,
      compact: compact,
    );

    if (trailingIcon == null || icon != null || !expand || isLoading) {
      return button;
    }

    final foreground = variant == ProjectActionButtonVariant.primary
        ? Theme.of(context).colorScheme.onPrimary
        : context.ds.textPrimary;
    final iconColor = onPressed == null
        ? foreground.withValues(alpha: 0.38)
        : foreground;

    return Stack(
      alignment: Alignment.center,
      children: [
        button,
        Positioned(
          right: compact ? 16 : 22,
          child: IgnorePointer(
            child: Icon(
              trailingIcon,
              size: compact ? 17 : 19,
              color: iconColor,
            ),
          ),
        ),
      ],
    );
  }
}
