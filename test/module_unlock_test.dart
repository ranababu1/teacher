import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/curriculum/domain/models/concept.dart';
import 'package:teacher/features/curriculum/domain/models/curriculum_module.dart';
import 'package:teacher/features/curriculum/domain/models/difficulty.dart';
import 'package:teacher/features/curriculum/domain/models/learning_path.dart';
import 'package:teacher/features/progress/domain/module_unlock.dart';

Concept _buildConcept(String id) {
  return Concept(
    id: id,
    title: id,
    description: 'desc',
    learningPathId: 'python',
    moduleId: 'module-of-$id',
    topicId: 'module-of-$id',
    difficulty: Difficulty.beginner,
    estimatedMinutes: 10,
    prerequisites: const [],
    learningObjectives: const [],
    explanation: const ConceptExplanation(sections: []),
    examples: const [],
    misconceptions: const [],
    exercises: const [],
    assessments: const [],
  );
}

CurriculumModule _buildModule(String id, int order) {
  return CurriculumModule(
    learningPathId: 'python',
    id: id,
    title: id,
    order: order,
    concepts: [_buildConcept('$id-concept')],
  );
}

LearningPath _buildPath(List<CurriculumModule> modules) {
  return LearningPath(
    id: 'python',
    title: 'Python',
    description: 'desc',
    difficulty: Difficulty.beginner,
    iconName: 'python',
    estimatedHours: 10,
    modules: modules,
  );
}

void main() {
  final moduleA = _buildModule('module-a', 1);
  final moduleB = _buildModule('module-b', 2);
  final moduleC = _buildModule('module-c', 3);
  final path = _buildPath([moduleA, moduleB, moduleC]);

  group('isModuleUnlocked', () {
    test('the first module is always unlocked', () {
      expect(
        isModuleUnlocked(path: path, module: moduleA, passedModuleIds: {}),
        isTrue,
      );
    });

    test('a later module is locked until the previous one is passed', () {
      expect(
        isModuleUnlocked(path: path, module: moduleB, passedModuleIds: {}),
        isFalse,
      );
      expect(
        isModuleUnlocked(
          path: path,
          module: moduleB,
          passedModuleIds: {'module-a'},
        ),
        isTrue,
      );
    });

    test('passing module A does not unlock module C, only module B', () {
      expect(
        isModuleUnlocked(
          path: path,
          module: moduleC,
          passedModuleIds: {'module-a'},
        ),
        isFalse,
      );
      expect(
        isModuleUnlocked(
          path: path,
          module: moduleC,
          passedModuleIds: {'module-a', 'module-b'},
        ),
        isTrue,
      );
    });
  });

  group('nextModule', () {
    test('returns the module immediately after the given one', () {
      expect(nextModule(path: path, module: moduleA), moduleB);
      expect(nextModule(path: path, module: moduleB), moduleC);
    });

    test('returns null for the last module in the path', () {
      expect(nextModule(path: path, module: moduleC), isNull);
    });
  });
}
