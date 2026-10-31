import '../../domain/entities/profile.dart';

/// Local / dummy profile source until Firestore is wired.
class ProfileLocalDataSource {
  Profile _profile = Profile.sample();

  Future<Profile> fetchProfile() async => _profile;

  Future<Profile> saveProfile({
    required String bio,
    required List<String> skills,
  }) async {
    _profile = _profile.copyWith(bio: bio, skills: skills);
    return _profile;
  }
}
