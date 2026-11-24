import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ai_activity.dart';
import '../services/app_logger.dart';
import 'ad_gate.dart';
import 'ad_ids.dart';

/// Interstitial ads between chapters, with Google's consent flow (UMP).
///
/// Android only for now. On every other platform (and in tests) every
/// method is a safe no-op.
///
/// Flow: [initializeSdk] in main, then [start] after the first frame,
/// which asks for consent when the law requires it and preloads one ad.
/// Navigation calls [showAtNextChapter]; it never waits for the ad and
/// never blocks navigation.
class AdService {
  AdService._();

  static final AdService instance = AdService._();

  /// Delay before showing an ad after a chapter change, so it appears over
  /// the next topic once that screen has loaded, not over the previous one.
  static const _afterNavigation = Duration(milliseconds: 700);

  final AdGate gate = AdGate(isAiBusy: () => AiActivity.isBusy);

  bool _started = false;
  bool _canRequestAds = false;
  bool _loading = false;
  bool _showing = false;
  InterstitialAd? _ad;
  AppLifecycleListener? _lifecycle;

  /// Ads run on Android only, and never on the web or in host tests.
  static bool get isSupported => !kIsWeb && Platform.isAndroid;

  /// Starts the Mobile Ads SDK. Safe to call without awaiting.
  static Future<void> initializeSdk() async {
    if (!isSupported) return;
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      AppLogger.warning('Mobile Ads init failed: $e');
    }
  }

  /// Consent, lifecycle tracking and the first preload. Call once.
  Future<void> start() async {
    if (!isSupported || _started) return;
    _started = true;
    _lifecycle = AppLifecycleListener(
      onResume: gate.onForeground,
      onShow: gate.onForeground,
      onHide: gate.onBackground,
      onPause: gate.onBackground,
    );
    await _gatherConsent();
    await _refreshCanRequestAds();
    _preload();
  }

  Future<void> _gatherConsent() {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        await ConsentForm.loadAndShowConsentFormIfRequired((formError) {
          if (formError != null) {
            AppLogger.warning('Consent form: ${formError.message}');
          }
          if (!done.isCompleted) done.complete();
        });
      },
      (error) {
        // Consent info could not be updated (offline, for example). The
        // previous session's consent still applies; canRequestAds says.
        AppLogger.warning('Consent info update failed: ${error.message}');
        if (!done.isCompleted) done.complete();
      },
    );
    return done.future;
  }

  Future<void> _refreshCanRequestAds() async {
    try {
      _canRequestAds = await ConsentInformation.instance.canRequestAds();
    } catch (_) {
      _canRequestAds = false;
    }
  }

  void _preload() {
    if (!_started || !_canRequestAds || _ad != null || _loading) return;
    _loading = true;
    InterstitialAd.load(
      adUnitId: AdIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loading = false;
          _ad = ad;
        },
        onAdFailedToLoad: (error) {
          _loading = false;
          AppLogger.info('Interstitial failed to load: ${error.message}');
        },
      ),
    );
  }

  /// Called right after navigating to the next chapter. Shows an ad over
  /// the new topic once it has loaded, if the timing rules allow it and an
  /// ad is already loaded. Never delays or blocks navigation.
  ///
  /// [checkNow]: also require the rules to pass at tap time. True for the
  /// Continue and Finish lesson buttons, so a tap made from a blocking
  /// screen (a skill check, say) never leads to an ad. False when coming
  /// from a passed topic test, which is still on screen at tap time; the
  /// check then happens only once the next topic is showing.
  void showAtNextChapter({bool checkNow = true}) {
    if (!_started) return;
    if (checkNow && !gate.canShow) return;
    if (_ad == null) {
      _preload();
      return;
    }
    Timer(_afterNavigation, _showIfAllowed);
  }

  void _showIfAllowed() {
    final ad = _ad;
    if (ad == null || _showing || !_canRequestAds || !gate.canShow) return;
    _ad = null;
    _showing = true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => gate.recordShown(),
      onAdDismissedFullScreenContent: (ad) {
        _showing = false;
        ad.dispose();
        _preload();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _showing = false;
        ad.dispose();
        _preload();
      },
    );
    ad.show();
  }

  /// Whether Settings must offer "Privacy options" (EEA/UK users).
  static Future<bool> isPrivacyOptionsRequired() async {
    if (!isSupported) return false;
    try {
      final status = await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus();
      return status == PrivacyOptionsRequirementStatus.required;
    } catch (_) {
      return false;
    }
  }

  /// Opens Google's privacy options form so the learner can change consent.
  Future<void> showPrivacyOptions() async {
    if (!isSupported) return;
    final done = Completer<void>();
    await ConsentForm.showPrivacyOptionsForm((formError) {
      if (formError != null) {
        AppLogger.warning('Privacy options form: ${formError.message}');
      }
      if (!done.isCompleted) done.complete();
    });
    await done.future;
    await _refreshCanRequestAds();
    if (!_canRequestAds) {
      _ad?.dispose();
      _ad = null;
    } else {
      _preload();
    }
  }

  @visibleForTesting
  void debugDispose() {
    _lifecycle?.dispose();
    _ad?.dispose();
  }
}

/// Keeps ads away while [child] is on screen. Wrap every test, skill
/// check, interview, practice, challenge and review session screen in it.
class NoAdsZone extends StatefulWidget {
  const NoAdsZone({super.key, required this.child});

  final Widget child;

  @override
  State<NoAdsZone> createState() => _NoAdsZoneState();
}

class _NoAdsZoneState extends State<NoAdsZone> {
  @override
  void initState() {
    super.initState();
    AdService.instance.gate.block(this);
  }

  @override
  void dispose() {
    AdService.instance.gate.unblock(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
