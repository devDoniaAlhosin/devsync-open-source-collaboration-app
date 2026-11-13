import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_stats.dart';
import '../../domain/repositories/projects_repository.dart';
import '../datasources/projects_local_data_source.dart';

class ProjectsRepositoryImpl implements ProjectsRepository {
  ProjectsRepositoryImpl({
    required ProjectsLocalDataSource localDataSource,
    required FirebaseAuth firebaseAuth,
  }) : _local = localDataSource,
       _auth = firebaseAuth;

  final ProjectsLocalDataSource _local;
  final FirebaseAuth _auth;

  @override
  Future<Result<List<Project>>> getProjects() async {
    try {
      return Success(await _local.fetchProjects());
    } catch (_) {
      return const FailureResult(UnexpectedFailure());
    }
  }

  @override
  Future<Result<ProjectStats>> getStats(String projectId) async {
    try {
      return Success(await _local.statsFor(projectId));
    } catch (_) {
      return const FailureResult(UnexpectedFailure());
    }
  }

  @override
  Future<Result<Project>> upsert(Project project) async {
    try {
      if (project.title.trim().isEmpty) {
        return const FailureResult(
          ValidationFailure('Project title is required'),
        );
      }
      final currentUserId = _auth.currentUser?.uid;
      final projectToSave = project.isOwner && project.ownerId == null
          ? project.copyWith(ownerId: currentUserId)
          : project;
      return Success(await _local.upsert(projectToSave));
    } catch (_) {
      return const FailureResult(UnexpectedFailure());
    }
  }
}
