import 'package:devsync_open_source_collaboration_app/core/di/injection.dart';
import 'package:devsync_open_source_collaboration_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/liked_matches_local_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/matching_local_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/matching_remote_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/models/match_item_model.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/models/match_request_model.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/models/match_response_model.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/repositories/matching_repository_impl.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/user_profile.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/usecases/get_ranked_matches_usecase.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/cubit/matching_cubit.dart';

import 'fake_auth_repository.dart';

class _FakeMatchingRemoteDS implements MatchingRemoteDataSource {
  @override
  Future<MatchResponseModel> getMatches(
    MatchRequestModel request,
  ) async => const MatchResponseModel(
    promptVersion: 'v1',
    matches: [
      MatchItemModel(
        projectId: 'sample-1',
        projectName: 'flutter/packages',
        description:
            'A collection of useful packages maintained by the Flutter team.',
        githubUrl: 'https://github.com/flutter/packages',
        neededSkills: ['Flutter', 'Dart'],
        score: 92,
        reason: 'Matches your skills.',
      ),
    ],
  );

  @override
  void close() {}
}

Future<void> configureTestDependencies({AuthRepository? repository}) async {
  await getIt.reset();
  getIt.registerLazySingleton<AuthRepository>(
    () => repository ?? FakeAuthRepository(),
  );
  registerAuthUseCasesAndCubits();

  if (!getIt.isRegistered<MatchingCubit>()) {
    final repo = MatchingRepositoryImpl(
      remoteDataSource: _FakeMatchingRemoteDS(),
      localDataSource: InMemoryMatchingLocalDataSource(),
    );
    getIt.registerFactory<MatchingCubit>(
      () => MatchingCubit(
        repository: repo,
        likedMatchesDataSource: InMemoryLikedMatchesDataSource(),
        getRankedMatchesUseCase: GetRankedMatchesUseCase(repo),
        profile: const UserProfile(
          uid: 'test-uid',
          declaredSkills: ['Flutter', 'Dart'],
          githubLanguages: {'Dart': 100},
          publicRepoCount: 1,
          totalContributions: 10,
        ),
      ),
    );
  }
}
