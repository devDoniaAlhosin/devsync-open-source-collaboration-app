import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum DsCardTone { standard, inset }

/// Surface card — radius 24, inset border (prototype `.card`).
class DsCard extends StatelessWidget {
  const DsCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    this.margin,
    this.tone = DsCardTone.standard,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final DsCardTone tone;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final palette = DevSyncPalette.of(context);
    final radius = borderRadius ?? AppSpacing.radiusCard;
    final color =
        tone == DsCardTone.inset ? palette.surfaceAlt : palette.surface;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: palette.border),
    );

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: color,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
