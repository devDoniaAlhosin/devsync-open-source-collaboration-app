import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/match_item.dart';

/// Data model for serializing [MatchItem] to/from Firestore.
///
/// This extends the domain entity with Firestore-specific serialization methods.
class MatchItemModel extends MatchItem {
  const MatchItemModel({
    required super.projectId,
    required super.projectName,
    required super.description,
    required super.githubUrl,
    required super.neededSkills,
    required super.score,
    required super.reason,
    super.maintainerId,
    super.isFallback,
    this.likedAt,
  });

  /// Timestamp when this match was liked (for Firestore sorting).
  final DateTime? likedAt;

  /// Convert domain entity to Firestore model.
  factory MatchItemModel.fromEntity(MatchItem entity) {
    return MatchItemModel(
      projectId: entity.projectId,
      projectName: entity.projectName,
      description: entity.description,
      githubUrl: entity.githubUrl,
      neededSkills: entity.neededSkills,
      score: entity.score,
      reason: entity.reason,
      maintainerId: entity.maintainerId,
      isFallback: entity.isFallback,
      likedAt: DateTime.now(),
    );
  }

  /// Parse from the API JSON response (for HTTP data source).
  factory MatchItemModel.fromJson(Map<String, dynamic> json) {
    return MatchItemModel(
      projectId: json['projectId'] as String,
      projectName: json['projectName'] as String,
      description: json['description'] as String? ?? '',
      githubUrl: json['githubUrl'] as String? ?? '',
      neededSkills: List<String>.from(json['neededSkills'] as List? ?? []),
      score: (json['score'] as num).toDouble(),
      reason: json['reason'] as String? ?? '',
      maintainerId: json['maintainerId'] as String?,
      isFallback: json['isFallback'] as bool? ?? false,
    );
  }

  /// Parse from Firestore document data.
  factory MatchItemModel.fromFirestore(Map<String, dynamic> data) {
    return MatchItemModel(
      projectId: data['projectId'] as String? ?? '',
      projectName: data['projectName'] as String? ?? '',
      description: data['description'] as String? ?? '',
      githubUrl: data['githubUrl'] as String? ?? '',
      neededSkills:
          (data['neededSkills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      score: (data['score'] as num?)?.toDouble() ?? 0.0,
      reason: data['reason'] as String? ?? '',
      maintainerId: data['maintainerId'] as String?,
      isFallback: data['isFallback'] as bool? ?? false,
      likedAt: (data['likedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Serialize to Firestore document data.
  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'projectName': projectName,
      'description': description,
      'githubUrl': githubUrl,
      'neededSkills': neededSkills,
      'score': score,
      'reason': reason,
      'maintainerId': maintainerId,
      'isFallback': isFallback,
      'likedAt': likedAt != null
          ? Timestamp.fromDate(likedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  /// Convert model back to domain entity.
  MatchItem toEntity() {
    return MatchItem(
      projectId: projectId,
      projectName: projectName,
      description: description,
      githubUrl: githubUrl,
      neededSkills: neededSkills,
      score: score,
      reason: reason,
      maintainerId: maintainerId,
      isFallback: isFallback,
    );
  }
}
