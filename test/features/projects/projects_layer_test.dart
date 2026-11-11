import 'package:devsync_open_source_collaboration_app/core/error/failures.dart';
import 'package:devsync_open_source_collaboration_app/core/result/result.dart';
import 'package:devsync_open_source_collaboration_app/features/projects/data/models/project_model.dart';
import 'package:devsync_open_source_collaboration_app/features/projects/data/models/project_stats_model.dart';
import 'package:devsync_open_source_collaboration_app/features/projects/domain/entities/collaboration_request_receipt.dart';
import 'package:devsync_open_source_collaboration_app/features/projects/domain/entities/project.dart';
import 'package:devsync_open_source_collaboration_app/features/projects/domain/entities/project_stats.dart';
import 'package:devsync_open_source_collaboration_app/features/projects/domain/repositories/projects_repository.dart';
import 'package:devsync_open_source_collaboration_app/features/projects/domain/usecases/get_joined_contributions.dart';
import 'package:devsync_open_source_collaboration_app/features/projects/domain/usecases/get_project_stats.dart';
import 'package:devsync_open_source_collaboration_app/features/projects/domain/usecases/get_projects.dart';
import 'package:devsync_open_source_collaboration_app/features/projects/domain/usecases/record_project_view.dart';
import 'package:devsync_open_source_collaboration_app/features/projects/domain/usecases/request_to_collaborate.dart';
import 'package:devsync_open_source_collaboration_app/features/projects/domain/usecases/upsert_project.dart';
import 'package:devsync_open_source_collaboration_app/features/projects/presentation/cubit/projects_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProjectModel', () {
    test('maps Firestore fields and resolves viewer-relative flags', () {
      final model = ProjectModel.fromMap(
        'p1',
        {
          'ownerId': 'u1',
          'ownerName': 'Sara',
          'title': 'devsync-api',
          'description': 'Backend',
          'githubUrl': 'https://github.com/devsync/api',
          'techStack': const ['Dart', 'Firebase'],
          'requiredContributors': 2,
          'viewsCount': 10,
          'requestsCount': 3,
          'matchPercentage': 140,
          'matchSummary': 'Strong fit',
          'matchedSkills': const ['Dart'],
          'alignments': const [
            {'label': 'Dart', 'score': 90},
          ],
          'github': const {'stars': 12, 'contributors': 4, 'openTasks': 5},
        },
        currentUserId: 'u1',
        pendingRequestProjectIds: const {'p1'},
      );

      expect(model.isOwner, isTrue);
      expect(model.hasPendingRequest, isTrue);
      expect(model.matchPercentage, 100);
      expect(model.github.stars, 12);
      expect(model.alignments.single.label, 'Dart');
      expect(model.githubRepoFullName, 'devsync/api');
      expect(
        model
            .toStats(
              ownerName: 'Sara',
              ownerResponseTime: 'Usually replies in 1 day',
              weeklyViews: const [1, 2],
            )
            .weeklyViews,
        const [0, 0, 0, 0, 0, 1, 2],
      );
    });

    test('weekly views always normalise to seven buckets', () {
      expect(ProjectStatsModel.normalizeWeeklyViews(const []), hasLength(7));
      expect(
        ProjectStatsModel.normalizeWeeklyViews(const [1, 2, 3, 4, 5, 6, 7, 8]),
        const [2, 3, 4, 5, 6, 7, 8],
      );
    });

    test('write payload excludes AI and GitHub-owned fields', () {
      final model = ProjectModel.fromMap('p1', {
        'ownerId': 'u1',
        'title': 'mint-ui',
        'description': 'UI kit',
        'githubUrl': 'https://github.com/devsync/mint-ui',
        'techStack': const ['Dart'],
        'requiredContributors': 1,
        'matchPercentage': 88,
        'matchSummary': 'Great fit',
        'github': const {'stars': 99},
      });

      final payload = model.toFirestore(ownerId: 'u1', isNew: false);

      expect(payload.containsKey('matchPercentage'), isFalse);
      expect(payload.containsKey('matchSummary'), isFalse);
      expect(payload.containsKey('github'), isFalse);
      expect(payload.containsKey('createdAt'), isFalse);
      expect(payload['githubRepo'], 'devsync/mint-ui');
    });
  });

  group('ProjectsCubit', () {
    test('load keeps stats for owned projects and joins count', () async {
      final repository = _FakeProjectsRepository();
      final cubit = _cubitFor(repository);

      await cubit.load();

      final loaded = cubit.state as ProjectsLoaded;
      expect(loaded.projects, hasLength(2));
      expect(loaded.stats.keys, ['owned']);
      expect(loaded.joinedContributors, 4);
      expect(loaded.discoverProjects.single.id, 'discover');
    });

    test('requestToCollaborate updates pending state and counter', () async {
      final repository = _FakeProjectsRepository();
      final cubit = _cubitFor(repository);
      await cubit.load();

      final error = await cubit.requestToCollaborate(
        repository.discoverProject,
        message: 'I can help',
      );

      expect(error, isNull);
      final success = cubit.state as ProjectOperationSuccess;
      final updated = success.projects.firstWhere((p) => p.id == 'discover');
      expect(updated.hasPendingRequest, isTrue);
      expect(
        updated.requestsCount,
        repository.discoverProject.requestsCount + 1,
      );
      expect(repository.lastMessage, 'I can help');
    });

    test(
      'requestToCollaborate is idempotent when a pending request exists',
      () async {
        final repository = _FakeProjectsRepository(created: false);
        final cubit = _cubitFor(repository);
        await cubit.load();

        await cubit.requestToCollaborate(repository.discoverProject);

        final success = cubit.state as ProjectOperationSuccess;
        final updated = success.projects.firstWhere((p) => p.id == 'discover');
        expect(updated.requestsCount, repository.discoverProject.requestsCount);
        expect(updated.hasPendingRequest, isTrue);
      },
    );

    test('upsert emits a success state with the saved project', () async {
      final repository = _FakeProjectsRepository();
      final cubit = _cubitFor(repository);
      await cubit.load();

      final error = await cubit.upsert(_newProject(), isNew: true);

      expect(error, isNull);
      final success = cubit.state as ProjectOperationSuccess;
      expect(success.message, contains('published'));
      expect(success.projects.first.id, 'new-project');
    });

    test(
      'every operation stamps a fresh operation id and fresh error text',
      () async {
        final repository = _FakeProjectsRepository();
        final cubit = _cubitFor(repository);
        await cubit.load();

        await cubit.upsert(_newProject(), isNew: true);
        final first = cubit.state as ProjectOperationSuccess;

        await cubit.upsert(_newProject(), isNew: true);
        final second = cubit.state as ProjectOperationSuccess;

        expect(second.message, first.message);
        expect(second.operationId, isNot(first.operationId));
      },
    );

    test('upsert surfaces repository validation failures', () async {
      final repository = _FakeProjectsRepository(failUpsert: true);
      final cubit = _cubitFor(repository);
      await cubit.load();

      final error = await cubit.upsert(_newProject(), isNew: true);

      expect(error, 'Project title is required');
      expect(cubit.state, isA<ProjectsLoaded>());
      expect(cubit.state, isNot(isA<ProjectOperationSuccess>()));
    });
  });
}

ProjectsCubit _cubitFor(ProjectsRepository repository) {
  return ProjectsCubit(
    getProjects: GetProjects(repository),
    getProjectStats: GetProjectStats(repository),
    upsertProject: UpsertProject(repository),
    requestToCollaborate: RequestToCollaborate(repository),
    getJoinedContributions: GetJoinedContributions(repository),
    recordProjectView: RecordProjectView(repository),
  );
}

Project _newProject() {
  return const Project(
    id: 'new-project',
    title: 'new-project',
    description: 'Fresh',
    githubUrl: 'https://github.com/devsync/new',
    techStack: ['Dart'],
    requiredContributors: 1,
    viewsCount: 0,
    requestsCount: 0,
    matchPercentage: 0,
    isOwner: true,
  );
}

class _FakeProjectsRepository implements ProjectsRepository {
  _FakeProjectsRepository({this.created = true, this.failUpsert = false});

  final bool created;
  final bool failUpsert;
  String? lastMessage;

  Project get ownedProject => Project(
    id: 'owned',
    title: 'owned-project',
    description: 'Mine',
    githubUrl: 'https://github.com/devsync/owned',
    techStack: const ['Dart'],
    requiredContributors: 1,
    viewsCount: 12,
    requestsCount: 2,
    matchPercentage: 80,
    isOwner: true,
    ownerId: 'u1',
  );

  Project get discoverProject => Project(
    id: 'discover',
    title: 'discover-project',
    description: 'Interesting',
    githubUrl: 'https://github.com/devsync/discover',
    techStack: const ['Dart'],
    requiredContributors: 2,
    viewsCount: 5,
    requestsCount: 3,
    matchPercentage: 92,
    isOwner: false,
    ownerId: 'u2',
    ownerName: 'Sara',
  );

  @override
  Future<Result<List<Project>>> getProjects() async {
    return Success([ownedProject, discoverProject]);
  }

  @override
  Future<Result<ProjectStats>> getStats(String projectId) async {
    return Success(
      ProjectStats(
        stars: 5,
        contributors: 2,
        openTasks: 1,
        ownerName: 'Sara',
        ownerResponseTime: 'Usually replies in 1 day',
        updatedLabel: 'Updated today',
        matchSummary: 'Great fit',
        alignments: const [SkillAlignment(label: 'Dart', score: 90)],
        matchedSkills: const ['Dart'],
        weeklyViews: const [1, 2, 3, 4, 5, 6, 7],
      ),
    );
  }

  @override
  Future<Result<Project>> upsert(Project project) async {
    if (failUpsert) {
      return const FailureResult(
        ValidationFailure('Project title is required'),
      );
    }
    return Success(
      project.copyWith(id: 'new-project', isOwner: true, ownerId: 'u1'),
    );
  }

  @override
  Future<Result<CollaborationRequestReceipt>> requestToCollaborate({
    required Project project,
    String? message,
  }) async {
    lastMessage = message;
    return Success(
      CollaborationRequestReceipt(
        requestId: 'r1',
        projectId: project.id,
        created: created,
      ),
    );
  }

  @override
  Future<Result<int>> getJoinedContributions() async => const Success(4);

  @override
  Future<Result<void>> recordView(String projectId) async =>
      const Success(null);
}
