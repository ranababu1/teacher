/// Counts AI requests in flight, app wide. Ads read it so an interstitial
/// never covers the screen while the learner waits for an AI answer.
abstract final class AiActivity {
  static int _inFlight = 0;

  static bool get isBusy => _inFlight > 0;

  /// Runs [request] and counts it as in flight until it completes.
  static Future<T> track<T>(Future<T> Function() request) async {
    _inFlight++;
    try {
      return await request();
    } finally {
      _inFlight--;
    }
  }
}
