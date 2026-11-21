import '../../../../core/result/result.dart';
import '../entities/project.dart';
import '../entities/project_stats.dart';

/// Contract for project discovery and ownership.
///
/// The implementation lives in the data layer and talks to Cloud Firestore,
/// the GitHub API and the DevSync API. Presentation only depends on this
/// interface.
///
/// Collaboration requests are intentionally **not** part of this contract:
/// the requests feature (`RequestsCubit` / `RequestModel`) owns their creation.
abstract class ProjectsRepository {
  /// Projects visible in Discover plus the signed-in user's owned projects.
  ///
  /// Viewer-relative flags (`isOwner`, `hasPendingRequest`) are resolved by the
  /// implementation from the current Firebase session.
  Future<Result<List<Project>>> getProjects();

  /// One project document, with viewer-relative flags resolved.
  Future<Result<Project>> getProject(String projectId);

  /// Aggregated details for the project screen: cached AI match data, GitHub
  /// repository metrics, owner profile and the last seven days of views.
  Future<Result<ProjectStats>> getStats(String projectId);

  /// Creates a new project or updates one the signed-in user owns.
  ///
  /// The data layer stamps `ownerId` from the Firebase session and always
  /// writes a non-empty `ownerName`. AI-owned fields (`matchPercentage`,
  /// alignment data, GitHub metrics) are never written from the client.
  Future<Result<Project>> upsert(Project project);

  /// Deletes a project the signed-in user owns.
  Future<Result<void>> delete(String projectId);

  /// Number of accepted collaboration requests across the user's projects.
  Future<Result<int>> getJoinedContributions();

  /// Records a unique daily view for [projectId] and bumps its view counter.
  Future<Result<void>> recordView(String projectId);
}
