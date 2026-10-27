/// Time window for the analytics section.
enum InsightsPeriod {
  days7('7 days', 'Last 7 days'),
  days30('30 days', 'Last 30 days'),
  days90('90 days', 'Last 90 days');

  const InsightsPeriod(this.chipLabel, this.longLabel);

  final String chipLabel;
  final String longLabel;
}

class BarPoint {
  const BarPoint(this.label, this.value);

  final String label;
  final int value;
}

class PeriodStats {
  const PeriodStats({
    required this.prsMerged,
    required this.commits,
    required this.reviews,
    required this.activeProjects,
    required this.bars,
  });

  final int prsMerged;
  final int commits;
  final int reviews;
  final int activeProjects;
  final List<BarPoint> bars;
}

class Milestone {
  const Milestone({
    required this.title,
    required this.subtitle,
    required this.achieved,
    required this.number,
  });

  final String title;
  final String subtitle;
  final bool achieved;
  final int number;
}

class InsightsData {
  const InsightsData({
    required this.summaryPrs,
    required this.summaryCommits,
    required this.summaryProjects,
    required this.stats,
    required this.milestones,
  });

  final int summaryPrs;
  final int summaryCommits;
  final int summaryProjects;
  final Map<InsightsPeriod, PeriodStats> stats;
  final List<Milestone> milestones;

  PeriodStats statsFor(InsightsPeriod p) => stats[p]!;

  factory InsightsData.sample() {
    const week = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final week7 = [
      for (final (i, v) in [3, 7, 4, 10, 6, 13, 8].indexed)
        BarPoint(week[i], v),
    ];
    final weeks4 = [
      for (final (i, v) in [38, 52, 44, 56].indexed) BarPoint('W${i + 1}', v),
    ];
    final weeks12 = [
      for (final (i, v) in [
        30,
        42,
        35,
        50,
        44,
        61,
        48,
        55,
        40,
        63,
        52,
        70,
      ].indexed)
        BarPoint('W${i + 1}', v),
    ];

    return InsightsData(
      summaryPrs: 12,
      summaryCommits: 48,
      summaryProjects: 4,
      stats: {
        InsightsPeriod.days7: PeriodStats(
          prsMerged: 12,
          commits: 48,
          reviews: 7,
          activeProjects: 4,
          bars: week7,
        ),
        InsightsPeriod.days30: PeriodStats(
          prsMerged: 41,
          commits: 190,
          reviews: 26,
          activeProjects: 6,
          bars: weeks4,
        ),
        InsightsPeriod.days90: PeriodStats(
          prsMerged: 118,
          commits: 540,
          reviews: 71,
          activeProjects: 9,
          bars: weeks12,
        ),
      },
      milestones: const [
        Milestone(
          title: 'First accepted contribution',
          subtitle: 'Merged your first community PR',
          achieved: true,
          number: 1,
        ),
        Milestone(
          title: 'Community collaborator',
          subtitle: 'Joined three active projects',
          achieved: true,
          number: 2,
        ),
        Milestone(
          title: 'Project maintainer',
          subtitle: 'Publish your first project to unlock',
          achieved: false,
          number: 3,
        ),
      ],
    );
  }
}
