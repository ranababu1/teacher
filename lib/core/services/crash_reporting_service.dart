import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Single funnel for everything crash-reporting so the rest of the app
/// never needs to know whether Crashlytics is available on the current
/// platform or even initialized (Android-only for now).
///
/// Privacy: reports contain stack traces and device/OS metadata only — no
/// user ids, no analytics, no message content. Collection is on by
/// default; the learner can turn it off in Settings at any time, and the
/// native SDK persists that choice across restarts.
class CrashReportingService {
  CrashReportingService._();

  static bool _initialized = false;

  /// Whether crash reporting is live on this platform run.
  static bool get isAvailable => _initialized;

  /// Initializes Firebase and routes all uncaught Flutter errors into
  /// Crashlytics. No-op on anything but Android.
  ///
  /// Firebase reads its configuration from android/app/google-services.json
  /// (project "teacher-max") via the google-services Gradle plugin, so no
  /// Dart-side options are needed.
  static Future<void> initialize() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    await Firebase.initializeApp();
    _initialized = true;

    // Framework errors are recorded as fatal (the Flutter framework
    // failed); asynchronous errors that escape past the platform
    // dispatcher are recorded as non-fatal, because returning true below
    // keeps the app running.
    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordFlutterError(
        FlutterErrorDetails(exception: error, stack: stack),
      );
      return true;
    };
  }

  /// Enables/disables Crashlytics collection. The native SDK persists the
  /// flag itself, so the choice survives restarts; the Settings screen also
  /// mirrors it in the app database for the UI.
  static Future<void> setCollectionEnabled(bool enabled) async {
    if (!_initialized) return;
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      enabled,
    );
  }

  /// Deliberately crashes the app — used only by the debug-build crash test
  /// in Settings to verify the end-to-end pipeline.
  static void crash() {
    if (!_initialized) {
      throw StateError('Crash reporting is unavailable on this platform.');
    }
    FirebaseCrashlytics.instance.crash();
  }
}