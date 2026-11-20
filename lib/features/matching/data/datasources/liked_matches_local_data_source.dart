import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../domain/entities/match_item.dart';
import '../../../projects/data/models/project_model.dart';
import '../models/match_record_model.dart';

/// Storage contract for managing liked matches.
abstract class LikedMatchesLocalDataSource {
  Future<List<MatchItem>> getLikedMatches();
  Future<void> addLikedMatch(MatchItem match, {String? promptVersion});
  Future<void> removeLikedMatch(String projectId);
  Future<void> clearLikedMatches();
}

/// Firestore implementation for persisting liked matches per user in the `match` collection.
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

  CollectionReference<Map<String, dynamic>> get _match =>
      _firestore.collection(FirestoreCollections.match);

  CollectionReference<Map<String, dynamic>> get _matchesLegacy =>
      _firestore.collection(FirestoreCollections.matches);

  CollectionReference<Map<String, dynamic>> get _projects =>
      _firestore.collection(FirestoreCollections.projects);

  @override
  Future<List<MatchItem>> getLikedMatches() => _run(
    'Could not load saved matches. Please try again.',
    (collection, userId) async {
      var snapshot = await collection
          .where('userId', isEqualTo: userId)
          .get()
          .timeout(_operationTimeout);

      if (snapshot.docs.isEmpty && collection.path != _matchesLegacy.path) {
        try {
          final legacySnapshot = await _matchesLegacy
              .where('userId', isEqualTo: userId)
              .get()
              .timeout(_operationTimeout);
          if (legacySnapshot.docs.isNotEmpty) {
            snapshot = legacySnapshot;
          }
        } catch (_) {}
      }

      final records =
          snapshot.docs
              .map(MatchRecordModel.fromFirestore)
              .toList(growable: false)
            ..sort((a, b) {
              final aDate = a.createdAt;
              final bDate = b.createdAt;
              if (aDate == null && bDate == null) return 0;
              if (aDate == null) return 1;
              if (bDate == null) return -1;
              return bDate.compareTo(aDate);
            });

      return Future.wait(records.map(_toMatchItem));
    },
  );

  @override
  Future<void> addLikedMatch(MatchItem match, {String? promptVersion}) => _run(
    'Could not save this match. Please try again.',
    (collection, userId) async {
      _validateProjectId(match.projectId);
      final docId = _matchDocumentId(userId, match.projectId);
      final model = MatchRecordModel(
        matchId: docId,
        userId: userId,
        projectId: match.projectId,
        score: match.score,
        reason: match.reason,
        promptVersion: promptVersion ?? '',
        projectName: match.projectName,
        description: match.description,
        githubUrl: match.githubUrl,
        neededSkills: match.neededSkills,
      );

      await collection
          .doc(docId)
          .set(model.toFirestore())
          .timeout(_operationTimeout);

      if (collection.path != _matchesLegacy.path) {
        try {
          await _matchesLegacy
              .doc(docId)
              .set(model.toFirestore())
              .timeout(_operationTimeout);
        } catch (_) {}
      }
    },
  );

  @override
  Future<void> removeLikedMatch(String projectId) => _run(
    'Could not remove this saved match. Please try again.',
    (collection, userId) async {
      _validateProjectId(projectId);
      final docId = _matchDocumentId(userId, projectId);
      await collection.doc(docId).delete().timeout(_operationTimeout);

      if (collection.path != _matchesLegacy.path) {
        try {
          await _matchesLegacy.doc(docId).delete().timeout(_operationTimeout);
        } catch (_) {}
      }
    },
  );

  @override
  Future<void> clearLikedMatches() => _run(
    'Could not clear saved matches. Please try again.',
    (collection, userId) async {
      final snapshot = await collection
          .where('userId', isEqualTo: userId)
          .get()
          .timeout(_operationTimeout);

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
      final result = await operation(_match, userId);
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

  String _matchDocumentId(String userId, String projectId) =>
      '${userId}_$projectId';

  Future<MatchItem> _toMatchItem(MatchRecordModel record) async {
    try {
      final snapshot = await _projects
          .doc(record.projectId)
          .get()
          .timeout(_operationTimeout);
      if (snapshot.exists) {
        final project = ProjectModel.fromFirestore(
          snapshot,
          currentUserId: record.userId,
        );
        return MatchItem(
          projectId: record.projectId,
          projectName: project.title.isEmpty
              ? (record.projectName.isEmpty
                    ? record.projectId
                    : record.projectName)
              : project.title,
          description: project.description.isNotEmpty
              ? project.description
              : record.description,
          githubUrl: project.githubUrl.isNotEmpty
              ? project.githubUrl
              : record.githubUrl,
          neededSkills: project.techStack.isNotEmpty
              ? project.techStack
              : record.neededSkills,
          score: record.score,
          reason: record.reason,
          maintainerId: project.ownerId.isEmpty ? null : project.ownerId,
        );
      }
    } catch (_) {}

    return MatchItem(
      projectId: record.projectId,
      projectName: record.projectName.isNotEmpty
          ? record.projectName
          : record.projectId,
      description: record.description.isNotEmpty
          ? record.description
          : 'Open source project',
      githubUrl: record.githubUrl,
      neededSkills: record.neededSkills,
      score: record.score,
      reason: record.reason,
    );
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
  Future<void> addLikedMatch(MatchItem match, {String? promptVersion}) async {
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
