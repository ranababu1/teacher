import '../../../core/services/app_logger.dart';
import 'ai_provider.dart';
import 'models/teacher_response.dart';
import 'teaching_context_builder.dart';

/// Assembles a [TeachingContext] via [TeachingContextBuilder] then asks the
/// [AIProvider] to respond — see instructions.md section 20: never send an
/// isolated question to the AI if context is available. Plain Dart, no
/// Riverpod, so it's trivially unit-testable with a fake [AIProvider]
/// (mirrors [RecordAttemptUseCase]).
class TeachUseCase {
  TeachUseCase({
    required TeachingContextBuilder contextBuilder,
    required AIProvider aiProvider,
    this.requestLoggingEnabled = false,
  }) : _contextBuilder = contextBuilder,
       _aiProvider = aiProvider;

  final TeachingContextBuilder _contextBuilder;
  final AIProvider _aiProvider;

  /// When true, logs request metadata (concept id, capability) — never the
  /// prompt content or API key. See instructions.md section 38.
  final bool requestLoggingEnabled;

  Future<TeacherResponse> call({
    required String conceptId,
    String? learnerMessage,
  }) async {
    final context = await _contextBuilder.build(conceptId);

    if (requestLoggingEnabled) {
      AppLogger.debug(
        'AI teach request: conceptId=$conceptId hasLearnerMessage=${learnerMessage != null}',
      );
    }

    return _aiProvider.teach(
      TeacherRequest(context: context, learnerMessage: learnerMessage),
    );
  }
}
