enum Difficulty {
  beginner,
  intermediate,
  advanced;

  static Difficulty fromJson(String value) {
    return Difficulty.values.firstWhere(
      (d) => d.name == value,
      orElse: () => Difficulty.beginner,
    );
  }

  String get label => switch (this) {
        Difficulty.beginner => 'Beginner',
        Difficulty.intermediate => 'Intermediate',
        Difficulty.advanced => 'Advanced',
      };
}
