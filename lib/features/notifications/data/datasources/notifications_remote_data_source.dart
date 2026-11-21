import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../domain/entities/app_notification.dart';

class NotificationsRemoteDataSource {
  NotificationsRemoteDataSource({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('User is not authenticated.');
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _inbox => _firestore
      .collection(FirestoreCollections.users)
      .doc(_uid)
      .collection(FirestoreCollections.notifications);

  Future<List<AppNotification>> fetchNotifications() async {
    final snapshot = await _inbox
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();

    return snapshot.docs.map(_fromDoc).toList(growable: false);
  }

  Future<void> markRead(String notificationId) async {
    final id = notificationId.trim();
    if (id.isEmpty) return;
    await _inbox.doc(id).update({'read': true});
  }

  /// Emits whether the signed-in user has at least one unread inbox doc.
  Stream<bool> watchHasUnread() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value(false);
      return _firestore
          .collection(FirestoreCollections.users)
          .doc(user.uid)
          .collection(FirestoreCollections.notifications)
          .where('read', isEqualTo: false)
          .limit(1)
          .snapshots()
          .map((snapshot) => snapshot.docs.isNotEmpty);
    });
  }

  AppNotification _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final created = data['createdAt'];
    DateTime createdAt;
    if (created is Timestamp) {
      createdAt = created.toDate();
    } else if (created is DateTime) {
      createdAt = created;
    } else {
      createdAt = DateTime.now();
    }

    return AppNotification(
      id: doc.id,
      title: (data['title'] as String?)?.trim() ?? 'Notification',
      body: (data['body'] as String?)?.trim() ?? '',
      type: (data['type'] as String?)?.trim() ?? '',
      read: data['read'] == true,
      createdAt: createdAt,
      requestId: (data['requestId'] as String?)?.trim() ?? '',
      projectId: (data['projectId'] as String?)?.trim() ?? '',
    );
  }
}
