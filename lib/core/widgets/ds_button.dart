import 'package:flutter/material.dart';

import '../theme/app_animations.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'ds_icon.dart';

enum DsButtonVariant { primary, secondary, quiet, danger, dangerFilled }

/// Prototype button: 56 dp default, radius 18, press scale 0.97.
class DsButton extends StatefulWidget {
  const DsButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = DsButtonVariant.primary,
    this.icon,
    this.expanded = true,
    this.isLoading = false,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final DsButtonVariant variant;
  final IconData? icon;
  final bool expanded;
  final bool isLoading;
  final bool compact;

  @override
  State<DsButton> createState() => _DsButtonState();
}

class _DsButtonState extends State<DsButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final palette = DevSyncPalette.of(context);
    final colors = _colorsFor(widget.variant, palette);
    final height = widget.compact
        ? AppSpacing.buttonHeightSm
        : AppSpacing.buttonHeight;
    final radius = widget.compact ? AppSpacing.radiusMd : AppSpacing.radiusLg;

    final child = AnimatedScale(
      scale: _pressed && _enabled ? AppAnimations.pressScale : 1,
      duration: AppAnimations.fast,
      curve: AppAnimations.emphasized,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: height,
          minWidth: AppSpacing.minTouchTarget,
        ),
        child: Material(
          color: colors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: colors.border ?? BorderSide.none,
          ),
          child: InkWell(
            onTap: _enabled ? widget.onPressed : null,
            onHighlightChanged: (v) => setState(() => _pressed = v),
            borderRadius: BorderRadius.circular(radius),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.compact ? AppSpacing.lg : AppSpacing.xl + 2,
              ),
              child: Row(
                mainAxisSize: widget.expanded
                    ? MainAxisSize.max
                    : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading)
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: colors.foreground,
                      ),
                    )
                  else ...[
                    if (widget.icon != null) ...[
                      DsIcon(widget.icon!, size: 20, color: colors.foreground),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Flexible(
                      child: Text(
                        widget.label,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colors.foreground,
                          fontSize: widget.compact ? 15 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (!_enabled && !widget.isLoading) {
      return Opacity(opacity: 0.38, child: child);
    }
    return child;
  }

  _ButtonColors _colorsFor(DsButtonVariant variant, DevSyncPalette palette) {
    return switch (variant) {
      DsButtonVariant.primary => const _ButtonColors(
        background: AppColors.teal,
        foreground: AppColors.onTeal,
      ),
      DsButtonVariant.secondary => _ButtonColors(
        background: Colors.transparent,
        foreground: palette.textPrimary,
        border: const BorderSide(color: AppColors.teal, width: 1.5),
      ),
      DsButtonVariant.quiet => _ButtonColors(
        background: palette.surfaceAlt,
        foreground: palette.textPrimary,
      ),
      DsButtonVariant.danger => _ButtonColors(
        background: Colors.transparent,
        foreground: palette.danger,
        border: BorderSide(color: palette.danger, width: 1.5),
      ),
      DsButtonVariant.dangerFilled => _ButtonColors(
        background: palette.danger,
        foreground: Colors.white,
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
