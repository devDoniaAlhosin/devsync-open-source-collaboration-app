import 'package:devsync_open_source_collaboration_app/core/result/result.dart';
import 'package:devsync_open_source_collaboration_app/features/notifications/data/datasources/notify_remote_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/projects/data/datasources/projects_remote_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/projects/data/repositories/projects_repository_impl.dart';
import 'package:devsync_open_source_collaboration_app/features/projects/domain/entities/project.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unused in these tests — upsert goes through [upsertOverride].
class _UnusedRemote extends Fake implements ProjectsRemoteDataSource {}

class _FakeNotify extends Fake implements NotifyRemoteDataSource {
  final projectIds = <String>[];

  @override
  Future<void> notifyProjectUpdated({required String projectId}) async {
    projectIds.add(projectId);
  }
}

Project _project({required String id}) {
  return Project(
    id: id,
    title: 'Charts',
    description: 'Flutter charts kit',
    githubUrl: 'https://github.com/org/charts',
    techStack: const ['Flutter'],
    requiredContributors: 1,
    viewsCount: 0,
    requestsCount: 0,
    matchPercentage: 0,
    isOwner: true,
    ownerId: 'owner-1',
    ownerName: 'Karim',
  );
}

void main() {
  late _FakeNotify notify;

  setUp(() {
    notify = _FakeNotify();
  });

  test('update calls notifyProjectUpdated', () async {
    final project = _project(id: 'p-existing');
    final repository = ProjectsRepositoryImpl(
      remote: _UnusedRemote(),
      notifyRemoteDataSource: notify,
      upsertOverride: (p) async => p,
    );

    final result = await repository.upsert(project);

    expect(result, isA<Success<Project>>());
    await Future<void>.delayed(Duration.zero);
    expect(notify.projectIds, ['p-existing']);
  });

  test('create does not call notifyProjectUpdated', () async {
    final draft = _project(id: '');
    final repository = ProjectsRepositoryImpl(
      remote: _UnusedRemote(),
      notifyRemoteDataSource: notify,
      upsertOverride: (p) async => _project(id: 'p-new'),
    );

    final result = await repository.upsert(draft);

    expect(result, isA<Success<Project>>());
    await Future<void>.delayed(Duration.zero);
    expect(notify.projectIds, isEmpty);
  });
}
