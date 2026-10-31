part of 'projects_cubit.dart';

sealed class ProjectsState extends Equatable {
  const ProjectsState();

  @override
  List<Object?> get props => [];
}

final class ProjectsInitial extends ProjectsState {
  const ProjectsInitial();
}

final class ProjectsLoading extends ProjectsState {
  const ProjectsLoading();
}

final class ProjectsLoaded extends ProjectsState {
  const ProjectsLoaded({
    required this.projects,
    required this.stats,
    required this.joinedContributors,
  });

  final List<Project> projects;
  final Map<String, ProjectStats> stats;
  final int joinedContributors;

  ProjectStats? statsFor(String projectId) => stats[projectId];

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

final class ProjectsFailure extends ProjectsState {
  const ProjectsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
