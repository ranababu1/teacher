import '../../curriculum/domain/models/assessment.dart';
import '../../curriculum/domain/models/concept.dart';
import '../../curriculum/domain/models/exercise.dart';

/// A short, ungraded question shown between explanation chunks. Answering
/// (right or wrong) unlocks Next; it never records an attempt.
class QuickCheck {
  const QuickCheck({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.feedback,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;

  /// Shown after answering, whatever the answer.
  final String feedback;

  bool isCorrect(int index) => index == correctIndex;
}

/// One screen of the step-by-step lesson.
sealed class LessonStep {
  const LessonStep();

  /// Stable id used to resume a lesson where the learner left it.
  String get id;

  /// Short label for the progress header and the step list.
  String get title;

  /// Whether Next stays locked until this step is answered.
  bool get gatesNext => false;
}

class GoalsStep extends LessonStep {
  const GoalsStep({required this.objectives, required this.hasPrerequisites});

  final List<String> objectives;
  final bool hasPrerequisites;

  @override
  String get id => 'goals';

  @override
  String get title => 'Goals';
}

class ExplanationStep extends LessonStep {
  const ExplanationStep({
    required this.index,
    required this.heading,
    required this.body,
    required this.part,
    required this.partCount,
  });

  /// Position among all explanation chunks of the lesson (0-based).
  final int index;
  final String heading;
  final String body;

  /// 1-based part of [heading] when a section was split, out of [partCount].
  final int part;
  final int partCount;

  @override
  String get id => 'explain-$index';

  @override
  String get title => partCount > 1 ? '$heading ($part/$partCount)' : heading;
}

class QuickCheckStep extends LessonStep {
  const QuickCheckStep({required this.index, required this.check});

  final int index;
  final QuickCheck check;

  @override
  String get id => 'quick-check-$index';

  @override
  String get title => 'Quick check';

  @override
  bool get gatesNext => true;
}

class ExampleStep extends LessonStep {
  const ExampleStep({
    required this.index,
    required this.count,
    required this.example,
  });

  final int index;
  final int count;
  final ConceptExample example;

  @override
  String get id => 'example-$index';

  @override
  String get title => example.title.isEmpty
      ? 'Example ${index + 1} of $count'
      : 'Example: ${example.title}';
}

class MisconceptionsStep extends LessonStep {
  const MisconceptionsStep({required this.misconceptions});

  final List<Misconception> misconceptions;

  @override
  String get id => 'misconceptions';

  @override
  String get title => 'Common misconceptions';
}

class TryItStep extends LessonStep {
  const TryItStep({required this.exercises});

  final List<Exercise> exercises;

  @override
  String get id => 'try-it';

  @override
  String get title => 'Try it';
}

class CheckUnderstandingStep extends LessonStep {
  const CheckUnderstandingStep({required this.assessments});

  final List<Assessment> assessments;

  @override
  String get id => 'check';

  @override
  String get title => 'Check your understanding';
}
