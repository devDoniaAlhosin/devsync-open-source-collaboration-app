import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/collaboration_request.dart';

class RequestModel extends RequestItem {
  const RequestModel({
    required super.id,
    required super.projectId,
    required super.senderId,
    required super.ownerId,
    required super.initials,
    required super.title,
    required super.subtitle,
    required super.status,
    required super.type,
    super.message,
    super.displayName,
    super.targetName,
    super.matchPercent,
    super.matchSummary,
    super.repositoryCount,
    super.commitCount,
    super.languageCount,
    super.skills,
    super.createdAt,
    super.respondedAt,
  });

  factory RequestModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String currentUserId,
  }) {
    final data = doc.data()!;
    final senderId = data['senderId'] as String?;
    final ownerId = data['ownerId'] as String?;
    final status = RequestStatus.values.firstWhere(
      (e) => e.name == data['status'],
      orElse: () => RequestStatus.pending,
    );

    return RequestModel(
      id: doc.id,
      projectId: data['projectId'] ?? '',
      senderId: senderId,
      ownerId: ownerId,
      initials: data['initials'] ?? '',
      title: data['title'] ?? '',
      subtitle: switch (status) {
        RequestStatus.accepted => 'Accepted',
        RequestStatus.declined => 'Declined',
        RequestStatus.pending || RequestStatus.isNew =>
          (data['subtitle'] as String?)?.trim().isNotEmpty == true
              ? data['subtitle'] as String
              : 'Pending',
      },
      status: status,
      type: ownerId == currentUserId && senderId != currentUserId
          ? RequestType.received
          : RequestType.sent,
      message: data['message'],
      displayName: data['displayName'] ?? 'Contributor',
      targetName: data['targetName'] ?? '',
      matchPercent: data['matchPercent'] ?? 0,
      matchSummary: data['matchSummary'] ?? '',
      repositoryCount: data['repositoryCount'] ?? 0,
      commitCount: data['commitCount'] ?? 0,
      languageCount: data['languageCount'] ?? 0,
      skills: List<String>.from(data['skills'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      respondedAt: (data['respondedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'senderId': senderId,
      'ownerId': ownerId,
      'initials': initials,
      'title': title,
      'subtitle': subtitle,
      'status': status.name,
      'type': type.name,
      'message': message,
      'displayName': displayName,
      'targetName': targetName,
      'matchPercent': matchPercent,
      'matchSummary': matchSummary,
      'repositoryCount': repositoryCount,
      'commitCount': commitCount,
      'languageCount': languageCount,
      'skills': skills,
      'createdAt': FieldValue.serverTimestamp(),
      'respondedAt': null,
    };
  }
}
