import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/matching_profile_repository.dart';

class FirestoreMatchingProfileRepository implements MatchingProfileRepository {
  FirestoreMatchingProfileRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  Future<Result<UserProfile>> getProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      return const FailureResult(
        AuthFailure('Please sign in to find matches.'),
      );
    }

    try {
      final snapshot = await _users.doc(user.uid).get();
      if (_auth.currentUser?.uid != user.uid) {
        return const FailureResult(
          AuthFailure('Your account changed. Please try again.'),
        );
      }
      return Success(_profileFromData(user, snapshot.data() ?? const {}));
    } on FirebaseException {
      return const FailureResult(
        NetworkFailure(
          'Could not load your matching profile. Please try again.',
        ),
      );
    } catch (_) {
      return const FailureResult(
        UnexpectedFailure(
          'Could not load your matching profile. Please try again.',
        ),
      );
    }
  }

  @override
  Future<Result<UserProfile>> updateDeclaredSkills(List<String> skills) async {
    final user = _auth.currentUser;
    if (user == null) {
      return const FailureResult(AuthFailure('Please sign in to save skills.'));
    }

    final normalized = _normalizeSkills(skills);
    if (normalized == null) {
      return const FailureResult(
        ValidationFailure(
          'Add at most 100 skills, with each skill no longer than 100 characters.',
          field: 'skills',
        ),
      );
    }

    try {
      // Write nested profile.skills as canonical; keep top-level mirrors in sync.
      await _users.doc(user.uid).set({
        'profile': {'skills': normalized},
        'skills': normalized,
        'declaredSkills': normalized,
        'matchingProfileUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (_auth.currentUser?.uid != user.uid) {
        return const FailureResult(
          AuthFailure('Your account changed. Please try again.'),
        );
      }
      return await getProfile();
    } on FirebaseException {
      return const FailureResult(
        NetworkFailure('Could not save your skills. Please try again.'),
      );
    } catch (_) {
      return const FailureResult(
        UnexpectedFailure('Could not save your skills. Please try again.'),
      );
    }
  }

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirestoreCollections.users);

  UserProfile _profileFromData(User user, Map<String, dynamic> data) {
    final profileMap = data['profile'] is Map
        ? Map<String, dynamic>.from(data['profile'] as Map)
        : const <String, dynamic>{};

    // Canonical: profile.skills. Fall back to legacy top-level mirrors.
    final skillsFromProfileMap = _readStringList(
      profileMap['skills'],
      maxItems: 100,
      maxLength: 100,
    );
    final skillsFromUsersDoc = _readStringList(
      data['skills'],
      maxItems: 100,
      maxLength: 100,
    );
    final declaredSkillsList = _readStringList(
      data['declaredSkills'],
      maxItems: 100,
      maxLength: 100,
    );

    final mergedSkills = skillsFromProfileMap.isNotEmpty
        ? skillsFromProfileMap
        : <String>{
            ...skillsFromUsersDoc,
            ...declaredSkillsList,
          }.toList();

    var languages = _readLanguages(data['githubLanguages']);
    if (languages.isEmpty && profileMap['languages'] is List) {
      final langs = <String, int>{};
      for (final item in profileMap['languages'] as List) {
        if (item is Map && item['name'] is String && item['percent'] is num) {
          final name = (item['name'] as String).trim();
          final percent = (item['percent'] as num).floor();
          if (name.isNotEmpty && percent >= 0) {
            langs[name] = percent;
          }
        }
      }
      if (langs.isNotEmpty) {
        languages = Map.unmodifiable(langs);
      }
    }

    return UserProfile(
      uid: user.uid,
      declaredSkills: mergedSkills,
      githubLanguages: languages,
      publicRepoCount: _readNonNegativeInt(
        data['publicRepoCount'] ?? profileMap['repos'],
      ),
      totalContributions: _readNonNegativeInt(
        data['totalContributions'] ?? profileMap['commits'],
      ),
      bio: _readOptionalString(
        data['bio'] ?? profileMap['bio'],
        maxLength: 5000,
      ),
      topRepositories: _readStringList(
        data['topRepositories'],
        maxItems: 50,
        maxLength: 200,
      ),
      displayName:
          _readOptionalString(
            data['displayName'] ?? profileMap['name'],
            maxLength: 200,
          ) ??
          user.displayName,
      githubUrl: _readOptionalString(
        data['githubUrl'] ?? profileMap['githubUrl'],
        maxLength: 500,
      ),
    );
  }

  static List<String>? _normalizeSkills(List<String> skills) {
    final normalized = <String>[];
    final seen = <String>{};
    for (final skill in skills) {
      final value = skill.trim();
      if (value.isEmpty) continue;
      if (value.length > 100) return null;
      if (seen.add(value.toLowerCase())) normalized.add(value);
    }
    return normalized.length <= 100 ? List.unmodifiable(normalized) : null;
  }

  static List<String> _readStringList(
    Object? raw, {
    required int maxItems,
    required int maxLength,
  }) {
    if (raw is! List) return const [];
    final values = <String>[];
    final seen = <String>{};
    for (final value in raw) {
      if (value is! String) continue;
      final trimmed = value.trim();
      if (trimmed.isEmpty || trimmed.length > maxLength) continue;
      if (seen.add(trimmed.toLowerCase())) values.add(trimmed);
      if (values.length == maxItems) break;
    }
    return List.unmodifiable(values);
  }

  static Map<String, int> _readLanguages(Object? raw) {
    if (raw is! Map) return const {};
    final languages = <String, int>{};
    for (final entry in raw.entries) {
      if (entry.key is! String || entry.value is! num) continue;
      final name = (entry.key as String).trim();
      final amount = entry.value as num;
      if (name.isEmpty || name.length > 100 || !amount.isFinite || amount < 0) {
        continue;
      }
      languages[name] = amount.floor();
      if (languages.length == 100) break;
    }
    return Map.unmodifiable(languages);
  }

  static int _readNonNegativeInt(Object? value) {
    if (value is! num || !value.isFinite || value < 0) return 0;
    return value.floor();
  }

  static String? _readOptionalString(Object? value, {required int maxLength}) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty || trimmed.length > maxLength ? null : trimmed;
  }
}
