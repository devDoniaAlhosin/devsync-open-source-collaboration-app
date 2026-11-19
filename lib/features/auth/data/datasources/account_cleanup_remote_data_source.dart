import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';

/// Splits [items] into batches of at most [size] for Firestore writes.
List<List<T>> chunkForBatch<T>(List<T> items, int size) {
  if (size < 1) {
    throw ArgumentError.value(size, 'size', 'must be >= 1');
  }
  if (items.isEmpty) return const [];
  final chunks = <List<T>>[];
  for (var i = 0; i < items.length; i += size) {
    final end = i + size > items.length ? items.length : i + size;
    chunks.add(items.sublist(i, end));
  }
  return chunks;
}

/// Removes a user's Firestore docs before Auth delete.
///
/// Order: feedback → requests (sent, owned) → projects → views →
/// FCM tokens → `users/{uid}`.
class AccountCleanupRemoteDataSource {
  AccountCleanupRemoteDataSource({FirebaseFirestore? firestore})
    : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  /// Wipe order used by tests.
  static const wipeSteps = <String>[
    'feedback.userId',
    'requests.senderId',
    'requests.ownerId',
    'projects.ownerId',
    'views.viewerId',
    'users.fcmTokens',
    'users.doc',
  ];

  static const _pageSize = 200;
  static const _batchLimit = 400;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirestoreCollections.users);

  /// Deletes user-owned docs for [uid]. Continues if one step fails.
  Future<void> wipeUserData(String uid) async {
    final trimmed = uid.trim();
    if (trimmed.isEmpty) return;

    await _runStep(
      () => _deleteByField(FirestoreCollections.feedback, 'userId', trimmed),
    );
    await _runStep(
      () => _deleteByField(FirestoreCollections.requests, 'senderId', trimmed),
    );
    await _runStep(
      () => _deleteByField(FirestoreCollections.requests, 'ownerId', trimmed),
    );
    await _runStep(
      () => _deleteByField(FirestoreCollections.projects, 'ownerId', trimmed),
    );
    await _runStep(
      () => _deleteByField(FirestoreCollections.views, 'viewerId', trimmed),
    );
    await _runStep(
      () => _deleteSubcollection(trimmed, FirestoreCollections.fcmTokens),
    );
    await _runStep(() => _users.doc(trimmed).delete());
  }

  Future<void> _runStep(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // Keep going so Auth delete can still run.
    }
  }

  Future<void> _deleteByField(
    String collection,
    String field,
    String uid,
  ) async {
    while (true) {
      final snapshot = await _firestore
          .collection(collection)
          .where(field, isEqualTo: uid)
          .limit(_pageSize)
          .get();
      if (snapshot.docs.isEmpty) return;
      await _commitDeletes(
        snapshot.docs.map((doc) => doc.reference).toList(growable: false),
      );
    }
  }

  Future<void> _deleteSubcollection(String uid, String subcollection) async {
    final parent = _users.doc(uid);
    while (true) {
      final snapshot = await parent
          .collection(subcollection)
          .limit(_pageSize)
          .get();
      if (snapshot.docs.isEmpty) return;
      await _commitDeletes(
        snapshot.docs.map((doc) => doc.reference).toList(growable: false),
      );
    }
  }

  Future<void> _commitDeletes(List<DocumentReference> refs) async {
    for (final chunk in chunkForBatch(refs, _batchLimit)) {
      final batch = _firestore.batch();
      for (final ref in chunk) {
        batch.delete(ref);
      }
      await batch.commit();
    }
  }
}
