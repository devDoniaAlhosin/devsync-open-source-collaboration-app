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
import '../../domain/usecases/request_to_collaborate.dart';
import '../../domain/usecases/upsert_project.dart';

part 'projects_state.dart';

/// Owns the project feed, the owner's dashboard metrics and all write
/// operations. Screens either share an instance through `BlocProvider.value`
/// (shell → editor) or create their own scope (project details).
class ProjectsCubit extends Cubit<ProjectsState> {
  ProjectsCubit({
    required GetProjects getProjects,
    required GetProjectStats getProjectStats,
    required UpsertProject upsertProject,
    required RequestToCollaborate requestToCollaborate,
    required GetJoinedContributions getJoinedContributions,
    required RecordProjectView recordProjectView,
  }) : _getProjects = getProjects,
       _getProjectStats = getProjectStats,
       _upsertProject = upsertProject,
       _requestToCollaborate = requestToCollaborate,
       _getJoinedContributions = getJoinedContributions,
       _recordProjectView = recordProjectView,
       super(const ProjectsInitial());

  final GetProjects _getProjects;
  final GetProjectStats _getProjectStats;
  final UpsertProject _upsertProject;
  final RequestToCollaborate _requestToCollaborate;
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

  /// Sends a collaboration request. Returns `null` on success.
  Future<String?> requestToCollaborate(
    Project project, {
    String? message,
  }) async {
    final result = await _requestToCollaborate(
      RequestToCollaborateParams(project: project, message: message),
    );

    switch (result) {
      case FailureResult(:final failure):
        return failure.message;
      case Success(:final data):
        final current = state;
        final loaded = current is ProjectsLoaded ? current : null;
        final projects = (loaded?.projects ?? <Project>[project])
            .map((item) {
              if (item.id != project.id) return item;
              return item.copyWith(
                hasPendingRequest: true,
                requestsCount: data.created
                    ? item.requestsCount + 1
                    : item.requestsCount,
              );
            })
            .toList(growable: false);

        emit(
          ProjectOperationSuccess(
            projects: projects,
            stats: Map<String, ProjectStats>.of(
              loaded?.stats ?? const <String, ProjectStats>{},
            ),
            joinedContributors: loaded?.joinedContributors ?? 0,
            message: data.created
                ? 'Request sent to ${_maintainerName(project)}.'
                : 'You already have a pending request for ${project.title}.',
            operationId: ++_operationId,
          ),
        );
        return null;
    }
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

  String _maintainerName(Project project) {
    final name = project.ownerName.trim();
    return name.isEmpty ? 'the maintainer' : name;
  }
}
