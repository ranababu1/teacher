import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/routes.dart';
import '../features/profile/domain/models/learner_profile.dart';

/// Decides the startup and onboarding redirects for go_router.
///
/// While the learner profile is still loading for the first time, every
/// location is parked on the blank [Routes.launch] page (remembering where
/// it was headed in `from`). Rendering the dashboard there instead would
/// flash it for a frame on a fresh install before the onboarding redirect
/// kicks in. Once the profile is known, the learner goes to onboarding or
/// on to the original destination. If the profile fails to load, the app
/// is not held on the blank page: it carries on as if onboarding is done.
String? startupRedirect({
  required AsyncValue<LearnerProfile> profile,
  required Uri uri,
}) {
  final onLaunch = uri.path == Routes.launch;
  final onOnboarding = uri.path == Routes.onboarding;

  if (!profile.hasValue && !profile.hasError) {
    if (onLaunch) return null;
    return Uri(
      path: Routes.launch,
      queryParameters: {'from': uri.toString()},
    ).toString();
  }

  final loaded = profile.valueOrNull;
  final needsOnboarding = loaded != null && !loaded.hasCompletedOnboarding;

  if (onLaunch) {
    if (needsOnboarding) return Routes.onboarding;
    final from = uri.queryParameters['from'];
    final usable =
        from != null &&
        from.startsWith('/') &&
        Uri.parse(from).path != Routes.launch &&
        Uri.parse(from).path != Routes.onboarding;
    return usable ? from : Routes.dashboard;
  }

  if (loaded == null) return null;
  if (needsOnboarding && !onOnboarding) return Routes.onboarding;
  if (!needsOnboarding && onOnboarding) return Routes.dashboard;
  return null;
}
