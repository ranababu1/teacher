import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';
import 'core/config/app_config_provider.dart';
import 'core/services/app_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } on Exception catch (e) {
    AppLogger.warning(
      'No .env file found — AI features will be unavailable: $e',
    );
  }

  AppLogger.info('Teacher starting up');

  runApp(
    ProviderScope(
      overrides: [appConfigProvider.overrideWithValue(AppConfig.fromEnv())],
      child: const TeacherApp(),
    ),
  );
}
