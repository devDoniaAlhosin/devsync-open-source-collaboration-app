import 'package:devsync_open_source_collaboration_app/features/matching/data/utils/profile_hash.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/domain/entities/profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileHashGenerator', () {
    test('generates consistent hash for same profile', () {
      final profile = Profile(
        name: 'Test User',
        githubUrl: 'https://github.com/testuser',
        completion: 80,
        bio: 'Test bio',
        repos: 10,
        commits: 100,
        languageCount: 3,
        activity: [],
        languages: [],
        skills: const ['Flutter', 'Dart'],
        topRepositories: const ['https://github.com/test/repo1'],
      );

      final hash1 = ProfileHashGenerator.fromProfile(profile);
      final hash2 = ProfileHashGenerator.fromProfile(profile);

      expect(hash1, equals(hash2));
      expect(hash1, isNotEmpty);
      expect(hash1.length, equals(64)); // SHA-256 produces 64-char hex string
    });

    test('generates different hash when skills change', () {
      final profile1 = Profile(
        name: 'Test User',
        githubUrl: 'https://github.com/testuser',
        completion: 80,
        bio: 'Test bio',
        repos: 10,
        commits: 100,
        languageCount: 3,
        activity: [],
        languages: [],
        skills: const ['Flutter', 'Dart'],
        topRepositories: const [],
      );

      final profile2 = profile1.copyWith(
        skills: const ['Flutter', 'Dart', 'Firebase'],
      );

      final hash1 = ProfileHashGenerator.fromProfile(profile1);
      final hash2 = ProfileHashGenerator.fromProfile(profile2);

      expect(hash1, isNot(equals(hash2)));
    });

    test('generates different hash when repos count changes', () {
      final profile1 = Profile(
        name: 'Test User',
        githubUrl: 'https://github.com/testuser',
        completion: 80,
        bio: 'Test bio',
        repos: 10,
        commits: 100,
        languageCount: 3,
        activity: [],
        languages: [],
        skills: const ['Flutter', 'Dart'],
        topRepositories: const [],
      );

      final profile2 = Profile(
        name: profile1.name,
        githubUrl: profile1.githubUrl,
        completion: profile1.completion,
        bio: profile1.bio,
        repos: 15, // Changed
        commits: profile1.commits,
        languageCount: profile1.languageCount,
        activity: profile1.activity,
        languages: profile1.languages,
        skills: profile1.skills,
        topRepositories: profile1.topRepositories,
      );

      final hash1 = ProfileHashGenerator.fromProfile(profile1);
      final hash2 = ProfileHashGenerator.fromProfile(profile2);

      expect(hash1, isNot(equals(hash2)));
    });

    test('generates different hash when top repositories change', () {
      final profile1 = Profile(
        name: 'Test User',
        githubUrl: 'https://github.com/testuser',
        completion: 80,
        bio: 'Test bio',
        repos: 10,
        commits: 100,
        languageCount: 3,
        activity: [],
        languages: [],
        skills: const ['Flutter', 'Dart'],
        topRepositories: const ['https://github.com/test/repo1'],
      );

      final profile2 = profile1.copyWith(
        topRepositories: const [
          'https://github.com/test/repo1',
          'https://github.com/test/repo2',
        ],
      );

      final hash1 = ProfileHashGenerator.fromProfile(profile1);
      final hash2 = ProfileHashGenerator.fromProfile(profile2);

      expect(hash1, isNot(equals(hash2)));
    });

    test('generates same hash regardless of skills order', () {
      final profile1 = Profile(
        name: 'Test User',
        githubUrl: 'https://github.com/testuser',
        completion: 80,
        bio: 'Test bio',
        repos: 10,
        commits: 100,
        languageCount: 3,
        activity: [],
        languages: [],
        skills: const ['Flutter', 'Dart', 'Firebase'],
        topRepositories: const [],
      );

      final profile2 = profile1.copyWith(
        skills: const ['Dart', 'Firebase', 'Flutter'], // Different order
      );

      final hash1 = ProfileHashGenerator.fromProfile(profile1);
      final hash2 = ProfileHashGenerator.fromProfile(profile2);

      // Should be equal because skills are sorted before hashing
      expect(hash1, equals(hash2));
    });

    test('generates same hash when non-relevant fields change', () {
      final profile1 = Profile(
        name: 'Test User',
        githubUrl: 'https://github.com/testuser',
        completion: 80,
        bio: 'Test bio',
        repos: 10,
        commits: 100,
        languageCount: 3,
        activity: [],
        languages: [],
        skills: const ['Flutter', 'Dart'],
        topRepositories: const [],
      );

      final profile2 = profile1.copyWith(
        bio: 'Different bio', // Bio doesn't affect matching
      );

      final hash1 = ProfileHashGenerator.fromProfile(profile1);
      final hash2 = ProfileHashGenerator.fromProfile(profile2);

      // Should be equal because bio is not included in hash
      expect(hash1, equals(hash2));
    });

    test('handles empty skills list', () {
      final profile = Profile(
        name: 'Test User',
        githubUrl: 'https://github.com/testuser',
        completion: 80,
        bio: 'Test bio',
        repos: 10,
        commits: 100,
        languageCount: 3,
        activity: [],
        languages: [],
        skills: const [],
        topRepositories: const [],
      );

      final hash = ProfileHashGenerator.fromProfile(profile);

      expect(hash, isNotEmpty);
      expect(hash.length, equals(64));
    });

    test('handles empty top repositories list', () {
      final profile = Profile(
        name: 'Test User',
        githubUrl: 'https://github.com/testuser',
        completion: 80,
        bio: 'Test bio',
        repos: 10,
        commits: 100,
        languageCount: 3,
        activity: [],
        languages: [],
        skills: const ['Flutter'],
        topRepositories: const [],
      );

      final hash = ProfileHashGenerator.fromProfile(profile);

      expect(hash, isNotEmpty);
      expect(hash.length, equals(64));
    });
  });
}
