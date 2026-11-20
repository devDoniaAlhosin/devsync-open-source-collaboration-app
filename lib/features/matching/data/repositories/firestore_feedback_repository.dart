import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/feedback_record.dart';
import '../../domain/repositories/feedback_repository.dart';

class FirestoreFeedbackRepository implements FeedbackRepository {
  const FirestoreFeedbackRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    Duration timeout = const Duration(seconds: 20),
  }) : _firestore = firestore,
       _auth = auth,
       _timeout = timeout;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Duration _timeout;

  @override
  Future<Result<List<FeedbackRecord>>> getUserFeedback() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return const FailureResult(AuthFailure('Sign in to load feedback.'));
    }

    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.feedback)
          .where('userId', isEqualTo: uid)
          .get()
          .timeout(_timeout);

      final records = <FeedbackRecord>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final projectId = data['projectId'] as String?;
        final userId = data['userId'] as String?;
        final action = data['action'] as String?;
        final promptVersion = data['promptVersion'] as String?;

        if (projectId == null || userId == null || action == null) continue;

        DateTime? timestamp;
        final raw = data['timestamp'] ?? data['createdAt'] ?? data['updatedAt'];
        if (raw is Timestamp) {
          timestamp = raw.toDate();
        }

        records.add(
          FeedbackRecord(
            id: doc.id,
            userId: userId,
            projectId: projectId,
            action: action,
            timestamp: timestamp,
            promptVersion: promptVersion,
          ),
        );
      }

      return Success(records);
    } on FirebaseException catch (e) {
      return FailureResult(
        NetworkFailure('Could not load feedback: ${e.message ?? e.code}'),
      );
    } on TimeoutException {
      return const FailureResult(
        NetworkFailure('Feedback is taking too long. Check your connection.'),
      );
    } catch (e) {
      return FailureResult(
        UnexpectedFailure('Unexpected error loading feedback: $e'),
      );
    }
  }
}
