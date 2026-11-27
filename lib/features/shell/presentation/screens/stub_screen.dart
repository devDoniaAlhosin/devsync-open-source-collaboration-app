import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ds_app_bar.dart';
import '../../../../core/widgets/ds_empty_state.dart';
import '../widgets/inbox_badge_builder.dart';

/// Fallback when a route has no screen yet. Hidden from nav for unfinished features.
class StubScreen extends StatelessWidget {
  const StubScreen({
    super.key,
    required this.title,
    required this.owner,
    this.description,
  });

  final String title;
  final String owner;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return InboxBadgeBuilder(
      builder: (context, hasUnreadNotifications, _) {
        return Scaffold(
          backgroundColor: context.ds.background,
          appBar: DsAppBar(
            title: title,
            eyebrow: 'WORKSPACE',
            onNotifications: () {
              Navigator.of(context).pushNamed(AppRoutes.notifications);
            },
            notificationBadge: hasUnreadNotifications,
          ),
          body: DsEmptyState(
            icon: AppIcons.projects,
            title: title,
            message: description ?? 'This screen is not available right now.',
            actionLabel: 'Back',
            onAction: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
        );
      },
    );
  }
}
