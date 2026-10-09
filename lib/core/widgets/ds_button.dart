import 'package:flutter/material.dart';

import '../theme/app_animations.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum DsButtonVariant { primary, secondary, ghost }

/// Shared button with 48 dp min height and brand press scale.
class DsButton extends StatefulWidget {
  const DsButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = DsButtonVariant.primary,
    this.icon,
    this.expanded = false,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final DsButtonVariant variant;
  final IconData? icon;
  final bool expanded;
  final bool isLoading;

  @override
  State<DsButton> createState() => _DsButtonState();
}

class _DsButtonState extends State<DsButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(widget.variant);

    final child = AnimatedScale(
      scale: _pressed && _enabled ? AppAnimations.pressScale : 1,
      duration: AppAnimations.fast,
      curve: AppAnimations.standard,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: AppSpacing.minTouchTarget,
          minWidth: AppSpacing.minTouchTarget,
        ),
        child: Material(
          color: colors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            side: colors.border ?? BorderSide.none,
          ),
          child: InkWell(
            onTap: _enabled ? widget.onPressed : null,
            onHighlightChanged: (v) => setState(() => _pressed = v),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg + 2,
                vertical: AppSpacing.md - 1,
              ),
              child: Row(
                mainAxisSize:
                    widget.expanded ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading) ...[
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.foreground,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ] else if (widget.icon != null) ...[
                    Icon(widget.icon, size: 20, color: colors.foreground),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Flexible(
                    child: Text(
                      widget.label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: colors.foreground,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (!_enabled && !widget.isLoading) {
      return Opacity(opacity: 0.45, child: child);
    }
    return child;
  }

  _ButtonColors _colorsFor(DsButtonVariant variant) {
    return switch (variant) {
      DsButtonVariant.primary => const _ButtonColors(
          background: AppColors.teal,
          foreground: AppColors.onTeal,
        ),
      DsButtonVariant.secondary => const _ButtonColors(
          background: Colors.transparent,
          foreground: AppColors.mint,
          border: BorderSide(color: AppColors.teal, width: 1.5),
        ),
      DsButtonVariant.ghost => const _ButtonColors(
          background: AppColors.line,
          foreground: AppColors.mint,
        ),
    };
  }
}

class _ButtonColors {
  const _ButtonColors({
    required this.background,
    required this.foreground,
    this.border,
  });

  final Color background;
  final Color foreground;
  final BorderSide? border;
}
