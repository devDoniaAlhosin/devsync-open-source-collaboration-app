import 'package:get_it/get_it.dart';

import 'data/datasources/github_remote_data_source.dart';
import 'data/datasources/projects_remote_data_source.dart';
import 'data/repositories/projects_repository_impl.dart';
import 'domain/repositories/projects_repository.dart';
import 'domain/usecases/delete_project.dart';
import 'domain/usecases/get_joined_contributions.dart';
import 'domain/usecases/get_project.dart';
import 'domain/usecases/get_project_stats.dart';
import 'domain/usecases/get_projects.dart';
import 'domain/usecases/record_project_view.dart';
import 'domain/usecases/upsert_project.dart';
import 'presentation/cubit/projects_cubit.dart';

void registerProjectsDependencies([GetIt? registry]) {
  final getIt = registry ?? GetIt.instance;

  if (!getIt.isRegistered<GithubRemoteDataSource>()) {
    getIt.registerLazySingleton<GithubRemoteDataSource>(
      () => GithubRemoteDataSource(),
    );
  }
  if (!getIt.isRegistered<ProjectsRemoteDataSource>()) {
    getIt.registerLazySingleton<ProjectsRemoteDataSource>(
      () => ProjectsRemoteDataSource(
        firestore: getIt(),
        auth: getIt(),
        github: getIt(),
      ),
    );
  }
  if (!getIt.isRegistered<ProjectsRepository>()) {
    getIt.registerLazySingleton<ProjectsRepository>(
      () => ProjectsRepositoryImpl(remote: getIt()),
    );
  }
  if (!getIt.isRegistered<GetProjects>()) {
    getIt.registerLazySingleton(() => GetProjects(getIt()));
  }
  if (!getIt.isRegistered<GetProject>()) {
    getIt.registerLazySingleton(() => GetProject(getIt()));
  }
  if (!getIt.isRegistered<GetProjectStats>()) {
    getIt.registerLazySingleton(() => GetProjectStats(getIt()));
  }
  if (!getIt.isRegistered<UpsertProject>()) {
    getIt.registerLazySingleton(() => UpsertProject(getIt()));
  }
  if (!getIt.isRegistered<DeleteProject>()) {
    getIt.registerLazySingleton(() => DeleteProject(getIt()));
  }
  if (!getIt.isRegistered<GetJoinedContributions>()) {
    getIt.registerLazySingleton(() => GetJoinedContributions(getIt()));
  }
  if (!getIt.isRegistered<RecordProjectView>()) {
    getIt.registerLazySingleton(() => RecordProjectView(getIt()));
  }

  if (getIt.isRegistered<ProjectsCubit>()) {
    getIt.unregister<ProjectsCubit>();
  }
  getIt.registerFactory(
    () => ProjectsCubit(
      getProjects: getIt(),
      getProjectStats: getIt(),
      upsertProject: getIt(),
      deleteProject: getIt(),
      getJoinedContributions: getIt(),
      recordProjectView: getIt(),
    ),
  );
}
