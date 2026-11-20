import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore representation of a user's liked match row.
class MatchRecordModel {
  const MatchRecordModel({
    required this.userId,
    required this.projectId,
    required this.score,
    required this.reason,
    required this.promptVersion,
    this.createdAt,
  });

  final String userId;
  final String projectId;
  final double score;
  final String reason;
  final String promptVersion;
  final DateTime? createdAt;

  factory MatchRecordModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    if (data == null) throw const FormatException('Missing match data');

    final userId = data['userId'];
    final projectId = data['projectId'];
    final score = data['score'];
    final reason = data['reason'];
    final promptVersion = data['promptVersion'];
    final createdAt = _readDate(data['createdAt']);

    if (userId is! String || userId.trim().isEmpty ||
        projectId is! String || projectId.trim().isEmpty ||
        score is! num || !score.isFinite || score < 0 || score > 100 ||
        reason is! String || promptVersion is! String) {
      throw const FormatException('Invalid match data');
    }

    return MatchRecordModel(
      userId: userId,
      projectId: projectId,
      score: score.toDouble(),
      reason: reason,
      promptVersion: promptVersion,
      createdAt: createdAt,
    );
  }

  Map<String, Object?> toFirestore() => {
    'userId': userId,
    'projectId': projectId,
    'score': score,
    'reason': reason,
    'promptVersion': promptVersion,
    'createdAt': FieldValue.serverTimestamp(),
  };

  static DateTime? _readDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
