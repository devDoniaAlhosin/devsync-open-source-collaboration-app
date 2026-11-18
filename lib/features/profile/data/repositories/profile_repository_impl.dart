import 'package:firebase_core/firebase_core.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../matching/domain/entities/github_scan_result.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/github_profile_remote_data_source.dart';
import '../datasources/profile_remote_data_source.dart';
import '../exceptions/github_profile_exceptions.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileRemoteDataSource remoteDataSource,
    required GithubProfileRemoteDataSource githubRemoteDataSource,
  }) : _remote = remoteDataSource,
       _github = githubRemoteDataSource;

  final ProfileRemoteDataSource _remote;
  final GithubProfileRemoteDataSource _github;

  static final _usernameRule = RegExp(
    r'^[a-zA-Z0-9](?:[a-zA-Z0-9]|-(?=[a-zA-Z0-9])){0,38}$',
  );

  static const int _bioLimit = 140;
  static const int _maxSkills = 30;
  static const int _maxSkillLength = 24;

  @override
  Future<Result<Profile>> getProfile() async {
    try {
      return Success(await _remote.fetch());
    } catch (e) {
      return FailureResult(_mapError(e));
    }
  }

  @override
  Future<Result<Profile>> updateProfile({
    required String bio,
    required List<String> skills,
  }) async {
    final trimmedBio = bio.trim();
    if (trimmedBio.isEmpty) {
      return const FailureResult(
        ValidationFailure('Bio cannot be empty', field: 'bio'),
      );
    }
    if (trimmedBio.length > _bioLimit) {
      return const FailureResult(
        ValidationFailure('Bio is limited to 140 characters', field: 'bio'),
      );
    }

    final cleanSkills = _cleanSkills(skills);
    if (cleanSkills.length > _maxSkills) {
      return const FailureResult(
        ValidationFailure('Too many skills (max 30)', field: 'skills'),
      );
    }
    if (cleanSkills.any((s) => s.length > _maxSkillLength)) {
      return const FailureResult(
        ValidationFailure(
          'A skill is limited to 24 characters',
          field: 'skills',
        ),
      );
    }

    try {
      final current = await _remote.fetch();
      return Success(
        await _remote.save(
          current.copyWith(bio: trimmedBio, skills: cleanSkills),
        ),
      );
    } catch (e) {
      return FailureResult(_mapError(e));
    }
  }

  @override
  Future<Result<GithubScanResult>> scanGithub(String username) async {
    final trimmed = username.trim();
    if (trimmed.isEmpty || !_usernameRule.hasMatch(trimmed)) {
      return const FailureResult(
        ValidationFailure('Enter a valid GitHub username', field: 'github'),
      );
    }

    try {
      return Success(await _github.scan(trimmed));
    } catch (e) {
      return FailureResult(_mapError(e));
    }
  }

  @override
  Future<Result<Profile>> saveGithubScan({
    required String githubUsername,
    required int repos,
    required int commits,
    required List<LanguageShare> languages,
  }) async {
    final username = githubUsername.trim();
    if (username.isEmpty) {
      return const FailureResult(
        ValidationFailure('GitHub username is required', field: 'github'),
      );
    }

    try {
      final current = await _remote.fetch();
      final suggested = [
        for (final l in languages)
          if (!current.skills.contains(l.name)) l.name,
      ];
      return Success(
        await _remote.save(
          current.copyWith(
            githubUrl: 'github.com/$username',
            repos: repos,
            commits: commits,
            languageCount: languages.length,
            languages: languages,
            suggestedSkills: suggested,
          ),
        ),
      );
    } catch (e) {
      return FailureResult(_mapError(e));
    }
  }

  List<String> _cleanSkills(List<String> skills) {
    final seen = <String>{};
    return [
      for (final s in skills)
        if (s.trim().isNotEmpty && seen.add(s.trim().toLowerCase())) s.trim(),
    ];
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
      return const UnexpectedFailure();
    }
    if (e is FirebaseException) {
      switch (e.code) {
        case 'permission-denied':
          return const PermissionFailure();
        case 'unavailable':
        case 'deadline-exceeded':
        case 'network-request-failed':
          return const NetworkFailure();
        case 'not-found':
          return const NotFoundFailure('Profile not found');
      }
    }
    return const UnexpectedFailure();
  }
}
