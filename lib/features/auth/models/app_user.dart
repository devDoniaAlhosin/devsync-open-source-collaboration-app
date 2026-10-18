import 'package:cloud_firestore/cloud_firestore.dart';

/// App-level user profile stored at `users/{uid}`.
class AppUser {
  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.authProviders = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final List<String> authProviders;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, Object?> toFirestore({required bool isNew}) {
    final now = FieldValue.serverTimestamp();
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'authProviders': authProviders,
      'updatedAt': now,
      if (isNew) 'createdAt': now,
    };
  }

  factory AppUser.fromFirestore(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      authProviders: (data['authProviders'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
