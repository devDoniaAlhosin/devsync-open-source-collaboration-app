import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../../profile/domain/entities/profile.dart';

class ProfileHashGenerator {
  static String fromProfile(Profile profile) {
    final githubLanguages = <String, int>{};
    for (final lang in profile.languages) {
      githubLanguages[lang.name] = lang.percent;
    }

    final Map<String, dynamic> hashData = {
      'declaredSkills': List<String>.from(profile.skills)..sort(),
      'githubLanguages': _sortedLanguages(githubLanguages),
      'publicRepoCount': profile.repos,
      'totalContributions': profile.commits,
      'topRepositories': List<String>.from(profile.topRepositories)..sort(),
    };

    final jsonString = json.encode(hashData);
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);

    return digest.toString();
  }

  static Map<String, int> _sortedLanguages(Map<String, int> languages) {
    final sortedKeys = languages.keys.toList()..sort();
    return {for (var key in sortedKeys) key: languages[key]!};
  }
}
