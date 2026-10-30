import 'package:flutter/material.dart';

import '../icons/app_icons.dart';
import '../theme/app_colors.dart';
import 'ds_icon_button.dart';

/// Prototype chrome-v13 top bar:
/// `[menu|back]  EYEBROW / Title  ……  [actions]`.
class DsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DsAppBar({
    super.key,
    required this.title,
    this.eyebrow,
    this.brand,
    this.showBack,
    this.showMenu = false,
    this.onBack,
    this.onMenu,
    this.onThemeToggle,
    this.onSettings,
    this.onNotifications,
    this.notificationBadge = false,
    this.actions = const [],
  });

  final String title;

  /// Small caps line above [title].
  final String? eyebrow;

  /// Optional brand mark before the title block (e.g. [DsBrandIcon]).
  final Widget? brand;

  /// Defaults to `Navigator.canPop` when [showMenu] is false.
  final bool? showBack;
  final bool showMenu;
  final VoidCallback? onBack;
  final VoidCallback? onMenu;

  final VoidCallback? onThemeToggle;
  final VoidCallback? onSettings;
  final VoidCallback? onNotifications;
  final bool notificationBadge;
  final List<Widget> actions;

  static const double _height = 64;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    final palette = DevSyncPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final canPop = Navigator.of(context).canPop();
    final leadBack = !showMenu && (showBack ?? canPop);

    final hasEyebrow = eyebrow != null && eyebrow!.isNotEmpty;
    final hasTitle = title.isNotEmpty;

    return Material(
      color: palette.background,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: _height,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: palette.border.withValues(alpha: 0.85),
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              if (showMenu) ...[
                DsIconButton(
                  icon: AppIcons.menu,
                  tooltip: 'Menu',
                  onPressed: onMenu,
                ),
                const SizedBox(width: 12),
              ] else if (leadBack) ...[
                DsIconButton(
                  icon: AppIcons.back,
                  tooltip: 'Back',
                  onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(width: 12),
              ],
              if (brand != null) ...[
                brand!,
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasEyebrow)
                      Text(
                        eyebrow!.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          color: palette.textMuted,
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                          height: 1.3,
                          letterSpacing: 1.3,
                        ),
                      ),
                    if (hasEyebrow && hasTitle) const SizedBox(height: 2),
                    if (hasTitle)
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.headlineMedium?.copyWith(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          height: 1.25,
                          letterSpacing: -0.6,
                        ),
                      ),
                  ],
                ),
              ),
              for (final action in actions) ...[
                const SizedBox(width: 7),
                action,
              ],
              if (onNotifications != null) ...[
                const SizedBox(width: 7),
                DsIconButton(
                  icon: AppIcons.notifications,
                  tooltip: 'Notifications',
                  showBadge: notificationBadge,
                  onPressed: onNotifications,
                ),
              ],
              if (onSettings != null) ...[
                const SizedBox(width: 7),
                DsIconButton(
                  icon: AppIcons.settings,
                  tooltip: 'Settings',
                  onPressed: onSettings,
                ),
              ],
              if (onThemeToggle != null) ...[
                const SizedBox(width: 7),
                DsIconButton(
                  icon: palette.isDark ? AppIcons.sun : AppIcons.moon,
                  tooltip: palette.isDark ? 'Light theme' : 'Dark theme',
                  onPressed: onThemeToggle,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
