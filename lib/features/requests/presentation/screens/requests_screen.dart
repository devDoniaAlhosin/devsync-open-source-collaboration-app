import 'package:devsync_open_source_collaboration_app/app/app_routes.dart';
import 'package:devsync_open_source_collaboration_app/core/di/injection.dart';
import 'package:devsync_open_source_collaboration_app/core/icons/app_icons.dart';
import 'package:devsync_open_source_collaboration_app/core/navigation/open_host_drawer.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_animations.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_colors.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_app_bar.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_empty_state.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_item_enter.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_page_fade.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_toast.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/presentation/cubit/requests_cubit.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/presentation/widgets/request_card.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/presentation/widgets/segmented_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key, this.onMenuPressed});

  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RequestsCubit>()..load(),
      child: _RequestsView(onMenuPressed: onMenuPressed),
    );
  }
}

class _RequestsView extends StatelessWidget {
  const _RequestsView({this.onMenuPressed});

  final VoidCallback? onMenuPressed;

  static String _emptyTitle(int tab) {
    return switch (tab) {
      1 => 'No received requests',
      2 => 'No sent requests',
      _ => 'No requests yet',
    };
  }

  static String _emptyMessage(int tab) {
    return switch (tab) {
      1 => 'When someone asks to join your project, it will show up here.',
      2 => 'Requests you send to join projects will appear here.',
      _ =>
        'When you send or receive collaboration requests, they will show up here.',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ds.background,
      appBar: DsAppBar(
        title: 'Requests',
        eyebrow: 'INBOX',
        showMenu: true,
        onMenu: () {
          if (onMenuPressed != null) {
            onMenuPressed!();
            return;
          }
          openHostDrawer(context);
        },
        onNotifications: () {
          Navigator.of(context).pushNamed(AppRoutes.notifications);
        },
        notificationBadge: true,
      ),
      body: DsPageFade(
        child: BlocListener<RequestsCubit, RequestsState>(
          listenWhen: (previous, current) =>
              current is RequestsLoaded &&
              current.actionError != null &&
              current.actionError !=
                  (previous is RequestsLoaded ? previous.actionError : null),
          listener: (context, state) {
            if (state case RequestsLoaded(actionError: final message?)) {
              showDsToast(context, message, tone: DsToastTone.error);
            }
          },
          child: BlocBuilder<RequestsCubit, RequestsState>(
            builder: (context, state) {
              return switch (state) {
                RequestsInitial() || RequestsLoading() => const Center(
                  child: CircularProgressIndicator(color: AppColors.teal),
                ),
                RequestsFailure(:final message) => DsEmptyState(
                  icon: AppIcons.error,
                  title: 'Could not load requests',
                  message: message,
                  actionLabel: 'Retry',
                  onAction: () => context.read<RequestsCubit>().load(),
                ),
                RequestsLoaded(:final tab, :final visible) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: SegmentedTabs(
                        index: tab,
                        onChanged: (i) =>
                            context.read<RequestsCubit>().setTab(i),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: AppAnimations.normal,
                        switchInCurve: AppAnimations.emphasized,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: visible.isEmpty
                            ? DsEmptyState(
                                key: ValueKey('empty-$tab'),
                                icon: AppIcons.inbox,
                                title: _emptyTitle(tab),
                                message: _emptyMessage(tab),
                              )
                            : ListView.builder(
                                key: ValueKey(tab),
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  24,
                                ),
                                itemCount: visible.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: DsItemEnter(
                                      index: index,
                                      child: ExpandedRequestCard(
                                        item: visible[index],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              };
            },
          ),
        ),
      ),
    );
  }
}
