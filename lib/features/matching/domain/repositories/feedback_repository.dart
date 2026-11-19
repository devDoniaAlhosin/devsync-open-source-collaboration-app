import '../../../../core/result/result.dart';
import '../entities/feedback_record.dart';

/// Read-only contract for fetching the current user's feedback from Firestore.
///
/// Matching never writes feedback; Yousef's feature owns writes.
abstract class FeedbackRepository {
  /// Returns all feedback docs where `userId == currentUser.uid`.
  ///
  /// Sorted by [FeedbackRecord.timestamp] descending in Dart (no composite
  /// index needed). Latest doc per [FeedbackRecord.projectId] wins.
  ///
  /// Returns [Failure] on auth error or Firestore failure.
  Future<Result<List<FeedbackRecord>>> getUserFeedback();
}
