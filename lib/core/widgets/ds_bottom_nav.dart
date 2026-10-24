import 'package:flutter/material.dart';

import '../theme/app_animations.dart';
import '../theme/app_colors.dart';
import 'ds_icon.dart';

class DsBottomNavItem {
  const DsBottomNavItem({
    required this.icon,
    required this.label,
    this.prominent = false,
    this.showBadge = false,
  });

  final IconData icon;
  final String label;
  final bool prominent;
  final bool showBadge;
}

/// Prototype `.nav-v6` — floating pill with a raised Discover control.
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

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: ds.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: ds.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: ds.isDark ? 0.38 : 0.10),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: SizedBox(
            height: 70,
            child: Padding(
              padding: const EdgeInsets.all(5),
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

class _ItemState extends State<_Item> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final selected = widget.selected;
    final item = widget.item;
    final color = selected ? ds.accentText : ds.textMuted;
    final fill = selected
        ? Color.alphaBlend(
            AppColors.teal.withValues(alpha: 0.13),
            ds.surface,
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
          scale: _pressed ? 0.91 : 1,
          duration: AppAnimations.fast,
          curve: AppAnimations.emphasized,
          child: AnimatedContainer(
            duration: AppAnimations.normal,
            curve: AppAnimations.emphasized,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Icon(item: item, selected: selected, color: color),
                    const SizedBox(height: 2),
                    AnimatedDefaultTextStyle(
                      duration: AppAnimations.normal,
                      curve: AppAnimations.emphasized,
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            height: 1.4,
                            letterSpacing: 0.1,
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
      width: 17,
      height: 2,
      decoration: BoxDecoration(
        color: AppColors.teal,
        borderRadius: BorderRadius.circular(3),
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

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    Widget icon;
    if (item.prominent) {
      icon = AnimatedContainer(
        duration: AppAnimations.normal,
        curve: AppAnimations.emphasized,
        width: 34,
        height: 30,
        transform: Matrix4.translationValues(0, selected ? -5 : -4, 0),
        decoration: BoxDecoration(
          color: AppColors.teal,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: ds.surface, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x442EE0C8),
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: DsIcon(item.icon, size: 18, color: AppColors.onTeal),
      );
    } else {
      icon = AnimatedSlide(
        duration: AppAnimations.normal,
        curve: AppAnimations.emphasized,
        offset: selected ? const Offset(0, -0.08) : Offset.zero,
        child: SizedBox(
          height: 24,
          child: DsIcon(item.icon, size: 20, color: color),
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
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: AppColors.teal,
                shape: BoxShape.circle,
                border: Border.all(color: ds.surface, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
