import 'package:devsync_open_source_collaboration_app/app/app_routes.dart';
import 'package:devsync_open_source_collaboration_app/core/dummy/dummy_requests.dart';
import 'package:devsync_open_source_collaboration_app/core/navigation/open_host_drawer.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_animations.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_app_bar.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_item_enter.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_page_fade.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/domain/entities/collaboration_request.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/presentation/widgets/request_card.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/presentation/widgets/segmented_tabs.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/presentation/widgets/team_message_button.dart';
import 'package:flutter/material.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key, this.onMenuPressed});

  final VoidCallback? onMenuPressed;

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  int _tab = 0;

  List<RequestItem> get _visibleRequests {
    switch (_tab) {
      case 1:
        return requests
            .where((item) => item.type == RequestType.received)
            .toList();
      case 2:
        return requests.where((item) => item.type == RequestType.sent).toList();
      default:
        return requests;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _visibleRequests;

    return Scaffold(
      appBar: DsAppBar(
        title: 'Requests',
        eyebrow: 'INBOX',
        showMenu: true,
        onMenu: () {
          if (widget.onMenuPressed != null) {
            widget.onMenuPressed!();
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SegmentedTabs(
                index: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppAnimations.normal,
                switchInCurve: AppAnimations.emphasized,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: ListView.builder(
                  key: ValueKey(_tab),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == items.length) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: DsItemEnter(
                          index: 0,
                          child: TeamMessagesButton(),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: DsItemEnter(
                        index: index,
                        child: ExpandedRequestCard(item: items[index]),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
