import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config_provider.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../curriculum/domain/models/exercise.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../../settings/domain/settings_models.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../data/gemini_provider.dart';
import '../../domain/ai_provider.dart';
import '../../domain/models/teacher_response.dart';
import '../../domain/teach_use_case.dart';
import '../../domain/teaching_context_builder.dart';
import 'api_key_providers.dart';
import 'misconception_providers.dart';

/// Stands in for [AIProvider] before a Gemini API key has been entered, so
/// every caller gets a consistent [AIUnavailableException] instead of a
/// null-check crash — the UI (see `AiTeacherPanel`) checks
/// [isAiConfiguredProvider] up front and never actually calls this, but
/// callers deeper in the stack (e.g. a future assessment flow) don't have
/// to duplicate that check to stay safe.
class _UnavailableAiProvider implements AIProvider {
  const _UnavailableAiProvider();

  @override
  Future<TeacherResponse> teach(TeacherRequest request) async =>
      _throwUnavailable();

  @override
  Future<AssessmentResult> assess(AssessmentRequest request) async =>
      _throwUnavailable();

  @override
  Future<Exercise> generateExercise(ExerciseRequest request) async =>
      _throwUnavailable();

  @override
  Future<ExplanationEvaluation> evaluateExplanation(
    ExplanationRequest request,
  ) async => _throwUnavailable();

  Never _throwUnavailable() {
    throw const AIUnavailableException('No Gemini API key configured yet.');
  }
}

/// The active [AIProvider] — a real [GeminiProvider] once the learner has
/// entered an API key (see instructions.md section 27), otherwise
/// [_UnavailableAiProvider]. Rebuilds automatically when the key,
/// [AppConfig]'s Gemini settings, or the explanation-depth preference
/// change, since it watches all three.
final aiProviderProvider = Provider<AIProvider>((ref) {
  final apiKey = ref.watch(geminiApiKeyControllerProvider).valueOrNull;
  if (apiKey == null || apiKey.isEmpty) {
    return const _UnavailableAiProvider();
  }

  final config = ref.watch(appConfigProvider);
  final depth =
      ref.watch(settingsControllerProvider).valueOrNull?.explanationDepth ??
      ExplanationDepth.standard;

  return GeminiProvider(
    apiKey: apiKey,
    model: config.geminiModel,
    baseUrl: config.geminiApiBaseUrl,
    explanationDepth: depth,
  );
});

/// Shared by every AI Teacher use case so context assembly can't drift
/// between them.
final teachingContextBuilderProvider = Provider<TeachingContextBuilder>((
  ref,
) {
  return TeachingContextBuilder(
    curriculumRepository: ref.watch(curriculumRepositoryProvider),
    masteryRepository: ref.watch(conceptMasteryRepositoryProvider),
    misconceptionRepository: ref.watch(misconceptionRepositoryProvider),
  );
});

/// Whether AI request logging is enabled — watched by every AI Teacher use
/// case provider (here and in `grading_providers.dart`).
final aiRequestLoggingEnabledProvider = Provider<bool>((ref) {
  return ref.watch(settingsControllerProvider).valueOrNull?.aiRequestLogging ??
      false;
});

final teachUseCaseProvider = Provider<TeachUseCase>((ref) {
  return TeachUseCase(
    contextBuilder: ref.watch(teachingContextBuilderProvider),
    aiProvider: ref.watch(aiProviderProvider),
    requestLoggingEnabled: ref.watch(aiRequestLoggingEnabledProvider),
  );
});
