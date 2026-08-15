import '../../../core/errors/app_exception.dart';
import '../../curriculum/domain/models/exercise.dart';
import '../../settings/domain/settings_models.dart';
import '../domain/ai_provider.dart';
import '../domain/models/teacher_response.dart';
import '../domain/models/teaching_context.dart';
import 'gemini_api_client.dart';
import 'gemini_prompt_builder.dart';
import 'gemini_response_schemas.dart';

/// Gemini-backed implementation of [AIProvider].
///
/// Builds a prompt per capability via `gemini_prompt_builder.dart`, sends
/// it through [GeminiApiClient], and parses the returned JSON into the
/// typed response models declared on [AIProvider]. A response that fails
/// to parse (missing or wrong-typed key, or an undecodable body from the
/// client) is retried exactly once before giving up with
/// [InvalidAIResponseException] — Gemini's structured-output mode is
/// reliable but not infallible.
class GeminiProvider implements AIProvider {
  GeminiProvider({
    required String apiKey,
    required String model,
    required String baseUrl,
    this.explanationDepth = ExplanationDepth.standard,
    GeminiApiClient? apiClient,
  }) : _client = apiClient ?? GeminiApiClient(apiKey: apiKey, baseUrl: baseUrl),
       _model = model;

  final ExplanationDepth explanationDepth;
  final GeminiApiClient _client;
  final String _model;

  @override
  Future<TeacherResponse> teach(TeacherRequest request) {
    final context = request.context as TeachingContext;
    final prompt = buildTeachPrompt(
      context,
      request.learnerMessage,
      depth: explanationDepth,
    );
    return _callWithRetry(() async {
      final json = await _client.generateContent(
        model: _model,
        systemInstruction: prompt.systemInstruction,
        userContent: prompt.userContent,
        responseSchema: teacherResponseSchema,
      );
      return TeacherResponse(
        explanation: _reqString(json, 'explanation'),
        followUpQuestion: _optString(json, 'followUpQuestion'),
      );
    });
  }

  @override
  Future<AssessmentResult> assess(AssessmentRequest request) {
    final context = request.context as TeachingContext;
    final prompt = buildAssessPrompt(
      context,
      request.learnerResponse,
      depth: explanationDepth,
    );
    return _callWithRetry(() async {
      final json = await _client.generateContent(
        model: _model,
        systemInstruction: prompt.systemInstruction,
        userContent: prompt.userContent,
        responseSchema: assessmentResultSchema,
      );
      return AssessmentResult(
        isCorrect: _reqBool(json, 'isCorrect'),
        feedback: _reqString(json, 'feedback'),
        detectedMisconceptions: _reqStringList(
          json,
          'detectedMisconceptions',
        ),
      );
    });
  }

  @override
  Future<Exercise> generateExercise(ExerciseRequest request) {
    final context = request.context as TeachingContext;
    final prompt = buildGenerateExercisePrompt(
      context,
      depth: explanationDepth,
    );
    return _callWithRetry(() async {
      final json = await _client.generateContent(
        model: _model,
        systemInstruction: prompt.systemInstruction,
        userContent: prompt.userContent,
        responseSchema: exerciseSchema,
      );
      try {
        return Exercise.fromJson(json);
      } on InvalidAIResponseException {
        rethrow;
      } catch (e) {
        throw InvalidAIResponseException(
          'Could not parse exercise from Gemini response: $e',
        );
      }
    });
  }

  @override
  Future<ExplanationEvaluation> evaluateExplanation(
    ExplanationRequest request,
  ) {
    final context = request.context as TeachingContext;
    final prompt = buildEvaluateExplanationPrompt(
      context,
      request.learnerExplanation,
      depth: explanationDepth,
    );
    return _callWithRetry(() async {
      final json = await _client.generateContent(
        model: _model,
        systemInstruction: prompt.systemInstruction,
        userContent: prompt.userContent,
        responseSchema: explanationEvaluationSchema,
      );
      return ExplanationEvaluation(
        isCorrect: _reqBool(json, 'isCorrect'),
        isComplete: _reqBool(json, 'isComplete'),
        feedback: _reqString(json, 'feedback'),
        detectedMisconceptions: _reqStringList(
          json,
          'detectedMisconceptions',
        ),
      );
    });
  }

  @override
  Future<void> testConnection() async {
    final json = await _client.generateContent(
      model: _model,
      systemInstruction:
          'You are a connectivity test. Respond only with the JSON object '
          '{"explanation": "ok"} and nothing else.',
      userContent: 'ping',
      responseSchema: teacherResponseSchema,
    );
    _reqString(json, 'explanation');
  }

  /// Runs [attempt] (a full generate-and-parse round trip); if it fails
  /// because the response couldn't be parsed into the expected shape,
  /// runs it exactly one more time. A second failure propagates as-is.
  Future<T> _callWithRetry<T>(Future<T> Function() attempt) async {
    try {
      return await attempt();
    } on InvalidAIResponseException {
      return await attempt();
    }
  }
}

// ---------------------------------------------------------------------------
// Strict field extraction — throws InvalidAIResponseException (rather than
// letting a raw TypeError/CastError escape) on a missing or wrong-typed
// key, so `_callWithRetry` can catch it uniformly.
// ---------------------------------------------------------------------------

String _reqString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String) {
    throw InvalidAIResponseException(
      'Gemini response missing required string field "$key"',
    );
  }
  return value;
}

String? _optString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! String) {
    throw InvalidAIResponseException(
      'Gemini response has a non-string value for field "$key"',
    );
  }
  return value;
}

bool _reqBool(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! bool) {
    throw InvalidAIResponseException(
      'Gemini response missing required boolean field "$key"',
    );
  }
  return value;
}

List<String> _reqStringList(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! List) {
    throw InvalidAIResponseException(
      'Gemini response missing required array field "$key"',
    );
  }
  return value.map((entry) {
    if (entry is! String) {
      throw InvalidAIResponseException(
        'Gemini response has a non-string entry in array field "$key"',
      );
    }
    return entry;
  }).toList();
}
