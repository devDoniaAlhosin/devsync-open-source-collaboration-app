import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_stats.dart';
import '../datasources/github_remote_data_source.dart';
import '../exceptions/projects_exceptions.dart';
import '../models/project_model.dart';

/// Firestore-facing source for projects, views and the owner dashboard.
///
/// Collection layout:
/// * `projects/{projectId}` — project document. AI fields (`matchPercentage`,
///   `matchSummary`, `alignments`, `matchedSkills`) and the cached `github` map
///   are written by the DevSync API, never by the client.
/// * `views/{projectId}_{uid}_{yyyy-MM-dd}` — one deterministic document per
///   viewer per day, so refreshing details does not inflate view counts.
///
/// Collaboration requests are **not** written here. The requests feature
/// (`RequestsCubit` / `RequestModel`) is the single create path; this source
/// only reads `requests` to resolve viewer-relative pending flags and the
/// owner dashboard counters.
class ProjectsRemoteDataSource {
  ProjectsRemoteDataSource({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    GithubRemoteDataSource? github,
  }) : _firestore = firestore,
       _auth = auth,
       _github = github ?? GithubRemoteDataSource();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GithubRemoteDataSource _github;

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

    final isNew = project.id.trim().isEmpty;
    final ref = isNew ? _projects.doc() : _projects.doc(project.id.trim());

    final ownerName = await _resolveOwnerName(
      preferred: project.ownerName,
      uid: uid,
    );
    if (ownerName.trim().isEmpty) {
      throw const ProjectValidationException(
        'A project owner name is required before saving.',
      );
    }

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
      ownerName: ownerName,
      createdAt: project.createdAt ?? (isNew ? DateTime.now() : null),
      hasPendingRequest: project.hasPendingRequest,
    );

    if (!isNew) {
      // Create/edit are guarded in one transaction so a concurrent owner
      // change cannot be overwritten between the read and the write.
      Project saved = model;
      await _firestore.runTransaction<void>((transaction) async {
        final snapshot = await transaction.get(ref);
        if (!snapshot.exists) throw const ProjectNotFoundException();

        final data = snapshot.data() ?? const <String, dynamic>{};
        final ownerId = _string(data['ownerId'] ?? data['ownerUid']);
        if (ownerId.isEmpty) {
          throw const ProjectValidationException(
            'This project has no owner. Re-create it before editing.',
          );
        }
        if (ownerId != uid) throw const ProjectForbiddenException();

        // Keep the original createdAt in the returned entity; `toFirestore`
        // deliberately does not rewrite it on edits.
        final existing = ProjectModel.fromFirestore(
          snapshot,
          currentUserId: uid,
        );
        saved = model.copyWith(createdAt: existing.createdAt);

        transaction.set(
          ref,
          model.toFirestore(ownerId: uid, ownerName: ownerName, isNew: false),
          SetOptions(merge: true),
        );
      });
      return saved;
    }

    await ref.set(
      model.toFirestore(ownerId: uid, ownerName: ownerName, isNew: true),
    );
    return model;
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
          .where('senderId', isEqualTo: uid)
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
        : (project.isOwner ? 'You' : 'Maintainer');

    if (project.ownerId.isEmpty) {
      return _OwnerProfile(fallbackName, 'Usually replies in 1 day');
    }

    try {
      final snapshot = await _users.doc(project.ownerId).get();
      final data = snapshot.data();
      final resolved = _nameFromUserDoc(data);
      final responseTime = _string(data?['responseTime'] ?? data?['replyTime']);
      return _OwnerProfile(
        resolved.isNotEmpty ? resolved : fallbackName,
        responseTime.isNotEmpty ? responseTime : 'Usually replies in 1 day',
      );
    } catch (_) {
      return _OwnerProfile(fallbackName, 'Usually replies in 1 day');
    }
  }

  /// Auth displayName → users.displayName → users.profile.name → email local → Maintainer.
  Future<String> _resolveOwnerName({
    required String preferred,
    required String uid,
  }) async {
    final fromProject = preferred.trim();
    if (fromProject.isNotEmpty) return fromProject;

    final authName = _auth.currentUser?.displayName?.trim() ?? '';
    if (authName.isNotEmpty) return authName;

    try {
      final snapshot = await _users.doc(uid).get();
      final fromDoc = _nameFromUserDoc(snapshot.data());
      if (fromDoc.isNotEmpty) return fromDoc;
    } catch (_) {
      // Fall through to email / default.
    }

    final email = _auth.currentUser?.email?.trim() ?? '';
    if (email.contains('@')) {
      final local = email.split('@').first.trim();
      if (local.isNotEmpty) return local;
    }

    return 'Maintainer';
  }

  String _nameFromUserDoc(Map<String, dynamic>? data) {
    if (data == null) return '';
    final displayName = _string(data['displayName']);
    if (displayName.isNotEmpty) return displayName;

    final profile = data['profile'];
    if (profile is Map) {
      final profileName = _string(profile['name']);
      if (profileName.isNotEmpty) return profileName;
    }
    return '';
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

  static int _newestFirst(Project a, Project b) {
    final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final byDate = bDate.compareTo(aDate);
    return byDate != 0 ? byDate : b.id.compareTo(a.id);
  }

  static String _string(Object? value) => value is String ? value.trim() : '';

  static String _two(int value) => value.toString().padLeft(2, '0');
}

class _OwnerProfile {
  const _OwnerProfile(this.name, this.responseTime);

  final String name;
  final String responseTime;
}
