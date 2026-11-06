import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/matching_local_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/matching_remote_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/models/match_item_model.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/models/match_request_model.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/models/match_response_model.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/repositories/matching_repository_impl.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/user_profile.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/failures/matching_failures.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRemoteDataSource implements MatchingRemoteDataSource {
  _FakeRemoteDataSource(this.response);

  MatchResponseModel response;
  MatchRequestModel? lastRequest;

  @override
  Future<MatchResponseModel> getMatches(MatchRequestModel request) async {
    lastRequest = request;
    return response;
  }

  @override
  void close() {}
}

void main() {
  const testProfile = UserProfile(
    uid: 'user-001',
    declaredSkills: ['Flutter', 'Dart'],
    githubLanguages: {'Dart': 5000},
    publicRepoCount: 10,
    totalContributions: 150,
  );

  group('MatchingRepositoryImpl - Filtering & Quality', () {
    test('filters out zero-score and missing-all-skills projects', () async {
      final remote = _FakeRemoteDataSource(
        const MatchResponseModel(
          promptVersion: 'v1.1',
          matches: [
            MatchItemModel(
              projectId: 'flutter-toolkit',
              projectName: 'Flutter Dev Toolkit',
              description: 'Flutter utilities',
              githubUrl: 'https://github.com/test/flutter',
              neededSkills: ['Flutter', 'Dart'],
              score: 90,
              reason: 'Strong match: you have Flutter and Dart',
            ),
            MatchItemModel(
              projectId: 'django-cms',
              projectName: 'Django CMS',
              description: 'CMS in Django',
              githubUrl: 'https://github.com/test/django',
              neededSkills: ['Python', 'Django'],
              score: 5,
              reason: 'Missing all required skills: Python, Django',
            ),
            MatchItemModel(
              projectId: 'k8s-helm',
              projectName: 'Kubernetes Helm',
              description: 'Helm charts',
              githubUrl: 'https://github.com/test/helm',
              neededSkills: ['Kubernetes', 'Helm'],
              score: 0,
              reason: 'No skill overlap',
            ),
          ],
        ),
      );

      final repo = MatchingRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: InMemoryMatchingLocalDataSource(),
      );

      final results = await repo.getRankedMatches(testProfile);

      expect(results.length, 1);
      expect(results.first.projectId, 'flutter-toolkit');
      expect(results.first.score, 90);
    });

    test('throws NoMatchesFailure when all candidates are non-matches', () async {
      final remote = _FakeRemoteDataSource(
        const MatchResponseModel(
          promptVersion: 'v1.1',
          matches: [
            MatchItemModel(
              projectId: 'django-cms',
              projectName: 'Django CMS',
              description: 'CMS in Django',
              githubUrl: 'https://github.com/test/django',
              neededSkills: ['Python', 'Django'],
              score: 0,
              reason: 'Missing all required skills: Python, Django',
            ),
          ],
        ),
      );

      final repo = MatchingRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: InMemoryMatchingLocalDataSource(),
      );

      expect(
        () => repo.getRankedMatches(testProfile),
        throwsA(isA<NoMatchesFailure>()),
      );
    });

    test('sorts relevant matches descending by score with tie-break', () async {
      final remote = _FakeRemoteDataSource(
        const MatchResponseModel(
          promptVersion: 'v1.1',
          matches: [
            MatchItemModel(
              projectId: 'b-proj',
              projectName: 'Project B',
              description: 'B',
              githubUrl: 'https://github.com/test/b',
              neededSkills: ['Flutter'],
              score: 60,
              reason: 'Partial match: you have Flutter',
            ),
            MatchItemModel(
              projectId: 'a-proj',
              projectName: 'Project A',
              description: 'A',
              githubUrl: 'https://github.com/test/a',
              neededSkills: ['Flutter'],
              score: 85,
              reason: 'Strong match: you have Flutter and Dart',
            ),
            MatchItemModel(
              projectId: 'c-proj',
              projectName: 'Project C',
              description: 'C',
              githubUrl: 'https://github.com/test/c',
              neededSkills: ['Flutter'],
              score: 60,
              reason: 'Partial match: you have Flutter',
            ),
          ],
        ),
      );

      final repo = MatchingRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: InMemoryMatchingLocalDataSource(),
      );

      final results = await repo.getRankedMatches(testProfile);

      expect(results.length, 3);
      expect(results[0].projectId, 'a-proj'); // 85
      expect(results[1].projectId, 'b-proj'); // 60, tie-break alphabetical
      expect(results[2].projectId, 'c-proj'); // 60
    });

    test('passes candidateProjects to remote request when provided', () async {
      final remote = _FakeRemoteDataSource(
        const MatchResponseModel(
          promptVersion: 'v1.1',
          matches: [
            MatchItemModel(
              projectId: 'candidate-1',
              projectName: 'Candidate One',
              description: 'Test',
              githubUrl: 'https://github.com/test/1',
              neededSkills: ['Flutter'],
              score: 80,
              reason: 'Great match',
            ),
          ],
        ),
      );

      final repo = MatchingRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: InMemoryMatchingLocalDataSource(),
      );

      const candidates = [
        CandidateProject(
          projectId: 'candidate-1',
          projectName: 'Candidate One',
          description: 'Test',
          githubUrl: 'https://github.com/test/1',
          neededSkills: ['Flutter'],
        ),
      ];

      await repo.getRankedMatches(
        testProfile,
        candidateProjects: candidates,
      );

      expect(remote.lastRequest?.projects, isNotNull);
      expect(remote.lastRequest!.projects!.length, 1);
      expect(remote.lastRequest!.projects!.first.projectId, 'candidate-1');
    });
  });
}
