import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/ai_teacher/data/gemini_prompt_builder.dart';
import 'package:teacher/features/ai_teacher/domain/models/teaching_context.dart';
import 'package:teacher/features/curriculum/domain/models/concept.dart';
import 'package:teacher/features/curriculum/domain/models/difficulty.dart';
import 'package:teacher/features/progress/domain/models/concept_mastery.dart';
import 'package:teacher/features/progress/domain/models/mastery_status.dart';
import 'package:teacher/features/settings/domain/settings_models.dart';

Concept _buildConcept() {
  return Concept(
    id: 'python-closures',
    title: 'Closures',
    description: 'Functions that capture variables from an enclosing scope.',
    learningPathId: 'python',
    moduleId: 'functions',
    topicId: 'functions',
    difficulty: Difficulty.intermediate,
    estimatedMinutes: 15,
    prerequisites: const ['python-functions'],
    learningObjectives: const [
      'Explain what a closure captures',
      'Identify a closure in real code',
    ],
    explanation: const ConceptExplanation(
      sections: [
        ExplanationSection(
          heading: 'What is a closure',
          body: 'A closure is a function bundled with its enclosing state.',
        ),
      ],
    ),
    examples: const [
      ConceptExample(
        title: 'Counter closure',
        language: 'python',
        code: 'def make_counter(): ...',
        explanation: 'Each call returns an independent counter.',
      ),
    ],
    misconceptions: const [],
    exercises: const [],
    assessments: const [],
  );
}

Concept _buildPrerequisite() {
  return Concept(
    id: 'python-functions',
    title: 'Functions',
    description: 'Reusable blocks of code.',
    learningPathId: 'python',
    moduleId: 'functions',
    topicId: 'functions',
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

ConceptMastery _buildMastery() {
  return const ConceptMastery(
    conceptId: 'python-closures',
    recallScore: 0.42,
    understandingScore: 0.55,
    applicationScore: 0.31,
    explanationScore: 0.2,
    codingScore: 0.6,
    debuggingScore: 0.1,
    overallMastery: 0.36,
    attemptCount: 7,
    successCount: 4,
    failureCount: 3,
    confidence: 0.5,
    lastReviewedAt: null,
    nextReviewAt: null,
    status: MasteryStatus.developing,
  );
}

TeachingContext _buildContext({List<String> recentMisconceptions = const []}) {
  return TeachingContext(
    concept: _buildConcept(),
    prerequisites: [_buildPrerequisite()],
    mastery: _buildMastery(),
    recentMisconceptions: recentMisconceptions,
    currentDifficultyLevel: 3,
  );
}

void main() {
  group('buildTeachPrompt', () {
    test('includes concept title, mastery numbers, and prerequisites', () {
      final context = _buildContext();
      final prompt = buildTeachPrompt(
        context,
        'Why does the counter keep its own state?',
        depth: ExplanationDepth.standard,
      );

      expect(prompt.userContent, contains('Closures'));
      expect(prompt.userContent, contains('0.42')); // recallScore
      expect(prompt.userContent, contains('0.55')); // understandingScore
      expect(prompt.userContent, contains('0.36')); // overallMastery
      expect(prompt.userContent, contains('Developing')); // status label
      expect(prompt.userContent, contains('Functions')); // prerequisite title
      expect(
        prompt.userContent,
        contains('Why does the counter keep its own state?'),
      );
      expect(prompt.userContent, contains('3')); // currentDifficultyLevel
    });

    test('omits recentMisconceptions section when empty', () {
      final context = _buildContext();
      final prompt = buildTeachPrompt(context, null, depth: ExplanationDepth.standard);

      expect(prompt.userContent, isNot(contains('Misconceptions recently')));
    });

    test('includes recentMisconceptions entries when present', () {
      final context = _buildContext(
        recentMisconceptions: [
          'Believes closures copy the variable value at definition time',
        ],
      );
      final prompt = buildTeachPrompt(context, null, depth: ExplanationDepth.standard);

      expect(prompt.userContent, contains('Misconceptions recently'));
      expect(
        prompt.userContent,
        contains('Believes closures copy the variable value at definition time'),
      );
    });

    test('handles a null/blank learner message by opening the topic', () {
      final context = _buildContext();
      final prompt = buildTeachPrompt(context, null, depth: ExplanationDepth.standard);

      expect(prompt.userContent, contains('has not asked anything specific yet'));
    });

    test('depth changes the system instruction wording', () {
      final context = _buildContext();
      final concise = buildTeachPrompt(context, null, depth: ExplanationDepth.concise);
      final deep = buildTeachPrompt(context, null, depth: ExplanationDepth.deep);

      expect(concise.systemInstruction, contains('concise'));
      expect(concise.systemInstruction, isNot(contains('multiple angles')));
      expect(deep.systemInstruction, contains('multiple angles'));
      expect(deep.systemInstruction, isNot(contains('minimal preamble')));
    });

    test('states the raw-JSON-only output requirement', () {
      final context = _buildContext();
      final prompt = buildTeachPrompt(context, null, depth: ExplanationDepth.standard);

      expect(prompt.systemInstruction, contains('ONLY the raw JSON object'));
    });
  });

  group('buildAssessPrompt', () {
    test('includes the learner response and context', () {
      final context = _buildContext();
      final prompt = buildAssessPrompt(
        context,
        'A closure is just a nested function.',
        depth: ExplanationDepth.standard,
      );

      expect(prompt.userContent, contains('A closure is just a nested function.'));
      expect(prompt.userContent, contains('Closures'));
      expect(prompt.systemInstruction, contains('name any misconceptions'));
    });
  });

  group('buildGenerateExercisePrompt', () {
    test('asks for exactly one new exercise using the context', () {
      final context = _buildContext();
      final prompt = buildGenerateExercisePrompt(context, depth: ExplanationDepth.standard);

      expect(prompt.userContent, contains('Generate one new exercise'));
      expect(prompt.userContent, contains('Closures'));
    });
  });

  group('buildEvaluateExplanationPrompt', () {
    test('includes the learner explanation and context', () {
      final context = _buildContext();
      final prompt = buildEvaluateExplanationPrompt(
        context,
        'Closures let a function remember variables from where it was created.',
        depth: ExplanationDepth.deep,
      );

      expect(
        prompt.userContent,
        contains('Closures let a function remember variables from where it was created.'),
      );
      expect(prompt.systemInstruction, contains('correctness and'));
    });
  });
}
