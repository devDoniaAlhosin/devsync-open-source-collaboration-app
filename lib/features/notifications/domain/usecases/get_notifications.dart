import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/app_notification.dart';
import '../repositories/notifications_repository.dart';

class GetNotifications implements UseCase<List<AppNotification>, NoParams> {
  GetNotifications(this._repository);

  final NotificationsRepository _repository;

  @override
  Future<Result<List<AppNotification>>> call(NoParams params) {
    return _repository.getNotifications();
  }
}
