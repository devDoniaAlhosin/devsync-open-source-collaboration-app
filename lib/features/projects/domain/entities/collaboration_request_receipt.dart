/// Result of asking to collaborate on a project.
///
/// [created] is `false` when the same user already had a pending request for
/// the project. The operation is idempotent, so callers should treat that as a
/// success too — it just must not increment the project's request counter.
class CollaborationRequestReceipt {
  const CollaborationRequestReceipt({
    required this.requestId,
    required this.projectId,
    required this.created,
  });

  final String requestId;
  final String projectId;
  final bool created;
}
