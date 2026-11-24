import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/services/app_logger.dart';
import '../ads_config.dart';
import '../domain/ad_gate.dart';

/// Interstitial ads: consent (UMP), SDK start-up, preloading and showing at
/// the allowed moments. Android only for now; everywhere else (iOS, desktop,
/// tests) every call is a no-op.
class AdService {
  AdService._();

  static final AdService instance = AdService._();

  final AdGate gate = AdGate(
    warmUp: AdsConfig.warmUp,
    minGap: AdsConfig.minGap,
  );

  /// True when the consent rules (for example GDPR) require a "Privacy
  /// options" entry point in Settings.
  final ValueNotifier<bool> privacyOptionsRequired = ValueNotifier(false);

  bool get isSupported => !kIsWeb && Platform.isAndroid;

  bool _started = false;
  bool _sdkReady = false;
  bool _showing = false;
  InterstitialAd? _ad;
  bool _loading = false;
  int _failedLoads = 0;

  /// Call once after runApp. Asks for consent when required, then starts
  /// the Mobile Ads SDK and preloads the first interstitial.
  Future<void> initialize() async {
    if (_started) return;
    _started = true;
    // Registers itself with the binding and lives as long as the app.
    AppLifecycleListener(
      onShow: gate.onForeground,
      onResume: gate.onForeground,
      onHide: gate.onBackground,
    );
    if (!isSupported) return;
    try {
      await _gatherConsent();
      await _refreshPrivacyOptions();
      if (!await ConsentInformation.instance.canRequestAds()) return;
      await _startSdk();
    } catch (e, st) {
      AppLogger.error('Ads failed to start', e, st);
    }
  }

  Future<void> _gatherConsent() {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        await ConsentForm.loadAndShowConsentFormIfRequired((error) {
          if (error != null) {
            AppLogger.warning('Consent form: ${error.message}');
          }
          if (!done.isCompleted) done.complete();
        });
      },
      (error) {
        AppLogger.warning('Consent info update failed: ${error.message}');
        if (!done.isCompleted) done.complete();
      },
    );
    return done.future;
  }

  Future<void> _refreshPrivacyOptions() async {
    final status = await ConsentInformation.instance
        .getPrivacyOptionsRequirementStatus();
    privacyOptionsRequired.value =
        status == PrivacyOptionsRequirementStatus.required;
  }

  Future<void> _startSdk() async {
    if (_sdkReady) return;
    await MobileAds.instance.initialize();
    _sdkReady = true;
    _preload();
  }

  /// Opens the consent "Privacy options" form (Settings row).
  Future<void> showPrivacyOptions() async {
    if (!isSupported) return;
    await ConsentForm.showPrivacyOptionsForm((error) {
      if (error != null) {
        AppLogger.warning('Privacy options form: ${error.message}');
      }
    });
    await _refreshPrivacyOptions();
    if (await ConsentInformation.instance.canRequestAds()) {
      await _startSdk();
    } else {
      _ad?.dispose();
      _ad = null;
    }
  }

  void _preload() {
    if (!_sdkReady || _ad != null || _loading) return;
    _loading = true;
    InterstitialAd.load(
      adUnitId: AdsConfig.interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loading = false;
          _failedLoads = 0;
          _ad = ad;
        },
        onAdFailedToLoad: (error) {
          _loading = false;
          _failedLoads++;
          AppLogger.warning('Interstitial failed to load: ${error.message}');
          // Back off: 30 s, 60 s, 120 s ... capped at 10 minutes.
          final seconds = (30 * (1 << (_failedLoads - 1).clamp(0, 5))).clamp(
            30,
            600,
          );
          Timer(Duration(seconds: seconds), _preload);
        },
      ),
    );
  }

  /// Call right after a "next topic" or "finish lesson" navigation. Shows
  /// a preloaded interstitial once the new screen has settled, but only
  /// when the [gate] allows it. Never waits for an ad to load.
  void showAfterNavigation() {
    if (!isSupported || !_sdkReady) return;
    Timer(AdsConfig.showDelay, _maybeShow);
  }

  void _maybeShow() {
    final ad = _ad;
    if (ad == null) {
      _preload();
      return;
    }
    if (_showing || !gate.canShow) return;
    _ad = null;
    _showing = true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => gate.markShown(),
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _showing = false;
        _preload();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        AppLogger.warning('Interstitial failed to show: ${error.message}');
        ad.dispose();
        _showing = false;
        _preload();
      },
    );
    ad.show();
  }
}
