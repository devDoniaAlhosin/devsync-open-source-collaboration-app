import 'package:flutter/material.dart';

import '../icons/app_icons.dart';
import '../theme/app_animations.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'ds_icon.dart';

enum DsChipVariant { neutral, selected, outline, success, muted }

/// Skill / filter / status chip (prototype `.chip`).
class DsChip extends StatefulWidget {
  const DsChip({
    super.key,
    required this.label,
    this.selected = false,
    this.variant,
    this.onTap,
    this.onDeleted,
    this.leading,
  });

  final String label;
  final bool selected;
  final DsChipVariant? variant;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;
  final Widget? leading;

  @override
  State<DsChip> createState() => _DsChipState();
}

class _DsChipState extends State<DsChip> {
  bool _pressed = false;

  DsChipVariant get _variant {
    if (widget.variant != null) return widget.variant!;
    return widget.selected ? DsChipVariant.selected : DsChipVariant.neutral;
  }

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(_variant, DevSyncPalette.of(context));

    final content = AnimatedScale(
      scale: _pressed ? 0.94 : 1,
      duration: AppAnimations.fast,
      child: Container(
        constraints: const BoxConstraints(minHeight: 34),
        padding: EdgeInsets.only(
          left: 13,
          right: widget.onDeleted != null ? AppSpacing.xs : 13,
          top: 6,
          bottom: 6,
        ),
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: style.border == null ? null : Border.fromBorderSide(style.border!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.leading != null) ...[
              widget.leading!,
              const SizedBox(width: 6),
            ],
            Text(
              widget.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: style.foreground,
                    fontWeight: style.bold ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
            ),
            if (widget.onDeleted != null)
              SizedBox(
                width: 28,
                height: 28,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 16,
                  onPressed: widget.onDeleted,
                  icon: DsIcon(AppIcons.close, color: style.foreground, size: 16),
                  tooltip: 'Remove ${widget.label}',
                ),
              ),
          ],
        ),
      ),
    );

    if (widget.onTap == null) return content;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: content,
    );
  }

  _ChipStyle _styleFor(DsChipVariant variant, DevSyncPalette palette) {
    return switch (variant) {
      DsChipVariant.neutral || DsChipVariant.muted => _ChipStyle(
          background: palette.surfaceAlt,
          foreground: palette.textPrimary,
        ),
      DsChipVariant.selected || DsChipVariant.success => const _ChipStyle(
          background: AppColors.teal,
          foreground: AppColors.onTeal,
          bold: true,
        ),
      DsChipVariant.outline => _ChipStyle(
          background: Colors.transparent,
          foreground: palette.textMuted,
          border: BorderSide(color: palette.border),
        ),
    };
  }
}

class _ChipStyle {
  const _ChipStyle({
    required this.background,
    required this.foreground,
    this.border,
    this.bold = false,
  });

  final Color background;
  final Color foreground;
  final BorderSide? border;
  final bool bold;
}
