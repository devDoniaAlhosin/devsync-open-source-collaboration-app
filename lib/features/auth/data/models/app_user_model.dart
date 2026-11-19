import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.uid,
    super.email,
    super.displayName,
    super.photoUrl,
    super.authProviders,
    super.githubLogin,
    super.needsEmailVerification,
    this.createdAt,
    this.updatedAt,
  });

  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory AppUserModel.fromFirebaseUser(
    User user, {
    String? githubLogin,
  }) {
    final passwordProvider = user.providerData.any(
      (p) => p.providerId == 'password',
    );
    return AppUserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      authProviders: user.providerData.map((p) => p.providerId).toSet().toList()
        ..sort(),
      githubLogin: githubLogin?.trim().isNotEmpty == true
          ? githubLogin!.trim()
          : null,
      needsEmailVerification: passwordProvider && !user.emailVerified,
    );
  }

  factory AppUserModel.fromFirestore(String uid, Map<String, dynamic> data) {
    final login = data['githubLogin'] as String?;
    return AppUserModel(
      uid: uid,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      authProviders:
          (data['authProviders'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      githubLogin: login?.trim().isNotEmpty == true ? login!.trim() : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, Object?> toFirestore({
    required bool isNew,
    bool includeGithubLogin = true,
  }) {
    final now = FieldValue.serverTimestamp();
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'authProviders': authProviders,
      'updatedAt': now,
      if (isNew) 'createdAt': now,
      if (includeGithubLogin &&
          githubLogin != null &&
          githubLogin!.trim().isNotEmpty)
        'githubLogin': githubLogin!.trim(),
    };
  }
}
