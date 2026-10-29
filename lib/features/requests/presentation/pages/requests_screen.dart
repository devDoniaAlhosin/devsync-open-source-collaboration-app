import 'package:devsync_open_source_collaboration_app/core/dummy/dummy_requests.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_animations.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/domain/entities/collaboration_request.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/presentation/widgets/request_card.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/presentation/widgets/segmented_tabs.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/presentation/widgets/team_message_button.dart';
import 'package:flutter/material.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 6, top: 8),
                    child: Text(
                      '2 need you',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6, bottom: 14),
                    child: Text(
                      'Requests',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  SegmentedTabs(
                    index: _tab,
                    onChanged: (i) => setState(() => _tab = i),
                  ),
                  const SizedBox(height: 14),
                  AnimatedSwitcher(
                    duration: AppAnimations.normal,
                    switchInCurve: AppAnimations.emphasized,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      final offset = animation.drive(
                        Tween(
                          begin: const Offset(0.3, 0),
                          end: Offset.zero,
                        ).chain(CurveTween(curve: AppAnimations.emphasized)),
                      );
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: offset, child: child),
                      );
                    },
                    child: Column(
                      key: ValueKey(_tab),
                      children: [
                        for (final item in _visibleRequests) ...[
                          ExpandedRequestCard(item: item),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const TeamMessagesButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
