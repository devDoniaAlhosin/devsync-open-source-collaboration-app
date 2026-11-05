import 'package:firebase_auth/firebase_auth.dart';

import 'data/datasources/auth_token_provider.dart';
import 'data/datasources/matching_http_remote_data_source.dart';
import 'data/datasources/matching_local_data_source.dart';
import 'data/repositories/matching_repository_impl.dart';
import 'domain/repositories/matching_repository.dart';

/// Builds the production [MatchingRepository] (HTTP remote + in-memory cache).
///
/// Uses authenticated HTTP calls to the DevSync backend API.
/// For testing, create a MatchingRepositoryImpl with a mock data source.
MatchingRepository createMatchingRepository(FirebaseAuth firebaseAuth) {
  final authTokenProvider = FirebaseAuthTokenProvider(firebaseAuth);

  return MatchingRepositoryImpl(
    remoteDataSource: MatchingHttpRemoteDataSource(
      authTokenProvider: authTokenProvider,
    ),
    localDataSource: InMemoryMatchingLocalDataSource(),
  );
}
