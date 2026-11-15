import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../projects/domain/entities/project.dart';
import '../domain/entities/collaboration_request.dart';
import 'screens/notification_permission_screen.dart';
import 'widgets/request_join_sheet.dart';

/// Opens the join sheet; on **Done** pushes the notification soft-ask screen.
///
/// Returns `true` when the user completed send (reached Done). Dismissing the
/// sheet without Done returns `false` and does not navigate.
///
/// [onSent] exposes the message the user wrote so callers can persist the
/// request in the data layer after the flow finishes.
Future<bool> presentCollaborationRequestFlow(
  BuildContext context, {
  required String projectName,
  required String maintainerName,
  String? initials,
  int matchPercent = 0,
  ValueChanged<RequestJoinResult>? onSent,
}) async {
  final result = await showRequestJoinSheet(
    context,
    item: RequestItem(
      initials: initials ?? initialsFromTitle(projectName),
      title: projectName,
      subtitle: 'Pending',
      status: RequestStatus.pending,
      type: RequestType.sent,
      targetName: projectName,
      matchPercent: matchPercent,
    ),
    maintainerName: maintainerName,
  );

  if (!context.mounted || result == null) return false;

  onSent?.call(result);

  await Navigator.of(context).pushNamed(
    AppRoutes.notificationPermission,
    arguments: NotificationPermissionArgs(
      maintainerName: result.maintainerName,
      projectName: result.projectName,
    ),
  );

  return true;
}
