import 'package:firebase_core/firebase_core.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/match_feedback_action.dart';
import '../../domain/repositories/matching_feedback_repository.dart';
import '../datasources/matching_feedback_remote_data_source.dart';

class MatchingFeedbackRepositoryImpl implements MatchingFeedbackRepository {
  const MatchingFeedbackRepositoryImpl({
    required MatchingFeedbackRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final MatchingFeedbackRemoteDataSource _remoteDataSource;

  @override
  Future<Result<MatchFeedbackAction?>> saveFeedback({
    required String projectId,
    required MatchFeedbackAction action,
    String? promptVersion,
  }) async {
    try {
      final previousAction = await _remoteDataSource.saveFeedback(
        projectId: projectId,
        action: action,
        promptVersion: promptVersion,
      );
      return Success(previousAction);
    } on StateError {
      return const FailureResult(AuthFailure('Sign in to save your feedback.'));
    } on ArgumentError catch (error) {
      return FailureResult(
        ValidationFailure(error.message?.toString() ?? 'Invalid project ID.'),
      );
    } on FirebaseException catch (error) {
      return _firebaseFailure(error);
    } catch (_) {
      return const FailureResult(UnexpectedFailure());
    }
  }

  @override
  Future<Result<void>> clearFeedback({required String projectId}) async {
    try {
      await _remoteDataSource.clearFeedback(projectId: projectId);
      return const Success(null);
    } on StateError {
      return const FailureResult(AuthFailure('Sign in to save your feedback.'));
    } on ArgumentError catch (error) {
      return FailureResult(
        ValidationFailure(error.message?.toString() ?? 'Invalid project ID.'),
      );
    } on FirebaseException catch (error) {
      return _firebaseFailure(error);
    } catch (_) {
      return const FailureResult(UnexpectedFailure());
    }
  }

  FailureResult<T> _firebaseFailure<T>(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return const FailureResult(PermissionFailure());
      case 'unavailable':
      case 'deadline-exceeded':
      case 'network-request-failed':
        return const FailureResult(NetworkFailure());
      case 'not-found':
        return const FailureResult(NotFoundFailure());
      default:
        return const FailureResult(UnexpectedFailure());
    }
  }
}
