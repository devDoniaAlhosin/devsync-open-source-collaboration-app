import 'dart:math';

class LanguageShare {
  const LanguageShare({
    required this.name,
    required this.percent,
    required this.colorArgb,
  });

  final String name;
  final int percent;

  /// ARGB color value (UI converts with `Color(colorArgb)`).
  final int colorArgb;
}

class Profile {
  const Profile({
    required this.name,
    required this.githubUrl,
    required this.completion,
    required this.bio,
    required this.repos,
    required this.commits,
    required this.languageCount,
    required this.activity,
    required this.languages,
    required this.skills,
    this.suggestedSkills = const [],
  });

  final String name;
  final String githubUrl;
  final int completion;
  final String bio;
  final int repos;
  final int commits;
  final int languageCount;
  final List<List<int>> activity;
  final List<LanguageShare> languages;
  final List<String> skills;
  final List<String> suggestedSkills;

  String get githubUsername {
    final parts = githubUrl.split('/').where((p) => p.isNotEmpty).toList();
    return parts.isEmpty ? githubUrl : parts.last;
  }

  Profile copyWith({String? bio, List<String>? skills}) {
    return Profile(
      name: name,
      githubUrl: githubUrl,
      completion: completion,
      bio: bio ?? this.bio,
      repos: repos,
      commits: commits,
      languageCount: languageCount,
      activity: activity,
      languages: languages,
      skills: skills ?? this.skills,
      suggestedSkills: suggestedSkills,
    );
  }

  static const int weeks = 20;
  static const int days = 7;

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
      completion: 80,
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

/// Backward-compatible alias while screens migrate imports.
typedef ProfileData = Profile;
