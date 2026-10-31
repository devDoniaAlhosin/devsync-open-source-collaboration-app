import '../../domain/entities/project.dart';
import '../../domain/entities/project_stats.dart';

/// Local / dummy projects source until Firestore is wired.
class ProjectsLocalDataSource {
  ProjectsLocalDataSource()
    : _projects = List<Project>.from(_seedProjects),
      _stats = Map<String, ProjectStats>.from(_seedStats);

  static const joinedContributors = 3;

  final List<Project> _projects;
  final Map<String, ProjectStats> _stats;

  Future<List<Project>> fetchProjects() async =>
      List<Project>.unmodifiable(_projects);

  Future<ProjectStats> statsFor(String projectId) async {
    return _stats[projectId] ?? _fallbackStats;
  }

  Future<Project> upsert(Project project) async {
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index == -1) {
      _projects.insert(0, project);
    } else {
      _projects[index] = project;
    }
    return project;
  }

  static const _seedProjects = <Project>[
    Project(
      id: 'flutter-charts',
      title: 'flutter-oss/charts',
      description:
          'A lightweight charting package for Flutter. Karim needs 2 or 3 '
          'contributors for animation, tests and docs.',
      githubUrl: 'https://github.com/flutter-oss/charts',
      techStack: ['Dart', 'Firebase', 'Animation', 'Testing'],
      requiredContributors: 3,
      viewsCount: 1240,
      requestsCount: 18,
      matchPercentage: 92,
      isOwner: false,
    ),
    Project(
      id: 'devsync-api',
      title: 'devsync-api',
      description:
          'REST and Cloud Functions backend for DevSync. Built for fast, '
          'composable developer collaboration.',
      githubUrl: 'https://github.com/devsync/api',
      techStack: ['TypeScript', 'Firebase'],
      requiredContributors: 2,
      viewsCount: 24,
      requestsCount: 3,
      matchPercentage: 88,
      isOwner: true,
    ),
    Project(
      id: 'mint-ui',
      title: 'mint-ui',
      description:
          'A mint-fresh component library for Flutter. Accessible, tactile '
          'and designed for dark-first products.',
      githubUrl: 'https://github.com/devsync/mint-ui',
      techStack: ['Dart', 'Design', 'Flutter'],
      requiredContributors: 1,
      viewsCount: 14,
      requestsCount: 4,
      matchPercentage: 85,
      isOwner: true,
    ),
    Project(
      id: 'pulse-analytics',
      title: 'pulse-analytics',
      description:
          'Open-source product analytics with privacy at its core. Looking for '
          'backend and data-viz collaborators.',
      githubUrl: 'https://github.com/pulse/analytics',
      techStack: ['Python', 'FastAPI', 'React'],
      requiredContributors: 2,
      viewsCount: 638,
      requestsCount: 9,
      matchPercentage: 76,
      isOwner: false,
    ),
    Project(
      id: 'openboard',
      title: 'openboard',
      description:
          'A realtime whiteboard for distributed teams. WebRTC, canvas and a '
          'surprisingly small bundle.',
      githubUrl: 'https://github.com/openboard/space',
      techStack: ['Next.js', 'TypeScript', 'Tailwind'],
      requiredContributors: 3,
      viewsCount: 412,
      requestsCount: 5,
      matchPercentage: 81,
      isOwner: false,
    ),
    Project(
      id: 'first-commit',
      title: 'first-commit',
      description:
          'Curated beginner issues, friendly reviews and a weekly pairing '
          'session for developers making their first open-source contribution.',
      githubUrl: 'https://github.com/firstcommit/community',
      techStack: ['Docs', 'Testing', 'TypeScript'],
      requiredContributors: 4,
      viewsCount: 204,
      requestsCount: 2,
      matchPercentage: 68,
      isOwner: false,
    ),
  ];

  static const _seedStats = <String, ProjectStats>{
    'flutter-charts': ProjectStats(
      stars: 1240,
      contributors: 6,
      openTasks: 3,
      ownerName: 'Karim A.',
      ownerResponseTime: 'Usually replies in 1 day',
      updatedLabel: 'Updated 2 days ago',
      matchSummary:
          'You wrote 14 Dart repos and shipped Firebase auth in two projects.',
      alignments: [
        SkillAlignment(label: 'Dart', score: 94),
        SkillAlignment(label: 'Firebase', score: 88),
        SkillAlignment(label: 'Activity', score: 76),
      ],
      matchedSkills: ['Dart', 'Firebase', 'Animation'],
      weeklyViews: [4, 7, 5, 11, 8, 14, 17],
    ),
    'devsync-api': ProjectStats(
      stars: 48,
      contributors: 3,
      openTasks: 5,
      ownerName: 'You',
      ownerResponseTime: 'Usually replies in 2 hours',
      updatedLabel: 'Updated today',
      matchSummary:
          'Your TypeScript and Firebase work maps directly to the backend.',
      alignments: [
        SkillAlignment(label: 'TypeScript', score: 90),
        SkillAlignment(label: 'Firebase', score: 86),
        SkillAlignment(label: 'Activity', score: 72),
      ],
      matchedSkills: ['TypeScript', 'Firebase'],
      weeklyViews: [2, 3, 2, 5, 4, 6, 8],
    ),
    'mint-ui': ProjectStats(
      stars: 21,
      contributors: 2,
      openTasks: 4,
      ownerName: 'You',
      ownerResponseTime: 'Usually replies in 2 hours',
      updatedLabel: 'Updated 3 days ago',
      matchSummary:
          'Your Flutter and design system work makes you a strong fit.',
      alignments: [
        SkillAlignment(label: 'Dart', score: 91),
        SkillAlignment(label: 'Design', score: 84),
        SkillAlignment(label: 'Activity', score: 69),
      ],
      matchedSkills: ['Dart', 'Design'],
      weeklyViews: [3, 4, 3, 4, 5, 5, 6],
    ),
    'pulse-analytics': ProjectStats(
      stars: 386,
      contributors: 4,
      openTasks: 7,
      ownerName: 'Sara M.',
      ownerResponseTime: 'Usually replies in 3 days',
      updatedLabel: 'Updated 1 week ago',
      matchSummary:
          'Your data-viz experiments overlap with the dashboard roadmap.',
      alignments: [
        SkillAlignment(label: 'Python', score: 70),
        SkillAlignment(label: 'FastAPI', score: 64),
        SkillAlignment(label: 'Activity', score: 81),
      ],
      matchedSkills: ['React'],
      weeklyViews: [6, 5, 9, 8, 10, 12, 11],
    ),
    'openboard': ProjectStats(
      stars: 742,
      contributors: 8,
      openTasks: 2,
      ownerName: 'Nour K.',
      ownerResponseTime: 'Usually replies in 12 hours',
      updatedLabel: 'Updated 4 days ago',
      matchSummary: 'Your TypeScript work is a match for the realtime editor.',
      alignments: [
        SkillAlignment(label: 'TypeScript', score: 83),
        SkillAlignment(label: 'React', score: 79),
        SkillAlignment(label: 'Activity', score: 66),
      ],
      matchedSkills: ['TypeScript'],
      weeklyViews: [9, 11, 8, 12, 14, 13, 16],
    ),
    'first-commit': ProjectStats(
      stars: 193,
      contributors: 12,
      openTasks: 6,
      ownerName: 'Maya R.',
      ownerResponseTime: 'Usually replies in 1 day',
      updatedLabel: 'Updated 5 days ago',
      matchSummary:
          'A welcoming project that matches your testing and docs interests.',
      alignments: [
        SkillAlignment(label: 'Testing', score: 74),
        SkillAlignment(label: 'Docs', score: 68),
        SkillAlignment(label: 'Activity', score: 52),
      ],
      matchedSkills: ['Testing'],
      weeklyViews: [5, 4, 6, 5, 7, 6, 8],
    ),
  };

  static const _fallbackStats = ProjectStats(
    stars: 0,
    contributors: 1,
    openTasks: 0,
    ownerName: 'You',
    ownerResponseTime: 'Usually replies in 1 day',
    updatedLabel: 'Updated just now',
    matchSummary:
        'Your project is live. Contributors will see how their skills align.',
    alignments: [
      SkillAlignment(label: 'Dart', score: 0),
      SkillAlignment(label: 'Firebase', score: 0),
      SkillAlignment(label: 'Activity', score: 0),
    ],
    matchedSkills: [],
    weeklyViews: [0, 0, 1, 1, 2, 2, 3],
  );
}
