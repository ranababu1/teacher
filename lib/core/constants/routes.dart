/// Centralized route paths — see instructions.md section 30.
class Routes {
  Routes._();

  static const dashboard = '/';
  static const learn = '/learn';
  static const practice = '/practice';
  static const review = '/review';
  static const progress = '/progress';
  static const profile = '/profile';
  static const flashCard = '/flash-card';
  static const onboarding = '/onboarding';

  /// Settings is a full-screen page pushed over whatever is open, so back
  /// always returns to the screen that opened it.
  static const settings = '/settings';

  /// Pre-0.17 location of Settings; kept as a redirect so old links work.
  static String get legacyProfileSettings => '$profile/settings';

  static String learningPath(String pathId) => '/learn/$pathId';
  static String module(String pathId, String moduleId) =>
      '/learn/$pathId/$moduleId';
  static String moduleTest(String pathId, String moduleId) =>
      '/learn/$pathId/$moduleId/test';
  static String lesson(String pathId, String moduleId, String conceptId) =>
      '/learn/$pathId/$moduleId/$conceptId';
  static String practiceSession(String conceptId) => '/practice/$conceptId';
  static String reviewSession(String conceptId) => '/review/$conceptId';
}
