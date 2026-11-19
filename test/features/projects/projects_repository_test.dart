import 'package:devsync_open_source_collaboration_app/core/error/failures.dart';
import 'package:devsync_open_source_collaboration_app/core/result/result.dart';
import 'package:devsync_open_source_collaboration_app/features/projects/data/models/project_model.dart';
import 'package:devsync_open_source_collaboration_app/features/projects/domain/entities/project.dart';
import 'package:devsync_open_source_collaboration_app/features/projects/domain/entities/project_stats.dart';
import 'package:devsync_open_source_collaboration_app/features/projects/domain/repositories/projects_repository.dart';
import 'package:devsync_open_source_collaboration_app/features/projects/domain/usecases/delete_project.dart';
import 'package:devsync_open_source_collaboration_app/features/projects/domain/usecases/upsert_project.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('create payload (real app flow)', () {
    test('new project writes ownerId schema not seed fields', () {
      final model = ProjectModel.fromMap('tmp', {
        'title': 'real-project',
        'description': 'From List a project',
        'githubUrl': 'https://github.com/devsync/real',
        'techStack': const ['Dart', 'Flutter'],
        'requiredContributors': 2,
      });

      final payload = model.toFirestore(
        ownerId: 'firebaseUid123',
        ownerName: 'Saga',
        isNew: true,
      );

      expect(payload['ownerId'], 'firebaseUid123');
      expect(payload['ownerName'], 'Saga');
      expect(payload['title'], 'real-project');
      expect(payload['techStack'], ['Dart', 'Flutter']);
      expect(payload['requiredContributors'], 2);
      expect(payload['viewsCount'], 0);
      expect(payload['requestsCount'], 0);
      expect(payload.containsKey('createdAt'), isTrue);
      expect(payload.containsKey('updatedAt'), isTrue);

      expect(payload.containsKey('difficulty'), isFalse);
      expect(payload.containsKey('maintainerId'), isFalse);
      expect(payload.containsKey('neededSkills'), isFalse);
      expect(payload.containsKey('contributorsCount'), isFalse);
    });
  });

  group('UpsertProject / DeleteProject use cases', () {
    test('upsert delegates to repository', () async {
      final repo = _FakeRepo();
      final result = await UpsertProject(repo)(_validCreate());

      expect(result, isA<Success<Project>>());
      expect(repo.upsertCalls, 1);
    });

    test('delete delegates to repository', () async {
      final repo = _FakeRepo();
      final result = await DeleteProject(repo)(
        const DeleteProjectParams('owned'),
      );

      expect(result, isA<Success<void>>());
      expect(repo.deleteCalls, 1);
    });

    test('delete empty id fails', () async {
      final repo = _FakeRepo(rejectEmptyDelete: true);
      final result = await DeleteProject(repo)(const DeleteProjectParams(''));

      expect(result, isA<FailureResult<void>>());
      expect(repo.deleteCalls, 1);
    });
  });
}

Project _validCreate() {
  return const Project(
    id: '',
    title: 'real-project',
    description: 'From List a project',
    githubUrl: 'https://github.com/devsync/real',
    techStack: ['Dart', 'Flutter'],
    requiredContributors: 2,
    viewsCount: 0,
    requestsCount: 0,
    matchPercentage: 0,
    isOwner: true,
  );
}

class _FakeRepo implements ProjectsRepository {
  _FakeRepo({this.rejectEmptyDelete = false});

  final bool rejectEmptyDelete;
  int upsertCalls = 0;
  int deleteCalls = 0;

  @override
  Future<Result<List<Project>>> getProjects() async => const Success([]);

  @override
  Future<Result<Project>> getProject(String projectId) async {
    return const FailureResult(NotFoundFailure('Project not found'));
  }

  @override
  Future<Result<ProjectStats>> getStats(String projectId) async {
    return const FailureResult(NotFoundFailure('Project not found'));
  }

  @override
  Future<Result<Project>> upsert(Project project) async {
    upsertCalls++;
    return Success(
      project.copyWith(id: 'created-id', ownerId: 'u1', isOwner: true),
    );
  }

  @override
  Future<Result<void>> delete(String projectId) async {
    deleteCalls++;
    if (rejectEmptyDelete && projectId.trim().isEmpty) {
      return const FailureResult(ValidationFailure('Project id is required'));
    }
    return const Success(null);
  }

  @override
  Future<Result<int>> getJoinedContributions() async => const Success(0);

  @override
  Future<Result<void>> recordView(String projectId) async =>
      const Success(null);
}
