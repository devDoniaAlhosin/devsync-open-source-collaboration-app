import 'package:flutter/material.dart';

import '../../../../core/dummy/dummy_notifications.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_app_bar.dart';
import '../../../../core/widgets/ds_empty_state.dart';
import '../../../../core/widgets/ds_item_enter.dart';
import '../../../../core/widgets/ds_notification_tile.dart';
import '../../../../core/widgets/ds_page_fade.dart';
import '../../../../core/icons/app_icons.dart';

/// Temporary local notifications inbox (dummy seed, no Firestore/FCM).
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<DummyNotification> _items;

  @override
  void initState() {
    super.initState();
    _items = seedDummyNotifications();
  }

  void _toggleUnread(String id) {
    setState(() {
      _items = [
        for (final item in _items)
          if (item.id == id) item.copyWith(unread: !item.unread) else item,
      ];
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = _items.where((n) => _isSameDay(n.createdAt, now)).toList();
    final earlier = _items.where((n) => !_isSameDay(n.createdAt, now)).toList();
    final ds = context.ds;
    final textTheme = Theme.of(context).textTheme;

    final rows = <Widget>[];
    if (today.isNotEmpty) {
      rows.add(
        _SectionLabel(
          label: 'Today',
          style: textTheme.labelMedium?.copyWith(color: ds.textMuted),
        ),
      );
      for (final item in today) {
        rows.add(
          DsNotificationTile(
            title: item.title,
            subtitle: item.subtitle,
            unread: item.unread,
            onTap: () => _toggleUnread(item.id),
          ),
        );
      }
    }
    if (earlier.isNotEmpty) {
      rows.add(
        _SectionLabel(
          label: 'Earlier',
          style: textTheme.labelMedium?.copyWith(color: ds.textMuted),
          topPad: today.isNotEmpty,
        ),
      );
      for (final item in earlier) {
        rows.add(
          DsNotificationTile(
            title: item.title,
            subtitle: item.subtitle,
            unread: item.unread,
            onTap: () => _toggleUnread(item.id),
          ),
        );
      }
    }

    return Scaffold(
      appBar: DsAppBar(
        title: 'Notifications',
        eyebrow: 'INBOX',
        showBack: true,
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: DsPageFade(
        child: _items.isEmpty
            ? const Center(
                child: DsEmptyState(
                  icon: AppIcons.inbox,
                  title: 'All caught up',
                  message: 'New request and match alerts will show up here.',
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.sm,
                  AppSpacing.screenPadding,
                  AppSpacing.xxxl,
                ),
                itemCount: rows.length,
                itemBuilder: (context, index) {
                  final child = rows[index];
                  final isLabel = child is _SectionLabel;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: isLabel ? 0 : AppSpacing.md,
                    ),
                    child: isLabel
                        ? child
                        : DsItemEnter(index: index, child: child),
                  );
                },
              ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.label,
    required this.style,
    this.topPad = false,
  });

  final String label;
  final TextStyle? style;
  final bool topPad;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: topPad ? AppSpacing.lg : AppSpacing.xs,
        bottom: AppSpacing.sm,
        left: 2,
      ),
      child: Text(label, style: style),
    );
  }
}
