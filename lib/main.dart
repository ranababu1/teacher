import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/services/app_logger.dart';
import 'core/services/crash_reporting_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase + Crashlytics on Android; a no-op everywhere else. Never
  // throws: if Firebase can't start, the app runs without crash reporting.
  await CrashReportingService.initialize();

  AppLogger.info('Teacher starting up');

  runApp(const ProviderScope(child: TeacherApp()));
}
