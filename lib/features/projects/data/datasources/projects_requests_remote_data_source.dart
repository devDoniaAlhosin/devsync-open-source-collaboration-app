import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firestore_collections.dart';

class ProjectsRequestsRemoteDataSource {
  ProjectsRequestsRemoteDataSource({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<Map<String, int>> fetchPendingCountsByProject() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('User is not authenticated.');

    final snapshot = await _firestore
        .collection(FirestoreCollections.requests)
        .where('ownerId', isEqualTo: uid)
        .get();
    return countPendingRequestsByProject(
      snapshot.docs.map((document) => document.data()),
    );
  }

  static Map<String, int> countPendingRequestsByProject(
    Iterable<Map<String, dynamic>> requests,
  ) {
    final sendersByProject = <String, Set<String>>{};

    for (final data in requests) {
      final status = data['status'];
      final projectId = data['projectId'];
      final senderId = data['senderId'];
      if ((status == 'pending' || status == 'isNew') &&
          projectId is String &&
          projectId.isNotEmpty &&
          senderId is String &&
          senderId.isNotEmpty) {
        sendersByProject.putIfAbsent(projectId, () => <String>{}).add(senderId);
      }
    }

    final counts = <String, int>{};
    for (final entry in sendersByProject.entries) {
      counts[entry.key] = entry.value.length;
    }
    return counts;
  }
}
