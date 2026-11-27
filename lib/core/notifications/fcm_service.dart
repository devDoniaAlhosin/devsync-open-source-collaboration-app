import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../firebase_options.dart';
import '../constants/firestore_collections.dart';
import 'notification_preferences.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  log('Background message: ${message.messageId}');
}

class FcmService {
  FcmService({
    required this.auth,
    required this.firestore,
    required this.onForegroundMessage,
    required this.onNotificationOpened,
    this.preferences,
  });

  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final void Function(String title, String body) onForegroundMessage;
  /// [type] is the FCM data `type` (e.g. request_accepted, project_updated).
  final void Function(String? type) onNotificationOpened;
  final NotificationPreferencesService? preferences;

  static String? typeOf(RemoteMessage message) {
    final type = message.data['type'];
    return type is String && type.isNotEmpty ? type : null;
  }

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final messaging = FirebaseMessaging.instance;

    FirebaseMessaging.onMessage.listen((message) {
      final type = message.data['type'];
      final prefs = preferences?.loadLocal() ?? const NotificationPreferences();
      if (type is String && type.isNotEmpty && !prefs.allowsType(type)) {
        return;
      }

      final notification = message.notification;
      final dataTitle = message.data['title'];
      final dataBody = message.data['body'];
      onForegroundMessage(
        notification?.title ??
            (dataTitle is String ? dataTitle : 'New request'),
        notification?.body ?? (dataBody is String ? dataBody : ''),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      onNotificationOpened(typeOf(message));
    });

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      onNotificationOpened(typeOf(initialMessage));
    }

    // Persist every registration / refresh so /notify can multicast.
    messaging.onRegistered.listen(_saveToken);

    await _registerIfAuthorized(messaging);

    auth.authStateChanges().listen((user) async {
      if (user == null) return;
      await _registerIfAuthorized(messaging);
    });
  }

  Future<AuthorizationStatus> requestPermission() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (_isAuthorized(settings.authorizationStatus)) {
      await _registerAndPersist(messaging);
    }

    return settings.authorizationStatus;
  }

  Future<void> _registerIfAuthorized(FirebaseMessaging messaging) async {
    final settings = await messaging.getNotificationSettings();
    if (_isAuthorized(settings.authorizationStatus)) {
      await _registerAndPersist(messaging);
    }
  }

  Future<void> _registerAndPersist(FirebaseMessaging messaging) async {
    try {
      await messaging.register();
    } on Object catch (error, stackTrace) {
      log(
        'FCM register failed',
        error: error,
        stackTrace: stackTrace,
        name: 'FcmService',
      );
    }

    // Fallback when onRegistered already fired before the listener attached.
    try {
      // ignore: deprecated_member_use
      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await _saveToken(token);
      }
    } on Object catch (error, stackTrace) {
      log(
        'FCM getToken failed',
        error: error,
        stackTrace: stackTrace,
        name: 'FcmService',
      );
    }
  }

  bool _isAuthorized(AuthorizationStatus status) =>
      status == AuthorizationStatus.authorized ||
      status == AuthorizationStatus.provisional;

  Future<void> _saveToken(String token) async {
    final user = auth.currentUser;
    if (user == null) return;
    final trimmed = token.trim();
    if (trimmed.isEmpty) return;

    try {
      await firestore
          .collection(FirestoreCollections.users)
          .doc(user.uid)
          .collection(FirestoreCollections.fcmTokens)
          .doc(trimmed)
          .set({
            'token': trimmed,
            'platform': 'android',
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } on Object catch (error, stackTrace) {
      log(
        'Could not save FCM token',
        error: error,
        stackTrace: stackTrace,
        name: 'FcmService',
      );
    }
  }
}
