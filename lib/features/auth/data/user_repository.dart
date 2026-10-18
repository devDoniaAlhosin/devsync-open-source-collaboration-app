import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

/// Upserts the signed-in user's profile document in Firestore.
class UserRepository {
  UserRepository({FirebaseFirestore? firestore}) : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  /// Creates `users/{uid}` on first login, or refreshes profile fields later.
  Future<void> ensureUserDoc(User user) async {
    final ref = _users.doc(user.uid);
    final snapshot = await ref.get();
    final providers =
        user.providerData.map((p) => p.providerId).toSet().toList()..sort();

    final appUser = AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      authProviders: providers,
    );

    if (!snapshot.exists) {
      await ref.set(appUser.toFirestore(isNew: true));
      return;
    }

    await ref.set(
      appUser.toFirestore(isNew: false),
      SetOptions(merge: true),
    );
  }
}
