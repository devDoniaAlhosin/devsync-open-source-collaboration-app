import 'package:devsync_open_source_collaboration_app/core/error/failures.dart';
import 'package:devsync_open_source_collaboration_app/core/result/result.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/data/datasources/insights_remote_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/data/repositories/insights_repository_impl.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/domain/entities/profile.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeProfileRemote extends Fake implements ProfileRemoteDataSource {
  _FakeProfileRemote(this.profile);

  final Profile profile;

  @override
  Future<Profile> fetch() async => profile;
}

class _FakeInsightsRemote extends Fake implements InsightsRemoteDataSource {
  @override
  Future<List<GithubEvent>> fetchEvents(String username) async => const [];

  @override
  Future<GithubPeriodCounts> fetchCounts(String username, DateTime since) async {
    return const GithubPeriodCounts(prsMerged: 1, commits: 2, reviews: 3);
  }
}

void main() {
  test('returns ValidationFailure when GitHub is not connected', () async {
    final repo = InsightsRepositoryImpl(
      profileRemoteDataSource: _FakeProfileRemote(
        Profile.empty(name: 'Nour'),
      ),
      insightsRemoteDataSource: _FakeInsightsRemote(),
    );

    final result = await repo.getInsights();

    expect(result, isA<FailureResult<dynamic>>());
    expect(
      (result as FailureResult).failure,
      isA<ValidationFailure>(),
    );
  });

  test('builds InsightsData when GitHub is connected', () async {
    final profile = Profile.empty(name: 'Nour').copyWith(
      githubUrl: 'https://github.com/nour',
    );
    final repo = InsightsRepositoryImpl(
      profileRemoteDataSource: _FakeProfileRemote(profile),
      insightsRemoteDataSource: _FakeInsightsRemote(),
      now: () => DateTime.utc(2026, 11, 27),
    );

    final result = await repo.getInsights();

    expect(result, isA<Success>());
    final data = (result as Success).data;
    expect(data.summaryPrs, 1);
    expect(data.summaryCommits, 2);
  });
}
