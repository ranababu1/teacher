/// The outcome of one attempt at a module's topic test. Integer math
/// throughout (never float) so there's no rounding ambiguity right at the
/// 70% pass boundary.
class ModuleTestResult {
  const ModuleTestResult({
    required this.correctCount,
    required this.totalQuestions,
  });

  final int correctCount;
  final int totalQuestions;

  int get scorePercent =>
      totalQuestions == 0 ? 0 : (correctCount * 100) ~/ totalQuestions;

  bool get isPassed =>
      totalQuestions > 0 && correctCount * 100 >= totalQuestions * 70;
}
