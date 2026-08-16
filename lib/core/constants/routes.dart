/// Centralized route paths — see instructions.md section 30.
class Routes {
  Routes._();

  static const dashboard = '/';
  static const learn = '/learn';
  static const practice = '/practice';
  static const review = '/review';
  static const progress = '/progress';
  static const settings = '/settings';
  static const flashCard = '/flash-card';
  static const onboarding = '/onboarding';

  static String learningPath(String pathId) => '/learn/$pathId';
  static String module(String pathId, String moduleId) =>
      '/learn/$pathId/$moduleId';
  static String lesson(String pathId, String moduleId, String conceptId) =>
      '/learn/$pathId/$moduleId/$conceptId';
  static String practiceSession(String conceptId) => '/practice/$conceptId';
  static String reviewSession(String conceptId) => '/review/$conceptId';
}
