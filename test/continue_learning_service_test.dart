import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/curriculum/domain/models/concept.dart';
import 'package:teacher/features/curriculum/domain/models/curriculum_module.dart';
import 'package:teacher/features/curriculum/domain/models/difficulty.dart';
import 'package:teacher/features/curriculum/domain/models/learning_path.dart';
import 'package:teacher/features/dashboard/domain/continue_learning_service.dart';
import 'package:teacher/features/dashboard/domain/models/continue_learning_state.dart';
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
  DateTime? lastAccessedAt,
  DateTime? completedAt,
}) => StudentProgress(
  conceptId: conceptId,
  learningPathId: pathId,
  moduleId: 'mod',
  startedAt: lastAccessedAt,
  completedAt: completedAt,
  lastAccessedAt: lastAccessedAt,
);

void main() {
  final now = DateTime(2026, 8, 16);
  final service = ContinueLearningService();

  test('returns empty when nothing has ever been started', () {
    final state = service.resolve(
      allProgress: const [],
      paths: const [],
      startedPathIds: const {},
    );
    expect(state, const ContinueLearningEmpty());
  });

  test('returns the most recent incomplete concept', () {
    final c1 = _concept('c1');
    final c2 = _concept('c2');
    final path = _path('python', [c1, c2]);

    final state = service.resolve(
      allProgress: [
        _progress('c1', 'python', lastAccessedAt: now.subtract(const Duration(days: 1))),
        _progress('c2', 'python', lastAccessedAt: now),
      ],
      paths: [path],
      startedPathIds: const {},
    );

    expect(state, isA<ContinueLearningConcept>());
    expect((state as ContinueLearningConcept).concept.id, 'c2');
  });

  test('advances to the next incomplete concept when the most recent is completed', () {
    final c1 = _concept('c1');
    final c2 = _concept('c2');
    final c3 = _concept('c3');
    final path = _path('python', [c1, c2, c3]);

    final state = service.resolve(
      allProgress: [
        _progress('c1', 'python', lastAccessedAt: now.subtract(const Duration(days: 1)), completedAt: now.subtract(const Duration(days: 1))),
        _progress('c2', 'python', lastAccessedAt: now, completedAt: now),
      ],
      paths: [path],
      startedPathIds: const {},
    );

    expect(state, isA<ContinueLearningConcept>());
    expect((state as ContinueLearningConcept).concept.id, 'c3');
  });

  test('scans the whole path for a gap left by out-of-order completion', () {
    final c1 = _concept('c1');
    final c2 = _concept('c2');
    final c3 = _concept('c3');
    final path = _path('python', [c1, c2, c3]);

    // c3 was completed most recently, but c2 is still incomplete.
    final state = service.resolve(
      allProgress: [
        _progress('c1', 'python', lastAccessedAt: now.subtract(const Duration(days: 2)), completedAt: now.subtract(const Duration(days: 2))),
        _progress('c2', 'python', lastAccessedAt: now.subtract(const Duration(days: 1))),
        _progress('c3', 'python', lastAccessedAt: now, completedAt: now),
      ],
      paths: [path],
      startedPathIds: const {},
    );

    expect(state, isA<ContinueLearningConcept>());
    expect((state as ContinueLearningConcept).concept.id, 'c2');
  });

  test('returns path-completed when every concept in the path is done', () {
    final c1 = _concept('c1');
    final c2 = _concept('c2');
    final path = _path('python', [c1, c2]);

    final state = service.resolve(
      allProgress: [
        _progress('c1', 'python', lastAccessedAt: now.subtract(const Duration(days: 1)), completedAt: now.subtract(const Duration(days: 1))),
        _progress('c2', 'python', lastAccessedAt: now, completedAt: now),
      ],
      paths: [path],
      startedPathIds: const {},
    );

    expect(state, isA<ContinueLearningPathCompleted>());
    expect((state as ContinueLearningPathCompleted).pathId, 'python');
  });

  test('ignores progress rows whose concept no longer exists', () {
    final state = service.resolve(
      allProgress: [_progress('stale', 'python', lastAccessedAt: now)],
      paths: [_path('python', [_concept('c1')])],
      startedPathIds: const {},
    );

    expect(state, const ContinueLearningEmpty());
  });

  test('resolves to the first concept of a started path when nothing has been attempted yet', () {
    final c1 = _concept('c1');
    final c2 = _concept('c2');
    final path = _path('python', [c1, c2]);

    final state = service.resolve(
      allProgress: const [],
      paths: [path],
      startedPathIds: const {'python'},
    );

    expect(state, isA<ContinueLearningConcept>());
    expect((state as ContinueLearningConcept).concept.id, 'c1');
  });

  test('skips a started path with no concepts in favor of the next started path', () {
    final emptyPath = _path('coming-soon', const []);
    final realPath = _path('python', [_concept('c1')]);

    final state = service.resolve(
      allProgress: const [],
      paths: [emptyPath, realPath],
      startedPathIds: const {'coming-soon', 'python'},
    );

    expect(state, isA<ContinueLearningConcept>());
    expect((state as ContinueLearningConcept).concept.id, 'c1');
  });
}
