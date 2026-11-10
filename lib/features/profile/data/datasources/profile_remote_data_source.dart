import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../domain/entities/profile.dart';
import '../models/profile_model.dart';

/// Thrown when a profile call happens with no signed-in user.
class NotSignedInException implements Exception {
  const NotSignedInException();
}

/// Reads / writes the profile fields inside `users/{uid}`.
/// Uses merge so auth fields (email, authProviders...) are never overwritten.
class ProfileRemoteDataSource {
  ProfileRemoteDataSource({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.collection(FirestoreCollections.users).doc(uid);

  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) throw const NotSignedInException();
    return user;
  }

  Future<Profile> fetch() async {
    final user = _requireUser();
    final snap = await _doc(user.uid).get();
    final fallbackName = (user.displayName ?? '').trim().isNotEmpty
        ? user.displayName!.trim()
        : (user.email?.split('@').first ?? 'Developer');

    final data = snap.data();
    if (data == null) return Profile.empty(name: fallbackName);

    // The profile fields live under the `profile` key to avoid clashing
    // with the auth fields stored in the same document.
    final profileMap = data['profile'];
    if (profileMap is! Map) return Profile.empty(name: fallbackName);

    return ProfileModel.fromMap(
      Map<String, dynamic>.from(profileMap),
      fallbackName: fallbackName,
    );
  }

  Future<Profile> save(Profile profile) async {
    final user = _requireUser();
    await _doc(user.uid).set({
      'profile': ProfileModel.toMap(profile),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return profile;
  }
}
