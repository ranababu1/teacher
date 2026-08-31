/// A started course's performance tier, shown as a small badge next to
/// its name on the Profile screen's "My Skills" list. [inProgress] for
/// anything not yet 100% complete; once complete, the tier is derived
/// from the average score across that course's genuinely-passed topic
/// quizzes (excluding grandfathered rows, which were never a real
/// attempt) — courses with no scored quiz default to [passed].
enum CourseStatus {
  inProgress,
  passed,
  expert,
  legend;

  static CourseStatus fromCompletion({
    required double overallPercent,
    required List<int> passedModuleScores,
  }) {
    if (overallPercent < 1.0) return CourseStatus.inProgress;
    if (passedModuleScores.isEmpty) return CourseStatus.passed;
    final average =
        passedModuleScores.reduce((a, b) => a + b) / passedModuleScores.length;
    if (average >= 90) return CourseStatus.legend;
    if (average >= 75) return CourseStatus.expert;
    return CourseStatus.passed;
  }

  String get label => switch (this) {
    CourseStatus.inProgress => 'In Progress',
    CourseStatus.passed => 'Passed',
    CourseStatus.expert => 'Expert',
    CourseStatus.legend => 'Legend',
  };
}
