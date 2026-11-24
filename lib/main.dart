import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/startup.dart';
import 'core/ads/ad_service.dart';
import 'core/services/app_logger.dart';
import 'core/services/crash_reporting_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Android 15+ (targetSdk 35+) always draws edge to edge. Opt in on older
  // versions too so every device behaves the same; screens keep content
  // out from under the bars with app bars and SafeArea.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Firebase + Crashlytics on Android; a no-op everywhere else. Never
  // throws: if Firebase can't start, the app runs without crash reporting.
  await CrashReportingService.initialize();

  AppLogger.info('Teacher starting up');

  // Mobile Ads SDK (Android only; a no-op elsewhere). Not awaited, so it
  // never delays the first frame.
  unawaited(AdService.initializeSdk());

  // Resolve theme mode and onboarding state while the native splash is
  // still showing, so the first frame is final (no theme or screen switch).
  final container = ProviderContainer();
  await preloadStartupState(container);

  runApp(
    UncontrolledProviderScope(container: container, child: const TeacherApp()),
  );

  // Consent (UMP) and the first ad preload need a running UI, so they
  // start after the first frame.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(AdService.instance.start());
  });
}
