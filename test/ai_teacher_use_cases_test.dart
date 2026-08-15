import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/core/errors/app_exception.dart';
import 'package:teacher/features/ai_teacher/domain/ai_provider.dart';
import 'package:teacher/features/ai_teacher/domain/assess_use_case.dart';
import 'package:teacher/features/ai_teacher/domain/evaluate_explanation_use_case.dart';
import 'package:teacher/features/ai_teacher/domain/generate_exercise_use_case.dart';
import 'package:teacher/features/ai_teacher/domain/misconception_repository.dart';
import 'package:teacher/features/ai_teacher/domain/models/detected_misconception.dart';
import 'package:teacher/features/ai_teacher/domain/models/teacher_response.dart';
import 'package:teacher/features/ai_teacher/domain/models/teaching_context.dart';
import 'package:teacher/features/ai_teacher/domain/teach_use_case.dart';
import 'package:teacher/features/ai_teacher/domain/teaching_context_builder.dart';
import 'package:teacher/features/curriculum/domain/curriculum_repository.dart';
import 'package:teacher/features/curriculum/domain/models/concept.dart';
import 'package:teacher/features/curriculum/domain/models/difficulty.dart';
import 'package:teacher/features/curriculum/domain/models/exercise.dart';
import 'package:teacher/features/curriculum/domain/models/item_type.dart';
import 'package:teacher/features/curriculum/domain/models/learning_path.dart';
import 'package:teacher/features/progress/domain/concept_mastery_repository.dart';
import 'package:teacher/features/progress/domain/models/concept_mastery.dart';
import 'package:teacher/features/progress/domain/models/mastery_status.dart';

Concept _buildConcept() => const Concept(
  id: 'python-closures',
  title: 'Closures',
  description: 'Functions that capture variables from an enclosing scope.',
  learningPathId: 'python',
  moduleId: 'functions',
  topicId: 'functions',
  difficulty: Difficulty.intermediate,
  estimatedMinutes: 15,
  prerequisites: [],
  learningObjectives: [],
  explanation: ConceptExplanation(sections: []),
  examples: [],
  misconceptions: [],
  exercises: [],
  assessments: [],
);

ConceptMastery _buildMastery(MasteryStatus status) => ConceptMastery(
  conceptId: 'python-closures',
  recallScore: 0.4,
  understandingScore: 0.4,
  applicationScore: 0.4,
  explanationScore: 0.4,
  codingScore: 0.4,
  debuggingScore: 0.4,
  overallMastery: 0.4,
  attemptCount: 3,
  successCount: 2,
  failureCount: 1,
  confidence: 0.5,
  lastReviewedAt: null,
  nextReviewAt: null,
  status: status,
);

class _FakeCurriculumRepository implements CurriculumRepository {
  _FakeCurriculumRepository({this.concept});

  Concept? concept;

  @override
  Future<Concept?> getConcept(String conceptId) async => concept;

  @override
  Future<List<Concept>> getPrerequisiteConcepts(String conceptId) async =>
      const [];

  @override
  Future<List<LearningPath>> getLearningPaths() async => const [];

  @override
  Future<LearningPath?> getLearningPath(String learningPathId) async => null;
}

class _FakeMasteryRepository implements ConceptMasteryRepository {
  _FakeMasteryRepository(this.mastery);

  final ConceptMastery mastery;

  @override
  Future<ConceptMastery> getMastery(String conceptId) async => mastery;

  @override
  Future<List<ConceptMastery>> getAllMastery() async => [mastery];

  @override
  Future<void> saveMastery(ConceptMastery mastery) async {}
}

class _FakeMisconceptionRepository implements MisconceptionRepository {
  _FakeMisconceptionRepository({this.unresolved = const []});

  final List<DetectedMisconception> unresolved;
  final List<String> recordedDescriptions = [];

  @override
  Future<List<DetectedMisconception>> getUnresolvedForConcept(
    String conceptId,
  ) async => unresolved;

  @override
  Future<DetectedMisconception> recordMisconception({
    required String conceptId,
    required String description,
    double confidence = 1.0,
  }) async {
    recordedDescriptions.add(description);
    return DetectedMisconception(
      id: recordedDescriptions.length,
      conceptId: conceptId,
      description: description,
      detectedAt: DateTime(2026, 8, 15),
      confidence: confidence,
    );
  }

  @override
  Future<void> resolveMisconception(int id) async {}
}

class _FakeAIProvider implements AIProvider {
  TeacherRequest? lastTeachRequest;
  AssessmentRequest? lastAssessRequest;
  ExplanationRequest? lastExplanationRequest;

  TeacherResponse teachResponse = const TeacherResponse(explanation: 'ok');
  AssessmentResult assessResult = const AssessmentResult(
    isCorrect: true,
    feedback: 'good',
    detectedMisconceptions: [],
  );
  ExplanationEvaluation explanationResult = const ExplanationEvaluation(
    isCorrect: true,
    isComplete: true,
    feedback: 'good',
    detectedMisconceptions: [],
  );
  ExerciseRequest? lastExerciseRequest;
  Exercise generatedExercise = const Exercise(
    id: 'generated-1',
    type: ItemType.shortAnswer,
    prompt: 'Generated prompt',
    hints: [],
  );

  @override
  Future<TeacherResponse> teach(TeacherRequest request) async {
    lastTeachRequest = request;
    return teachResponse;
  }

  @override
  Future<AssessmentResult> assess(AssessmentRequest request) async {
    lastAssessRequest = request;
    return assessResult;
  }

  @override
  Future<Exercise> generateExercise(ExerciseRequest request) async {
    lastExerciseRequest = request;
    return generatedExercise;
  }

  @override
  Future<ExplanationEvaluation> evaluateExplanation(
    ExplanationRequest request,
  ) async {
    lastExplanationRequest = request;
    return explanationResult;
  }
}

void main() {
  late _FakeCurriculumRepository curriculumRepository;
  late _FakeMasteryRepository masteryRepository;
  late _FakeMisconceptionRepository misconceptionRepository;
  late _FakeAIProvider aiProvider;
  late TeachingContextBuilder contextBuilder;

  setUp(() {
    curriculumRepository = _FakeCurriculumRepository(concept: _buildConcept());
    masteryRepository = _FakeMasteryRepository(
      _buildMastery(MasteryStatus.developing),
    );
    misconceptionRepository = _FakeMisconceptionRepository(
      unresolved: [
        DetectedMisconception(
          id: 1,
          conceptId: 'python-closures',
          description: 'Thinks closures copy by value',
          detectedAt: DateTime(2026, 8, 1),
          confidence: 1,
        ),
      ],
    );
    aiProvider = _FakeAIProvider();
    contextBuilder = TeachingContextBuilder(
      curriculumRepository: curriculumRepository,
      masteryRepository: masteryRepository,
      misconceptionRepository: misconceptionRepository,
    );
  });

  group('TeachingContextBuilder', () {
    test('assembles context from concept, mastery, and unresolved misconceptions', () async {
      final context = await contextBuilder.build('python-closures');

      expect(context.concept.id, 'python-closures');
      expect(context.mastery.status, MasteryStatus.developing);
      expect(
        context.recentMisconceptions,
        contains('Thinks closures copy by value'),
      );
      expect(context.currentDifficultyLevel, 3); // developing -> 3
    });

    test('throws ContentNotFoundException when the concept does not exist', () {
      curriculumRepository.concept = null;
      expect(
        () => contextBuilder.build('missing'),
        throwsA(isA<ContentNotFoundException>()),
      );
    });
  });

  group('TeachUseCase', () {
    test('passes an assembled context and the learner message to AIProvider.teach', () async {
      final useCase = TeachUseCase(
        contextBuilder: contextBuilder,
        aiProvider: aiProvider,
      );

      final response = await useCase.call(
        conceptId: 'python-closures',
        learnerMessage: 'Why does this keep state?',
      );

      expect(response.explanation, 'ok');
      expect(aiProvider.lastTeachRequest?.learnerMessage, 'Why does this keep state?');
      final context = aiProvider.lastTeachRequest?.context;
      expect(context, isA<TeachingContext>());
      expect((context as TeachingContext).concept.id, 'python-closures');
    });
  });

  group('AssessUseCase', () {
    test('returns the AI verdict and persists every detected misconception', () async {
      aiProvider.assessResult = const AssessmentResult(
        isCorrect: false,
        feedback: 'Not quite — closures capture the variable, not its value.',
        detectedMisconceptions: ['Believes closures copy by value'],
      );
      final useCase = AssessUseCase(
        contextBuilder: contextBuilder,
        misconceptionRepository: misconceptionRepository,
        aiProvider: aiProvider,
      );

      final result = await useCase.call(
        conceptId: 'python-closures',
        learnerResponse: 'It copies the value.',
      );

      expect(result.isCorrect, isFalse);
      expect(aiProvider.lastAssessRequest?.learnerResponse, 'It copies the value.');
      expect(
        misconceptionRepository.recordedDescriptions,
        ['Believes closures copy by value'],
      );
    });

    test('persists nothing when the AI detects no misconceptions', () async {
      final useCase = AssessUseCase(
        contextBuilder: contextBuilder,
        misconceptionRepository: misconceptionRepository,
        aiProvider: aiProvider,
      );

      await useCase.call(
        conceptId: 'python-closures',
        learnerResponse: 'A closure captures its enclosing scope.',
      );

      expect(misconceptionRepository.recordedDescriptions, isEmpty);
    });
  });

  group('EvaluateExplanationUseCase', () {
    test('returns the AI verdict and persists detected misconceptions', () async {
      aiProvider.explanationResult = const ExplanationEvaluation(
        isCorrect: true,
        isComplete: false,
        feedback: 'Correct so far, but you left out how it terminates.',
        detectedMisconceptions: ['Assumes static always means final'],
      );
      final useCase = EvaluateExplanationUseCase(
        contextBuilder: contextBuilder,
        misconceptionRepository: misconceptionRepository,
        aiProvider: aiProvider,
      );

      final result = await useCase.call(
        conceptId: 'python-closures',
        learnerExplanation: 'A closure remembers variables from its scope.',
      );

      expect(result.isCorrect, isTrue);
      expect(result.isComplete, isFalse);
      expect(
        aiProvider.lastExplanationRequest?.learnerExplanation,
        'A closure remembers variables from its scope.',
      );
      expect(
        misconceptionRepository.recordedDescriptions,
        ['Assumes static always means final'],
      );
    });
  });

  group('GenerateExerciseUseCase', () {
    test('returns the AI-authored exercise, passing the assembled context', () async {
      aiProvider.generatedExercise = const Exercise(
        id: 'generated-closures-1',
        type: ItemType.predictOutput,
        prompt: 'What does this print?',
        hints: ['Think about scope'],
        code: 'x = 1',
      );
      final useCase = GenerateExerciseUseCase(
        contextBuilder: contextBuilder,
        aiProvider: aiProvider,
      );

      final exercise = await useCase.call(conceptId: 'python-closures');

      expect(exercise.id, 'generated-closures-1');
      expect(exercise.prompt, 'What does this print?');
      final context = aiProvider.lastExerciseRequest?.context;
      expect(context, isA<TeachingContext>());
      expect((context as TeachingContext).concept.id, 'python-closures');
    });
  });
}
