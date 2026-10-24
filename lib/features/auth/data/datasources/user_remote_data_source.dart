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
  Future<void> ensureUserDoc(User user) async {
    final ref = _users.doc(user.uid);
    final snapshot = await ref.get();
    final model = AppUserModel.fromFirebaseUser(user);

    if (!snapshot.exists) {
      await ref.set(model.toFirestore(isNew: true));
      return;
    }

    await ref.set(model.toFirestore(isNew: false), SetOptions(merge: true));
  }
}
