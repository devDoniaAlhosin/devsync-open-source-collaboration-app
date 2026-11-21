import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/notifications_repository.dart';

class MarkNotificationReadParams {
  const MarkNotificationReadParams(this.notificationId);

  final String notificationId;
}

class MarkNotificationRead
    implements UseCase<void, MarkNotificationReadParams> {
  MarkNotificationRead(this._repository);

  final NotificationsRepository _repository;

  @override
  Future<Result<void>> call(MarkNotificationReadParams params) {
    return _repository.markRead(params.notificationId);
  }
}
