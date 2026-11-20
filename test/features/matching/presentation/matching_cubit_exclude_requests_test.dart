import 'package:devsync_open_source_collaboration_app/core/result/result.dart';
import 'package:devsync_open_source_collaboration_app/core/usecase/usecase.dart';
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
import 'package:devsync_open_source_collaboration_app/features/projects/domain/entities/project.dart';
import 'package:devsync_open_source_collaboration_app/features/projects/domain/entities/project_stats.dart';
import 'package:devsync_open_source_collaboration_app/features/projects/domain/repositories/projects_repository.dart';
import 'package:devsync_open_source_collaboration_app/features/projects/domain/usecases/get_projects.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/domain/repositories/requests_repository.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/domain/entities/collaboration_request.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/domain/usecases/get_unavailable_project_ids.dart';
import 'package:devsync_open_source_collaboration_app/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

const _profile = UserProfile(
  uid: 'viewer-1',
  declaredSkills: ['Flutter', 'Dart'],
  githubLanguages: {'Dart': 80},
  publicRepoCount: 4,
  totalContributions: 40,
);

void main() {
  test('excludes owned, pending, and accepted projects from ranked feed', () async {
    final remote = _RecordingRemote(
      const MatchResponseModel(
        promptVersion: 'v1',
        matches: [
          MatchItemModel(
            projectId: 'open-1',
            projectName: 'Open',
            description: 'Still available',
            githubUrl: 'https://github.com/a/open',
            neededSkills: ['Flutter'],
            score: 90,
            reason: 'Skill match',
            maintainerId: 'owner-a',
          ),
          MatchItemModel(
            projectId: 'accepted-1',
            projectName: 'Accepted',
            description: 'Already joined',
            githubUrl: 'https://github.com/a/accepted',
            neededSkills: ['Flutter'],
            score: 95,
            reason: 'Skill match',
            maintainerId: 'owner-b',
          ),
          MatchItemModel(
            projectId: 'owned-1',
            projectName: 'Mine',
            description: 'Own project',
            githubUrl: 'https://github.com/a/mine',
            neededSkills: ['Flutter'],
            score: 99,
            reason: 'Skill match',
            maintainerId: 'viewer-1',
          ),
        ],
      ),
    );

    final repository = MatchingRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: InMemoryMatchingLocalDataSource(),
    );

    final cubit = MatchingCubit(
      repository: repository,
      likedMatchesDataSource: InMemoryLikedMatchesDataSource(),
      getRankedMatchesUseCase: GetRankedMatchesUseCase(repository),
      profile: _profile,
      getProjects: GetProjects(_FakeProjectsRepository()),
      getUnavailableProjectIds: GetUnavailableProjectIds(
        _FakeRequestsRepository(unavailableIds: {'accepted-1', 'pending-1'}),
      ),
    );

    await cubit.loadInitialData();

    expect(remote.lastRequest?.projects?.map((c) => c.projectId), ['open-1']);
    expect(cubit.state.matches.map((m) => m.projectId), ['open-1']);

    await cubit.close();
  });
}

class _RecordingRemote implements MatchingRemoteDataSource {
  _RecordingRemote(this.response);

  final MatchResponseModel response;
  MatchRequestModel? lastRequest;

  @override
  Future<MatchResponseModel> getMatches(MatchRequestModel request) async {
    lastRequest = request;
    return response;
  }

  @override
  void close() {}
}

class _FakeProjectsRepository implements ProjectsRepository {
  @override
  Future<Result<List<Project>>> getProjects() async => Success([
    _project(id: 'open-1', ownerId: 'owner-a'),
    _project(id: 'accepted-1', ownerId: 'owner-b'),
    _project(id: 'pending-1', ownerId: 'owner-c'),
    _project(id: 'owned-1', ownerId: 'viewer-1'),
  ]);

  @override
  Future<Result<Project>> getProject(String projectId) async =>
      const FailureResult(UnexpectedFailure());

  @override
  Future<Result<void>> delete(String projectId) async =>
      const FailureResult(UnexpectedFailure());

  @override
  Future<Result<int>> getJoinedContributions() async => const Success(0);

  @override
  Future<Result<ProjectStats>> getStats(String projectId) async =>
      const FailureResult(UnexpectedFailure());

  @override
  Future<Result<void>> recordView(String projectId) async =>
      const Success(null);

  @override
  Future<Result<Project>> upsert(Project project) async =>
      const FailureResult(UnexpectedFailure());
}

class _FakeRequestsRepository implements RequestsRepository {
  _FakeRequestsRepository({required this.unavailableIds});

  final Set<String> unavailableIds;

  @override
  Future<Result<List<RequestItem>>> getRequests() async => const Success([]);

  @override
  Future<Result<Set<String>>> getUnavailableProjectIds() async =>
      Success(unavailableIds);

  @override
  Future<Result<RequestItem>> createRequest({
    required RequestItem item,
  }) async => const FailureResult(UnexpectedFailure());

  @override
  Future<Result<RequestItem>> updateStatus({
    required String requestId,
    required RequestStatus status,
  }) async => const FailureResult(UnexpectedFailure());

  @override
  Stream<bool> watchHasPendingReceived() => Stream.value(false);
}

Project _project({required String id, required String ownerId}) => Project(
  id: id,
  title: id,
  description: 'desc',
  githubUrl: 'https://github.com/org/$id',
  techStack: const ['Flutter'],
  requiredContributors: 1,
  viewsCount: 0,
  requestsCount: 0,
  matchPercentage: 0,
  isOwner: ownerId == 'viewer-1',
  ownerId: ownerId,
);
