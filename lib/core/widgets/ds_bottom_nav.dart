import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_animations.dart';
import '../theme/app_colors.dart';
import 'ds_icon.dart';
import 'ds_logo.dart';

class DsBottomNavItem {
  const DsBottomNavItem({
    this.icon,
    required this.label,
    this.brandMark = false,
    this.prominent = false,
    this.showBadge = false,
  }) : assert(icon != null || brandMark, 'Provide an icon or brandMark');

  final IconData? icon;
  final String label;

  /// Shows the DevSync icon mark instead of [icon].
  final bool brandMark;
  final bool prominent;
  final bool showBadge;
}

/// Floating glass pill dock — raised Discover control, soft selected wash.
class DsBottomNav extends StatelessWidget {
  const DsBottomNav({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
  });

  final List<DsBottomNavItem> items;
  final int index;
  final ValueChanged<int> onChanged;

  /// Pill height inside the floating chrome.
  static const double pillHeight = 72;

  /// Bottom inset under the pill (outside [SafeArea]).
  static const double outerBottom = 12;

  /// Extra bottom space body content needs when [Scaffold.extendBody] is true
  /// (pill + outer padding; safe-area is still applied via [MediaQuery]).
  static const double bodyClearance = pillHeight + outerBottom;

  static const double _radius = 22;
  static const double _pad = 6;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final shadowAlpha = ds.isDark ? 0.45 : 0.12;
    final glass = ds.surface.withValues(alpha: ds.isDark ? 0.82 : 0.90);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, outerBottom),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_radius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: shadowAlpha),
                blurRadius: 32,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: AppColors.teal.withValues(
                  alpha: ds.isDark ? 0.08 : 0.06,
                ),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_radius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: ColoredBox(
                color: glass,
                child: Stack(
                  children: [
                    // Soft top sheen so the dock reads as glass, not flat white.
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      height: 28,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(
                                alpha: ds.isDark ? 0.07 : 0.42,
                              ),
                              Colors.white.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(_radius),
                          border: Border.all(
                            color: ds.border.withValues(
                              alpha: ds.isDark ? 0.9 : 0.85,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: pillHeight,
                      child: Padding(
                        padding: const EdgeInsets.all(_pad),
                        child: Row(
                          children: [
                            for (var i = 0; i < items.length; i++)
                              Expanded(
                                child: _Item(
                                  item: items[i],
                                  selected: i == index,
                                  onTap: () => onChanged(i),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Item extends StatefulWidget {
  const _Item({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final DsBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_Item> createState() => _ItemState();
}

class _ItemState extends State<_Item> with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _pop;
  late final Animation<double> _popScale;

  @override
  void initState() {
    super.initState();
    _pop = AnimationController(
      vsync: this,
      duration: AppAnimations.normal,
    );
    _popScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0.86)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 28,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.86, end: 1.12)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 42,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.12, end: 1)
            .chain(CurveTween(curve: AppAnimations.emphasized)),
        weight: 30,
      ),
    ]).animate(_pop);
  }

  @override
  void didUpdateWidget(covariant _Item oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected) {
      final reduce = MediaQuery.disableAnimationsOf(context);
      if (!reduce) {
        _pop.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final selected = widget.selected;
    final item = widget.item;
    final color = selected ? ds.accentText : ds.textMuted;
    final fill = selected
        ? Color.alphaBlend(
            AppColors.teal.withValues(alpha: ds.isDark ? 0.18 : 0.12),
            ds.surface.withValues(alpha: 0.55),
          )
        : Colors.transparent;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.92 : 1,
          duration: AppAnimations.fast,
          curve: AppAnimations.emphasized,
          child: AnimatedContainer(
            duration: AppAnimations.normal,
            curve: AppAnimations.emphasized,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? AppColors.teal.withValues(
                        alpha: ds.isDark ? 0.22 : 0.14,
                      )
                    : Colors.transparent,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _popScale,
                      child: _Icon(
                        item: item,
                        selected: selected,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 3),
                    AnimatedDefaultTextStyle(
                      duration: AppAnimations.normal,
                      curve: AppAnimations.emphasized,
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            color: color,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w600,
                            fontSize: 10,
                            height: 1.3,
                            letterSpacing: selected ? 0.05 : 0.15,
                          ),
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (selected)
                  const Positioned(
                    top: 0,
                    child: _ActiveHairline(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveHairline extends StatelessWidget {
  const _ActiveHairline();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 2.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        gradient: LinearGradient(
          colors: [
            AppColors.teal.withValues(alpha: 0.35),
            AppColors.teal,
            AppColors.teal.withValues(alpha: 0.35),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withValues(alpha: 0.45),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  const _Icon({
    required this.item,
    required this.selected,
    required this.color,
  });

  final DsBottomNavItem item;
  final bool selected;
  final Color color;

  Widget _glyph({required double size, required Color color}) {
    if (item.brandMark) {
      return DsLogo(
        variant: DsLogoVariant.icon,
        height: size,
        color: color,
      );
    }
    return DsIcon(item.icon!, size: size, color: color);
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    Widget icon;
    if (item.prominent) {
      icon = AnimatedContainer(
        duration: AppAnimations.normal,
        curve: AppAnimations.emphasized,
        width: 36,
        height: 32,
        transform: Matrix4.translationValues(0, selected ? -4 : -3, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: ds.surface.withValues(alpha: 0.95),
            width: 2,
          ),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF5AEED8),
              AppColors.teal,
              Color(0xFF1BC4AE),
            ],
            stops: [0, 0.45, 1],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.teal.withValues(alpha: selected ? 0.42 : 0.28),
              blurRadius: selected ? 16 : 12,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: ds.isDark ? 0.28 : 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: _glyph(size: 18, color: AppColors.onTeal),
      );
    } else {
      icon = AnimatedSlide(
        duration: AppAnimations.normal,
        curve: AppAnimations.emphasized,
        offset: selected ? const Offset(0, -0.06) : Offset.zero,
        child: AnimatedOpacity(
          duration: AppAnimations.normal,
          opacity: selected ? 1 : 0.88,
          child: SizedBox(
            height: 24,
            child: _glyph(size: 20, color: color),
          ),
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        icon,
        if (item.showBadge)
          Positioned(
            top: item.prominent ? -6 : -1,
            right: item.prominent ? 0 : -3,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.teal,
                shape: BoxShape.circle,
                border: Border.all(color: ds.surface, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.teal.withValues(alpha: 0.5),
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
