import 'package:devsync_open_source_collaboration_app/features/profile/data/datasources/insights_remote_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/data/exceptions/github_profile_exceptions.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/data/models/insights_data.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/repositories/insights_repository.dart';

class InsightsRepositoryImpl implements InsightsRepository {
  InsightsRepositoryImpl({
    required ProfileRemoteDataSource profileRemoteDataSource,
    required InsightsRemoteDataSource insightsRemoteDataSource,
    DateTime Function()? now,
  }) : _profile = profileRemoteDataSource,
       _insights = insightsRemoteDataSource,
       _now = now ?? DateTime.now;

  final ProfileRemoteDataSource _profile;
  final InsightsRemoteDataSource _insights;
  final DateTime Function() _now;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Future<Result<InsightsData>> getInsights() async {
    try {
      final profile = await _profile.fetch();
      if (!profile.hasGithub) {
        return const FailureResult(
          ValidationFailure(
            'Connect GitHub to see your insights',
            field: 'github',
          ),
        );
      }

      final username = profile.githubUsername;
      final now = _now().toUtc();
      final events = await _insights.fetchEvents(username);

      final stats = <InsightsPeriod, PeriodStats>{};
      for (final period in InsightsPeriod.values) {
        final since = now.subtract(Duration(days: _days(period)));
        final counts = await _insights.fetchCounts(username, since);
        stats[period] = PeriodStats(
          prsMerged: counts.prsMerged,
          commits: counts.commits,
          reviews: counts.reviews,
          activeProjects: _activeProjects(events, since),
          bars: _bars(period, events, now),
        );
      }

      final last90 = stats[InsightsPeriod.days90]!;
      return Success(
        InsightsData(
          summaryPrs: last90.prsMerged,
          summaryCommits: last90.commits,
          summaryProjects: last90.activeProjects,
          stats: stats,
          milestones: [
            Milestone(
              title: 'First accepted contribution',
              subtitle: 'Merged your first community PR',
              achieved: last90.prsMerged > 0,
              number: 1,
            ),
            Milestone(
              title: 'Community collaborator',
              subtitle: 'Joined three active projects',
              achieved: last90.activeProjects >= 3,
              number: 2,
            ),
            const Milestone(
              title: 'Project maintainer',
              subtitle: 'Publish your first project to unlock',
              achieved: false,
              number: 3,
            ),
          ],
        ),
      );
    } catch (e) {
      return FailureResult(_mapError(e));
    }
  }

  int _days(InsightsPeriod period) => switch (period) {
    InsightsPeriod.days7 => 7,
    InsightsPeriod.days30 => 30,
    InsightsPeriod.days90 => 90,
  };

  int _bucketCount(InsightsPeriod period) => switch (period) {
    InsightsPeriod.days7 => 7,
    InsightsPeriod.days30 => 4,
    InsightsPeriod.days90 => 12,
  };

  int _activeProjects(List<GithubEvent> events, DateTime since) {
    return {
      for (final e in events)
        if (!e.createdAt.isBefore(since)) e.repo,
    }.length;
  }

  List<BarPoint> _bars(
    InsightsPeriod period,
    List<GithubEvent> events,
    DateTime now,
  ) {
    final today = DateTime.utc(now.year, now.month, now.day);
    final span = _days(period);
    final buckets = _bucketCount(period);
    final counts = List<int>.filled(buckets, 0);

    for (final e in events) {
      final day = DateTime.utc(
        e.createdAt.year,
        e.createdAt.month,
        e.createdAt.day,
      );
      final daysAgo = today.difference(day).inDays;
      if (daysAgo < 0 || daysAgo >= span) continue;
      final fromEnd = daysAgo * buckets ~/ span;
      counts[buckets - 1 - fromEnd]++;
    }

    return [
      for (var i = 0; i < buckets; i++)
        BarPoint(_label(period, i, buckets, today), counts[i]),
    ];
  }

  String _label(InsightsPeriod period, int index, int buckets, DateTime today) {
    if (period == InsightsPeriod.days7) {
      final day = today.subtract(Duration(days: buckets - 1 - index));
      return _weekdays[day.weekday - 1];
    }
    return 'W${index + 1}';
  }

  Failure _mapError(Object e) {
    if (e is NotSignedInException) {
      return const AuthFailure('Please sign in again');
    }
    if (e is GithubUserNotFoundException) {
      return const NotFoundFailure('GitHub user not found');
    }
    if (e is GithubProfileNetworkException) {
      return const NetworkFailure();
    }
    if (e is GithubProfileException) {
      return const UnexpectedFailure(
        'Could not load your GitHub activity. '
        'If this keeps happening, wait a minute and retry.',
      );
    }
    if (e is FirebaseException) {
      switch (e.code) {
        case 'permission-denied':
          return const PermissionFailure();
        case 'unavailable':
        case 'deadline-exceeded':
        case 'network-request-failed':
          return const NetworkFailure();
      }
    }
    return const UnexpectedFailure();
  }
}
