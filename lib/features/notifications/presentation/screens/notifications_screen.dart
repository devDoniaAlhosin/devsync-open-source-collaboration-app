import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_app_bar.dart';
import '../../../../core/widgets/ds_empty_state.dart';
import '../../../../core/widgets/ds_item_enter.dart';
import '../../../../core/widgets/ds_notification_tile.dart';
import '../../../../core/widgets/ds_page_fade.dart';
import '../../domain/entities/app_notification.dart';
import '../cubit/notifications_cubit.dart';

/// Firestore inbox under `users/{uid}/notifications`.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NotificationsCubit>()..load(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _openRequests(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.requests);
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: ds.background,
      appBar: DsAppBar(
        title: 'Notifications',
        eyebrow: 'INBOX',
        showBack: true,
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: DsPageFade(
        child: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            return switch (state) {
              NotificationsInitial() || NotificationsLoading() => const Center(
                child: CircularProgressIndicator(color: AppColors.teal),
              ),
              NotificationsFailure(:final message) => DsEmptyState(
                icon: AppIcons.error,
                title: 'Could not load inbox',
                message: message,
                actionLabel: 'Retry',
                onAction: () => context.read<NotificationsCubit>().load(),
              ),
              NotificationsLoaded(:final items) => items.isEmpty
                  ? const Center(
                      child: DsEmptyState(
                        icon: AppIcons.inbox,
                        title: 'All caught up',
                        message:
                            'New request and accept alerts will show up here.',
                      ),
                    )
                  : _buildList(context, items, textTheme, ds),
            };
          },
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<AppNotification> items,
    TextTheme textTheme,
    DevSyncPalette ds,
  ) {
    final now = DateTime.now();
    final today = items.where((n) => _isSameDay(n.createdAt, now)).toList();
    final earlier = items.where((n) => !_isSameDay(n.createdAt, now)).toList();

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
            subtitle: item.body,
            unread: !item.read,
            onTap: () {
              context.read<NotificationsCubit>().markRead(item.id);
              _openRequests(context);
            },
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
            subtitle: item.body,
            unread: !item.read,
            onTap: () {
              context.read<NotificationsCubit>().markRead(item.id);
              _openRequests(context);
            },
          ),
        );
      }
    }

    return RefreshIndicator(
      onRefresh: () => context.read<NotificationsCubit>().load(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
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
            padding: EdgeInsets.only(bottom: isLabel ? 0 : AppSpacing.md),
            child: isLabel ? child : DsItemEnter(index: index, child: child),
          );
        },
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
