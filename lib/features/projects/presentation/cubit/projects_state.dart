part of 'projects_cubit.dart';

sealed class ProjectsState extends Equatable {
  const ProjectsState();

  @override
  List<Object?> get props => const [];
}

final class ProjectsInitial extends ProjectsState {
  const ProjectsInitial();
}

final class ProjectsLoading extends ProjectsState {
  const ProjectsLoading();
}

/// Base state that owns the project feed. [ProjectOperationSuccess] extends it
/// so widgets can keep rendering data while a transient success banner fires.
class ProjectsLoaded extends ProjectsState {
  const ProjectsLoaded({
    required this.projects,
    required this.stats,
    required this.joinedContributors,
  });

  final List<Project> projects;
  final Map<String, ProjectStats> stats;
  final int joinedContributors;

  List<Project> get ownedProjects =>
      projects.where((project) => project.isOwner).toList(growable: false);

  List<Project> get discoverProjects =>
      projects.where((project) => !project.isOwner).toList(growable: false);

  ProjectStats? statsFor(String projectId) => stats[projectId];

  Project? projectById(String projectId) {
    for (final project in projects) {
      if (project.id == projectId) return project;
    }
    return null;
  }

  ProjectsLoaded copyWith({
    List<Project>? projects,
    Map<String, ProjectStats>? stats,
    int? joinedContributors,
  }) {
    return ProjectsLoaded(
      projects: projects ?? this.projects,
      stats: stats ?? this.stats,
      joinedContributors: joinedContributors ?? this.joinedContributors,
    );
  }

  @override
  List<Object?> get props => [projects, stats, joinedContributors];
}

/// Emitted after a save or collaboration request. Carries the full feed so the
/// UI never falls back to a spinner for a one-off operation.
///
/// [operationId] is unique per emit, so listeners can react to every operation
/// even when two consecutive ones produce the same [message] (for example
/// publishing two projects back to back).
final class ProjectOperationSuccess extends ProjectsLoaded {
  const ProjectOperationSuccess({
    required super.projects,
    required super.stats,
    required super.joinedContributors,
    required this.message,
    required this.operationId,
  });

  final String message;
  final int operationId;

  @override
  List<Object?> get props => [...super.props, message, operationId];
}

final class ProjectsFailure extends ProjectsState {
  const ProjectsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
