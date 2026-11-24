import 'package:flutter/foundation.dart';

/// AdMob settings in one place. The AdMob *app* ID is set once in
/// android/app/build.gradle.kts (manifestPlaceholders "admobAppId"):
/// Google's test app ID for debug and profile, Teacher's real one for
/// release. The manifest reads it from there.
abstract final class AdsConfig {
  /// Google's official test interstitial unit. Debug and profile builds
  /// always use it, so testing never counts as real traffic.
  static const _testInterstitialUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  /// Teacher's real interstitial unit (AdMob > Apps > Teacher > Ad units).
  /// Release builds only.
  static const _releaseInterstitialUnitId =
      'ca-app-pub-1106747567696734/5701967862';

  static String get interstitialUnitId =>
      kReleaseMode ? _releaseInterstitialUnitId : _testInterstitialUnitId;

  /// No ads until the learner has used the app this long in a session.
  static const warmUp = Duration(minutes: 5);

  /// At most one interstitial per this much usage time.
  static const minGap = Duration(minutes: 3);

  /// Wait after a "next topic" navigation so the new screen has settled
  /// (and any test screen it replaced is gone) before an ad shows.
  static const showDelay = Duration(milliseconds: 800);
}
