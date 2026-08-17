import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/core/errors/app_exception.dart';
import 'package:teacher/features/ai_teacher/data/gemini_api_client.dart';
import 'package:teacher/features/ai_teacher/data/gemini_provider.dart';
import 'package:teacher/features/ai_teacher/domain/models/module_test_context.dart';
import 'package:teacher/features/ai_teacher/domain/models/teacher_response.dart';
import 'package:teacher/features/ai_teacher/domain/models/teaching_context.dart';
import 'package:teacher/features/curriculum/domain/models/concept.dart';
import 'package:teacher/features/curriculum/domain/models/difficulty.dart';
import 'package:teacher/features/progress/domain/models/concept_mastery.dart';
import 'package:teacher/features/progress/domain/models/mastery_status.dart';

/// Fake [HttpClientAdapter] that never touches the network. Each call to
/// [fetch] is dispatched to the [_action] at the current 0-based call
/// index (clamped to the last one supplied), so tests can script a
/// sequence of responses/failures and assert exactly how many times the
/// "network" was hit.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._actions);

  final List<ResponseBody Function(RequestOptions options)> _actions;
  int callCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final index = callCount < _actions.length
        ? callCount
        : _actions.length - 1;
    callCount++;
    return _actions[index](options);
  }

  @override
  void close({bool force = false}) {}
}

/// Builds the Gemini HTTP envelope: the actual structured payload is a
/// JSON-encoded string nested inside `candidates[0].content.parts[0].text`.
String _envelope(String innerText) => jsonEncode({
  'candidates': [
    {
      'content': {
        'parts': [
          {'text': innerText},
        ],
      },
    },
  ],
});

ResponseBody _jsonResponse(String body, [int statusCode = 200]) {
  return ResponseBody.fromString(
    body,
    statusCode,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );
}

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
    prerequisites: const [],
    learningObjectives: const ['Explain what a closure captures'],
    explanation: const ConceptExplanation(
      sections: [
        ExplanationSection(
          heading: 'What is a closure',
          body: 'A closure bundles a function with its enclosing state.',
        ),
      ],
    ),
    examples: const [],
    misconceptions: const [],
    exercises: const [],
    assessments: const [],
  );
}

TeachingContext _buildContext() {
  return TeachingContext(
    concept: _buildConcept(),
    prerequisites: const [],
    mastery: const ConceptMastery(
      conceptId: 'python-closures',
      recallScore: 0.4,
      understandingScore: 0.5,
      applicationScore: 0.3,
      explanationScore: 0.2,
      codingScore: 0.6,
      debuggingScore: 0.1,
      overallMastery: 0.35,
      attemptCount: 5,
      successCount: 3,
      failureCount: 2,
      confidence: 0.5,
      lastReviewedAt: null,
      nextReviewAt: null,
      status: MasteryStatus.developing,
    ),
    recentMisconceptions: const [],
    currentDifficultyLevel: 3,
  );
}

ModuleTestContext _buildModuleTestContext() {
  return ModuleTestContext(
    learningPathId: 'python',
    moduleId: 'functions',
    moduleTitle: 'Functions',
    conceptContexts: [_buildContext()],
  );
}

GeminiProvider _providerWith(_FakeAdapter adapter) {
  final dio = Dio();
  dio.httpClientAdapter = adapter;
  final client = GeminiApiClient(
    apiKey: 'test-api-key',
    baseUrl: 'https://example.invalid',
    dio: dio,
  );
  return GeminiProvider(
    apiKey: 'test-api-key',
    model: 'gemini-test-model',
    baseUrl: 'https://example.invalid',
    apiClient: client,
  );
}

void main() {
  group('GeminiProvider.teach', () {
    test('a well-formed success response parses into a TeacherResponse', () async {
      final adapter = _FakeAdapter([
        (_) => _jsonResponse(
          _envelope(
            jsonEncode({
              'explanation': 'A closure captures variables by reference.',
              'followUpQuestion': 'What happens if the captured variable changes?',
            }),
          ),
        ),
      ]);
      final provider = _providerWith(adapter);

      final result = await provider.teach(
        TeacherRequest(context: _buildContext(), learnerMessage: 'What is a closure?'),
      );

      expect(result, isA<TeacherResponse>());
      expect(result.explanation, 'A closure captures variables by reference.');
      expect(
        result.followUpQuestion,
        'What happens if the captured variable changes?',
      );
      expect(adapter.callCount, 1);
    });
  });

  group('GeminiProvider.evaluateExplanation', () {
    test('a well-formed success response parses into an ExplanationEvaluation', () async {
      final adapter = _FakeAdapter([
        (_) => _jsonResponse(
          _envelope(
            jsonEncode({
              'isCorrect': false,
              'isComplete': false,
              'feedback': 'You are missing why the counter keeps separate state.',
              'detectedMisconceptions': ['Believes all calls share one counter'],
            }),
          ),
        ),
      ]);
      final provider = _providerWith(adapter);

      final result = await provider.evaluateExplanation(
        ExplanationRequest(
          context: _buildContext(),
          learnerExplanation: 'A closure is just a function inside a function.',
        ),
      );

      expect(result.isCorrect, false);
      expect(result.isComplete, false);
      expect(
        result.feedback,
        'You are missing why the counter keeps separate state.',
      );
      expect(
        result.detectedMisconceptions,
        ['Believes all calls share one counter'],
      );
      expect(adapter.callCount, 1);
    });
  });

  group('GeminiProvider.generateModuleTest', () {
    test('a well-formed response parses into a list of Assessments', () async {
      final adapter = _FakeAdapter([
        (_) => _jsonResponse(
          _envelope(
            jsonEncode({
              'questions': [
                {
                  'id': 'q1',
                  'type': 'multipleChoice',
                  'prompt': 'What does a closure capture?',
                  'options': ['Nothing', 'Variables by reference', 'Only ints'],
                  'correctOptionIndex': 1,
                  'explanation': 'Closures capture variables by reference.',
                },
                {
                  'id': 'q2',
                  'type': 'multipleChoice',
                  'prompt': 'When is a closure created?',
                  'options': ['At call time', 'At definition time'],
                  'correctOptionIndex': 1,
                },
              ],
            }),
          ),
        ),
      ]);
      final provider = _providerWith(adapter);

      final result = await provider.generateModuleTest(
        ModuleTestRequest(context: _buildModuleTestContext(), questionCount: 2),
      );

      expect(result, hasLength(2));
      expect(result.first.id, 'q1');
      expect(result.first.correctOptionIndex, 1);
      expect(adapter.callCount, 1);
    });

    test(
      'fewer questions than requested retries exactly once then throws InvalidAIResponseException',
      () async {
        final adapter = _FakeAdapter([
          (_) => _jsonResponse(
            _envelope(
              jsonEncode({
                'questions': [
                  {
                    'id': 'q1',
                    'type': 'multipleChoice',
                    'prompt': 'Only one question came back',
                    'options': ['A', 'B'],
                    'correctOptionIndex': 0,
                  },
                ],
              }),
            ),
          ),
        ]);
        final provider = _providerWith(adapter);

        await expectLater(
          provider.generateModuleTest(
            ModuleTestRequest(
              context: _buildModuleTestContext(),
              questionCount: 10,
            ),
          ),
          throwsA(isA<InvalidAIResponseException>()),
        );
        expect(adapter.callCount, 2);
      },
    );
  });

  group('error mapping', () {
    test('a non-2xx HTTP status throws AIUnavailableException', () async {
      final adapter = _FakeAdapter([
        (_) => _jsonResponse(jsonEncode({'error': 'quota exceeded'}), 429),
      ]);
      final provider = _providerWith(adapter);

      await expectLater(
        provider.teach(
          TeacherRequest(context: _buildContext(), learnerMessage: 'hi'),
        ),
        throwsA(isA<AIUnavailableException>()),
      );
    });

    test(
      'malformed inner JSON retries exactly once then throws InvalidAIResponseException',
      () async {
        final adapter = _FakeAdapter([
          (_) => _jsonResponse(_envelope('not valid json {{{')),
        ]);
        final provider = _providerWith(adapter);

        await expectLater(
          provider.teach(
            TeacherRequest(context: _buildContext(), learnerMessage: 'hi'),
          ),
          throwsA(isA<InvalidAIResponseException>()),
        );
        expect(adapter.callCount, 2);
      },
    );

    test(
      'a response missing a required key retries exactly once then throws InvalidAIResponseException',
      () async {
        final adapter = _FakeAdapter([
          // Missing the required "explanation" key.
          (_) => _jsonResponse(
            _envelope(jsonEncode({'followUpQuestion': 'huh?'})),
          ),
        ]);
        final provider = _providerWith(adapter);

        await expectLater(
          provider.teach(
            TeacherRequest(context: _buildContext(), learnerMessage: 'hi'),
          ),
          throwsA(isA<InvalidAIResponseException>()),
        );
        expect(adapter.callCount, 2);
      },
    );

    test('a connection error throws NetworkUnavailableException', () async {
      final adapter = _FakeAdapter([
        (options) => throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        ),
      ]);
      final provider = _providerWith(adapter);

      await expectLater(
        provider.teach(
          TeacherRequest(context: _buildContext(), learnerMessage: 'hi'),
        ),
        throwsA(isA<NetworkUnavailableException>()),
      );
    });
  });
}
