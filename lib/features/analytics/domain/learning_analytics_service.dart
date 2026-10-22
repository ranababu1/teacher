import '../../assessment/domain/attempt_quality.dart';
import '../../assessment/domain/models/attempt.dart';
import '../../curriculum/domain/models/learning_path.dart';
import 'models/learning_analytics.dart';

/// Turns raw attempt history into [LearningAnalytics]. Pure and
/// synchronous so it is cheap to test; "success" uses the same bar as the
/// Progress screen's accuracy (attempt quality >= 0.6).
class LearningAnalyticsService {
  const LearningAnalyticsService();

  static const _successThreshold = 0.6;
  static const _minAttemptsForWeakConcept = 2;
  static const _maxWeakConcepts = 5;

  LearningAnalytics compute({
    required List<Attempt> attempts,
    required List<LearningPath> paths,
    required DateTime now,
  }) {
    bool success(Attempt a) => qualityOf(a) >= _successThreshold;
    final today = DateTime(now.year, now.month, now.day);
    DateTime dayOf(DateTime t) {
      final local = t.toLocal();
      return DateTime(local.year, local.month, local.day);
    }

    // Daily, last 28 days.
    final days = [
      for (var i = 27; i >= 0; i--)
        DateTime(today.year, today.month, today.day - i),
    ];
    final byDay = <DateTime, List<Attempt>>{};
    for (final a in attempts) {
      byDay.putIfAbsent(dayOf(a.createdAt), () => []).add(a);
    }
    final last28 = [
      for (final d in days)
        DailyActivity(
          day: d,
          attempts: byDay[d]?.length ?? 0,
          successes: byDay[d]?.where(success).length ?? 0,
        ),
    ];

    // Weekly accuracy: four 7-day windows ending today.
    final weekly = [
      for (var w = 3; w >= 0; w--)
        () {
          final window = last28.sublist((3 - w) * 7, (3 - w) * 7 + 7);
          final n = window.fold(0, (s, d) => s + d.attempts);
          final ok = window.fold(0, (s, d) => s + d.successes);
          return WeeklyAccuracy(
            weekStart: window.first.day,
            attempts: n,
            accuracy: n == 0 ? null : ok / n,
          );
        }(),
    ];

    // Concept lookup for course and weak-concept breakdowns.
    final conceptInfo =
        <String, ({LearningPath path, String moduleId, String title})>{};
    for (final p in paths) {
      for (final m in p.modules) {
        for (final c in m.concepts) {
          conceptInfo[c.id] = (path: p, moduleId: m.id, title: c.title);
        }
      }
    }

    final byCourse = <String, List<Attempt>>{};
    final byConcept = <String, List<Attempt>>{};
    for (final a in attempts) {
      final info = conceptInfo[a.conceptId];
      if (info == null) continue;
      byCourse.putIfAbsent(info.path.id, () => []).add(a);
      byConcept.putIfAbsent(a.conceptId, () => []).add(a);
    }
    final courses = [
      for (final e in byCourse.entries)
        CourseAccuracy(
          learningPathId: e.key,
          title: paths.firstWhere((p) => p.id == e.key).title,
          attempts: e.value.length,
          accuracy: e.value.where(success).length / e.value.length,
        ),
    ]..sort((a, b) => b.attempts.compareTo(a.attempts));

    final weak =
        [
          for (final e in byConcept.entries)
            if (e.value.length >= _minAttemptsForWeakConcept)
              WeakConcept(
                conceptId: e.key,
                title: conceptInfo[e.key]!.title,
                learningPathId: conceptInfo[e.key]!.path.id,
                moduleId: conceptInfo[e.key]!.moduleId,
                attempts: e.value.length,
                accuracy: e.value.where(success).length / e.value.length,
              ),
        ].where((w) => w.accuracy < 1).toList()..sort((a, b) {
          final byAccuracy = a.accuracy.compareTo(b.accuracy);
          return byAccuracy != 0
              ? byAccuracy
              : b.attempts.compareTo(a.attempts);
        });

    final dayParts = {for (final p in DayPart.values) p: 0};
    for (final a in attempts) {
      final part = DayPart.of(a.createdAt.toLocal());
      dayParts[part] = dayParts[part]! + 1;
    }

    return LearningAnalytics(
      totalAttempts: attempts.length,
      last28Days: last28,
      weekly: weekly,
      courses: courses,
      weakConcepts: weak.take(_maxWeakConcepts).toList(),
      attemptsByDayPart: dayParts,
    );
  }
}
