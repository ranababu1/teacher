import '../../../core/services/app_logger.dart';
import '../../curriculum/domain/models/exercise.dart';
import 'ai_provider.dart';
import 'models/teacher_response.dart';
import 'teaching_context_builder.dart';

/// Generates one new, AI-authored practice exercise for a concept,
/// calibrated to the learner's current mastery and difficulty level.
/// Per instructions.md sections 55-56, AI-generated content augments the
/// curriculum but never becomes part of it — callers must not persist the
/// result back into curriculum content, only play it through
/// [ExercisePlayer] for that session. Plain Dart, no Riverpod; mirrors
/// [TeachUseCase].
class GenerateExerciseUseCase {
  GenerateExerciseUseCase({
    required TeachingContextBuilder contextBuilder,
    required AIProvider aiProvider,
    this.requestLoggingEnabled = false,
  }) : _contextBuilder = contextBuilder,
       _aiProvider = aiProvider;

  final TeachingContextBuilder _contextBuilder;
  final AIProvider _aiProvider;
  final bool requestLoggingEnabled;

  Future<Exercise> call({required String conceptId}) async {
    final context = await _contextBuilder.build(conceptId);

    if (requestLoggingEnabled) {
      AppLogger.debug('AI generateExercise request: conceptId=$conceptId');
    }

    return _aiProvider.generateExercise(ExerciseRequest(context: context));
  }
}
