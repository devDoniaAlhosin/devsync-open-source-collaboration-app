import 'dart:math';

class LanguageShare {
  const LanguageShare({
    required this.name,
    required this.percent,
    required this.colorArgb,
  });

  final String name;
  final int percent;

  final int colorArgb;
}

class Profile {
  const Profile({
    required this.name,
    required this.githubUrl,
    required this.bio,
    required this.repos,
    required this.commits,
    required this.languageCount,
    required this.activity,
    required this.languages,
    required this.skills,
    this.suggestedSkills = const [],
  });

  factory Profile.empty({required String name}) {
    return Profile(
      name: name,
      githubUrl: '',
      bio: '',
      repos: 0,
      commits: 0,
      languageCount: 0,
      activity: List.generate(weeks, (_) => List.filled(days, 0)),
      languages: const [],
      skills: const [],
    );
  }

  static const int weeks = 20;
  static const int days = 7;

  final String name;
  final String githubUrl;
  final String bio;
  final int repos;
  final int commits;
  final int languageCount;

  final List<List<int>> activity;
  final List<LanguageShare> languages;
  final List<String> skills;
  final List<String> suggestedSkills;

  bool get hasGithub => githubUrl.trim().isNotEmpty;

  String get githubUsername {
    final parts = githubUrl.split('/').where((p) => p.isNotEmpty).toList();
    return parts.isEmpty ? githubUrl : parts.last;
  }

  int get completion {
    var done = 0;
    if (name.trim().isNotEmpty) done++;
    if (bio.trim().isNotEmpty) done++;
    if (hasGithub) done++;
    if (skills.isNotEmpty) done++;
    if (repos > 0 || languages.isNotEmpty) done++;
    return done * 100 ~/ 5;
  }

  Profile copyWith({
    String? name,
    String? githubUrl,
    String? bio,
    int? repos,
    int? commits,
    int? languageCount,
    List<List<int>>? activity,
    List<LanguageShare>? languages,
    List<String>? skills,
    List<String>? suggestedSkills,
  }) {
    return Profile(
      name: name ?? this.name,
      githubUrl: githubUrl ?? this.githubUrl,
      bio: bio ?? this.bio,
      repos: repos ?? this.repos,
      commits: commits ?? this.commits,
      languageCount: languageCount ?? this.languageCount,
      activity: activity ?? this.activity,
      languages: languages ?? this.languages,
      skills: skills ?? this.skills,
      suggestedSkills: suggestedSkills ?? this.suggestedSkills,
    );
  }

  factory Profile.sample() {
    final rnd = Random(7);
    final activity = List.generate(
      weeks,
      (_) => List.generate(days, (_) {
        final r = rnd.nextDouble();
        if (r < 0.45) return 0;
        if (r < 0.65) return 1;
        if (r < 0.82) return 2;
        if (r < 0.93) return 3;
        return 4;
      }),
    );

    return Profile(
      name: 'Nour Hassan',
      githubUrl: 'github.com/nour-dev',
      bio:
          'Final-year student. I like Flutter animation and shipping small apps.',
      repos: 18,
      commits: 940,
      languageCount: 5,
      activity: activity,
      languages: const [
        LanguageShare(name: 'Dart', percent: 72, colorArgb: 0xFF2EE0C8),
        LanguageShare(name: 'Python', percent: 18, colorArgb: 0xFF8FBFB4),
        LanguageShare(name: 'JS', percent: 10, colorArgb: 0xFF3E5A57),
      ],
      skills: const ['Flutter', 'Firebase', 'Animation'],
    );
  }
}

typedef ProfileData = Profile;
