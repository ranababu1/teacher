import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/app_logger.dart';
import '../features/profile/presentation/providers/profile_providers.dart';
import '../features/settings/presentation/providers/settings_providers.dart';

/// Loads what the first frame depends on (theme mode and whether onboarding
/// is done) before `runApp`, while the native splash is still on screen.
///
/// The first Flutter frame then already has the learner's theme and the
/// right screen, instead of drawing defaults and switching a moment later.
/// Bounded by [timeout] and never throws: if loading is slow or fails, the
/// app starts anyway and the blank launch route covers the gap.
Future<void> preloadStartupState(
  ProviderContainer container, {
  Duration timeout = const Duration(seconds: 3),
}) async {
  try {
    await Future.wait([
      container.read(settingsControllerProvider.future),
      container.read(learnerProfileControllerProvider.future),
    ]).timeout(timeout);
  } on Object catch (e) {
    AppLogger.info('Startup preload incomplete, continuing: $e');
  }
}
