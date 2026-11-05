import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/match_item.dart';
import '../models/match_item_model.dart';

/// Local data source for managing liked/hearted matches.
///
/// Provides abstraction over storage mechanism (in-memory or Firestore).
abstract class LikedMatchesLocalDataSource {
  /// Get all liked matches.
  ///
  /// Returns empty list if user not authenticated or no likes saved.
  Future<List<MatchItem>> getLikedMatches();

  /// Add a match to liked list if not already present.
  Future<void> addLikedMatch(MatchItem match);

  /// Remove a match from liked list.
  Future<void> removeLikedMatch(String projectId);

  /// Clear all liked matches.
  Future<void> clearLikedMatches();
}

/// Firestore implementation of liked matches storage.
///
/// Stores liked matches in Firestore under collection:
/// `liked_matches/{userId}/matches/{projectId}`
///
/// Provides:
/// - Persistence across app restarts
/// - Sync across multiple devices
/// - Offline-first behavior (Firestore cache)
class FirestoreLikedMatchesDataSource implements LikedMatchesLocalDataSource {
  FirestoreLikedMatchesDataSource({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const String _collectionName = 'liked_matches';
  static const String _subCollectionName = 'matches';

  /// Get reference to user's liked matches collection.
  CollectionReference<Map<String, dynamic>>? _getUserMatchesCollection() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    return _firestore
        .collection(_collectionName)
        .doc(userId)
        .collection(_subCollectionName);
  }

  @override
  Future<List<MatchItem>> getLikedMatches() async {
    final collection = _getUserMatchesCollection();
    if (collection == null) return [];

    try {
      final snapshot = await collection
          .orderBy('likedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MatchItemModel.fromFirestore(doc.data()).toEntity())
          .toList();
    } catch (e) {
      // Handle errors gracefully - return empty list
      // In production, consider logging this error
      return [];
    }
  }

  @override
  Future<void> addLikedMatch(MatchItem match) async {
    final collection = _getUserMatchesCollection();
    if (collection == null) return;

    try {
      final model = MatchItemModel.fromEntity(match);
      await collection.doc(match.projectId).set(model.toFirestore());
    } catch (e) {
      // Handle errors gracefully
      // In production, consider logging this error
    }
  }

  @override
  Future<void> removeLikedMatch(String projectId) async {
    final collection = _getUserMatchesCollection();
    if (collection == null) return;

    try {
      await collection.doc(projectId).delete();
    } catch (e) {
      // Handle errors gracefully
    }
  }

  @override
  Future<void> clearLikedMatches() async {
    final collection = _getUserMatchesCollection();
    if (collection == null) return;

    try {
      // Firestore doesn't have a "delete collection" API client-side
      // Fetch all docs and delete them
      final snapshot = await collection.get();
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      // Handle errors gracefully
    }
  }
}

/// In-memory implementation of liked matches storage (for testing).
class InMemoryLikedMatchesDataSource implements LikedMatchesLocalDataSource {
  InMemoryLikedMatchesDataSource._();

  static final InMemoryLikedMatchesDataSource instance =
      InMemoryLikedMatchesDataSource._();

  final List<MatchItem> _items = [];

  @override
  Future<List<MatchItem>> getLikedMatches() async => List.unmodifiable(_items);

  @override
  Future<void> addLikedMatch(MatchItem match) async {
    if (_items.any((m) => m.projectId == match.projectId)) return;
    _items.insert(0, match);
  }

  @override
  Future<void> removeLikedMatch(String projectId) async {
    _items.removeWhere((m) => m.projectId == projectId);
  }

  @override
  Future<void> clearLikedMatches() async {
    _items.clear();
  }
}
