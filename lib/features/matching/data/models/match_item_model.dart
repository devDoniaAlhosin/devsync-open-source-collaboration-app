import '../../domain/entities/match_item.dart';

/// Serializable model for a match item — adds JSON conversion on top of the
/// domain entity.
///
/// Used by data sources to parse Cloud Function responses and Firestore
/// documents into the domain [MatchItem].
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
  });

  /// Parse from the Cloud Function JSON response or Firestore document.
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

  /// Serialize for Firestore cache storage.
  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'projectName': projectName,
      'description': description,
      'githubUrl': githubUrl,
      'neededSkills': neededSkills,
      'score': score,
      'reason': reason,
      if (maintainerId != null) 'maintainerId': maintainerId,
      'isFallback': isFallback,
    };
  }

  /// Convert a domain entity to this model (useful for caching).
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
    );
  }
}
