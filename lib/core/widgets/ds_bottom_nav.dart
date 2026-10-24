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
        child: Material(
          color: ds.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: ds.border),
          ),
          child: SizedBox(
            height: 72,
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
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final DsBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final color = selected ? ds.accentText : ds.textMuted;

    return Material(
      color: selected
          ? Color.alphaBlend(AppColors.teal.withValues(alpha: 0.12), ds.surface)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: AnimatedScale(
          scale: 1,
          duration: AppAnimations.fast,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  if (item.prominent)
                    Container(
                      width: 34,
                      height: 30,
                      margin: const EdgeInsets.only(bottom: 2),
                      transform: Matrix4.translationValues(0, -4, 0),
                      decoration: BoxDecoration(
                        color: AppColors.teal,
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x442EE0C8),
                            blurRadius: 14,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: DsIcon(
                        item.icon,
                        size: 18,
                        color: AppColors.onTeal,
                      ),
                    )
                  else
                    SizedBox(
                      height: 24,
                      child: DsIcon(item.icon, size: 20, color: color),
                    ),
                  if (item.showBadge)
                    Positioned(
                      top: item.prominent ? -2 : 0,
                      right: item.prominent ? 0 : -2,
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
              ),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      height: 1.4,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
