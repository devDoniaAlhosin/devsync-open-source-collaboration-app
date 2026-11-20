import '../../../../core/result/result.dart';
import '../entities/app_notification.dart';

abstract class NotificationsRepository {
  Future<Result<List<AppNotification>>> getNotifications();
  Future<Result<void>> markRead(String notificationId);
}
