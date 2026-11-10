import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/collaboration_request_receipt.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_stats.dart';
import '../../domain/repositories/projects_repository.dart';
import '../datasources/projects_remote_data_source.dart';
import '../mappers/projects_failure_mapper.dart';

class ProjectsRepositoryImpl implements ProjectsRepository {
  ProjectsRepositoryImpl({required ProjectsRemoteDataSource remote})
    : _remote = remote;

  final ProjectsRemoteDataSource _remote;

  @override
  Future<Result<List<Project>>> getProjects() {
    return _guard(_remote.fetchProjects);
  }

  @override
  Future<Result<ProjectStats>> getStats(String projectId) {
    if (projectId.trim().isEmpty) {
      return Future.value(
        const FailureResult<ProjectStats>(
          ValidationFailure('Project id is required'),
        ),
      );
    }
    return _guard(() => _remote.fetchStats(projectId));
  }

  @override
  Future<Result<Project>> upsert(Project project) {
    final title = project.title.trim();
    if (title.isEmpty) {
      return Future.value(
        const FailureResult<Project>(
          ValidationFailure('Project title is required', field: 'title'),
        ),
      );
    }
    if (project.description.trim().isEmpty) {
      return Future.value(
        const FailureResult<Project>(
          ValidationFailure(
            'Describe what you are building',
            field: 'description',
          ),
        ),
      );
    }

    final uri = Uri.tryParse(project.githubUrl.trim());
    if (uri == null ||
        !uri.hasAuthority ||
        !uri.host.toLowerCase().contains('github.com')) {
      return Future.value(
        const FailureResult<Project>(
          ValidationFailure(
            'Use a valid github.com repository link',
            field: 'githubUrl',
          ),
        ),
      );
    }
    if (project.techStack.isEmpty) {
      return Future.value(
        const FailureResult<Project>(
          ValidationFailure('Choose at least one skill', field: 'techStack'),
        ),
      );
    }
    if (project.requiredContributors < 1) {
      return Future.value(
        const FailureResult<Project>(
          ValidationFailure(
            'Add at least one required contributor',
            field: 'requiredContributors',
          ),
        ),
      );
    }

    return _guard(() => _remote.upsert(project));
  }

  @override
  Future<Result<CollaborationRequestReceipt>> requestToCollaborate({
    required Project project,
    String? message,
  }) {
    if (project.id.trim().isEmpty) {
      return Future.value(
        const FailureResult<CollaborationRequestReceipt>(
          ValidationFailure('Pick a project before requesting to collaborate'),
        ),
      );
    }
    return _guard(
      () => _remote.requestToCollaborate(project: project, message: message),
    );
  }

  @override
  Future<Result<int>> getJoinedContributions() {
    return _guard(_remote.fetchJoinedContributions);
  }

  @override
  Future<Result<void>> recordView(String projectId) {
    return _guard(() => _remote.recordView(projectId));
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } on Object catch (error) {
      return FailureResult(mapProjectsError(error));
    }
  }
}
