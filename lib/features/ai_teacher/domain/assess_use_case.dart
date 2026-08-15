import '../../../core/services/app_logger.dart';
import 'ai_provider.dart';
import 'misconception_repository.dart';
import 'models/teacher_response.dart';
import 'teaching_context_builder.dart';

/// Has the AI grade a learner's free-text response to a short-answer,
/// scenario, or similar exercise, and persists any misconceptions it
/// detects via [MisconceptionRepository] — see instructions.md section 18.
/// Plain Dart, no Riverpod; mirrors [TeachUseCase].
class AssessUseCase {
  AssessUseCase({
    required TeachingContextBuilder contextBuilder,
    required MisconceptionRepository misconceptionRepository,
    required AIProvider aiProvider,
    this.requestLoggingEnabled = false,
  }) : _contextBuilder = contextBuilder,
       _misconceptionRepository = misconceptionRepository,
       _aiProvider = aiProvider;

  final TeachingContextBuilder _contextBuilder;
  final MisconceptionRepository _misconceptionRepository;
  final AIProvider _aiProvider;
  final bool requestLoggingEnabled;

  Future<AssessmentResult> call({
    required String conceptId,
    required String learnerResponse,
  }) async {
    final context = await _contextBuilder.build(conceptId);

    if (requestLoggingEnabled) {
      AppLogger.debug('AI assess request: conceptId=$conceptId');
    }

    final result = await _aiProvider.assess(
      AssessmentRequest(context: context, learnerResponse: learnerResponse),
    );

    for (final description in result.detectedMisconceptions) {
      await _misconceptionRepository.recordMisconception(
        conceptId: conceptId,
        description: description,
      );
    }

    return result;
  }
}
