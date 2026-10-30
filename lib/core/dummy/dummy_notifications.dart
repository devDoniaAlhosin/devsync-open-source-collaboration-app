/// Local seed data for the temporary notifications screen.
///
/// ## How to seed for test
///
/// **In-app (now):** open the bell → `/notifications`. Data is this list.
/// Edit titles / `unread` flags here and hot-restart. Tap a tile to toggle unread.
///
/// **Later Firestore (when FCM lands):** add `notifications` to
/// `FirestoreCollections`, then in Console create
/// `users/{uid}/notifications/{id}` docs like:
/// ```json
/// {
///   "title": "New collaboration request",
///   "subtitle": "Alex wants to join DevSync",
///   "unread": true,
///   "createdAt": "<server timestamp>",
///   "type": "request"
/// }
/// ```
/// Until the app reads Firestore, Console seeds will not show in-app.
class DummyNotification {
  const DummyNotification({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    this.unread = true,
  });

  final String id;
  final String title;
  final String subtitle;
  final DateTime createdAt;
  final bool unread;

  DummyNotification copyWith({bool? unread}) => DummyNotification(
    id: id,
    title: title,
    subtitle: subtitle,
    createdAt: createdAt,
    unread: unread ?? this.unread,
  );
}

List<DummyNotification> seedDummyNotifications() {
  final now = DateTime.now();
  return [
    DummyNotification(
      id: 'n1',
      title: 'New collaboration request',
      subtitle: 'Sara wants to join devsync-api · 10 min',
      createdAt: now.subtract(const Duration(minutes: 10)),
    ),
    DummyNotification(
      id: 'n2',
      title: 'Request accepted',
      subtitle: 'nova-tools/cli accepted you · 2 h',
      createdAt: now.subtract(const Duration(hours: 2)),
    ),
    DummyNotification(
      id: 'n3',
      title: 'Project update',
      subtitle: '3 new commits on devsync-api',
      createdAt: now.subtract(const Duration(days: 1, hours: 3)),
      unread: false,
    ),
    DummyNotification(
      id: 'n4',
      title: 'New matches',
      subtitle: '5 projects fit your skills',
      createdAt: now.subtract(const Duration(days: 2)),
      unread: false,
    ),
    DummyNotification(
      id: 'n5',
      title: 'Maintainer replied',
      subtitle: 'Bishay left a note on your join request · yesterday',
      createdAt: now.subtract(const Duration(days: 1, hours: 8)),
    ),
    DummyNotification(
      id: 'n6',
      title: 'Task assigned',
      subtitle: 'Wire FCM permission prompt · due this week',
      createdAt: now.subtract(const Duration(days: 3)),
      unread: false,
    ),
  ];
}
