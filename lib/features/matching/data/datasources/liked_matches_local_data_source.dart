import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/match_item.dart';
import '../models/match_item_model.dart';

/// Storage contract for managing liked matches.
abstract class LikedMatchesLocalDataSource {
  Future<List<MatchItem>> getLikedMatches();
  Future<void> addLikedMatch(MatchItem match);
  Future<void> removeLikedMatch(String projectId);
  Future<void> clearLikedMatches();
}

/// Firestore implementation for persisting liked matches per user.
class FirestoreLikedMatchesDataSource implements LikedMatchesLocalDataSource {
  FirestoreLikedMatchesDataSource({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    Duration operationTimeout = const Duration(seconds: 15),
  }) : _firestore = firestore,
       _auth = auth,
       _operationTimeout = operationTimeout;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Duration _operationTimeout;

  static const String _collectionName = 'liked_matches';
  static const String _subCollectionName = 'matches';

  @override
  Future<List<MatchItem>> getLikedMatches() => _run(
    'Could not load saved matches. Please try again.',
    (collection, _) async {
      final snapshot = await collection
          .orderBy('likedAt', descending: true)
          .get()
          .timeout(_operationTimeout);
      return snapshot.docs.map((doc) {
        final match = MatchItemModel.fromFirestore(doc.data()).toEntity();
        if (match.projectId != doc.id) {
          throw const FormatException('Saved match ID does not match');
        }
        return match;
      }).toList();
    },
  );

  @override
  Future<void> addLikedMatch(MatchItem match) => _run(
    'Could not save this match. Please try again.',
    (collection, _) async {
      _validateProjectId(match.projectId);
      final model = MatchItemModel.fromEntity(match);
      await collection
          .doc(match.projectId)
          .set(model.toFirestore())
          .timeout(_operationTimeout);
    },
  );

  @override
  Future<void> removeLikedMatch(String projectId) => _run(
    'Could not remove this saved match. Please try again.',
    (collection, _) async {
      _validateProjectId(projectId);
      await collection.doc(projectId).delete().timeout(_operationTimeout);
    },
  );

  @override
  Future<void> clearLikedMatches() => _run(
    'Could not clear saved matches. Please try again.',
    (collection, userId) async {
      final snapshot = await collection.get().timeout(_operationTimeout);
      // Firestore allows at most 500 writes per batch.
      for (var offset = 0; offset < snapshot.docs.length; offset += 500) {
        _ensureCurrentUser(userId);
        final batch = _firestore.batch();
        for (final doc in snapshot.docs.skip(offset).take(500)) {
          batch.delete(doc.reference);
        }
        await batch.commit().timeout(_operationTimeout);
      }
    },
  );

  Future<T> _run<T>(
    String failureMessage,
    Future<T> Function(
      CollectionReference<Map<String, dynamic>> collection,
      String userId,
    )
    operation,
  ) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      throw const LikedMatchesException(
        'Sign in to access your saved matches.',
      );
    }

    try {
      final collection = _firestore
          .collection(_collectionName)
          .doc(userId)
          .collection(_subCollectionName);
      final result = await operation(collection, userId);
      _ensureCurrentUser(userId);
      return result;
    } on FirebaseException {
      throw LikedMatchesException(failureMessage);
    } on TimeoutException {
      throw const LikedMatchesException(
        'Saved matches are taking too long. Check your connection and retry.',
      );
    } on FormatException {
      throw const LikedMatchesException(
        'Saved match data could not be read. Please try again.',
      );
    } on LikedMatchesException {
      rethrow;
    } catch (_) {
      throw LikedMatchesException(failureMessage);
    }
  }

  void _ensureCurrentUser(String userId) {
    if (_auth.currentUser?.uid != userId) {
      throw const LikedMatchesException(
        'Your account changed. Please load saved matches again.',
      );
    }
  }

  void _validateProjectId(String projectId) {
    if (projectId.trim().isEmpty || projectId.contains('/')) {
      throw const LikedMatchesException(
        'This match has an invalid project ID.',
      );
    }
  }
}

class LikedMatchesException implements Exception {
  const LikedMatchesException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// In-memory implementation of liked matches for testing.
class InMemoryLikedMatchesDataSource implements LikedMatchesLocalDataSource {
  InMemoryLikedMatchesDataSource();

  static final InMemoryLikedMatchesDataSource instance =
      InMemoryLikedMatchesDataSource();

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
