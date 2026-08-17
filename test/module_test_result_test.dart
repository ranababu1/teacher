import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/progress/domain/models/module_test_result.dart';

void main() {
  group('ModuleTestResult', () {
    test('exactly 70% passes', () {
      const result = ModuleTestResult(correctCount: 7, totalQuestions: 10);
      expect(result.scorePercent, 70);
      expect(result.isPassed, isTrue);
    });

    test('just under 70% fails', () {
      const result = ModuleTestResult(correctCount: 2, totalQuestions: 3);
      expect(result.scorePercent, 66);
      expect(result.isPassed, isFalse);
    });

    test('a perfect score passes', () {
      const result = ModuleTestResult(correctCount: 10, totalQuestions: 10);
      expect(result.scorePercent, 100);
      expect(result.isPassed, isTrue);
    });

    test('a zero score fails', () {
      const result = ModuleTestResult(correctCount: 0, totalQuestions: 10);
      expect(result.scorePercent, 0);
      expect(result.isPassed, isFalse);
    });

    test('zero total questions scores 0% and does not divide by zero', () {
      const result = ModuleTestResult(correctCount: 0, totalQuestions: 0);
      expect(result.scorePercent, 0);
      expect(result.isPassed, isFalse);
    });
  });
}
