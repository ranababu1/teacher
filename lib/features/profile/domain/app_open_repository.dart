abstract class AppOpenRepository {
  /// Number of distinct calendar days the app has ever been opened on —
  /// feeds the "opening the app earns XP" bonus, once per day.
  Future<int> getOpenDayCount();

  /// Records today as an open day. Idempotent within the same calendar
  /// day, so calling this on every app start never double-counts. Returns
  /// whether today was newly recorded (`false` if it already was).
  Future<bool> recordOpenToday();
}
