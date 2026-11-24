import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/startup.dart';
import 'core/services/app_logger.dart';
import 'core/services/crash_reporting_service.dart';
import 'features/ads/data/ad_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Draw behind the status and navigation bars (the default from Android
  // 15). Screens keep content clear of them with SafeArea or an app bar.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Firebase + Crashlytics on Android; a no-op everywhere else. Never
  // throws: if Firebase can't start, the app runs without crash reporting.
  await CrashReportingService.initialize();

  AppLogger.info('Teacher starting up');

  // Resolve theme mode and onboarding state while the native splash is
  // still showing, so the first frame is final (no theme or screen switch).
  final container = ProviderContainer();
  await preloadStartupState(container);

  runApp(
    UncontrolledProviderScope(container: container, child: const TeacherApp()),
  );

  // Ads (Android only): ask for consent where required, then start the
  // Mobile Ads SDK (MobileAds.instance.initialize) and preload an
  // interstitial. Runs after runApp because the consent form needs a
  // visible activity. Never blocks start-up.
  unawaited(AdService.instance.initialize());
}
