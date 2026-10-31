import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_stats.dart';
import '../../domain/usecases/get_project_stats.dart';
import '../../domain/usecases/get_projects.dart';
import '../../domain/usecases/upsert_project.dart';

part 'projects_state.dart';

/// Dummy metric until Firestore tracks joined contributor counts.
const _joinedContributors = 3;

class ProjectsCubit extends Cubit<ProjectsState> {
  ProjectsCubit({
    required this._getProjects,
    required this._getProjectStats,
    required this._upsertProject,
  }) : super(const ProjectsInitial());

  final GetProjects _getProjects;
  final GetProjectStats _getProjectStats;
  final UpsertProject _upsertProject;

  Future<void> load() async {
    emit(const ProjectsLoading());
    final result = await _getProjects(const NoParams());
    switch (result) {
      case Success(:final data):
        final stats = <String, ProjectStats>{};
        for (final project in data) {
          final statsResult = await _getProjectStats(
            GetProjectStatsParams(project.id),
          );
          if (statsResult case Success(data: final projectStats)) {
            stats[project.id] = projectStats;
          }
        }
        emit(
          ProjectsLoaded(
            projects: data,
            stats: stats,
            joinedContributors: _joinedContributors,
          ),
        );
      case FailureResult(:final failure):
        emit(ProjectsFailure(failure.message));
    }
  }

  Future<void> upsert(Project project) async {
    final current = state;
    final result = await _upsertProject(project);
    switch (result) {
      case Success(:final data):
        if (current is ProjectsLoaded) {
          final projects = List<Project>.of(current.projects);
          final index = projects.indexWhere((p) => p.id == data.id);
          if (index == -1) {
            projects.insert(0, data);
          } else {
            projects[index] = data;
          }
          final stats = Map<String, ProjectStats>.of(current.stats);
          if (!stats.containsKey(data.id)) {
            final statsResult = await _getProjectStats(
              GetProjectStatsParams(data.id),
            );
            if (statsResult case Success(data: final projectStats)) {
              stats[data.id] = projectStats;
            }
          }
          emit(current.copyWith(projects: projects, stats: stats));
        } else {
          await load();
        }
      case FailureResult(:final failure):
        emit(ProjectsFailure(failure.message));
    }
  }

  Future<ProjectStats?> statsFor(String projectId) async {
    final current = state;
    if (current is ProjectsLoaded) {
      final cached = current.stats[projectId];
      if (cached != null) return cached;
    }
    final result = await _getProjectStats(GetProjectStatsParams(projectId));
    return switch (result) {
      Success(:final data) => data,
      FailureResult() => null,
    };
  }
}
