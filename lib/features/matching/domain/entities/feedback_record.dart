import 'package:equatable/equatable.dart';

/// A single user feedback action on a project match.
///
/// Written by Yousef's like/skip feature; matching reads this read-only.
class FeedbackRecord extends Equatable {
  const FeedbackRecord({
    required this.id,
    required this.userId,
    required this.projectId,
    required this.action,
    this.timestamp,
    this.promptVersion,
  });

  final String id;
  final String userId;
  final String projectId;

  /// Raw action value from Firestore (e.g. "like", "skip").
  final String action;

  /// Nullable: Yousef's doc may omit this field.
  final DateTime? timestamp;

  /// Optional: version of the prompt associated with this recommendation.
  final String? promptVersion;

  bool get isLike => action == 'like';
  bool get isSkip => action == 'skip';

  @override
  List<Object?> get props => [
    id,
    userId,
    projectId,
    action,
    timestamp,
    promptVersion,
  ];
}
