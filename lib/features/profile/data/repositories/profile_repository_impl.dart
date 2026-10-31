import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({required ProfileLocalDataSource localDataSource})
    : _local = localDataSource;

  final ProfileLocalDataSource _local;

  @override
  Future<Result<Profile>> getProfile() async {
    try {
      return Success(await _local.fetchProfile());
    } catch (_) {
      return const FailureResult(UnexpectedFailure());
    }
  }

  @override
  Future<Result<Profile>> updateProfile({
    required String bio,
    required List<String> skills,
  }) async {
    try {
      final trimmed = bio.trim();
      if (trimmed.isEmpty) {
        return const FailureResult(
          ValidationFailure('Bio cannot be empty', field: 'bio'),
        );
      }
      return Success(
        await _local.saveProfile(bio: trimmed, skills: skills),
      );
    } catch (_) {
      return const FailureResult(UnexpectedFailure());
    }
  }
}
