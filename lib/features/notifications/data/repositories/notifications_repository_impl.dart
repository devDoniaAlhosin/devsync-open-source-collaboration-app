import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl({
    required NotificationsRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final NotificationsRemoteDataSource _remote;

  @override
  Future<Result<List<AppNotification>>> getNotifications() async {
    try {
      return Success(await _remote.fetchNotifications());
    } on StateError {
      return const FailureResult(AuthFailure('Sign in to view notifications.'));
    } on FirebaseException catch (e) {
      return _firebaseFailure(e);
    } catch (_) {
      return const FailureResult(UnexpectedFailure());
    }
  }

  @override
  Future<Result<void>> markRead(String notificationId) async {
    try {
      await _remote.markRead(notificationId);
      return const Success(null);
    } on StateError {
      return const FailureResult(AuthFailure('Sign in to view notifications.'));
    } on FirebaseException catch (e) {
      return _firebaseFailure(e);
    } catch (_) {
      return const FailureResult(UnexpectedFailure());
    }
  }

  FailureResult<T> _firebaseFailure<T>(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return const FailureResult(PermissionFailure());
      case 'unavailable':
      case 'deadline-exceeded':
        return const FailureResult(NetworkFailure());
      default:
        return const FailureResult(UnexpectedFailure());
    }
  }
}
