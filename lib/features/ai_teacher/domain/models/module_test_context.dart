import 'package:equatable/equatable.dart';

import 'teaching_context.dart';

/// Everything the AI needs to author a topic test covering an entire
/// module — one [TeachingContext] per concept in the module, so the
/// generated questions can draw on any of them.
class ModuleTestContext extends Equatable {
  const ModuleTestContext({
    required this.learningPathId,
    required this.moduleId,
    required this.moduleTitle,
    required this.conceptContexts,
  });

  final String learningPathId;
  final String moduleId;
  final String moduleTitle;
  final List<TeachingContext> conceptContexts;

  @override
  List<Object?> get props => [
    learningPathId,
    moduleId,
    moduleTitle,
    conceptContexts,
  ];
}
