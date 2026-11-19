import 'package:flutter_test/flutter_test.dart';

import 'package:devsync_open_source_collaboration_app/core/error/failures.dart';
import 'package:devsync_open_source_collaboration_app/core/result/result.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/feedback_record.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/repositories/feedback_repository.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/usecases/get_user_feedback_usecase.dart';

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class _FakeFeedbackRepository implements FeedbackRepository {
  _FakeFeedbackRepository(this._result);

  final Result<List<FeedbackRecord>> _result;

  @override
  Future<Result<List<FeedbackRecord>>> getUserFeedback() async => _result;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

FeedbackRecord _record({
  required String id,
  required String projectId,
  required String action,
  DateTime? timestamp,
}) => FeedbackRecord(
  id: id,
  userId: 'user1',
  projectId: projectId,
  action: action,
  timestamp: timestamp,
);

final _t1 = DateTime(2024, 1, 10);
final _t2 = DateTime(2024, 1, 20);
final _t3 = DateTime(2024, 1, 30);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('GetUserFeedbackUseCase', () {
    test('returns empty list when repository returns empty', () async {
      final useCase = GetUserFeedbackUseCase(
        _FakeFeedbackRepository(const Success([])),
      );
      final result = await useCase();
      result.fold(
        (f) => fail('expected success, got failure: ${f.message}'),
        (records) => expect(records, isEmpty),
      );
    });

    test('propagates Failure from repository', () async {
      final useCase = GetUserFeedbackUseCase(
        _FakeFeedbackRepository(const FailureResult(AuthFailure('auth error'))),
      );
      final result = await useCase();
      result.fold(
        (f) => expect(f.message, 'auth error'),
        (_) => fail('expected failure'),
      );
    });

    test('deduplicates by projectId — latest timestamp wins', () async {
      final records = [
        _record(id: 'a', projectId: 'p1', action: 'like', timestamp: _t1),
        _record(
          id: 'b',
          projectId: 'p1',
          action: 'skip',
          timestamp: _t3,
        ), // newer
        _record(id: 'c', projectId: 'p2', action: 'like', timestamp: _t2),
      ];
      final useCase = GetUserFeedbackUseCase(
        _FakeFeedbackRepository(Success(records)),
      );
      final result = await useCase();
      result.fold((f) => fail('expected success'), (deduped) {
        expect(deduped.length, 2);
        final p1 = deduped.firstWhere((r) => r.projectId == 'p1');
        expect(p1.id, 'b'); // latest
        expect(p1.action, 'skip');
      });
    });

    test('sorts descending by timestamp', () async {
      final records = [
        _record(id: 'a', projectId: 'p1', action: 'like', timestamp: _t1),
        _record(id: 'b', projectId: 'p2', action: 'skip', timestamp: _t3),
        _record(id: 'c', projectId: 'p3', action: 'like', timestamp: _t2),
      ];
      final useCase = GetUserFeedbackUseCase(
        _FakeFeedbackRepository(Success(records)),
      );
      final result = await useCase();
      result.fold((f) => fail('expected success'), (sorted) {
        expect(sorted.map((r) => r.id).toList(), ['b', 'c', 'a']);
      });
    });

    test('tolerates null timestamp — nulls sorted last', () async {
      final records = [
        _record(id: 'a', projectId: 'p1', action: 'like', timestamp: null),
        _record(id: 'b', projectId: 'p2', action: 'skip', timestamp: _t1),
      ];
      final useCase = GetUserFeedbackUseCase(
        _FakeFeedbackRepository(Success(records)),
      );
      final result = await useCase();
      result.fold((f) => fail('expected success'), (sorted) {
        expect(sorted.first.id, 'b'); // has timestamp
        expect(sorted.last.id, 'a'); // null timestamp
      });
    });

    test('isLike and isSkip helpers on FeedbackRecord', () {
      final like = _record(id: 'x', projectId: 'p', action: 'like');
      final skip = _record(id: 'y', projectId: 'q', action: 'skip');
      final other = _record(id: 'z', projectId: 'r', action: 'request');
      expect(like.isLike, isTrue);
      expect(like.isSkip, isFalse);
      expect(skip.isSkip, isTrue);
      expect(skip.isLike, isFalse);
      expect(other.isLike, isFalse);
      expect(other.isSkip, isFalse);
    });

    test('dedup keeps single record for single-occurrence projects', () async {
      final records = [
        _record(id: 'a', projectId: 'p1', action: 'like', timestamp: _t1),
        _record(id: 'b', projectId: 'p2', action: 'like', timestamp: _t2),
        _record(id: 'c', projectId: 'p3', action: 'skip', timestamp: _t3),
      ];
      final useCase = GetUserFeedbackUseCase(
        _FakeFeedbackRepository(Success(records)),
      );
      final result = await useCase();
      result.fold((f) => fail('expected success'), (deduped) {
        expect(deduped.length, 3);
        expect(deduped.map((r) => r.id).toList(), ['c', 'b', 'a']);
      });
    });
  });
}
