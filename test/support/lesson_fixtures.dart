import 'package:teacher/features/curriculum/domain/models/assessment.dart';
import 'package:teacher/features/curriculum/domain/models/concept.dart';
import 'package:teacher/features/curriculum/domain/models/difficulty.dart';
import 'package:teacher/features/curriculum/domain/models/exercise.dart';
import 'package:teacher/features/curriculum/domain/models/item_type.dart';

String para(String word, [int words = 40]) =>
    List.filled(words, word).join(' ');

Concept lessonConcept({
  String id = 'c1',
  List<String> objectives = const ['Know names', 'Know objects'],
  List<String> prerequisites = const [],
  List<ExplanationSection>? sections,
  List<ConceptExample>? examples,
  List<Misconception>? misconceptions,
  List<Exercise>? exercises,
  List<Assessment>? assessments,
}) => Concept(
  id: id,
  title: 'Variables',
  description: 'Names and objects.',
  learningPathId: 'python',
  moduleId: 'm1',
  topicId: 't1',
  difficulty: Difficulty.beginner,
  estimatedMinutes: 10,
  prerequisites: prerequisites,
  learningObjectives: objectives,
  explanation: ConceptExplanation(
    sections:
        sections ??
        [
          ExplanationSection(
            heading: 'Labels',
            body: '${para('alpha')}\n\n${para('beta')}',
          ),
          ExplanationSection(heading: 'Identity', body: para('gamma', 20)),
          ExplanationSection(heading: 'Mutability', body: para('delta', 20)),
        ],
  ),
  examples:
      examples ??
      const [
        ConceptExample(
          title: 'Aliasing',
          language: 'python',
          code: 'x = [1]\ny = x',
          explanation: 'Both names share one list.',
        ),
        ConceptExample(
          title: 'Copying',
          language: 'python',
          code: 'y = list(x)',
          explanation: 'A new list.',
        ),
      ],
  misconceptions:
      misconceptions ??
      const [
        Misconception(
          description: 'Assignment copies the value.',
          clarification: 'Assignment binds a name to the same object.',
        ),
      ],
  exercises:
      exercises ??
      const [
        Exercise(
          id: 'c1-ex1',
          type: ItemType.predictOutput,
          prompt: 'What prints?',
          hints: [],
          code: 'print(1)',
          expectedAnswer: '1',
        ),
      ],
  assessments:
      assessments ??
      const [
        Assessment(
          id: 'c1-a1',
          type: ItemType.multipleChoice,
          prompt: 'Which operator checks identity?',
          options: ['==', 'is'],
          correctOptionIndex: 1,
          explanation: '`is` compares identity.',
        ),
      ],
);
