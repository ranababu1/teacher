import '../../../core/errors/app_exception.dart';
import '../../../core/services/app_logger.dart';
import '../../curriculum/domain/curriculum_repository.dart';
import '../../curriculum/domain/models/assessment.dart';
import '../../curriculum/domain/models/item_type.dart';
import 'ai_provider.dart';
import 'models/module_test_context.dart';
import 'models/teacher_response.dart';
import 'teaching_context_builder.dart';

/// Generates a batch of AI-authored multiple-choice questions covering an
/// entire module, used to gate advancing to the next module in a path.
/// Per instructions.md sections 55-56, this is ephemeral — never
/// persisted back into curriculum content, only played through the
/// module-test screen for that attempt. Plain Dart, no Riverpod; mirrors
/// [GenerateExerciseUseCase].
class GenerateModuleTestUseCase {
  GenerateModuleTestUseCase({
    required CurriculumRepository curriculumRepository,
    required TeachingContextBuilder contextBuilder,
    required AIProvider aiProvider,
    this.requestLoggingEnabled = false,
    this.questionCount = 10,
  }) : _curriculumRepository = curriculumRepository,
       _contextBuilder = contextBuilder,
       _aiProvider = aiProvider;

  final CurriculumRepository _curriculumRepository;
  final TeachingContextBuilder _contextBuilder;
  final AIProvider _aiProvider;
  final bool requestLoggingEnabled;
  final int questionCount;

  Future<List<Assessment>> call({
    required String learningPathId,
    required String moduleId,
  }) async {
    final path = await _curriculumRepository.getLearningPath(learningPathId);
    if (path == null) {
      throw ContentNotFoundException(
        'No learning path found for id $learningPathId',
      );
    }
    final module = path.findModule(moduleId);
    if (module == null) {
      throw ContentNotFoundException(
        'No module found for id $moduleId in path $learningPathId',
      );
    }

    final conceptContexts = [
      for (final concept in module.concepts)
        await _contextBuilder.build(concept.id),
    ];

    final context = ModuleTestContext(
      learningPathId: learningPathId,
      moduleId: moduleId,
      moduleTitle: module.title,
      conceptContexts: conceptContexts,
    );

    if (requestLoggingEnabled) {
      AppLogger.debug(
        'AI generateModuleTest request: learningPathId=$learningPathId '
        'moduleId=$moduleId questionCount=$questionCount',
      );
    }

    final questions = await _aiProvider.generateModuleTest(
      ModuleTestRequest(context: context, questionCount: questionCount),
    );

    // Defensive filter: only keep well-formed, auto-gradable multiple-choice
    // items, in case a provider partially violates its own schema.
    return questions.where((question) {
      final options = question.options;
      final correctOptionIndex = question.correctOptionIndex;
      return question.type == ItemType.multipleChoice &&
          options != null &&
          options.length >= 2 &&
          correctOptionIndex != null &&
          correctOptionIndex >= 0 &&
          correctOptionIndex < options.length;
    }).toList();
  }
}
