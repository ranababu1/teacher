import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/data_revision_provider.dart';
import '../../../curriculum/domain/models/learning_path.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../domain/apply_skill_check_placement_use_case.dart';
import '../../domain/models/skill_check.dart';
import '../../domain/skill_check_service.dart';

final skillCheckServiceProvider = Provider<SkillCheckService>(
  (ref) => SkillCheckService(),
);

/// A freshly sampled skill check for a course. Auto-disposed, so every
/// visit to the screen draws a new set of questions.
final skillCheckProvider = FutureProvider.autoDispose
    .family<({LearningPath path, List<SkillCheckQuestion> questions})?, String>(
      (ref, pathId) async {
        final path = await ref.watch(learningPathProvider(pathId).future);
        if (path == null) return null;
        return (
          path: path,
          questions: ref.read(skillCheckServiceProvider).buildQuestions(path),
        );
      },
    );

final applySkillCheckPlacementProvider =
    Provider<Future<void> Function(SkillCheckResult)>((ref) {
      return (result) async {
        await ApplySkillCheckPlacementUseCase(
          pathProgress: ref.read(learningPathProgressRepositoryProvider),
          moduleTests: ref.read(moduleTestProgressRepositoryProvider),
        ).call(result);
        ref.read(dataRevisionProvider.notifier).bump();
      };
    });
