import 'data/datasources/matching_local_data_source.dart';
import 'data/datasources/matching_remote_data_source.dart';
import 'data/repositories/matching_repository_impl.dart';
import 'presentation/controllers/matching_controller.dart';

/// Default demo composition. Screens can receive a controller from the caller.
MatchingController createDemoMatchingController() => MatchingController(
  repository: MatchingRepositoryImpl(
    remoteDataSource: MockMatchingRemoteDataSource(),
    localDataSource: InMemoryMatchingLocalDataSource(),
  ),
);
