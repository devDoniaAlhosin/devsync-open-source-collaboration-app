import 'package:equatable/equatable.dart';

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

  final String action;

  final DateTime? timestamp;

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
