/// Decides when an interstitial may show. Pure logic, no SDK calls, so it
/// can be unit tested with a fake clock.
///
/// Rules:
/// - Time counts only while the app is in the foreground (session usage).
/// - No ads in the first [warmUp] of usage.
/// - Then at most one ad per [minGap] of usage.
/// - Never while a no-ads screen is open (tests, quizzes, practice,
///   challenges, interview, review) or while an AI request is running.
class AdGate {
  AdGate({required this.warmUp, required this.minGap, DateTime Function()? now})
    : _now = now ?? DateTime.now {
    _foregroundSince = _now();
  }

  final Duration warmUp;
  final Duration minGap;
  final DateTime Function() _now;

  Duration _usageBeforeResume = Duration.zero;
  DateTime? _foregroundSince;
  Duration? _usageAtLastAd;
  int _noAdsZones = 0;
  int _aiRequests = 0;

  /// Foreground time so far this session.
  Duration get usage {
    final since = _foregroundSince;
    return since == null
        ? _usageBeforeResume
        : _usageBeforeResume + _now().difference(since);
  }

  bool get inNoAdsZone => _noAdsZones > 0;
  bool get aiRequestRunning => _aiRequests > 0;

  void onBackground() {
    final since = _foregroundSince;
    if (since == null) return;
    _usageBeforeResume += _now().difference(since);
    _foregroundSince = null;
  }

  void onForeground() {
    _foregroundSince ??= _now();
  }

  void enterNoAdsZone() => _noAdsZones++;

  void exitNoAdsZone() {
    if (_noAdsZones > 0) _noAdsZones--;
  }

  void aiRequestStarted() => _aiRequests++;

  void aiRequestFinished() {
    if (_aiRequests > 0) _aiRequests--;
  }

  bool get canShow {
    if (inNoAdsZone || aiRequestRunning) return false;
    if (_foregroundSince == null) return false;
    final used = usage;
    if (used < warmUp) return false;
    final last = _usageAtLastAd;
    return last == null || used - last >= minGap;
  }

  void markShown() => _usageAtLastAd = usage;
}
