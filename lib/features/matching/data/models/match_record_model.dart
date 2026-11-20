import 'package:cloud_firestore/cloud_firestore.dart';

class MatchRecordModel {
  const MatchRecordModel({
    required this.userId,
    required this.projectId,
    required this.score,
    required this.reason,
    required this.promptVersion,
    this.matchId = '',
    this.projectName = '',
    this.description = '',
    this.githubUrl = '',
    this.neededSkills = const [],
    this.createdAt,
  });

  final String matchId;
  final String userId;
  final String projectId;
  final double score;
  final String reason;
  final String promptVersion;
  final String projectName;
  final String description;
  final String githubUrl;
  final List<String> neededSkills;
  final DateTime? createdAt;

  factory MatchRecordModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    if (data == null) throw const FormatException('Missing match data');

    final matchId = (data['matchId'] as String?)?.trim() ?? document.id;
    final userId = data['userId'];
    final projectId = data['projectId'];
    final score = data['score'];
    final reason = data['reason'] as String? ?? '';
    final promptVersion = data['promptVersion'] as String? ?? '';
    final createdAt = _readDate(data['createdAt']);
    final projectName = data['projectName'] as String? ?? '';
    final description = data['description'] as String? ?? '';
    final githubUrl = data['githubUrl'] as String? ?? '';
    final neededSkills =
        (data['neededSkills'] as List?)?.whereType<String>().toList(
          growable: false,
        ) ??
        const [];

    if (userId is! String ||
        userId.trim().isEmpty ||
        projectId is! String ||
        projectId.trim().isEmpty ||
        score is! num ||
        !score.isFinite ||
        score < 0 ||
        score > 100) {
      throw const FormatException('Invalid match data');
    }

    return MatchRecordModel(
      matchId: matchId.isNotEmpty ? matchId : document.id,
      userId: userId,
      projectId: projectId,
      score: score.toDouble(),
      reason: reason,
      promptVersion: promptVersion,
      projectName: projectName,
      description: description,
      githubUrl: githubUrl,
      neededSkills: neededSkills,
      createdAt: createdAt,
    );
  }

  Map<String, Object?> toFirestore() {
    final id = matchId.isNotEmpty ? matchId : '${userId}_$projectId';
    return {
      'matchId': id,
      'userId': userId,
      'projectId': projectId,
      'score': score,
      'reason': reason,
      'promptVersion': promptVersion,
      if (projectName.isNotEmpty) 'projectName': projectName,
      if (description.isNotEmpty) 'description': description,
      if (githubUrl.isNotEmpty) 'githubUrl': githubUrl,
      if (neededSkills.isNotEmpty) 'neededSkills': neededSkills,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static DateTime? _readDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
