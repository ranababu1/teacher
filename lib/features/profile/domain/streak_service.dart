/// Truncates a timestamp to its local calendar day — the unit every
/// streak calculation in this file works in.
DateTime dayOf(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// Computes learning streaks from a set of active calendar days. See
/// instructions.md section 45.
class StreakService {
  /// The streak ending today, or yesterday if the learner hasn't opened
  /// the app yet today — missing only *today* doesn't break a streak,
  /// only a full missed day does.
  int currentStreak({required Set<DateTime> activeDays, DateTime? now}) {
    final today = dayOf(now ?? DateTime.now());
    var cursor = activeDays.contains(today)
        ? today
        : today.subtract(const Duration(days: 1));

    var streak = 0;
    while (activeDays.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// The longest run of consecutive active days anywhere in history — used
  /// for streak badges so they don't disappear the day after a streak
  /// breaks (unlike [currentStreak], which resets to 0).
  int longestStreak({required Set<DateTime> activeDays}) {
    if (activeDays.isEmpty) return 0;

    final sorted = activeDays.toList()..sort();
    var longest = 1;
    var current = 1;
    for (var i = 1; i < sorted.length; i++) {
      final gap = sorted[i].difference(sorted[i - 1]).inDays;
      current = gap == 1 ? current + 1 : 1;
      if (current > longest) longest = current;
    }
    return longest;
  }
}
