class CollaborationRequest {
  const CollaborationRequest({
    required this.id,
    required this.projectId,
    required this.senderId,
    required this.recipientId,
    required this.message,
    required this.status,
    required this.direction,
    this.projectName,
    this.senderName,
    this.recipientName,
    this.createdAt,
  });

  final String id;
  final String projectId;
  final String senderId;
  final String recipientId;
  final String message;

  final CollaborationRequestStatus status;
  final CollaborationRequestDirection direction;

  final String? projectName;
  final String? senderName;
  final String? recipientName;
  final DateTime? createdAt;

  bool get isPending => status == CollaborationRequestStatus.pending;

  bool get isIncoming => direction == CollaborationRequestDirection.incoming;
}

enum CollaborationRequestStatus { pending, accepted, declined }

enum CollaborationRequestDirection { incoming, outgoing }
