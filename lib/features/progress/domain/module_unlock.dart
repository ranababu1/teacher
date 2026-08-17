import '../../curriculum/domain/models/curriculum_module.dart';
import '../../curriculum/domain/models/learning_path.dart';

/// Whether [module] is unlocked within [path] — the first module in a
/// path is always unlocked (once the path itself is started); every
/// later module requires the immediately preceding module's id to be in
/// [passedModuleIds]. Indexes within [path.modules] rather than looking
/// [module] up globally, since module ids are reused across paths.
bool isModuleUnlocked({
  required LearningPath path,
  required CurriculumModule module,
  required Set<String> passedModuleIds,
}) {
  final index = path.modules.indexWhere((m) => m.id == module.id);
  if (index <= 0) return true;
  final previous = path.modules[index - 1];
  return passedModuleIds.contains(previous.id);
}

/// The module immediately after [module] in [path]'s order, or `null` if
/// [module] is the last one (nothing to unlock next).
CurriculumModule? nextModule({
  required LearningPath path,
  required CurriculumModule module,
}) {
  final index = path.modules.indexWhere((m) => m.id == module.id);
  if (index == -1 || index + 1 >= path.modules.length) return null;
  return path.modules[index + 1];
}
