import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../firebase_options.dart';

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
  });

  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final void Function(String title, String body) onForegroundMessage;
  final void Function() onNotificationOpened;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final messaging = FirebaseMessaging.instance;

    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      final dataTitle = message.data['title'];
      final dataBody = message.data['body'];
      onForegroundMessage(
        notification?.title ??
            (dataTitle is String ? dataTitle : 'New request'),
        notification?.body ?? (dataBody is String ? dataBody : ''),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((_) {
      onNotificationOpened();
    });

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) onNotificationOpened();

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
      await messaging.register();
    }

    return settings.authorizationStatus;
  }

  Future<void> _registerIfAuthorized(FirebaseMessaging messaging) async {
    final settings = await messaging.getNotificationSettings();
    if (_isAuthorized(settings.authorizationStatus)) {
      await messaging.register();
    }
  }

  bool _isAuthorized(AuthorizationStatus status) =>
      status == AuthorizationStatus.authorized ||
      status == AuthorizationStatus.provisional;

  Future<void> _saveToken(String token) async {
    final user = auth.currentUser;
    if (user == null) return;

    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('fcmTokens')
        .doc(token)
        .set({
          'token': token,
          'platform': 'android',
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }
}
