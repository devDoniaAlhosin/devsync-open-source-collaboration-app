import 'package:flutter/material.dart';

import '../theme/app_animations.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'ds_icon.dart';

/// App-bar icon control: [DevSyncPalette.surface] + [DevSyncPalette.border].
class DsIconButton extends StatefulWidget {
  const DsIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.active = false,
    this.showBadge = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool active;
  final bool showBadge;

  @override
  State<DsIconButton> createState() => _DsIconButtonState();
}

class _DsIconButtonState extends State<DsIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final palette = DevSyncPalette.of(context);
    final bg = widget.active ? AppColors.teal : palette.surface;
    final fg = widget.active ? AppColors.onTeal : palette.textPrimary;
    const radius = AppSpacing.radiusIcon;

    final button = AnimatedScale(
      scale: _pressed ? AppAnimations.iconPressScale : 1,
      duration: AppAnimations.fast,
      child: Material(
        color: bg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: widget.active
              ? BorderSide.none
              : BorderSide(color: palette.border),
        ),
        child: InkWell(
          onTap: widget.onPressed,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          borderRadius: BorderRadius.circular(radius),
          child: SizedBox(
            width: AppSpacing.iconButton,
            height: AppSpacing.iconButton,
            child: Stack(
              alignment: Alignment.center,
              children: [
                DsIcon(widget.icon, color: fg, size: 19),
                if (widget.showBadge)
                  Positioned(
                    top: 8,
                    right: 9,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: AppColors.teal,
                        shape: BoxShape.circle,
                        border: Border.all(color: palette.surface, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip == null) return button;
    return Tooltip(message: widget.tooltip!, child: button);
  }
}
