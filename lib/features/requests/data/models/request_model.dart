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
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return RequestModel(
      id: doc.id,
      projectId: data['projectId'] ?? '',
      senderId: data['senderId'],
      ownerId: data['ownerId'],
      initials: data['initials'] ?? '',
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      status: RequestStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => RequestStatus.pending,
      ),
      type: RequestType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => RequestType.sent,
      ),
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
