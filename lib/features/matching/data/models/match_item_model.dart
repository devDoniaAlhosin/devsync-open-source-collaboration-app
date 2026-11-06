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
    final score = json['score'];
    final skills = json['neededSkills'];
    final maintainerId = json['maintainerId'];
    final isFallback = json['isFallback'];
    if (score is! num ||
        !score.isFinite ||
        score < 0 ||
        score > 100 ||
        skills is! List ||
        skills.any((skill) => skill is! String) ||
        (maintainerId != null && maintainerId is! String) ||
        (isFallback != null && isFallback is! bool)) {
      throw const FormatException('Invalid project match');
    }
    return MatchItemModel(
      projectId: _readString(json, 'projectId', nonEmpty: true),
      projectName: _readString(json, 'projectName', nonEmpty: true),
      description: _readString(json, 'description'),
      githubUrl: _readString(json, 'githubUrl'),
      neededSkills: List<String>.unmodifiable(skills.cast<String>()),
      score: score.toDouble(),
      reason: _readString(json, 'reason'),
      maintainerId: maintainerId as String?,
      isFallback: isFallback as bool? ?? false,
    );
  }

  /// Parse from Firestore document data.
  factory MatchItemModel.fromFirestore(Map<String, dynamic> data) {
    final match = MatchItemModel.fromJson(data);
    final timestamp = data['likedAt'];
    if (timestamp != null && timestamp is! Timestamp) {
      throw const FormatException('Invalid saved match timestamp');
    }
    return MatchItemModel(
      projectId: match.projectId,
      projectName: match.projectName,
      description: match.description,
      githubUrl: match.githubUrl,
      neededSkills: match.neededSkills,
      score: match.score,
      reason: match.reason,
      maintainerId: match.maintainerId,
      isFallback: match.isFallback,
      likedAt: (timestamp as Timestamp?)?.toDate(),
    );
  }

  static String _readString(
    Map<String, dynamic> json,
    String key, {
    bool nonEmpty = false,
  }) {
    final value = json[key];
    if (value is! String || (nonEmpty && value.trim().isEmpty)) {
      throw FormatException('Invalid match $key');
    }
    return value;
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
