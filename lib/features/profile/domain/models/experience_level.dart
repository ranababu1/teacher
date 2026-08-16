/// A coarse XP-based tier shown under the learner's name on the Profile
/// screen. See instructions.md section 45.
enum ExperienceLevel {
  newDeveloper,
  beginnerDeveloper,
  juniorDeveloper,
  intermediateDeveloper,
  advancedDeveloper;

  static ExperienceLevel forXp(int xp) {
    if (xp >= 15000) return ExperienceLevel.advancedDeveloper;
    if (xp >= 6000) return ExperienceLevel.intermediateDeveloper;
    if (xp >= 2000) return ExperienceLevel.juniorDeveloper;
    if (xp >= 500) return ExperienceLevel.beginnerDeveloper;
    return ExperienceLevel.newDeveloper;
  }

  String get label => switch (this) {
    ExperienceLevel.newDeveloper => 'New Developer',
    ExperienceLevel.beginnerDeveloper => 'Beginner Developer',
    ExperienceLevel.juniorDeveloper => 'Junior Developer',
    ExperienceLevel.intermediateDeveloper => 'Intermediate Developer',
    ExperienceLevel.advancedDeveloper => 'Advanced Developer',
  };
}
