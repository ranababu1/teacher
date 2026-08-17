import '../../curriculum/domain/models/assessment.dart';
import '../../curriculum/domain/models/exercise.dart';
import '../../settings/domain/settings_models.dart';
import '../domain/ai_provider.dart';
import '../domain/models/module_test_context.dart';
import '../domain/models/teacher_response.dart';
import '../domain/models/teaching_context.dart';
import 'ai_response_parsing.dart' as parsing;
import 'openai_compatible_api_client.dart';
import 'openai_compatible_prompt_builder.dart';

/// Implementation of [AIProvider] for any OpenAI Chat-Completions-compatible
/// backend — used for both OpenAI itself and DeepSeek, which documents
/// wire-compatibility with the same request/response shape. The two are
/// distinguished only by [OpenAiCompatibleApiClient]'s `baseUrl`, the
/// [model] name, and [providerLabel] (used purely in error-message text).
///
/// Builds a prompt per capability via `openai_compatible_prompt_builder.dart`,
/// sends it through [OpenAiCompatibleApiClient], and parses the returned
/// JSON into the typed response models declared on [AIProvider]. A
/// response that fails to parse is retried exactly once before giving up
/// with InvalidAIResponseException — `response_format: json_object` only
/// guarantees valid JSON, not the specific shape asked for in the prompt.
class OpenAiCompatibleProvider implements AIProvider {
  OpenAiCompatibleProvider({
    required String apiKey,
    required String model,
    required String baseUrl,
    required this.providerLabel,
    this.explanationDepth = ExplanationDepth.standard,
    OpenAiCompatibleApiClient? apiClient,
  }) : _client =
           apiClient ??
           OpenAiCompatibleApiClient(
             apiKey: apiKey,
             baseUrl: baseUrl,
             providerLabel: providerLabel,
           ),
       _model = model;

  final String providerLabel;
  final ExplanationDepth explanationDepth;
  final OpenAiCompatibleApiClient _client;
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
      final json = await _client.chatCompletion(
        model: _model,
        systemInstruction: prompt.systemInstruction,
        userContent: prompt.userContent,
      );
      return TeacherResponse(
        explanation: parsing.reqString(
          json,
          'explanation',
          providerLabel: providerLabel,
        ),
        followUpQuestion: parsing.optString(
          json,
          'followUpQuestion',
          providerLabel: providerLabel,
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
      final json = await _client.chatCompletion(
        model: _model,
        systemInstruction: prompt.systemInstruction,
        userContent: prompt.userContent,
      );
      return AssessmentResult(
        isCorrect: parsing.reqBool(
          json,
          'isCorrect',
          providerLabel: providerLabel,
        ),
        feedback: parsing.reqString(
          json,
          'feedback',
          providerLabel: providerLabel,
        ),
        detectedMisconceptions: parsing.reqStringList(
          json,
          'detectedMisconceptions',
          providerLabel: providerLabel,
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
      final json = await _client.chatCompletion(
        model: _model,
        systemInstruction: prompt.systemInstruction,
        userContent: prompt.userContent,
      );
      return parsing.parseExercise(json, providerLabel: providerLabel);
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
      final json = await _client.chatCompletion(
        model: _model,
        systemInstruction: prompt.systemInstruction,
        userContent: prompt.userContent,
      );
      return ExplanationEvaluation(
        isCorrect: parsing.reqBool(
          json,
          'isCorrect',
          providerLabel: providerLabel,
        ),
        isComplete: parsing.reqBool(
          json,
          'isComplete',
          providerLabel: providerLabel,
        ),
        feedback: parsing.reqString(
          json,
          'feedback',
          providerLabel: providerLabel,
        ),
        detectedMisconceptions: parsing.reqStringList(
          json,
          'detectedMisconceptions',
          providerLabel: providerLabel,
        ),
      );
    });
  }

  @override
  Future<List<Assessment>> generateModuleTest(ModuleTestRequest request) {
    final context = request.context as ModuleTestContext;
    final prompt = buildModuleTestPrompt(
      context,
      questionCount: request.questionCount,
      depth: explanationDepth,
    );
    return parsing.callWithRetry(() async {
      final json = await _client.chatCompletion(
        model: _model,
        systemInstruction: prompt.systemInstruction,
        userContent: prompt.userContent,
      );
      return parsing.parseAssessmentList(
        json,
        providerLabel: providerLabel,
        minCount: request.questionCount,
      );
    });
  }

  @override
  Future<void> testConnection() async {
    final json = await _client.chatCompletion(
      model: _model,
      systemInstruction:
          'You are a connectivity test. Respond only with the JSON object '
          '{"explanation": "ok"} and nothing else.',
      userContent: 'ping',
    );
    parsing.reqString(json, 'explanation', providerLabel: providerLabel);
  }
}
