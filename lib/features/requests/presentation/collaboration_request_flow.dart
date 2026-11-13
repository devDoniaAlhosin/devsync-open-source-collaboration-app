import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/di/injection.dart';
import '../../projects/domain/entities/project.dart';
import '../domain/entities/collaboration_request.dart';
import 'cubit/requests_cubit.dart';
import 'screens/notification_permission_screen.dart';
import 'widgets/request_join_sheet.dart';

/// Saves the collaboration request before showing the success step.
Future<bool> presentCollaborationRequestFlow(
  BuildContext context, {
  required String projectName,
  required String maintainerName,
  String? initials,
  String? projectId,
  String? ownerId,
  int matchPercent = 0,
}) async {
  final resolvedProjectId = projectId?.trim();
  final resolvedOwnerId = ownerId?.trim();

  if (resolvedProjectId == null ||
      resolvedProjectId.isEmpty ||
      resolvedOwnerId == null ||
      resolvedOwnerId.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'This project is missing its project or maintainer account ID. '
          'A request cannot be sent yet.',
        ),
      ),
    );
    return false;
  }

  final requestItem = RequestItem(
    projectId: resolvedProjectId,
    ownerId: resolvedOwnerId,
    initials: initials ?? initialsFromTitle(projectName),
    title: projectName,
    subtitle: 'Pending',
    status: RequestStatus.pending,
    type: RequestType.sent,
    targetName: projectName,
    matchPercent: matchPercent,
  );

  final requestsCubit = getIt<RequestsCubit>();
  final RequestJoinResult? result;
  try {
    result = await showRequestJoinSheet(
      context,
      item: requestItem,
      maintainerName: maintainerName,
      onSend: (message) =>
          requestsCubit.create(requestItem.copyWith(message: message)),
    );
  } finally {
    await requestsCubit.close();
  }

  if (!context.mounted || result == null) return false;

  await Navigator.of(context).pushNamed(
    AppRoutes.notificationPermission,
    arguments: NotificationPermissionArgs(
      maintainerName: result.maintainerName,
      projectName: result.projectName,
    ),
  );

  return true;
}
