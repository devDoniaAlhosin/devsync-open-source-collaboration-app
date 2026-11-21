abstract final class FirestoreCollections {
  static const users = 'users';
  static const fcmTokens = 'fcmTokens';
  /// Inbox under `users/{uid}/notifications/{id}` (Admin write, owner read).
  static const notifications = 'notifications';
  static const projects = 'projects';
  static const views = 'views';
  /// Liked / saved Heart actions. Doc id = `{uid}_{projectId}`.
  static const matches = 'matches';
  /// Like / skip analytics. Doc id = `{uid}_{projectId}`.
  static const feedbacks = 'feedbacks';
  static const requests = 'requests';
  static const tasks = 'tasks';
}
