import 'lesson_step.dart';

/// Immutable navigation state for a step-by-step lesson: which step is
/// showing and which quick checks have been answered. Pure, so it is
/// unit-tested without widgets.
class LessonFlow {
  const LessonFlow({
    required this.steps,
    this.index = 0,
    this.answers = const {},
  });

  /// Starts at the step with [resumeStepId], or at the first step when it
  /// is unknown. Quick checks before the resume point count as answered so
  /// a resumed learner is not stuck behind a gate they already passed.
  factory LessonFlow.resume(List<LessonStep> steps, String? resumeStepId) {
    final at = resumeStepId == null
        ? -1
        : steps.indexWhere((s) => s.id == resumeStepId);
    if (at <= 0) return LessonFlow(steps: steps);
    return LessonFlow(
      steps: steps,
      index: at,
      answers: {
        for (final s in steps.take(at))
          if (s is QuickCheckStep) s.id: s.check.correctIndex,
      },
    );
  }

  final List<LessonStep> steps;
  final int index;

  /// Quick check step id to the option the learner picked.
  final Map<String, int> answers;

  bool get isEmpty => steps.isEmpty;
  LessonStep get current => steps[index];
  bool get isFirst => index == 0;
  bool get isLast => index == steps.length - 1;
  double get progress => steps.isEmpty ? 0 : (index + 1) / steps.length;

  bool isAnswered(LessonStep step) =>
      !step.gatesNext || answers.containsKey(step.id);

  bool get canGoNext => !isEmpty && isAnswered(current);

  /// Furthest step reachable without skipping an unanswered quick check.
  int get furthestReachable {
    for (var i = 0; i < steps.length; i++) {
      if (!isAnswered(steps[i])) return i;
    }
    return steps.length - 1;
  }

  bool canJumpTo(int target) =>
      target >= 0 && target < steps.length && target <= furthestReachable;

  LessonFlow next() => canGoNext && !isLast ? _copy(index: index + 1) : this;

  LessonFlow back() => isFirst ? this : _copy(index: index - 1);

  LessonFlow jumpTo(int target) =>
      canJumpTo(target) ? _copy(index: target) : this;

  LessonFlow answer(int option) {
    final step = current;
    if (step is! QuickCheckStep || answers.containsKey(step.id)) return this;
    return _copy(answers: {...answers, step.id: option});
  }

  LessonFlow _copy({int? index, Map<String, int>? answers}) => LessonFlow(
    steps: steps,
    index: index ?? this.index,
    answers: answers ?? this.answers,
  );
}
