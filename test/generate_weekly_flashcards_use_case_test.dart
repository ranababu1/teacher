import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/curriculum/domain/curriculum_repository.dart';
import 'package:teacher/features/curriculum/domain/models/concept.dart';
import 'package:teacher/features/curriculum/domain/models/difficulty.dart';
import 'package:teacher/features/curriculum/domain/models/learning_path.dart';
import 'package:teacher/features/flashcards/domain/generate_weekly_flashcards_use_case.dart';
import 'package:teacher/features/progress/domain/models/student_progress.dart';
import 'package:teacher/features/progress/domain/student_progress_repository.dart';

Concept _buildConcept({
  required String id,
  List<Misconception> misconceptions = const [],
  List<ExplanationSection> sections = const [],
}) => Concept(
  id: id,
  title: 'Title for $id',
  description: 'desc',
  learningPathId: 'python',
  moduleId: 'mod',
  topicId: 'mod',
  difficulty: Difficulty.beginner,
  estimatedMinutes: 10,
  prerequisites: const [],
  learningObjectives: const [],
  explanation: ConceptExplanation(sections: sections),
  examples: const [],
  misconceptions: misconceptions,
  exercises: const [],
  assessments: const [],
);

StudentProgress _buildProgress(String conceptId, DateTime? lastAccessedAt) =>
    StudentProgress(
      conceptId: conceptId,
      learningPathId: 'python',
      moduleId: 'mod',
      startedAt: lastAccessedAt,
      completedAt: null,
      lastAccessedAt: lastAccessedAt,
    );

class _FakeProgressRepository implements StudentProgressRepository {
  _FakeProgressRepository(this.progress);

  final List<StudentProgress> progress;

  @override
  Future<List<StudentProgress>> getAllProgress() async => progress;

  @override
  Future<StudentProgress?> getProgress(String conceptId) async => null;

  @override
  Future<void> markStarted({
    required String conceptId,
    required String learningPathId,
    required String moduleId,
  }) async {}

  @override
  Future<void> markCompleted(String conceptId) async {}
}

class _FakeCurriculumRepository implements CurriculumRepository {
  _FakeCurriculumRepository(this.concepts);

  final Map<String, Concept> concepts;

  @override
  Future<Concept?> getConcept(String conceptId) async => concepts[conceptId];

  @override
  Future<List<Concept>> getPrerequisiteConcepts(String conceptId) async =>
      const [];

  @override
  Future<List<LearningPath>> getLearningPaths() async => const [];

  @override
  Future<LearningPath?> getLearningPath(String learningPathId) async => null;
}

void main() {
  final now = DateTime(2026, 8, 15);

  test('builds a card from a recently-studied concept\'s misconception', () async {
    final concept = _buildConcept(
      id: 'c1',
      misconceptions: [
        const Misconception(
          description: 'Closures copy the variable value.',
          clarification: 'They capture the variable by reference.',
        ),
      ],
    );
    final useCase = GenerateWeeklyFlashcardsUseCase(
      progressRepository: _FakeProgressRepository([
        _buildProgress('c1', now.subtract(const Duration(days: 2))),
      ]),
      curriculumRepository: _FakeCurriculumRepository({'c1': concept}),
    );

    final cards = await useCase.call(now: now);

    expect(cards, hasLength(1));
    expect(cards.single.conceptId, 'c1');
    expect(cards.single.front, contains('Closures copy the variable value.'));
    expect(cards.single.back, 'They capture the variable by reference.');
  });

  test('adds an explanation-section card when room remains', () async {
    final concept = _buildConcept(
      id: 'c1',
      sections: [
        const ExplanationSection(heading: 'Why it matters', body: 'Because.'),
      ],
    );
    final useCase = GenerateWeeklyFlashcardsUseCase(
      progressRepository: _FakeProgressRepository([
        _buildProgress('c1', now.subtract(const Duration(days: 1))),
      ]),
      curriculumRepository: _FakeCurriculumRepository({'c1': concept}),
    );

    final cards = await useCase.call(now: now);

    expect(cards, hasLength(1));
    expect(cards.single.front, contains('Why it matters'));
    expect(cards.single.back, 'Because.');
  });

  test('ignores concepts not accessed within the last 7 days', () async {
    final concept = _buildConcept(
      id: 'stale',
      sections: [const ExplanationSection(heading: 'H', body: 'B')],
    );
    final useCase = GenerateWeeklyFlashcardsUseCase(
      progressRepository: _FakeProgressRepository([
        _buildProgress('stale', now.subtract(const Duration(days: 10))),
      ]),
      curriculumRepository: _FakeCurriculumRepository({'stale': concept}),
    );

    final cards = await useCase.call(now: now);

    expect(cards, isEmpty);
  });

  test('ignores concepts that have never been opened', () async {
    final concept = _buildConcept(id: 'never');
    final useCase = GenerateWeeklyFlashcardsUseCase(
      progressRepository: _FakeProgressRepository([
        _buildProgress('never', null),
      ]),
      curriculumRepository: _FakeCurriculumRepository({'never': concept}),
    );

    final cards = await useCase.call(now: now);

    expect(cards, isEmpty);
  });

  test('caps the number of cards per concept', () async {
    final concept = _buildConcept(
      id: 'busy',
      misconceptions: List.generate(
        5,
        (i) => Misconception(description: 'M$i', clarification: 'C$i'),
      ),
    );
    final useCase = GenerateWeeklyFlashcardsUseCase(
      progressRepository: _FakeProgressRepository([
        _buildProgress('busy', now.subtract(const Duration(hours: 1))),
      ]),
      curriculumRepository: _FakeCurriculumRepository({'busy': concept}),
    );

    final cards = await useCase.call(now: now);

    expect(cards, hasLength(3));
  });

  test('skips a recently-accessed concept that no longer exists', () async {
    final useCase = GenerateWeeklyFlashcardsUseCase(
      progressRepository: _FakeProgressRepository([
        _buildProgress('missing', now.subtract(const Duration(hours: 1))),
      ]),
      curriculumRepository: _FakeCurriculumRepository(const {}),
    );

    final cards = await useCase.call(now: now);

    expect(cards, isEmpty);
  });
}
