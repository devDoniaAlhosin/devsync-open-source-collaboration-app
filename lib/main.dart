import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/devsync_app.dart';
import 'core/theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.forest,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const DevSyncApp());
}
