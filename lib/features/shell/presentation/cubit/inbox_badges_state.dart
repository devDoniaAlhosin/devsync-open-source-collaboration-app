part of 'inbox_badges_cubit.dart';

final class InboxBadgesState extends Equatable {
  const InboxBadgesState({
    this.hasUnreadNotifications = false,
    this.hasNewRequests = false,
  });

  final bool hasUnreadNotifications;
  final bool hasNewRequests;

  InboxBadgesState copyWith({
    bool? hasUnreadNotifications,
    bool? hasNewRequests,
  }) {
    return InboxBadgesState(
      hasUnreadNotifications:
          hasUnreadNotifications ?? this.hasUnreadNotifications,
      hasNewRequests: hasNewRequests ?? this.hasNewRequests,
    );
  }

  @override
  List<Object?> get props => [hasUnreadNotifications, hasNewRequests];
}
