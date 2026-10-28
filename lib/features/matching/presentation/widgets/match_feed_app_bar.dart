import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Top app bar displaying drawer menu, "DEVSYNC / For you" header,
/// and bookmark & notification actions with unread indicator.
class MatchFeedAppBar extends StatelessWidget {
  final VoidCallback? onMenuPressed;

  final VoidCallback? onBookmarkPressed;
  final VoidCallback? onNotificationsPressed;
  final bool hasUnreadNotifications;
  final String title;
  final bool showBookmark;
  const MatchFeedAppBar({
    super.key,
    this.title = 'For you',
    this.showBookmark = true,
    this.onMenuPressed,
    this.onBookmarkPressed,
    this.onNotificationsPressed,
    this.hasUnreadNotifications = true,
  });

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          _SquareIconButton(
            icon: Icons.menu_rounded,
            tooltip: 'Menu',
            onTap: onMenuPressed,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DEVSYNC',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: ds.textMuted,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    fontSize: 10,
                  ),
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          if (showBookmark) ...[
            _SquareIconButton(
              icon: Icons.bookmark_border_rounded,
              tooltip: 'Saved matches',
              onTap: onBookmarkPressed,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          _SquareIconButton(
            icon: Icons.notifications_none_rounded,
            tooltip: 'Notifications',
            showIndicator: hasUnreadNotifications,
            onTap: onNotificationsPressed,
          ),
        ],
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  final IconData icon;

  final String tooltip;
  final VoidCallback? onTap;
  final bool showIndicator;
  const _SquareIconButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.showIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: ds.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: ds.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, size: 20, color: ds.textPrimary),
                if (showIndicator)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.teal,
                        shape: BoxShape.circle,
                      ),
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
