/// Pure timing rules for interstitial ads. No plugin code here, so the
/// rules are unit tested on their own (test/core/ads/ad_gate_test.dart).
///
/// - No ads during the first [grace] of foreground use in this session.
/// - After that, at most one ad per [interval] of foreground use.
/// - Never while a blocking screen is open (tests, skill checks,
///   interviews, practice, challenges, review sessions) or while an AI
///   request is running.
///
/// Time only counts while the app is in the foreground, so leaving the
/// app open in the background never "earns" an ad.
class AdGate {
  AdGate({
    DateTime Function()? clock,
    bool Function()? isAiBusy,
    this.grace = const Duration(minutes: 5),
    this.interval = const Duration(minutes: 3),
  }) : _clock = clock ?? DateTime.now,
       _isAiBusy = isAiBusy ?? _never {
    _resumedAt = _clock();
  }

  static bool _never() => false;

  final DateTime Function() _clock;
  final bool Function() _isAiBusy;
  final Duration grace;
  final Duration interval;

  Duration _banked = Duration.zero;
  DateTime? _resumedAt;
  Duration? _lastShownAtUsage;
  final Set<Object> _blockers = {};

  /// Foreground time used so far in this session.
  Duration get usage {
    final resumedAt = _resumedAt;
    if (resumedAt == null) return _banked;
    return _banked + _clock().difference(resumedAt);
  }

  bool get isForeground => _resumedAt != null;

  void onForeground() {
    _resumedAt ??= _clock();
  }

  void onBackground() {
    final resumedAt = _resumedAt;
    if (resumedAt == null) return;
    _banked += _clock().difference(resumedAt);
    _resumedAt = null;
  }

  /// Marks a screen (or anything else) that must never be covered by an ad.
  void block(Object token) => _blockers.add(token);

  void unblock(Object token) => _blockers.remove(token);

  bool get isBlocked => _blockers.isNotEmpty || _isAiBusy();

  /// Whether an ad may be shown right now, ignoring whether one is loaded.
  bool get canShow {
    if (!isForeground || isBlocked) return false;
    final used = usage;
    if (used < grace) return false;
    final last = _lastShownAtUsage;
    return last == null || used - last >= interval;
  }

  /// Call when an ad was actually shown.
  void recordShown() => _lastShownAtUsage = usage;
}
