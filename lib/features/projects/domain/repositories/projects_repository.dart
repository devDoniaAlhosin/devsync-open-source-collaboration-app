import '../../../../core/result/result.dart';
import '../entities/collaboration_request_receipt.dart';
import '../entities/project.dart';
import '../entities/project_stats.dart';

/// Contract for project discovery, ownership and collaboration requests.
///
/// The implementation lives in the data layer and talks to Cloud Firestore,
/// the GitHub API and the DevSync API. Presentation only depends on this
/// interface.
abstract class ProjectsRepository {
  /// Projects visible in Discover plus the signed-in user's owned projects.
  ///
  /// Viewer-relative flags (`isOwner`, `hasPendingRequest`) are resolved by the
  /// implementation from the current Firebase session.
  Future<Result<List<Project>>> getProjects();

  /// Aggregated details for the project screen: cached AI match data, GitHub
  /// repository metrics, owner profile and the last seven days of views.
  Future<Result<ProjectStats>> getStats(String projectId);

  /// Creates a new project or updates one the signed-in user owns.
  ///
  /// AI-owned fields (`matchPercentage`, alignment data, GitHub metrics) are
  /// never written from the client.
  Future<Result<Project>> upsert(Project project);

  /// Writes a pending collaboration request and notifies the owner.
  ///
  /// Idempotent: an existing pending request is returned with
  /// [CollaborationRequestReceipt.created] set to `false`.
  Future<Result<CollaborationRequestReceipt>> requestToCollaborate({
    required Project project,
    String? message,
  });

  /// Number of accepted collaboration requests across the user's projects.
  Future<Result<int>> getJoinedContributions();

  /// Records a unique daily view for [projectId] and bumps its view counter.
  Future<Result<void>> recordView(String projectId);
}
