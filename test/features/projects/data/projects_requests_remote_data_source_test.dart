import 'package:devsync_open_source_collaboration_app/features/projects/data/datasources/projects_requests_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('counts unique pending senders per project only', () {
    final counts =
        ProjectsRequestsRemoteDataSource.countPendingRequestsByProject([
          {'projectId': 'project-1', 'senderId': 'user-1', 'status': 'pending'},
          {'projectId': 'project-1', 'senderId': 'user-1', 'status': 'pending'},
          {'projectId': 'project-1', 'senderId': 'user-2', 'status': 'isNew'},
          {
            'projectId': 'project-1',
            'senderId': 'user-3',
            'status': 'accepted',
          },
          {'projectId': 'project-2', 'senderId': 'user-4', 'status': 'pending'},
        ]);

    expect(counts, {'project-1': 2, 'project-2': 1});
  });
}
