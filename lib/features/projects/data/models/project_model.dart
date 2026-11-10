import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/project.dart';
import '../../domain/entities/project_stats.dart';
import 'project_stats_model.dart';

/// Cached GitHub repository metrics.
///
/// Written by the DevSync API sync job (and refreshed opportunistically by
/// [GithubRemoteDataSource]) so cards can render without hitting GitHub on
/// every rebuild.
class GithubMetricsModel {
  const GithubMetricsModel({
    this.stars = 0,
    this.contributors = 0,
    this.openTasks = 0,
    this.syncedAt,
  });

  static const empty = GithubMetricsModel();

  final int stars;
  final int contributors;
  final int openTasks;
  final DateTime? syncedAt;

  bool get isEmpty => stars == 0 && contributors == 0 && openTasks == 0;

  bool isFresh({Duration maxAge = const Duration(hours: 6)}) {
    final synced = syncedAt;
    if (synced == null) return false;
    return DateTime.now().difference(synced) < maxAge;
  }

  factory GithubMetricsModel.fromValue(Object? value) {
    if (value is! Map) return empty;
    return GithubMetricsModel(
      stars: _asInt(value['stars'] ?? value['stargazersCount']),
      contributors: _asInt(value['contributors']),
      openTasks: _asInt(value['openTasks'] ?? value['openIssues']),
      syncedAt: _asDate(value['syncedAt'] ?? value['updatedAt']),
    );
  }

  Map<String, Object?> toFirestore() {
    return {
      'stars': stars,
      'contributors': contributors,
      'openTasks': openTasks,
      'syncedAt': syncedAt ?? DateTime.now(),
    };
  }
}

/// Firestore DTO for a project document.
///
/// Extends the domain [Project] directly; the extra fields are cached data
/// owned by the AI matching engine and the GitHub sync job. They are read-only
/// for this feature, so [toFirestore] deliberately omits them.
class ProjectModel extends Project {
  const ProjectModel({
    required super.id,
    required super.title,
    required super.description,
    required super.githubUrl,
    required super.techStack,
    required super.requiredContributors,
    required super.viewsCount,
    required super.requestsCount,
    required super.matchPercentage,
    required super.isOwner,
    super.ownerId,
    super.ownerName,
    super.createdAt,
    super.hasPendingRequest,
    this.updatedAt,
    this.matchSummary = '',
    this.alignments = const [],
    this.matchedSkills = const [],
    this.github = GithubMetricsModel.empty,
  });

  final DateTime? updatedAt;
  final String matchSummary;
  final List<SkillAlignment> alignments;
  final List<String> matchedSkills;
  final GithubMetricsModel github;

  factory ProjectModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    String? currentUserId,
    Set<String> pendingRequestProjectIds = const {},
  }) {
    return ProjectModel.fromMap(
      doc.id,
      doc.data() ?? const <String, dynamic>{},
      currentUserId: currentUserId,
      pendingRequestProjectIds: pendingRequestProjectIds,
    );
  }

  factory ProjectModel.fromMap(
    String id,
    Map<String, dynamic> data, {
    String? currentUserId,
    Set<String> pendingRequestProjectIds = const {},
  }) {
    final ownerId = _asString(data['ownerId'] ?? data['ownerUid']);
    return ProjectModel(
      id: id,
      title: _asString(data['title']),
      description: _asString(data['description']),
      githubUrl: _asString(data['githubUrl']),
      techStack: _asStringList(data['techStack']),
      requiredContributors: _asInt(
        data['requiredContributors'] ?? data['contributorsNeeded'],
      ),
      viewsCount: _asInt(data['viewsCount']),
      requestsCount: _asInt(data['requestsCount']),
      matchPercentage: _asPercent(data['matchPercentage']),
      isOwner: ownerId.isNotEmpty && ownerId == currentUserId,
      ownerId: ownerId,
      ownerName: _asString(data['ownerName']),
      createdAt: _asDate(data['createdAt']),
      hasPendingRequest: pendingRequestProjectIds.contains(id),
      updatedAt: _asDate(data['updatedAt']),
      matchSummary: _asString(data['matchSummary']),
      alignments: _asAlignments(data['alignments']),
      matchedSkills: _asStringList(data['matchedSkills']),
      github: GithubMetricsModel.fromValue(data['github']),
    );
  }

  /// Payload for create/update. Never writes AI or repository-metric fields.
  Map<String, Object?> toFirestore({
    required String ownerId,
    required bool isNew,
  }) {
    final now = DateTime.now();
    return {
      'ownerId': ownerId,
      if (ownerName.trim().isNotEmpty) 'ownerName': ownerName.trim(),
      'title': title.trim(),
      'description': description.trim(),
      'githubUrl': githubUrl.trim(),
      if (githubRepoFullName.isNotEmpty) 'githubRepo': githubRepoFullName,
      'techStack': List<String>.of(techStack),
      'requiredContributors': requiredContributors,
      'updatedAt': now,
      if (isNew) 'createdAt': now,
      if (isNew) 'viewsCount': 0,
      if (isNew) 'requestsCount': 0,
    };
  }

  /// `owner/repo` parsed from [githubUrl], or an empty string.
  String get githubRepoFullName {
    final uri = Uri.tryParse(githubUrl.trim());
    if (uri == null || !uri.host.toLowerCase().contains('github.com')) {
      return '';
    }
    final segments = uri.pathSegments
        .where((segment) => segment.trim().isNotEmpty)
        .toList(growable: false);
    if (segments.length < 2) return '';
    var repo = segments[1];
    if (repo.toLowerCase().endsWith('.git')) {
      repo = repo.substring(0, repo.length - 4);
    }
    return '${segments[0]}/$repo';
  }

  ProjectStats toStats({
    required String ownerName,
    required String ownerResponseTime,
    required List<double> weeklyViews,
    GithubMetricsModel? liveGithub,
  }) {
    final metrics = liveGithub ?? github;
    return ProjectStats(
      stars: metrics.stars,
      contributors: metrics.contributors,
      openTasks: metrics.openTasks,
      ownerName: ownerName,
      ownerResponseTime: ownerResponseTime,
      updatedLabel: relativeUpdatedLabel(updatedAt ?? createdAt),
      matchSummary: matchSummary.trim().isEmpty
          ? ProjectStatsModel.fallbackSummary
          : matchSummary.trim(),
      alignments: alignments,
      matchedSkills: matchedSkills,
      weeklyViews: ProjectStatsModel.normalizeWeeklyViews(weeklyViews),
    );
  }
}

String _asString(Object? value) => value is String ? value.trim() : '';

int _asInt(Object? value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

int _asPercent(Object? value) {
  final parsed = _asInt(value);
  if (parsed < 0) return 0;
  if (parsed > 100) return 100;
  return parsed;
}

DateTime? _asDate(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  return null;
}

List<String> _asStringList(Object? value) {
  if (value is! Iterable) return const [];
  return value
      .where((item) => item != null)
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

List<SkillAlignment> _asAlignments(Object? value) {
  if (value is! Iterable) return const [];
  return [
    for (final item in value)
      if (item is Map)
        SkillAlignment(
          label: _asString(item['label'] ?? item['skill']),
          score: _asPercent(item['score']),
        ),
  ].where((alignment) => alignment.label.isNotEmpty).toList(growable: false);
}
