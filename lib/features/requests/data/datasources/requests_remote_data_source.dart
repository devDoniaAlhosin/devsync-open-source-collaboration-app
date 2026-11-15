import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../domain/entities/collaboration_request.dart';
import '../models/request_model.dart';

class RequestsRemoteDataSource {
  RequestsRemoteDataSource({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection(FirestoreCollections.requests);

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('User is not authenticated.');
    }
    return uid;
  }

  Future<List<RequestItem>> fetchRequests() async {
    final uid = _uid;

    final results = await Future.wait([
      _requests.where('senderId', isEqualTo: uid).get(),
      _requests.where('ownerId', isEqualTo: uid).get(),
    ]);

    final docs = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};

    for (final result in results) {
      for (final doc in result.docs) {
        docs[doc.id] = doc;
      }
    }

    final items = docs.values
        .map((doc) => RequestModel.fromFirestore(doc, currentUserId: uid))
        .toList();

    items.sort((a, b) {
      final aDate = a.createdAt ?? DateTime(2000);
      final bDate = b.createdAt ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });

    return items;
  }

  Future<RequestItem> createRequest({required RequestItem item}) async {
    final uid = _uid;

    if (item.projectId.isEmpty ||
        item.ownerId == null ||
        item.ownerId!.isEmpty) {
      throw ArgumentError('Project ID and owner ID are required.');
    }

    if (item.ownerId == uid) {
      throw ArgumentError('You cannot request to join your own project.');
    }

    final requestId = '${uid}_${item.projectId}';
    if (utf8.encode(requestId).length > 1500) {
      throw ArgumentError('Project ID is too long.');
    }

    final legacyDuplicate = await _requests
        .where('projectId', isEqualTo: item.projectId)
        .where('senderId', isEqualTo: uid)
        .where('status', whereIn: ['pending', 'isNew'])
        .limit(1)
        .get();
    if (legacyDuplicate.docs.isNotEmpty &&
        legacyDuplicate.docs.single.id != requestId) {
      throw StateError('You already have a pending request.');
    }

    final model = RequestModel(
      id: requestId,
      projectId: item.projectId,
      senderId: uid,
      ownerId: item.ownerId,
      initials: item.initials,
      title: item.title,
      subtitle: item.subtitle,
      status: RequestStatus.pending,
      type: RequestType.sent,
      message: item.message,
      displayName: item.displayName,
      targetName: item.targetName,
      matchPercent: item.matchPercent,
      matchSummary: item.matchSummary,
      repositoryCount: item.repositoryCount,
      commitCount: item.commitCount,
      languageCount: item.languageCount,
      skills: item.skills,
    );

    final ref = _requests.doc(requestId);
    await _firestore.runTransaction<void>((transaction) async {
      final existing = await transaction.get(ref);
      if (existing.exists) {
        final status = existing.data()?['status'];
        if (status == 'pending' || status == 'isNew') {
          throw StateError('You already have a pending request.');
        }
        if (status != 'declined') {
          throw StateError('You have already been accepted for this project.');
        }
      }

      transaction.set(ref, model.toFirestore());
    });

    final saved = await ref.get();
    return RequestModel.fromFirestore(saved, currentUserId: uid);
  }

  Future<RequestItem> updateStatus({
    required String requestId,
    required RequestStatus status,
  }) async {
    if (status != RequestStatus.accepted && status != RequestStatus.declined) {
      throw ArgumentError('Invalid request status.');
    }

    final uid = _uid;
    final ref = _requests.doc(requestId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);

      if (!snapshot.exists) {
        throw StateError('Request not found.');
      }

      final data = snapshot.data()!;
      if (data['ownerId'] != uid) {
        throw StateError('You cannot respond to this request.');
      }

      if (data['status'] != 'pending' && data['status'] != 'isNew') {
        throw StateError('Request is no longer pending.');
      }

      transaction.update(ref, {
        'status': status.name,
        'respondedAt': FieldValue.serverTimestamp(),
      });

      return RequestModel.fromFirestore(
        snapshot,
        currentUserId: uid,
      ).copyWith(status: status, respondedAt: DateTime.now());
    });
  }
}
