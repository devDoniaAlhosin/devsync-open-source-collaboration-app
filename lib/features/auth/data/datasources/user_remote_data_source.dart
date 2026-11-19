import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../models/app_user_model.dart';

/// Upserts the signed-in user's profile document in Firestore.
class UserRemoteDataSource {
  UserRemoteDataSource({FirebaseFirestore? firestore})
    : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirestoreCollections.users);

  /// Creates `users/{uid}` on first login, or refreshes profile fields later.
  ///
  /// Pass [githubLogin] after GitHub OAuth so the Connect step can auto-scan.
  /// Omitting it leaves any existing `githubLogin` field untouched.
  Future<void> ensureUserDoc(User user, {String? githubLogin}) async {
    final ref = _users.doc(user.uid);
    final snapshot = await ref.get();
    final model = AppUserModel.fromFirebaseUser(
      user,
      githubLogin: githubLogin,
    );

    if (!snapshot.exists) {
      await ref.set(model.toFirestore(isNew: true));
      return;
    }

    await ref.set(
      model.toFirestore(
        isNew: false,
        includeGithubLogin: githubLogin != null && githubLogin.trim().isNotEmpty,
      ),
      SetOptions(merge: true),
    );
  }

  Future<String?> fetchGithubLogin(String uid) async {
    final snapshot = await _users.doc(uid).get();
    final data = snapshot.data();
    if (data == null) return null;
    final login = data['githubLogin'] as String?;
    final trimmed = login?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  Future<void> deleteUserDoc(String uid) async {
    await _users.doc(uid).delete();
  }
}
