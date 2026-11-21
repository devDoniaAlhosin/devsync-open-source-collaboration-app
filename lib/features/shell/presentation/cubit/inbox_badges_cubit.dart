import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../notifications/domain/usecases/watch_unread_notifications.dart';
import '../../../requests/domain/usecases/watch_pending_received_requests.dart';

part 'inbox_badges_state.dart';

/// Shell chrome dots: unread notifications + pending received requests.
class InboxBadgesCubit extends Cubit<InboxBadgesState> {
  InboxBadgesCubit({
    required WatchUnreadNotifications watchUnreadNotifications,
    required WatchPendingReceivedRequests watchPendingReceivedRequests,
  }) : super(const InboxBadgesState()) {
    _unreadSub = watchUnreadNotifications(const NoParams()).listen(
      (hasUnread) => emit(state.copyWith(hasUnreadNotifications: hasUnread)),
      onError: (_) => emit(state.copyWith(hasUnreadNotifications: false)),
    );
    _requestsSub = watchPendingReceivedRequests(const NoParams()).listen(
      (hasPending) => emit(state.copyWith(hasNewRequests: hasPending)),
      onError: (_) => emit(state.copyWith(hasNewRequests: false)),
    );
  }

  StreamSubscription<bool>? _unreadSub;
  StreamSubscription<bool>? _requestsSub;

  @override
  Future<void> close() async {
    await _unreadSub?.cancel();
    await _requestsSub?.cancel();
    return super.close();
  }
}
