import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/core/errors/app_exception.dart';
import 'package:teacher/features/ai_teacher/domain/ai_provider.dart';
import 'package:teacher/features/ai_teacher/domain/models/teacher_response.dart';
import 'package:teacher/features/ai_teacher/domain/teach_use_case.dart';
import 'package:teacher/features/ai_teacher/domain/teaching_context_builder.dart';
import 'package:teacher/features/ai_teacher/presentation/providers/ai_teacher_providers.dart';
import 'package:teacher/features/ai_teacher/presentation/providers/teach_providers.dart';
import 'package:teacher/features/curriculum/domain/models/assessment.dart';
import 'package:teacher/features/curriculum/domain/models/exercise.dart';
import 'package:teacher/features/ai_teacher/domain/models/roadmap_generation.dart';
import 'package:teacher/features/ai_teacher/domain/models/study_coaching.dart';
import 'package:teacher/features/ai_teacher/domain/models/teaching_context.dart';
import 'package:teacher/features/curriculum/domain/models/concept.dart';
import 'package:teacher/features/curriculum/domain/models/difficulty.dart';
import 'package:teacher/features/progress/domain/models/concept_mastery.dart';
import 'package:teacher/features/progress/domain/models/mastery_status.dart';

class _FakeTeach extends AIProvider {
  _FakeTeach(this._handler);
  final Future<TeacherResponse> Function(String? message) _handler;
  final prompts = <String?>[];

  @override
  Future<TeacherResponse> teach(TeacherRequest request) {
    prompts.add(request.learnerMessage);
    return _handler(request.learnerMessage);
  }

  @override
  Future<AssessmentResult> assess(AssessmentRequest request) =>
      throw UnimplementedError();
  @override
  Future<Exercise> generateExercise(ExerciseRequest request) =>
      throw UnimplementedError();
  @override
  Future<ExplanationEvaluation> evaluateExplanation(
    ExplanationRequest request,
  ) => throw UnimplementedError();
  @override
  Future<List<Assessment>> generateModuleTest(ModuleTestRequest request) =>
      throw UnimplementedError();
  @override
  Future<void> testConnection() async {}
  @override
  Future<StudyCoachingAdvice> coachStudyPlan(StudyCoachingRequest request) =>
      throw UnimplementedError();
  @override
  Future<RoadmapDraft> generateRoadmap(RoadmapGenerationRequest request) =>
      throw UnimplementedError();
}

class _FakeContextBuilder implements TeachingContextBuilder {
  @override
  Future<TeachingContext> build(String conceptId) async {
    return TeachingContext(
      concept: Concept(
        id: conceptId,
        title: 'Closures',
        description: 'd',
        learningPathId: 'python',
        moduleId: 'm',
        topicId: 't',
        difficulty: Difficulty.intermediate,
        estimatedMinutes: 10,
        prerequisites: const [],
        learningObjectives: const [],
        explanation: const ConceptExplanation(sections: []),
        examples: const [],
        misconceptions: const [],
        exercises: const [],
        assessments: const [],
      ),
      prerequisites: const [],
      mastery: const ConceptMastery(
        conceptId: 'c',
        recallScore: 0,
        understandingScore: 0,
        applicationScore: 0,
        explanationScore: 0,
        codingScore: 0,
        debuggingScore: 0,
        overallMastery: 0,
        attemptCount: 0,
        successCount: 0,
        failureCount: 0,
        confidence: 0,
        lastReviewedAt: null,
        nextReviewAt: null,
        status: MasteryStatus.notStarted,
      ),
      recentMisconceptions: const [],
      currentDifficultyLevel: 1,
    );
  }
}

void main() {
  test('needsContinuation marks the reply as continuable', () async {
    final fake = _FakeTeach(
      (_) async => const TeacherResponse(
        explanation: 'Part one.',
        needsContinuation: true,
      ),
    );
    final container = ProviderContainer(
      overrides: [
        teachUseCaseProvider.overrideWithValue(
          TeachUseCase(contextBuilder: _FakeContextBuilder(), aiProvider: fake),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(aiConversationControllerProvider('c1').notifier)
        .sendMessage('Explain closures');
    final messages = container
        .read(aiConversationControllerProvider('c1'))
        .valueOrNull!;
    expect(messages, hasLength(2));
    expect(messages.last.canContinue, isTrue);
    expect(messages.last.text, 'Part one.');
  });

  test(
    'token cutoff error offers Continue and continueAnswer resumes',
    () async {
      var calls = 0;
      final fake = _FakeTeach((message) async {
        calls++;
        if (calls == 1) {
          throw const AIUnavailableException(
            'Claude response was truncated (stop_reason: max_tokens).',
            aiTruncatedUserMessage,
          );
        }
        return const TeacherResponse(explanation: 'Part two.');
      });
      final container = ProviderContainer(
        overrides: [
          teachUseCaseProvider.overrideWithValue(
            TeachUseCase(
              contextBuilder: _FakeContextBuilder(),
              aiProvider: fake,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(
        aiConversationControllerProvider('c1').notifier,
      );

      await notifier.sendMessage('Explain closures deeply');
      var messages = container
          .read(aiConversationControllerProvider('c1'))
          .valueOrNull!;
      expect(messages.last.isError, isTrue);
      expect(messages.last.canContinue, isTrue);
      expect(messages.last.text, aiTruncatedUserMessage);

      await notifier.continueAnswer();
      messages = container
          .read(aiConversationControllerProvider('c1'))
          .valueOrNull!;
      expect(messages.last.isError, isFalse);
      expect(messages.last.text, 'Part two.');
      expect(fake.prompts.last, contains('Continue from where you stopped'));
      expect(fake.prompts.last, contains('Explain closures deeply'));
    },
  );

  test(
    'continueAnswer includes prior AI text and avoids repeating it',
    () async {
      var calls = 0;
      final fake = _FakeTeach((message) async {
        calls++;
        if (calls == 1) {
          return const TeacherResponse(
            explanation: 'First chunk about scope.',
            needsContinuation: true,
          );
        }
        return const TeacherResponse(
          explanation: 'Second chunk about capture.',
        );
      });
      final container = ProviderContainer(
        overrides: [
          teachUseCaseProvider.overrideWithValue(
            TeachUseCase(
              contextBuilder: _FakeContextBuilder(),
              aiProvider: fake,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(
        aiConversationControllerProvider('c1').notifier,
      );

      await notifier.sendMessage('Tell me more');
      await notifier.continueAnswer();
      expect(fake.prompts.last, contains('First chunk about scope.'));
      expect(fake.prompts.last, contains('Do not repeat earlier content'));
      final messages = container
          .read(aiConversationControllerProvider('c1'))
          .valueOrNull!;
      expect(
        messages.where((m) => m.isFromLearner && m.text == 'Continue'),
        hasLength(1),
      );
    },
  );
}
