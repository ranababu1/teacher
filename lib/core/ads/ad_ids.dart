import 'package:flutter/foundation.dart';

/// Every AdMob id the app uses, in one place.
///
/// Debug and profile builds always use Google's test ids, so no real ad is
/// ever requested while developing (clicking real ads on your own app can
/// get the AdMob account suspended). Release builds use Teacher's ids.
///
/// The AdMob *app* id also has to be in the Android manifest. It is set
/// once, in android/app/build.gradle.kts (manifestPlaceholders
/// "admobAppId"): the sample id in defaultConfig for debug/profile, and
/// [androidReleaseAppId] in the release build type. Keep the two in sync.
abstract final class AdIds {
  /// Teacher's AdMob app id (Android). Mirrors build.gradle.kts.
  static const androidReleaseAppId = 'ca-app-pub-1106747567696734~9070367235';

  /// Teacher's interstitial ad unit (Android), shown between chapters.
  static const androidReleaseInterstitial =
      'ca-app-pub-1106747567696734/5701967862';

  /// Google's sample AdMob app id (Android). Test ads only.
  static const androidTestAppId = 'ca-app-pub-3940256099942544~3347511713';

  /// Google's test interstitial unit (Android).
  static const androidTestInterstitial =
      'ca-app-pub-3940256099942544/1033173712';

  /// The interstitial unit for this build.
  static String get interstitial =>
      kReleaseMode ? androidReleaseInterstitial : androidTestInterstitial;
}
