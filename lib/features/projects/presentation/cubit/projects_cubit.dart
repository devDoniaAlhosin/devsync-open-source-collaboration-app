import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_stats.dart';
import '../../domain/usecases/delete_project.dart';
import '../../domain/usecases/get_joined_contributions.dart';
import '../../domain/usecases/get_project_stats.dart';
import '../../domain/usecases/get_projects.dart';
import '../../domain/usecases/record_project_view.dart';
import '../../domain/usecases/upsert_project.dart';

part 'projects_state.dart';

/// Project feed + writes. Requests go through `RequestsCubit`.
class ProjectsCubit extends Cubit<ProjectsState> {
  ProjectsCubit({
    required GetProjects getProjects,
    required GetProjectStats getProjectStats,
    required UpsertProject upsertProject,
    required DeleteProject deleteProject,
    required GetJoinedContributions getJoinedContributions,
    required RecordProjectView recordProjectView,
  }) : _getProjects = getProjects,
       _getProjectStats = getProjectStats,
       _upsertProject = upsertProject,
       _deleteProject = deleteProject,
       _getJoinedContributions = getJoinedContributions,
       _recordProjectView = recordProjectView,
       super(const ProjectsInitial());

  final GetProjects _getProjects;
  final GetProjectStats _getProjectStats;
  final UpsertProject _upsertProject;
  final DeleteProject _deleteProject;
  final GetJoinedContributions _getJoinedContributions;
  final RecordProjectView _recordProjectView;

  int _operationId = 0;

  /// [silent] refreshes without the full-page spinner.
  Future<void> load({bool silent = false}) async {
    if (!silent) emit(const ProjectsLoading());

    final projectsResult = await _getProjects(const NoParams());
    switch (projectsResult) {
      case FailureResult(:final failure):
        if (silent && state is ProjectsLoaded) return;
        emit(ProjectsFailure(failure.message));
        return;
      case Success(:final data):
        final previous = state;
        final cachedStats = previous is ProjectsLoaded
            ? Map<String, ProjectStats>.of(previous.stats)
            : <String, ProjectStats>{};
        cachedStats.removeWhere(
          (id, _) => !data.any((project) => project.id == id),
        );

        final joinedResult = await _getJoinedContributions(const NoParams());
        final joined = switch (joinedResult) {
          Success(:final data) => data,
          FailureResult() => 0,
        };

        emit(
          ProjectsLoaded(
            projects: data,
            stats: cachedStats,
            joinedContributors: joined,
          ),
        );
    }
  }

  Future<void> refresh() => load(silent: true);

  Future<void> loadProject(
    Project project, {
    ProjectStats? initialStats,
  }) async {
    emit(const ProjectsLoading());

    final stats = initialStats ?? await _statsFor(project.id);
    if (stats == null) {
      emit(const ProjectsFailure('Could not load project details'));
      return;
    }

    emit(
      ProjectsLoaded(
        projects: [project],
        stats: {project.id: stats},
        joinedContributors: 0,
      ),
    );
    unawaited(recordProjectView(project.id));
  }

  /// `null` on success, else error text.
  Future<String?> upsert(Project project, {bool isNew = false}) async {
    final result = await _upsertProject(project);
    switch (result) {
      case FailureResult(:final failure):
        return failure.message;
      case Success(:final data):
        final current = state;
        final loaded = current is ProjectsLoaded ? current : null;
        final projects = List<Project>.of(
          loaded?.projects ?? const <Project>[],
        );
        final index = projects.indexWhere((item) => item.id == data.id);
        if (index == -1) {
          projects.insert(0, data);
        } else {
          projects[index] = data;
        }

        emit(
          ProjectOperationSuccess(
            projects: projects,
            stats: Map<String, ProjectStats>.of(
              loaded?.stats ?? const <String, ProjectStats>{},
            ),
            joinedContributors: loaded?.joinedContributors ?? 0,
            message: isNew
                ? 'Project published to Discover.'
                : 'Project updated.',
            operationId: ++_operationId,
          ),
        );
        return null;
    }
  }

  /// `null` on success, else error text.
  Future<String?> delete(String projectId) async {
    final result = await _deleteProject(DeleteProjectParams(projectId));
    switch (result) {
      case FailureResult(:final failure):
        return failure.message;
      case Success():
        final current = state;
        final loaded = current is ProjectsLoaded ? current : null;
        final projects = List<Project>.of(
          loaded?.projects ?? const <Project>[],
        )..removeWhere((item) => item.id == projectId);
        final stats = Map<String, ProjectStats>.of(
          loaded?.stats ?? const <String, ProjectStats>{},
        )..remove(projectId);

        emit(
          ProjectOperationSuccess(
            projects: projects,
            stats: stats,
            joinedContributors: loaded?.joinedContributors ?? 0,
            message: 'Project deleted.',
            operationId: ++_operationId,
          ),
        );
        return null;
    }
  }

  void markRequestPending(String projectId) {
    final current = state;
    if (current is! ProjectsLoaded) return;

    var changed = false;
    final projects = <Project>[];
    for (final project in current.projects) {
      if (project.id == projectId && !project.hasPendingRequest) {
        changed = true;
        projects.add(
          project.copyWith(
            hasPendingRequest: true,
            requestsCount: project.requestsCount + 1,
          ),
        );
      } else {
        projects.add(project);
      }
    }

    if (!changed) return;
    emit(current.copyWith(projects: projects));
  }

  Future<void> recordProjectView(String projectId) async {
    await _recordProjectView(RecordProjectViewParams(projectId));
  }

  Future<ProjectStats?> statsFor(String projectId) async {
    final current = state;
    if (current is ProjectsLoaded) {
      final cached = current.statsFor(projectId);
      if (cached != null) return cached;
    }
    return _statsFor(projectId);
  }

  Future<ProjectStats?> _statsFor(String projectId) async {
    final result = await _getProjectStats(GetProjectStatsParams(projectId));
    return switch (result) {
      Success(:final data) => data,
      FailureResult() => null,
    };
  }
}
