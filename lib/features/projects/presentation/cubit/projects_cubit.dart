import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_stats.dart';
import '../../domain/usecases/get_joined_contributions.dart';
import '../../domain/usecases/get_project_stats.dart';
import '../../domain/usecases/get_projects.dart';
import '../../domain/usecases/record_project_view.dart';
import '../../domain/usecases/upsert_project.dart';

part 'projects_state.dart';

/// Owns the project feed, the owner's dashboard metrics and all project write
/// operations. Screens either share an instance through `BlocProvider.value`
/// (shell → editor) or create their own scope (project details).
///
/// Collaboration requests are not sent from this cubit. The details and
/// Discover screens call the requests feature (`presentCollaborationRequestFlow`
/// → `RequestsCubit`), then call [markRequestPending] to reflect the new state.
class ProjectsCubit extends Cubit<ProjectsState> {
  ProjectsCubit({
    required GetProjects getProjects,
    required GetProjectStats getProjectStats,
    required UpsertProject upsertProject,
    required GetJoinedContributions getJoinedContributions,
    required RecordProjectView recordProjectView,
  }) : _getProjects = getProjects,
       _getProjectStats = getProjectStats,
       _upsertProject = upsertProject,
       _getJoinedContributions = getJoinedContributions,
       _recordProjectView = recordProjectView,
       super(const ProjectsInitial());

  final GetProjects _getProjects;
  final GetProjectStats _getProjectStats;
  final UpsertProject _upsertProject;
  final GetJoinedContributions _getJoinedContributions;
  final RecordProjectView _recordProjectView;

  /// Monotonic id stamped on every [ProjectOperationSuccess] so listeners fire
  /// once per operation, not once per distinct message.
  int _operationId = 0;

  /// Loads Discover + My projects. Set [silent] to refresh after returning from
  /// a detail route without flashing the full-page spinner.
  Future<void> load({bool silent = false}) async {
    if (!silent) emit(const ProjectsLoading());

    final projectsResult = await _getProjects(const NoParams());
    switch (projectsResult) {
      case FailureResult(:final failure):
        // A background refresh must not replace a working feed with an error.
        if (silent && state is ProjectsLoaded) return;
        emit(ProjectsFailure(failure.message));
        return;
      case Success(:final data):
        final stats = <String, ProjectStats>{};
        for (final project in data.where((project) => project.isOwner)) {
          final statsResult = await _getProjectStats(
            GetProjectStatsParams(project.id),
          );
          if (statsResult case Success(data: final projectStats)) {
            stats[project.id] = projectStats;
          }
        }

        final joinedResult = await _getJoinedContributions(const NoParams());
        final joined = switch (joinedResult) {
          Success(:final data) => data,
          FailureResult() => 0,
        };

        emit(
          ProjectsLoaded(
            projects: data,
            stats: stats,
            joinedContributors: joined,
          ),
        );
    }
  }

  Future<void> refresh() => load(silent: true);

  /// Loads a single project and its stats for the details screen.
  ///
  /// Details keeps its own cubit scope so this never replaces the Discover
  /// feed. A view is recorded after the stats resolve.
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

  /// Returns `null` on success, or a user-facing error message.
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

  /// Marks [projectId] as requested after the requests feature successfully
  /// created the request document.
  ///
  /// The request write (and the `projects.requestsCount` increment) is owned by
  /// the requests feature, so the feed only mirrors the result. Guarding on
  /// [Project.hasPendingRequest] keeps repeated taps from inflating the local
  /// counter.
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

  /// Fire-and-forget: a failed view log must never break the details screen.
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
