import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../../profile/domain/entities/profile.dart';

/// Utility for generating profile hashes for cache invalidation.
///
/// Creates a hash from profile fields that affect matching recommendations.
/// When these fields change, the cache is automatically invalidated.
class ProfileHashGenerator {
  /// Generate a hash from a Profile entity.
  static String fromProfile(Profile profile) {
    // Extract matching-relevant fields from Profile
    final githubLanguages = <String, int>{};
    for (final lang in profile.languages) {
      githubLanguages[lang.name] = lang.percent;
    }

    // Create a stable string representation of matching-relevant fields
    final Map<String, dynamic> hashData = {
      'declaredSkills': List<String>.from(profile.skills)..sort(),
      'githubLanguages': _sortedLanguages(githubLanguages),
      'publicRepoCount': profile.repos,
      'totalContributions': profile.commits,
      'topRepositories': List<String>.from(profile.topRepositories)..sort(),
    };

    // Convert to JSON and hash
    final jsonString = json.encode(hashData);
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);

    return digest.toString();
  }

  /// Sort GitHub languages map by key for stable hashing.
  static Map<String, int> _sortedLanguages(Map<String, int> languages) {
    final sortedKeys = languages.keys.toList()..sort();
    return {for (var key in sortedKeys) key: languages[key]!};
  }
}
