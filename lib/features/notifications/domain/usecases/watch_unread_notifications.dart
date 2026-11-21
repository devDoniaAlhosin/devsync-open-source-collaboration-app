import '../../../../core/usecase/usecase.dart';
import '../repositories/notifications_repository.dart';

class WatchUnreadNotifications implements StreamUseCase<bool, NoParams> {
  WatchUnreadNotifications(this._repository);

  final NotificationsRepository _repository;

  @override
  Stream<bool> call(NoParams params) => _repository.watchHasUnread();
}
