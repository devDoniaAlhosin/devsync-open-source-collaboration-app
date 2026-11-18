import 'package:get_it/get_it.dart';

import 'data/datasources/devsync_api_data_source.dart';
import 'data/datasources/github_remote_data_source.dart';
import 'data/datasources/projects_remote_data_source.dart';
import 'data/repositories/projects_repository_impl.dart';
import 'domain/repositories/projects_repository.dart';
import 'domain/usecases/get_joined_contributions.dart';
import 'domain/usecases/get_project_stats.dart';
import 'domain/usecases/get_projects.dart';
import 'domain/usecases/record_project_view.dart';
import 'domain/usecases/request_to_collaborate.dart';
import 'domain/usecases/upsert_project.dart';
import 'presentation/cubit/projects_cubit.dart';

/// Registers the projects feature with the shared [GetIt] container.
///
/// [FirebaseFirestore] and [FirebaseAuth] are registered by the app composition
/// root. Registering this feature twice is a no-op (hot restart / tests).
void registerProjectsDependencies([GetIt? registry]) {
  final getIt = registry ?? GetIt.instance;
  if (getIt.isRegistered<ProjectsRepository>()) return;

  getIt
    ..registerLazySingleton<GithubRemoteDataSource>(
      () => GithubRemoteDataSource(),
    )
    ..registerLazySingleton<DevSyncApiDataSource>(() => DevSyncApiDataSource())
    ..registerLazySingleton<ProjectsRemoteDataSource>(
      () => ProjectsRemoteDataSource(
        firestore: getIt(),
        auth: getIt(),
        github: getIt(),
        devsyncApi: getIt(),
      ),
    )
    ..registerLazySingleton<ProjectsRepository>(
      () => ProjectsRepositoryImpl(remote: getIt()),
    )
    ..registerLazySingleton(() => GetProjects(getIt()))
    ..registerLazySingleton(() => GetProjectStats(getIt()))
    ..registerLazySingleton(() => UpsertProject(getIt()))
    ..registerLazySingleton(() => RequestToCollaborate(getIt()))
    ..registerLazySingleton(() => GetJoinedContributions(getIt()))
    ..registerLazySingleton(() => RecordProjectView(getIt()))
    ..registerFactory(
      () => ProjectsCubit(
        getProjects: getIt(),
        getProjectStats: getIt(),
        upsertProject: getIt(),
        requestToCollaborate: getIt(),
        getJoinedContributions: getIt(),
        recordProjectView: getIt(),
      ),
    );
}
