import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/cache_config.dart';
import '../models/match_item_model.dart';

abstract class MatchingCacheDataSource {
  Future<List<MatchItemModel>?> getCachedMatches();

  Future<void> cacheMatches(
    List<MatchItemModel> matches, {
    required String profileHash,
  });

  Future<bool> isCacheValid(
    String profileHash, {
    Duration ttl = const Duration(hours: 1),
  });

  Future<void> clearCache();
}

class FirestoreMatchingCacheDataSource implements MatchingCacheDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final MatchingCacheConfig _config;

  static const String _collection = 'matches_cache';

  FirestoreMatchingCacheDataSource({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    MatchingCacheConfig config = const MatchingCacheConfig(),
  }) : _firestore = firestore,
       _auth = auth,
       _config = config;

  String? get _userId => _auth.currentUser?.uid;

  @override
  Future<List<MatchItemModel>?> getCachedMatches() async {
    if (!_config.enabled) return null;

    final userId = _userId;
    if (userId == null) return null;

    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();

      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null) return null;

      final matchesData = data['matches'] as List<dynamic>?;
      if (matchesData == null || matchesData.isEmpty) return null;

      return matchesData
          .map((m) => MatchItemModel.fromJson(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheMatches(
    List<MatchItemModel> matches, {
    required String profileHash,
  }) async {
    if (!_config.enabled) return;

    final userId = _userId;
    if (userId == null) return;

    try {
      await _firestore.collection(_collection).doc(userId).set({
        'matches': matches.map((m) => m.toJson()).toList(),
        'cachedAt': FieldValue.serverTimestamp(),
        'profileHash': profileHash,
        'ttl': _config.ttl.inSeconds,
      });
    } catch (e) {
      return;
    }
  }

  @override
  Future<bool> isCacheValid(
    String profileHash, {
    Duration ttl = const Duration(hours: 1),
  }) async {
    if (!_config.enabled) return false;

    final userId = _userId;
    if (userId == null) return false;

    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();

      if (!doc.exists) return false;

      final data = doc.data();
      if (data == null) return false;

      final cachedHash = data['profileHash'] as String?;
      if (cachedHash != profileHash) return false;

      final cachedAt = data['cachedAt'] as Timestamp?;
      if (cachedAt == null) return false;

      final cacheAge = DateTime.now().difference(cachedAt.toDate());
      final effectiveTtl = _config.ttl;

      return cacheAge < effectiveTtl;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> clearCache() async {
    final userId = _userId;
    if (userId == null) return;

    try {
      await _firestore.collection(_collection).doc(userId).delete();
    } catch (e) {
      return;
    }
  }
}

class NoOpMatchingCacheDataSource implements MatchingCacheDataSource {
  const NoOpMatchingCacheDataSource();

  @override
  Future<List<MatchItemModel>?> getCachedMatches() async => null;

  @override
  Future<void> cacheMatches(
    List<MatchItemModel> matches, {
    required String profileHash,
  }) async {}

  @override
  Future<bool> isCacheValid(
    String profileHash, {
    Duration ttl = const Duration(hours: 1),
  }) async => false;

  @override
  Future<void> clearCache() async {}
}
