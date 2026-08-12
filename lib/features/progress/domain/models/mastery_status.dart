enum MasteryStatus {
  notStarted,
  learning,
  developing,
  proficient,
  mastered,
  needsReview;

  static MasteryStatus fromJson(String value) {
    return MasteryStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => MasteryStatus.notStarted,
    );
  }

  String get label => switch (this) {
        MasteryStatus.notStarted => 'Not Started',
        MasteryStatus.learning => 'Learning',
        MasteryStatus.developing => 'Developing',
        MasteryStatus.proficient => 'Proficient',
        MasteryStatus.mastered => 'Mastered',
        MasteryStatus.needsReview => 'Needs Review',
      };
}
