import '../../curriculum/domain/models/exercise.dart';
import '../../settings/domain/settings_models.dart';
import '../domain/ai_provider.dart';
import '../domain/models/teacher_response.dart';
import '../domain/models/teaching_context.dart';
import 'ai_response_parsing.dart' as parsing;
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
/// InvalidAIResponseException — Gemini's structured-output mode is
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

  static const _providerLabel = 'Gemini';

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
    return parsing.callWithRetry(() async {
      final json = await _client.generateContent(
        model: _model,
        systemInstruction: prompt.systemInstruction,
        userContent: prompt.userContent,
        responseSchema: teacherResponseSchema,
      );
      return TeacherResponse(
        explanation: parsing.reqString(
          json,
          'explanation',
          providerLabel: _providerLabel,
        ),
        followUpQuestion: parsing.optString(
          json,
          'followUpQuestion',
          providerLabel: _providerLabel,
        ),
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
    return parsing.callWithRetry(() async {
      final json = await _client.generateContent(
        model: _model,
        systemInstruction: prompt.systemInstruction,
        userContent: prompt.userContent,
        responseSchema: assessmentResultSchema,
      );
      return AssessmentResult(
        isCorrect: parsing.reqBool(
          json,
          'isCorrect',
          providerLabel: _providerLabel,
        ),
        feedback: parsing.reqString(
          json,
          'feedback',
          providerLabel: _providerLabel,
        ),
        detectedMisconceptions: parsing.reqStringList(
          json,
          'detectedMisconceptions',
          providerLabel: _providerLabel,
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
    return parsing.callWithRetry(() async {
      final json = await _client.generateContent(
        model: _model,
        systemInstruction: prompt.systemInstruction,
        userContent: prompt.userContent,
        responseSchema: exerciseSchema,
      );
      return parsing.parseExercise(json, providerLabel: _providerLabel);
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
    return parsing.callWithRetry(() async {
      final json = await _client.generateContent(
        model: _model,
        systemInstruction: prompt.systemInstruction,
        userContent: prompt.userContent,
        responseSchema: explanationEvaluationSchema,
      );
      return ExplanationEvaluation(
        isCorrect: parsing.reqBool(
          json,
          'isCorrect',
          providerLabel: _providerLabel,
        ),
        isComplete: parsing.reqBool(
          json,
          'isComplete',
          providerLabel: _providerLabel,
        ),
        feedback: parsing.reqString(
          json,
          'feedback',
          providerLabel: _providerLabel,
        ),
        detectedMisconceptions: parsing.reqStringList(
          json,
          'detectedMisconceptions',
          providerLabel: _providerLabel,
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
    parsing.reqString(json, 'explanation', providerLabel: _providerLabel);
  }
}
