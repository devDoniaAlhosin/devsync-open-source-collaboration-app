import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../domain/entities/match_feedback_action.dart';

class MatchingFeedbackRemoteDataSource {
  MatchingFeedbackRemoteDataSource({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<MatchFeedbackAction?> saveFeedback({
    required String projectId,
    required MatchFeedbackAction action,
    String? promptVersion,
  }) async {
    final uid = _currentUserId;
    final normalizedProjectId = projectId.trim();
    final version = promptVersion?.trim();
    final ref = _feedbackRef(uid, normalizedProjectId);
    return _firestore.runTransaction<MatchFeedbackAction?>((transaction) async {
      final previous = await transaction.get(ref);
      final previousAction = switch (previous.data()?['action']) {
        'like' => MatchFeedbackAction.like,
        'skip' => MatchFeedbackAction.skip,
        _ => null,
      };

      // Full replace so legacy fields (e.g. timestamp) cannot break rules.
      transaction.set(ref, {
        'userId': uid,
        'projectId': normalizedProjectId,
        'action': action.name,
        'updatedAt': FieldValue.serverTimestamp(),
        if (version != null && version.isNotEmpty) 'promptVersion': version,
      });

      return previousAction;
    });
  }

  Future<void> clearFeedback({required String projectId}) async {
    final ref = _feedbackRef(_currentUserId, projectId.trim());
    await _firestore.runTransaction<void>((transaction) async {
      final previous = await transaction.get(ref);
      if (previous.exists) transaction.delete(ref);
    });
  }

  String get _currentUserId {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('User is not authenticated.');
    return uid;
  }

  DocumentReference<Map<String, dynamic>> _feedbackRef(
    String uid,
    String projectId,
  ) {
    if (projectId.isEmpty || projectId.contains('/')) {
      throw ArgumentError('A valid project ID is required.');
    }

    final documentId = '${uid}_$projectId';
    if (utf8.encode(documentId).length > 1500) {
      throw ArgumentError('Project ID is too long.');
    }

    return _firestore.collection(FirestoreCollections.feedbacks).doc(documentId);
  }
}
