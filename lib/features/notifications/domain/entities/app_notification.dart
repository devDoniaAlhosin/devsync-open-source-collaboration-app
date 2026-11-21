class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.read,
    required this.createdAt,
    this.requestId = '',
    this.projectId = '',
  });

  final String id;
  final String title;
  final String body;
  final String type;
  final bool read;
  final DateTime createdAt;
  final String requestId;
  final String projectId;

  AppNotification copyWith({bool? read}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      type: type,
      read: read ?? this.read,
      createdAt: createdAt,
      requestId: requestId,
      projectId: projectId,
    );
  }
}
