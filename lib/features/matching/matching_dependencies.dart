import 'data/datasources/matching_local_data_source.dart';
import 'data/datasources/matching_remote_data_source.dart';
import 'data/repositories/matching_repository_impl.dart';
import 'domain/repositories/matching_repository.dart';
import 'presentation/cubit/matching_cubit.dart';

/// Builds the demo [MatchingRepository] (mock remote + in-memory cache).
MatchingRepository createDemoMatchingRepository() => MatchingRepositoryImpl(
  remoteDataSource: MockMatchingRemoteDataSource(),
  localDataSource: InMemoryMatchingLocalDataSource(),
);

/// Default demo composition when a screen is not given a shared cubit.
MatchingCubit createDemoMatchingCubit() =>
    MatchingCubit(repository: createDemoMatchingRepository());
