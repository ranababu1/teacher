import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/curriculum/domain/models/curriculum_module.dart';
import 'package:teacher/features/curriculum/domain/models/difficulty.dart';
import 'package:teacher/features/curriculum/domain/models/item_type.dart';
import 'package:teacher/features/curriculum/domain/models/learning_path.dart';

Map<String, dynamic> _sampleConceptJson({String id = 'python-closures'}) => {
  'id': id,
  'title': 'Closures',
  'description': 'A closure captures variables from an enclosing scope.',
  'moduleId': 'functions',
  'topicId': 'functions',
  'difficulty': 'advanced',
  'estimatedMinutes': 25,
  'prerequisites': ['python-scope'],
  'learningObjectives': ['Explain what a closure is.'],
  'explanation': {
    'sections': [
      {'heading': 'What Is a Closure', 'body': 'A closure forms when...'},
    ],
  },
  'examples': [
    {
      'title': 'Counter closure',
      'language': 'python',
      'code': 'def make_counter(): ...',
      'explanation': 'Walks through scope capture.',
    },
  ],
  'misconceptions': [
    {
      'description': 'A closure copies the value at creation time.',
      'clarification':
          'It captures a reference to the variable, not its value.',
    },
  ],
  'exercises': [
    {
      'id': 'python-closures-ex1',
      'type': 'predictOutput',
      'prompt': 'What does this print?',
      'code': 'x = 1',
      'hints': ['Think about scope.'],
      'expectedAnswer': '1',
      'solutionExplanation': 'Because...',
    },
  ],
  'assessments': [
    {
      'id': 'python-closures-assess-mcq1',
      'type': 'multipleChoice',
      'prompt': 'Which statement is true?',
      'options': ['A', 'B', 'C', 'D'],
      'correctOptionIndex': 1,
      'explanation': 'B is correct because...',
    },
  ],
};

Map<String, dynamic> _sampleModuleJson() => {
  'learningPathId': 'python',
  'moduleId': 'functions',
  'title': 'Functions',
  'order': 3,
  'concepts': [_sampleConceptJson()],
};

void main() {
  group('Curriculum parsing', () {
    test(
      'CurriculumModule.fromJson parses nested concepts with the right types',
      () {
        final module = CurriculumModule.fromJson(_sampleModuleJson());

        expect(module.id, 'functions');
        expect(module.order, 3);
        expect(module.concepts, hasLength(1));

        final concept = module.concepts.single;
        expect(concept.title, 'Closures');
        expect(concept.difficulty, Difficulty.advanced);
        expect(concept.learningPathId, 'python');
        expect(concept.prerequisites, ['python-scope']);
        expect(concept.exercises.single.type, ItemType.predictOutput);
        expect(concept.assessments.single.type, ItemType.multipleChoice);
        expect(concept.assessments.single.correctOptionIndex, 1);
      },
    );

    test('LearningPath.findConcept and findModule resolve by id', () {
      final module = CurriculumModule.fromJson(_sampleModuleJson());
      final path = LearningPath(
        id: 'python',
        title: 'Python',
        description: 'Learn Python.',
        difficulty: Difficulty.beginner,
        iconName: 'python',
        estimatedHours: 12,
        modules: [module],
      );

      expect(path.findConcept('python-closures')?.title, 'Closures');
      expect(path.findModule('functions')?.title, 'Functions');
      expect(path.findConcept('does-not-exist'), isNull);
      expect(path.conceptCount, 1);
    });

    test('an unrecognized difficulty string falls back to beginner instead of throwing', () {
      expect(Difficulty.fromJson('legendary'), Difficulty.beginner);
    });

    test('languageForLearningPathId maps react to javascript and defaults to python', () {
      expect(languageForLearningPathId('react'), 'javascript');
      expect(languageForLearningPathId('python'), 'python');
      expect(languageForLearningPathId('java'), 'python');
    });
  });
}
