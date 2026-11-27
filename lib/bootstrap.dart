import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'core/notifications/fcm_service.dart';
import 'app/devsync_app.dart';
import 'core/di/injection.dart';
import 'core/theme/app_colors.dart';
import 'firebase_options.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Android auto-inits Firebase via google-services.json before Dart runs.
  // Dart often still sees apps as empty, then initializeApp throws
  // [core/duplicate-app] and never reaches runApp → stuck on splash.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }
  await configureDependencies(
    onForegroundMessage: DevSyncApp.showNotification,
    onNotificationOpened: DevSyncApp.openFromNotification,
  );
  try {
    await getIt<FcmService>().initialize();
  } on FirebaseException catch (error, stackTrace) {
    log(
      'Could not initialize Firebase Messaging.',
      error: error,
      stackTrace: stackTrace,
    );
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.lightBackground,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const DevSyncApp());
}
