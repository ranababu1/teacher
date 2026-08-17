import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/core/errors/app_exception.dart';
import 'package:teacher/features/ai_teacher/domain/ai_provider.dart';
import 'package:teacher/features/ai_teacher/domain/generate_module_test_use_case.dart';
import 'package:teacher/features/ai_teacher/domain/misconception_repository.dart';
import 'package:teacher/features/ai_teacher/domain/models/detected_misconception.dart';
import 'package:teacher/features/ai_teacher/domain/models/module_test_context.dart';
import 'package:teacher/features/ai_teacher/domain/models/teacher_response.dart';
import 'package:teacher/features/ai_teacher/domain/teaching_context_builder.dart';
import 'package:teacher/features/curriculum/domain/curriculum_repository.dart';
import 'package:teacher/features/curriculum/domain/models/assessment.dart';
import 'package:teacher/features/curriculum/domain/models/concept.dart';
import 'package:teacher/features/curriculum/domain/models/curriculum_module.dart';
import 'package:teacher/features/curriculum/domain/models/difficulty.dart';
import 'package:teacher/features/curriculum/domain/models/exercise.dart';
import 'package:teacher/features/curriculum/domain/models/item_type.dart';
import 'package:teacher/features/curriculum/domain/models/learning_path.dart';
import 'package:teacher/features/progress/domain/concept_mastery_repository.dart';
import 'package:teacher/features/progress/domain/models/concept_mastery.dart';

Concept _buildConcept(String id) {
  return Concept(
    id: id,
    title: id,
    description: 'desc',
    learningPathId: 'python',
    moduleId: 'basics',
    topicId: 'basics',
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
}

LearningPath _buildPath() {
  final module = CurriculumModule(
    learningPathId: 'python',
    id: 'basics',
    title: 'Python Basics',
    order: 1,
    concepts: [_buildConcept('concept-1'), _buildConcept('concept-2')],
  );
  return LearningPath(
    id: 'python',
    title: 'Python',
    description: 'desc',
    difficulty: Difficulty.beginner,
    iconName: 'python',
    estimatedHours: 10,
    modules: [module],
  );
}

class _FakeCurriculumRepository implements CurriculumRepository {
  _FakeCurriculumRepository(this.path);

  final LearningPath? path;

  @override
  Future<LearningPath?> getLearningPath(String learningPathId) async => path;

  @override
  Future<List<LearningPath>> getLearningPaths() async =>
      path == null ? const [] : [path!];

  @override
  Future<Concept?> getConcept(String conceptId) async {
    if (path == null) return null;
    return path!.findConcept(conceptId);
  }

  @override
  Future<List<Concept>> getPrerequisiteConcepts(String conceptId) async =>
      const [];
}

class _FakeMasteryRepository implements ConceptMasteryRepository {
  @override
  Future<ConceptMastery> getMastery(String conceptId) async =>
      ConceptMastery.empty(conceptId);

  @override
  Future<List<ConceptMastery>> getAllMastery() async => const [];

  @override
  Future<void> saveMastery(ConceptMastery mastery) async {}
}

class _FakeMisconceptionRepository implements MisconceptionRepository {
  @override
  Future<List<DetectedMisconception>> getUnresolvedForConcept(
    String conceptId,
  ) async => const [];

  @override
  Future<DetectedMisconception> recordMisconception({
    required String conceptId,
    required String description,
    double confidence = 1.0,
  }) => throw UnimplementedError();

  @override
  Future<void> resolveMisconception(int id) async {}
}

class _FakeAIProvider implements AIProvider {
  List<Assessment> questionsToReturn = const [];
  ModuleTestRequest? lastRequest;

  @override
  Future<List<Assessment>> generateModuleTest(ModuleTestRequest request) async {
    lastRequest = request;
    return questionsToReturn;
  }

  @override
  Future<TeacherResponse> teach(TeacherRequest request) => throw UnimplementedError();

  @override
  Future<AssessmentResult> assess(AssessmentRequest request) => throw UnimplementedError();

  @override
  Future<Exercise> generateExercise(ExerciseRequest request) => throw UnimplementedError();

  @override
  Future<ExplanationEvaluation> evaluateExplanation(ExplanationRequest request) =>
      throw UnimplementedError();

  @override
  Future<void> testConnection() => throw UnimplementedError();
}

Assessment _mcq(String id, {int correctOptionIndex = 0, List<String>? options}) {
  return Assessment(
    id: id,
    type: ItemType.multipleChoice,
    prompt: 'prompt-$id',
    options: options ?? const ['A', 'B'],
    correctOptionIndex: correctOptionIndex,
  );
}

void main() {
  late _FakeAIProvider aiProvider;
  late GenerateModuleTestUseCase useCase;

  setUp(() {
    aiProvider = _FakeAIProvider();
    useCase = GenerateModuleTestUseCase(
      curriculumRepository: _FakeCurriculumRepository(_buildPath()),
      contextBuilder: TeachingContextBuilder(
        curriculumRepository: _FakeCurriculumRepository(_buildPath()),
        masteryRepository: _FakeMasteryRepository(),
        misconceptionRepository: _FakeMisconceptionRepository(),
      ),
      aiProvider: aiProvider,
      questionCount: 2,
    );
  });

  test('builds a ModuleTestContext with one TeachingContext per concept in the module', () async {
    aiProvider.questionsToReturn = [_mcq('q1'), _mcq('q2')];

    await useCase.call(learningPathId: 'python', moduleId: 'basics');

    final context = aiProvider.lastRequest!.context as ModuleTestContext;
    expect(context.learningPathId, 'python');
    expect(context.moduleId, 'basics');
    expect(context.moduleTitle, 'Python Basics');
    expect(context.conceptContexts, hasLength(2));
    expect(context.conceptContexts.map((c) => c.concept.id), [
      'concept-1',
      'concept-2',
    ]);
  });

  test('returns well-formed multiple-choice questions as-is', () async {
    aiProvider.questionsToReturn = [
      _mcq('q1', correctOptionIndex: 1, options: ['A', 'B', 'C']),
    ];

    final result = await useCase.call(learningPathId: 'python', moduleId: 'basics');

    expect(result, hasLength(1));
    expect(result.first.id, 'q1');
  });

  test('drops a question with an out-of-range correctOptionIndex', () async {
    aiProvider.questionsToReturn = [
      _mcq('good'),
      _mcq('bad-index', correctOptionIndex: 5, options: ['A', 'B']),
    ];

    final result = await useCase.call(learningPathId: 'python', moduleId: 'basics');

    expect(result.map((a) => a.id), ['good']);
  });

  test('drops a question that is not multipleChoice', () async {
    aiProvider.questionsToReturn = [
      _mcq('good'),
      const Assessment(id: 'not-mcq', type: ItemType.shortAnswer, prompt: 'p'),
    ];

    final result = await useCase.call(learningPathId: 'python', moduleId: 'basics');

    expect(result.map((a) => a.id), ['good']);
  });

  test('uses the per-call questionCount override instead of the constructor default', () async {
    aiProvider.questionsToReturn = [_mcq('q1')];

    await useCase.call(
      learningPathId: 'python',
      moduleId: 'basics',
      questionCount: 20,
    );

    expect(aiProvider.lastRequest!.questionCount, 20);
  });

  test('throws ContentNotFoundException for an unknown learning path', () async {
    final missingPathUseCase = GenerateModuleTestUseCase(
      curriculumRepository: _FakeCurriculumRepository(null),
      contextBuilder: TeachingContextBuilder(
        curriculumRepository: _FakeCurriculumRepository(null),
        masteryRepository: _FakeMasteryRepository(),
        misconceptionRepository: _FakeMisconceptionRepository(),
      ),
      aiProvider: aiProvider,
    );

    await expectLater(
      missingPathUseCase.call(learningPathId: 'nope', moduleId: 'basics'),
      throwsA(isA<ContentNotFoundException>()),
    );
  });

  test('throws ContentNotFoundException for an unknown module', () async {
    await expectLater(
      useCase.call(learningPathId: 'python', moduleId: 'nope'),
      throwsA(isA<ContentNotFoundException>()),
    );
  });
}
