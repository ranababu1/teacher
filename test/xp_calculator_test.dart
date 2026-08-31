import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/assessment/domain/models/attempt.dart';
import 'package:teacher/features/curriculum/domain/models/concept.dart';
import 'package:teacher/features/curriculum/domain/models/curriculum_module.dart';
import 'package:teacher/features/curriculum/domain/models/difficulty.dart';
import 'package:teacher/features/curriculum/domain/models/item_type.dart';
import 'package:teacher/features/curriculum/domain/models/learning_path.dart';
import 'package:teacher/features/profile/domain/models/experience_level.dart';
import 'package:teacher/features/profile/domain/xp_calculator.dart';
import 'package:teacher/features/progress/domain/models/student_progress.dart';

Attempt _attempt({
  required int id,
  required String conceptId,
  required String itemId,
  required ItemKind itemKind,
  bool? isCorrect,
  DateTime? createdAt,
}) => Attempt(
  id: id,
  conceptId: conceptId,
  itemId: itemId,
  itemKind: itemKind,
  itemType: ItemType.shortAnswer,
  isCorrect: isCorrect,
  selfRating: null,
  hintsUsed: 0,
  userResponse: null,
  createdAt: createdAt ?? DateTime(2026, 8, 16),
);

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
}) => StudentProgress(
  conceptId: conceptId,
  learningPathId: pathId,
  moduleId: 'mod',
  startedAt: DateTime(2026, 8, 1),
  completedAt: completed ? DateTime(2026, 8, 1) : null,
  lastAccessedAt: DateTime(2026, 8, 1),
);

void main() {
  final calculator = XpCalculator();

  test('a correct exercise attempt awards base + quality bonus XP', () {
    final xp = calculator.calculate(
      attempts: [
        _attempt(
          id: 1,
          conceptId: 'c1',
          itemId: 'e1',
          itemKind: ItemKind.exercise,
          isCorrect: true,
        ),
      ],
      allProgress: const [],
      paths: const [],
    );
    expect(xp, 20 + 25);
  });

  test('an incorrect exercise attempt awards only base XP', () {
    final xp = calculator.calculate(
      attempts: [
        _attempt(
          id: 1,
          conceptId: 'c1',
          itemId: 'e1',
          itemKind: ItemKind.exercise,
          isCorrect: false,
        ),
      ],
      allProgress: const [],
      paths: const [],
    );
    expect(xp, 20);
  });

  test('a correct assessment attempt awards base + quality bonus XP', () {
    final xp = calculator.calculate(
      attempts: [
        _attempt(
          id: 1,
          conceptId: 'c1',
          itemId: 'a1',
          itemKind: ItemKind.assessment,
          isCorrect: true,
        ),
      ],
      allProgress: const [],
      paths: const [],
    );
    expect(xp, 40 + 50);
  });

  test('repeated attempts on the same item award XP only once', () {
    final xp = calculator.calculate(
      attempts: [
        _attempt(
          id: 1,
          conceptId: 'c1',
          itemId: 'e1',
          itemKind: ItemKind.exercise,
          isCorrect: false,
          createdAt: DateTime(2026, 8, 1),
        ),
        _attempt(
          id: 2,
          conceptId: 'c1',
          itemId: 'e1',
          itemKind: ItemKind.exercise,
          isCorrect: true,
          createdAt: DateTime(2026, 8, 2),
        ),
      ],
      allProgress: const [],
      paths: const [],
    );
    // Only the first (chronologically) attempt counts — the incorrect one.
    expect(xp, 20);
  });

  test('a different item on the same concept still awards its own XP', () {
    final xp = calculator.calculate(
      attempts: [
        _attempt(
          id: 1,
          conceptId: 'c1',
          itemId: 'e1',
          itemKind: ItemKind.exercise,
          isCorrect: true,
        ),
        _attempt(
          id: 2,
          conceptId: 'c1',
          itemId: 'e2',
          itemKind: ItemKind.exercise,
          isCorrect: true,
        ),
      ],
      allProgress: const [],
      paths: const [],
    );
    expect(xp, (20 + 25) * 2);
  });

  test('a completed concept ("lesson") adds a flat bonus', () {
    final xp = calculator.calculate(
      attempts: const [],
      allProgress: [_progress('c1', 'python', completed: true)],
      paths: const [],
    );
    expect(xp, 250);
  });

  test('a completed module ("topic") adds a bonus once every concept in it is done', () {
    final c1 = _concept('c1');
    final c2 = _concept('c2');
    final path = _path('python', [c1, c2]);

    final partial = calculator.calculate(
      attempts: const [],
      allProgress: [_progress('c1', 'python', completed: true)],
      paths: [path],
    );
    expect(partial, 250); // only the concept bonus — module isn't done yet

    final full = calculator.calculate(
      attempts: const [],
      allProgress: [
        _progress('c1', 'python', completed: true),
        _progress('c2', 'python', completed: true),
      ],
      paths: [path],
    );
    // Both concepts done also completes the module AND the course (this
    // path has exactly one module), so all three tiers stack.
    expect(full, 250 * 2 + 400 + 2000);
  });

  test('passed module tests ("quizzes") each award a flat bonus', () {
    final xp = calculator.calculate(
      attempts: const [],
      allProgress: const [],
      paths: const [],
      passedModuleTestCount: 3,
    );
    expect(xp, 600 * 3);
  });

  test('app-open days each award a flat bonus', () {
    final xp = calculator.calculate(
      attempts: const [],
      allProgress: const [],
      paths: const [],
      appOpenDays: 4,
    );
    expect(xp, 25 * 4);
  });

  group('ExperienceLevel.forXp', () {
    test('boundaries map to the right tier', () {
      expect(ExperienceLevel.forXp(0), ExperienceLevel.newDeveloper);
      expect(ExperienceLevel.forXp(1999), ExperienceLevel.newDeveloper);
      expect(ExperienceLevel.forXp(2000), ExperienceLevel.beginnerDeveloper);
      expect(ExperienceLevel.forXp(7999), ExperienceLevel.beginnerDeveloper);
      expect(ExperienceLevel.forXp(8000), ExperienceLevel.juniorDeveloper);
      expect(ExperienceLevel.forXp(23999), ExperienceLevel.juniorDeveloper);
      expect(
        ExperienceLevel.forXp(24000),
        ExperienceLevel.intermediateDeveloper,
      );
      expect(
        ExperienceLevel.forXp(59999),
        ExperienceLevel.intermediateDeveloper,
      );
      expect(ExperienceLevel.forXp(60000), ExperienceLevel.advancedDeveloper);
    });
  });
}
