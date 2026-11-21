import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/mark_notification_read.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({
    required GetNotifications getNotifications,
    required MarkNotificationRead markNotificationRead,
  }) : _getNotifications = getNotifications,
       _markNotificationRead = markNotificationRead,
       super(const NotificationsInitial());

  final GetNotifications _getNotifications;
  final MarkNotificationRead _markNotificationRead;

  Future<void> load() async {
    emit(const NotificationsLoading());
    final result = await _getNotifications(const NoParams());
    switch (result) {
      case Success(:final data):
        emit(NotificationsLoaded(items: data));
      case FailureResult(:final failure):
        emit(NotificationsFailure(failure.message));
    }
  }

  Future<void> markRead(String id) async {
    final current = state;
    if (current is! NotificationsLoaded) return;

    final result = await _markNotificationRead(
      MarkNotificationReadParams(id),
    );
    if (result is! Success) return;

    emit(
      current.copyWith(
        items: [
          for (final item in current.items)
            if (item.id == id) item.copyWith(read: true) else item,
        ],
      ),
    );
  }
}
