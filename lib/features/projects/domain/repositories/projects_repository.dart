import '../../../../core/result/result.dart';
import '../entities/project.dart';
import '../entities/project_stats.dart';

abstract class ProjectsRepository {
  Future<Result<List<Project>>> getProjects();

  Future<Result<ProjectStats>> getStats(String projectId);

  Future<Result<Project>> upsert(Project project);
}
