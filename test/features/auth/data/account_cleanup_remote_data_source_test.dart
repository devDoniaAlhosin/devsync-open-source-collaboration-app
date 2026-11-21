import 'package:devsync_open_source_collaboration_app/features/auth/data/datasources/account_cleanup_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('chunkForBatch', () {
    test('returns empty for empty input', () {
      expect(chunkForBatch<int>(const [], 400), isEmpty);
    });

    test('keeps a short list as a single chunk', () {
      expect(chunkForBatch([1, 2, 3], 400), [
        [1, 2, 3],
      ]);
    });

    test('splits at the batch limit', () {
      final items = List<int>.generate(401, (i) => i);
      final chunks = chunkForBatch(items, 400);
      expect(chunks.length, 2);
      expect(chunks[0].length, 400);
      expect(chunks[1], [400]);
    });

    test('rejects a non-positive size', () {
      expect(() => chunkForBatch([1], 0), throwsArgumentError);
    });
  });

  test('wipe steps stay in cascade order', () {
    expect(AccountCleanupRemoteDataSource.wipeSteps, [
      'feedbacks.userId',
      'matches.userId',
      'requests.senderId',
      'requests.ownerId',
      'projects.ownerId',
      'views.viewerId',
      'users.notifications',
      'users.fcmTokens',
      'users.doc',
    ]);
  });
}
