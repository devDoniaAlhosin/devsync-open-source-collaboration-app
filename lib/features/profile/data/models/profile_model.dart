import '../../domain/entities/profile.dart';

abstract final class ProfileModel {
  static Profile fromMap(
    Map<String, dynamic> map, {
    required String fallbackName,
  }) {
    final name = _str(map['name']).trim();
    return Profile(
      name: name.isEmpty ? fallbackName : name,
      githubUrl: _str(map['githubUrl']),
      bio: _str(map['bio']),
      repos: _int(map['repos']),
      commits: _int(map['commits']),
      languageCount: _int(map['languageCount']),
      activity: _activityFromFlat(map['activity']),
      languages: _languages(map['languages']),
      skills: _strings(map['skills']),
      suggestedSkills: _strings(map['suggestedSkills']),
    );
  }

  static Map<String, dynamic> toMap(Profile p) {
    return {
      'name': p.name,
      'githubUrl': p.githubUrl,
      'bio': p.bio,
      'repos': p.repos,
      'commits': p.commits,
      'languageCount': p.languageCount,
      'languages': [
        for (final l in p.languages)
          {'name': l.name, 'percent': l.percent, 'colorArgb': l.colorArgb},
      ],
      'activity': [for (final week in p.activity) ...week],
      'skills': p.skills,
      'suggestedSkills': p.suggestedSkills,
    };
  }

  static String _str(Object? v) => v is String ? v : '';

  static int _int(Object? v) => v is num ? v.toInt() : 0;

  static List<String> _strings(Object? v) =>
      v is List ? v.whereType<String>().toList() : const [];

  static List<LanguageShare> _languages(Object? v) {
    if (v is! List) return const [];
    return [
      for (final item in v)
        if (item is Map)
          LanguageShare(
            name: _str(item['name']),
            percent: _int(item['percent']),
            colorArgb: item['colorArgb'] is num
                ? (item['colorArgb'] as num).toInt()
                : 0xFF3E5A57,
          ),
    ];
  }

  static List<List<int>> _activityFromFlat(Object? v) {
    final flat = v is List
        ? [for (final e in v) e is num ? e.toInt() : 0]
        : <int>[];
    return List.generate(
      Profile.weeks,
      (w) => List.generate(Profile.days, (d) {
        final i = w * Profile.days + d;
        return i < flat.length ? flat[i].clamp(0, 4).toInt() : 0;
      }),
    );
  }
}
