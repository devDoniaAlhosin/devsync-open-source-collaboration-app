import 'package:devsync_open_source_collaboration_app/core/error/failures.dart';
import 'package:devsync_open_source_collaboration_app/core/result/result.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/data/models/insights_data.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/domain/repositories/insights_repository.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/domain/usecases/get_insights.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/cubit/insights_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeInsightsRepository implements InsightsRepository {
  _FakeInsightsRepository(this.result);

  Result<InsightsData> result;
  var calls = 0;

  @override
  Future<Result<InsightsData>> getInsights() async {
    calls += 1;
    return result;
  }
}

void main() {
  test('load emits InsightsLoaded on success', () async {
    final repo = _FakeInsightsRepository(Success(InsightsData.sample()));
    final cubit = InsightsCubit(getInsights: GetInsights(repo));

    await cubit.load();

    expect(cubit.state, isA<InsightsLoaded>());
    expect(repo.calls, 1);
    await cubit.close();
  });

  test('load emits InsightsFailure on error', () async {
    final repo = _FakeInsightsRepository(
      const FailureResult(ValidationFailure('Connect GitHub')),
    );
    final cubit = InsightsCubit(getInsights: GetInsights(repo));

    await cubit.load();

    expect(cubit.state, isA<InsightsFailure>());
    expect((cubit.state as InsightsFailure).message, 'Connect GitHub');
    await cubit.close();
  });

  test('load ignores result when cubit already closed', () async {
    final repo = _FakeInsightsRepository(Success(InsightsData.sample()));
    final cubit = InsightsCubit(getInsights: GetInsights(repo));

    final future = cubit.load();
    await cubit.close();
    await future;

    expect(repo.calls, 1);
  });
}
