import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/firestore_collections.dart';

/// Push preference flags (defaults on).
class NotificationPreferences {
  const NotificationPreferences({
    this.requests = true,
    this.matches = true,
  });

  final bool requests;
  final bool matches;

  static const requestsKey = 'notify_requests';
  static const matchesKey = 'notify_matches';

  /// FCM / inbox types gated by [requests].
  static bool isRequestType(String type) {
    switch (type) {
      case 'request_received':
      case 'request_accepted':
      case 'project_updated':
        return true;
      default:
        return false;
    }
  }

  /// FCM types gated by [matches].
  static bool isMatchType(String type) {
    return type == 'new_match' || type.startsWith('match_');
  }

  bool allowsType(String type) {
    if (isRequestType(type)) return requests;
    if (isMatchType(type)) return matches;
    return true;
  }

  NotificationPreferences copyWith({bool? requests, bool? matches}) {
    return NotificationPreferences(
      requests: requests ?? this.requests,
      matches: matches ?? this.matches,
    );
  }
}

/// Persists prefs to SharedPreferences + `users/{uid}.notificationPrefs`.
class NotificationPreferencesService {
  NotificationPreferencesService({
    required SharedPreferences prefs,
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _prefs = prefs,
       _auth = auth,
       _firestore = firestore;

  final SharedPreferences _prefs;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  NotificationPreferences loadLocal() {
    return NotificationPreferences(
      requests: _prefs.getBool(NotificationPreferences.requestsKey) ?? true,
      matches: _prefs.getBool(NotificationPreferences.matchesKey) ?? true,
    );
  }

  Future<NotificationPreferences> load() async {
    final local = loadLocal();
    final uid = _auth.currentUser?.uid;
    if (uid == null) return local;

    try {
      final snap = await _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .get();
      final raw = snap.data()?['notificationPrefs'];
      if (raw is! Map) return local;

      final loaded = NotificationPreferences(
        requests: raw['requests'] is bool ? raw['requests'] as bool : local.requests,
        matches: raw['matches'] is bool ? raw['matches'] as bool : local.matches,
      );
      await _writeLocal(loaded);
      return loaded;
    } on Object {
      return local;
    }
  }

  Future<NotificationPreferences> setRequests(bool value) async {
    final next = loadLocal().copyWith(requests: value);
    await _persist(next);
    return next;
  }

  Future<NotificationPreferences> setMatches(bool value) async {
    final next = loadLocal().copyWith(matches: value);
    await _persist(next);
    return next;
  }

  Future<void> _persist(NotificationPreferences prefs) async {
    await _writeLocal(prefs);
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection(FirestoreCollections.users).doc(uid).set({
      'notificationPrefs': {
        'requests': prefs.requests,
        'matches': prefs.matches,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _writeLocal(NotificationPreferences prefs) async {
    await _prefs.setBool(NotificationPreferences.requestsKey, prefs.requests);
    await _prefs.setBool(NotificationPreferences.matchesKey, prefs.matches);
  }
}
