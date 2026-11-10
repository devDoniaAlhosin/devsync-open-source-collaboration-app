import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../domain/entities/collaboration_request_receipt.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_stats.dart';
import '../datasources/devsync_api_data_source.dart';
import '../datasources/github_remote_data_source.dart';
import '../exceptions/projects_exceptions.dart';
import '../models/project_model.dart';

/// Firestore-facing source for projects, views and collaboration requests.
///
/// Collection layout:
/// * `projects/{projectId}` — project document. AI fields (`matchPercentage`,
///   `matchSummary`, `alignments`, `matchedSkills`) and the cached `github` map
///   are written by the DevSync API, never by the client.
/// * `views/{projectId}_{uid}_{yyyy-MM-dd}` — one deterministic document per
///   viewer per day, so refreshing details does not inflate view counts.
/// * `requests/{requestId}` — collaboration requests shared with the requests
///   feature inbox (`requesterId`, `ownerId`, `status`, `matchPercentage`).
class ProjectsRemoteDataSource {
  ProjectsRemoteDataSource({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    GithubRemoteDataSource? github,
    DevSyncApiDataSource? devsyncApi,
  }) : _firestore = firestore,
       _auth = auth,
       _github = github ?? GithubRemoteDataSource(),
       _devsyncApi = devsyncApi ?? DevSyncApiDataSource();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GithubRemoteDataSource _github;
  final DevSyncApiDataSource _devsyncApi;

  String? get _currentUserId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _projects =>
      _firestore.collection(FirestoreCollections.projects);

  CollectionReference<Map<String, dynamic>> get _views =>
      _firestore.collection(FirestoreCollections.views);

  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection(FirestoreCollections.requests);

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirestoreCollections.users);

  Future<List<Project>> fetchProjects() async {
    final snapshot = await _projects.get();
    final uid = _currentUserId;
    final pendingIds = uid == null
        ? const <String>{}
        : await _pendingProjectIds(uid);

    final projects = snapshot.docs
        .map(
          (doc) => ProjectModel.fromFirestore(
            doc,
            currentUserId: uid,
            pendingRequestProjectIds: pendingIds,
          ),
        )
        .toList(growable: false);

    return List<Project>.of(projects)..sort(_newestFirst);
  }

  Future<ProjectStats> fetchStats(String projectId) async {
    final snapshot = await _projects.doc(projectId).get();
    if (!snapshot.exists) throw const ProjectNotFoundException();

    final project = ProjectModel.fromFirestore(
      snapshot,
      currentUserId: _currentUserId,
    );
    final owner = await _ownerFor(project);
    final github = await _resolveGithub(project);
    final weeklyViews = await _weeklyViews(projectId);

    return project.toStats(
      ownerName: owner.name,
      ownerResponseTime: owner.responseTime,
      weeklyViews: weeklyViews,
      liveGithub: github,
    );
  }

  Future<Project> upsert(Project project) async {
    final uid = _currentUserId;
    if (uid == null) throw const AuthRequiredException();

    final isNew = _isNewProject(project);
    final ref = isNew ? _projects.doc() : _projects.doc(project.id);

    if (!isNew) {
      final snapshot = await ref.get();
      if (!snapshot.exists) throw const ProjectNotFoundException();
      final ownerId = _string(
        snapshot.data()?['ownerId'] ?? snapshot.data()?['ownerUid'],
      );
      if (ownerId.isNotEmpty && ownerId != uid) {
        throw const ProjectForbiddenException();
      }
    }

    final displayName = _auth.currentUser?.displayName?.trim() ?? '';
    final model = ProjectModel(
      id: ref.id,
      title: project.title.trim(),
      description: project.description.trim(),
      githubUrl: project.githubUrl.trim(),
      techStack: project.techStack,
      requiredContributors: project.requiredContributors,
      viewsCount: project.viewsCount,
      requestsCount: project.requestsCount,
      matchPercentage: project.matchPercentage,
      isOwner: true,
      ownerId: uid,
      ownerName: project.ownerName.trim().isNotEmpty
          ? project.ownerName.trim()
          : displayName,
      createdAt: project.createdAt ?? (isNew ? DateTime.now() : null),
      hasPendingRequest: project.hasPendingRequest,
    );

    await ref.set(
      model.toFirestore(ownerId: uid, isNew: isNew),
      SetOptions(merge: true),
    );
    return model;
  }

  Future<CollaborationRequestReceipt> requestToCollaborate({
    required Project project,
    String? message,
  }) async {
    final uid = _currentUserId;
    if (uid == null) throw const AuthRequiredException();

    final projectRef = _projects.doc(project.id);
    final snapshot = await projectRef.get();
    if (!snapshot.exists) throw const ProjectNotFoundException();

    final data = snapshot.data() ?? const <String, dynamic>{};
    final ownerId = _string(data['ownerId'] ?? data['ownerUid']);
    if (ownerId.isEmpty) {
      throw const ProjectValidationException('This project has no owner yet');
    }
    if (ownerId == uid) {
      throw const ProjectValidationException('You already own this project');
    }

    final existing = await _requests
        .where('projectId', isEqualTo: project.id)
        .where('requesterId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return CollaborationRequestReceipt(
        requestId: existing.docs.first.id,
        projectId: project.id,
        created: false,
      );
    }

    final user = _auth.currentUser;
    final requesterName = _string(user?.displayName).isEmpty
        ? 'Contributor'
        : _string(user?.displayName);
    final projectTitle = _string(data['title']).isEmpty
        ? project.title
        : _string(data['title']);
    final requestRef = _requests.doc();

    final batch = _firestore.batch();
    batch.set(requestRef, {
      'projectId': project.id,
      'projectTitle': projectTitle,
      'ownerId': ownerId,
      if (_string(data['ownerName']).isNotEmpty)
        'ownerName': _string(data['ownerName']),
      'requesterId': uid,
      'requesterName': requesterName,
      if (_string(user?.email).isNotEmpty) 'requesterEmail': user?.email,
      'message': _truncate(message?.trim() ?? '', 1000),
      'matchPercentage': project.matchPercentage,
      'status': 'pending',
      'type': 'sent',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.update(projectRef, {'requestsCount': FieldValue.increment(1)});
    await batch.commit();

    // Push is best-effort and server-owned; the request itself is committed.
    try {
      await _devsyncApi.notifyCollaborationRequest(
        requestId: requestRef.id,
        projectId: project.id,
        projectTitle: projectTitle,
        ownerId: ownerId,
        requesterId: uid,
        requesterName: requesterName,
        message: message,
      );
    } catch (_) {
      // The notification can be retried by the API's own queue/cron.
    }

    return CollaborationRequestReceipt(
      requestId: requestRef.id,
      projectId: project.id,
      created: true,
    );
  }

  Future<int> fetchJoinedContributions() async {
    final uid = _currentUserId;
    if (uid == null) return 0;

    final snapshot = await _requests
        .where('ownerId', isEqualTo: uid)
        .where('status', isEqualTo: 'accepted')
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Future<void> recordView(String projectId) async {
    final uid = _currentUserId;
    if (uid == null) return;

    final now = DateTime.now();
    final dayKey = '${now.year}-${_two(now.month)}-${_two(now.day)}';
    final viewRef = _views.doc('${projectId}_${uid}_$dayKey');
    final projectRef = _projects.doc(projectId);

    await _firestore.runTransaction((transaction) async {
      final projectSnapshot = await transaction.get(projectRef);
      if (!projectSnapshot.exists) return;

      final projectData = projectSnapshot.data() ?? const <String, dynamic>{};
      final ownerId = _string(
        projectData['ownerId'] ?? projectData['ownerUid'],
      );
      if (ownerId == uid) return;

      final viewSnapshot = await transaction.get(viewRef);
      if (viewSnapshot.exists) return;

      transaction.set(viewRef, {
        'projectId': projectId,
        'viewerId': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      transaction.update(projectRef, {'viewsCount': FieldValue.increment(1)});
    });
  }

  Future<Set<String>> _pendingProjectIds(String uid) async {
    try {
      final snapshot = await _requests
          .where('requesterId', isEqualTo: uid)
          .where('status', isEqualTo: 'pending')
          .get();
      return {
        for (final doc in snapshot.docs)
          if (_string(doc.data()['projectId']).isNotEmpty)
            _string(doc.data()['projectId']),
      };
    } catch (_) {
      // A missing index or offline cache should not block Discover.
      return const <String>{};
    }
  }

  Future<_OwnerProfile> _ownerFor(ProjectModel project) async {
    final cachedName = project.ownerName.trim();
    final fallbackName = cachedName.isNotEmpty
        ? cachedName
        : (project.isOwner ? 'You' : 'Project owner');

    if (project.ownerId.isEmpty) {
      return _OwnerProfile(fallbackName, 'Usually replies in 1 day');
    }

    try {
      final snapshot = await _users.doc(project.ownerId).get();
      final data = snapshot.data();
      final displayName = _string(data?['displayName']);
      final responseTime = _string(data?['responseTime'] ?? data?['replyTime']);
      return _OwnerProfile(
        displayName.isNotEmpty ? displayName : fallbackName,
        responseTime.isNotEmpty ? responseTime : 'Usually replies in 1 day',
      );
    } catch (_) {
      return _OwnerProfile(fallbackName, 'Usually replies in 1 day');
    }
  }

  Future<GithubMetricsModel> _resolveGithub(ProjectModel project) async {
    final cached = project.github;
    if (cached.isFresh() || project.githubUrl.trim().isEmpty) {
      return cached;
    }

    try {
      final fresh = await _github.fetchMetrics(project.githubUrl);
      await _projects.doc(project.id).set({
        'github': fresh.toFirestore(),
      }, SetOptions(merge: true));
      return fresh;
    } catch (_) {
      return cached;
    }
  }

  Future<List<double>> _weeklyViews(String projectId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final counts = await Future.wait(
      List<Future<int>>.generate(7, (index) {
        final start = today.subtract(Duration(days: 6 - index));
        final end = start.add(const Duration(days: 1));
        return _countViews(projectId, start, end);
      }),
    );
    return counts.map((value) => value.toDouble()).toList(growable: false);
  }

  Future<int> _countViews(
    String projectId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final snapshot = await _views
          .where('projectId', isEqualTo: projectId)
          .where('createdAt', isGreaterThanOrEqualTo: start)
          .where('createdAt', isLessThan: end)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  static bool _isNewProject(Project project) {
    return project.id.trim().isEmpty ||
        project.id.startsWith('project-') ||
        project.id.startsWith('draft-');
  }

  static int _newestFirst(Project a, Project b) {
    final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final byDate = bDate.compareTo(aDate);
    return byDate != 0 ? byDate : b.id.compareTo(a.id);
  }

  static String _string(Object? value) => value is String ? value.trim() : '';

  static String _two(int value) => value.toString().padLeft(2, '0');

  static String _truncate(String value, int maxLength) {
    if (value.length <= maxLength) return value;
    return value.substring(0, maxLength);
  }
}

class _OwnerProfile {
  const _OwnerProfile(this.name, this.responseTime);

  final String name;
  final String responseTime;
}
