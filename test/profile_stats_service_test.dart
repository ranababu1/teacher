import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/assessment/domain/models/attempt.dart';
import 'package:teacher/features/curriculum/domain/models/concept.dart';
import 'package:teacher/features/curriculum/domain/models/curriculum_module.dart';
import 'package:teacher/features/curriculum/domain/models/difficulty.dart';
import 'package:teacher/features/curriculum/domain/models/item_type.dart';
import 'package:teacher/features/curriculum/domain/models/learning_path.dart';
import 'package:teacher/features/profile/domain/models/badge.dart';
import 'package:teacher/features/profile/domain/profile_stats_service.dart';
import 'package:teacher/features/progress/domain/models/student_progress.dart';

Concept _concept(String id) => Concept(
  id: id,
  title: 'Title $id',
  description: 'desc',
  learningPathId: 'python',
  moduleId: 'mod',
  topicId: 'mod',
  difficulty: Difficulty.beginner,
  estimatedMinutes: 10,
  prerequisites: const [],
  learningObjectives: const [],
  explanation: const ConceptExplanation(sections: []),
  examples: const [],
  misconceptions: const [],
  exercises: const [],
  assessments: const [],
);

LearningPath _path(String id, List<Concept> concepts) => LearningPath(
  id: id,
  title: 'Path $id',
  description: 'desc',
  difficulty: Difficulty.beginner,
  iconName: 'python',
  estimatedHours: 5,
  modules: [
    CurriculumModule(
      learningPathId: id,
      id: 'mod',
      title: 'Module',
      order: 0,
      concepts: concepts,
    ),
  ],
);

StudentProgress _progress(
  String conceptId,
  String pathId, {
  bool completed = false,
  DateTime? lastAccessedAt,
}) => StudentProgress(
  conceptId: conceptId,
  learningPathId: pathId,
  moduleId: 'mod',
  startedAt: lastAccessedAt,
  completedAt: completed ? lastAccessedAt : null,
  lastAccessedAt: lastAccessedAt,
);

Attempt _attempt({
  required int id,
  required String conceptId,
  required String itemId,
  required ItemKind itemKind,
  ItemType itemType = ItemType.shortAnswer,
  DateTime? createdAt,
}) => Attempt(
  id: id,
  conceptId: conceptId,
  itemId: itemId,
  itemKind: itemKind,
  itemType: itemType,
  isCorrect: true,
  selfRating: null,
  hintsUsed: 0,
  userResponse: null,
  createdAt: createdAt ?? DateTime(2026, 8, 16),
);

void main() {
  final service = ProfileStatsService();
  final today = DateTime(2026, 8, 16);

  test('counts courses, lessons, practice, and coding challenges correctly', () {
    final c1 = _concept('c1');
    final c2 = _concept('c2');
    final path = _path('python', [c1, c2]);

    final stats = service.compute(
      paths: [path],
      allProgress: [
        _progress('c1', 'python', completed: true, lastAccessedAt: DateTime(2026, 8, 16)),
        _progress('c2', 'python', completed: true, lastAccessedAt: DateTime(2026, 8, 16)),
      ],
      allAttempts: [
        _attempt(id: 1, conceptId: 'c1', itemId: 'e1', itemKind: ItemKind.exercise),
        _attempt(
          id: 2,
          conceptId: 'c1',
          itemId: 'e2',
          itemKind: ItemKind.exercise,
          itemType: ItemType.coding,
        ),
        _attempt(
          id: 3,
          conceptId: 'c2',
          itemId: 'a1',
          itemKind: ItemKind.assessment,
          itemType: ItemType.coding,
        ),
      ],
      now: today,
    );

    expect(stats.coursesCompleted, 1);
    expect(stats.lessonsCompleted, 2);
    expect(stats.practiceQuestionsAttempted, 2); // both exercise attempts
    expect(stats.codingChallengesAttempted, 2); // one exercise + one assessment, both ItemType.coding
    expect(stats.badges.map((b) => b.id), contains(BadgeId.firstCourse));
  });

  test('badges reflect longest streak, not current streak', () {
    final stats = service.compute(
      paths: const [],
      allProgress: [
        // A 7-day active run that ended 10 days ago — current streak is
        // now 0, but the badge should still be unlocked.
        for (var i = 10; i < 17; i++)
          _progress('c$i', 'python', lastAccessedAt: today.subtract(Duration(days: i))),
      ],
      allAttempts: const [],
      now: today,
    );

    expect(stats.currentStreak, 0);
    expect(stats.badges.map((b) => b.id), contains(BadgeId.sevenDayStreak));
  });

  test('no activity means no badges and zero stats', () {
    final stats = service.compute(
      paths: const [],
      allProgress: const [],
      allAttempts: const [],
      now: today,
    );
    expect(stats.badges, isEmpty);
    expect(stats.totalXp, 0);
    expect(stats.currentStreak, 0);
  });
}
