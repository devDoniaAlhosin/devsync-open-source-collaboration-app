import 'data/datasources/matching_http_remote_data_source.dart';
import 'data/datasources/matching_local_data_source.dart';
import 'data/datasources/matching_remote_data_source.dart';
import 'data/repositories/matching_repository_impl.dart';
import 'domain/repositories/matching_repository.dart';
import 'presentation/cubit/matching_cubit.dart';

/// Builds the production [MatchingRepository] (HTTP remote + in-memory cache).
MatchingRepository createMatchingRepository() => MatchingRepositoryImpl(
  remoteDataSource: MatchingHttpRemoteDataSource(),
  localDataSource: InMemoryMatchingLocalDataSource(),
);

/// Builds the demo [MatchingRepository] (mock remote + in-memory cache).
MatchingRepository createDemoMatchingRepository() => MatchingRepositoryImpl(
  remoteDataSource: MockMatchingRemoteDataSource(),
  localDataSource: InMemoryMatchingLocalDataSource(),
);

/// Default demo composition when a screen is not given a shared cubit.
MatchingCubit createDemoMatchingCubit() =>
    MatchingCubit(repository: createDemoMatchingRepository());
