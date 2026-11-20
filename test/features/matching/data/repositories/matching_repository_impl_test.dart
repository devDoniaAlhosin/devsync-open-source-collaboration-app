import 'dart:io';

import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/matching_http_remote_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/matching_local_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/matching_remote_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/models/match_item_model.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/models/match_request_model.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/models/match_response_model.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/repositories/matching_repository_impl.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/match_item.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/user_profile.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/failures/matching_failures.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRemoteDataSource implements MatchingRemoteDataSource {
  _FakeRemoteDataSource(this.response, {this.error});

  MatchResponseModel response;
  Object? error;
  MatchRequestModel? lastRequest;

  @override
  Future<MatchResponseModel> getMatches(MatchRequestModel request) async {
    lastRequest = request;
    if (error != null) throw error!;
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

    test(
      'throws NoMatchesFailure when all candidates are non-matches',
      () async {
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
      },
    );

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

      await repo.getRankedMatches(testProfile, candidateProjects: candidates);

      expect(remote.lastRequest?.projects, isNotNull);
      expect(remote.lastRequest!.projects!.length, 1);
      expect(remote.lastRequest!.projects!.first.projectId, 'candidate-1');
    });

    test(
      'drops matches whose projectId was not in candidateProjects',
      () async {
        final remote = _FakeRemoteDataSource(
          const MatchResponseModel(
            promptVersion: 'v1.1',
            matches: [
              MatchItemModel(
                projectId: 'candidate-1',
                projectName: 'Candidate One',
                description: 'Known',
                githubUrl: 'https://github.com/test/1',
                neededSkills: ['Flutter'],
                score: 80,
                reason: 'Good match',
              ),
              MatchItemModel(
                projectId: 'unknown-project',
                projectName: 'Unknown Project',
                description: 'Not sent',
                githubUrl: 'https://github.com/test/unknown',
                neededSkills: ['Flutter'],
                score: 95,
                reason: 'High score but not sent',
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
            description: 'Known',
            githubUrl: 'https://github.com/test/1',
            neededSkills: ['Flutter'],
          ),
        ];

        final results = await repo.getRankedMatches(
          testProfile,
          candidateProjects: candidates,
        );

        expect(results.length, 1);
        expect(results.first.projectId, 'candidate-1');
      },
    );

    test(
      'propagates fallback flag to matches when response has fallback true',
      () async {
        final remote = _FakeRemoteDataSource(
          const MatchResponseModel(
            promptVersion: 'v1.1',
            fallback: true,
            matches: [
              MatchItemModel(
                projectId: 'candidate-1',
                projectName: 'Candidate One',
                description: 'Known',
                githubUrl: 'https://github.com/test/1',
                neededSkills: ['Flutter'],
                score: 80,
                reason: 'Good match',
              ),
            ],
          ),
        );

        final repo = MatchingRepositoryImpl(
          remoteDataSource: remote,
          localDataSource: InMemoryMatchingLocalDataSource(),
        );

        final results = await repo.getRankedMatches(testProfile);
        expect(results.first.isFallback, isTrue);
      },
    );
  });

  group('Deterministic Fallback', () {
    const fallbackProfile = UserProfile(
      uid: 'user-001',
      declaredSkills: ['Flutter', 'Dart', 'GraphQL'],
      githubLanguages: {'Dart': 5000},
      publicRepoCount: 10,
      totalContributions: 150,
    );

    const candidateA = CandidateProject(
      projectId: 'proj-a',
      projectName: 'Project A',
      description: 'Flutter and Dart',
      githubUrl: 'https://github.com/a',
      neededSkills: ['Flutter', 'Dart'], // 2/2 = 100%
      maintainerId: 'other-user',
    );

    const candidateB = CandidateProject(
      projectId: 'proj-b',
      projectName: 'Project B',
      description: 'Flutter and Python',
      githubUrl: 'https://github.com/b',
      neededSkills: ['Flutter', 'Python'], // 1/2 = 50%
      maintainerId: 'other-user',
    );

    const candidateC = CandidateProject(
      projectId: 'proj-c',
      projectName: 'Project C',
      description: 'Flutter and GraphQL',
      githubUrl: 'https://github.com/c',
      neededSkills: ['Flutter', 'GraphQL'], // 2/2 = 100%
      maintainerId: 'other-user',
    );

    const candidateNoOverlap = CandidateProject(
      projectId: 'proj-no-overlap',
      projectName: 'Rust Lib',
      description: 'Rust only',
      githubUrl: 'https://github.com/rust',
      neededSkills: ['Rust', 'Wasm'],
      maintainerId: 'other-user',
    );

    const candidateNoSkills = CandidateProject(
      projectId: 'proj-no-skills',
      projectName: 'No Skills',
      description: 'Empty skills',
      githubUrl: 'https://github.com/empty',
      neededSkills: [],
      maintainerId: 'other-user',
    );

    const candidateOwn = CandidateProject(
      projectId: 'proj-own',
      projectName: 'My Project',
      description: 'Owned by user-001',
      githubUrl: 'https://github.com/my',
      neededSkills: ['Flutter', 'Dart'],
      maintainerId: 'user-001',
    );

    test(
      'calculates correct score math, reason from overlapping skills, and sorts score desc, id asc',
      () async {
        final remote = _FakeRemoteDataSource(
          const MatchResponseModel(promptVersion: 'v1', matches: []),
          error: const SocketException('offline'),
        );
        final repo = MatchingRepositoryImpl(
          remoteDataSource: remote,
          localDataSource: InMemoryMatchingLocalDataSource(),
        );

        final results = await repo.getRankedMatches(
          fallbackProfile,
          candidateProjects: [
            candidateB, // 50%
            candidateA, // 100%, proj-a
            candidateC, // 100%, proj-c
            candidateNoOverlap,
            candidateNoSkills,
            candidateOwn,
          ],
        );

        expect(results.length, 3);
        // proj-a (100) vs proj-c (100): alphabetical tie-break -> proj-a first, proj-c second
        expect(results[0].projectId, 'proj-a');
        expect(results[0].score, 100.0);
        expect(results[0].reason, 'Flutter, Dart');
        expect(results[0].isFallback, isTrue);
        expect(results[0].source, MatchSource.fallback);

        expect(results[1].projectId, 'proj-c');
        expect(results[1].score, 100.0);
        expect(results[1].reason, 'Flutter, GraphQL');

        expect(results[2].projectId, 'proj-b');
        expect(results[2].score, 50.0);
        expect(results[2].reason, 'Flutter');
      },
    );

    test(
      'throws NoMatchesFailure when no candidates qualify for fallback',
      () async {
        final remote = _FakeRemoteDataSource(
          const MatchResponseModel(promptVersion: 'v1', matches: []),
          error: const MatchingApiException(
            'Service unavailable',
            statusCode: 503,
          ),
        );
        final repo = MatchingRepositoryImpl(
          remoteDataSource: remote,
          localDataSource: InMemoryMatchingLocalDataSource(),
        );

        expect(
          () => repo.getRankedMatches(
            fallbackProfile,
            candidateProjects: [
              candidateOwn,
              candidateNoOverlap,
              candidateNoSkills,
            ],
          ),
          throwsA(isA<NoMatchesFailure>()),
        );
      },
    );

    test('does NOT fall back on 401/403 auth errors', () async {
      final remote = _FakeRemoteDataSource(
        const MatchResponseModel(promptVersion: 'v1', matches: []),
        error: const MatchingApiException('Unauthorized', statusCode: 401),
      );
      final repo = MatchingRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: InMemoryMatchingLocalDataSource(),
      );

      expect(
        () => repo.getRankedMatches(
          fallbackProfile,
          candidateProjects: [candidateA],
        ),
        throwsA(isA<AuthFailure>()),
      );
    });

    test(
      'deterministic: multiple executions yield identical results without randomness',
      () async {
        final remote = _FakeRemoteDataSource(
          const MatchResponseModel(promptVersion: 'v1', matches: []),
          error: const SocketException('Connection reset'),
        );
        final repo = MatchingRepositoryImpl(
          remoteDataSource: remote,
          localDataSource: InMemoryMatchingLocalDataSource(),
        );

        final candidates = [candidateB, candidateA, candidateC];
        final run1 = await repo.getRankedMatches(
          fallbackProfile,
          candidateProjects: candidates,
        );
        final run2 = await repo.getRankedMatches(
          fallbackProfile,
          candidateProjects: candidates,
        );

        expect(
          run1.map((m) => m.projectId).toList(),
          run2.map((m) => m.projectId).toList(),
        );
        expect(
          run1.map((m) => m.score).toList(),
          run2.map((m) => m.score).toList(),
        );
        expect(
          run1.map((m) => m.reason).toList(),
          run2.map((m) => m.reason).toList(),
        );
      },
    );
  });
}
