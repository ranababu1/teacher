import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/assessment/domain/models/attempt_outcome.dart';
import 'package:teacher/features/curriculum/domain/models/item_type.dart';
import 'package:teacher/features/progress/domain/mastery_calculator.dart';
import 'package:teacher/features/progress/domain/models/concept_mastery.dart';
import 'package:teacher/features/progress/domain/models/mastery_status.dart';

void main() {
  final calculator = MasteryCalculator();

  group('MasteryCalculator', () {
    test('a brand-new concept starts at notStarted with zero scores', () {
      final mastery = ConceptMastery.empty('python-closures');
      expect(mastery.status, MasteryStatus.notStarted);
      expect(mastery.overallMastery, 0);
    });

    test(
      'a correct multiple-choice attempt raises recallScore and overallMastery',
      () {
        final initial = ConceptMastery.empty('python-closures');

        final updated = calculator.recompute(
          current: initial,
          itemType: ItemType.multipleChoice,
          outcome: const AttemptOutcome(
            isCorrect: true,
            selfRating: null,
            hintsUsed: 0,
          ),
        );

        expect(updated.recallScore, greaterThan(0));
        expect(updated.overallMastery, updated.recallScore);
        expect(updated.attemptCount, 1);
        expect(updated.successCount, 1);
        expect(updated.status, MasteryStatus.learning);
      },
    );

    test('only dimensions with evidence count toward overallMastery', () {
      final initial = ConceptMastery.empty('python-closures');

      final afterCoding = calculator.recompute(
        current: initial,
        itemType: ItemType.coding,
        outcome: const AttemptOutcome(
          isCorrect: null,
          selfRating: SelfRating.easy,
          hintsUsed: 0,
        ),
      );

      // Only codingScore has been touched, so overall == codingScore exactly,
      // not diluted by the five other still-zero dimensions.
      expect(afterCoding.overallMastery, afterCoding.codingScore);
      expect(afterCoding.recallScore, 0);
      expect(afterCoding.debuggingScore, 0);
    });

    test('repeated strong performance moves status toward mastered', () {
      var mastery = ConceptMastery.empty('python-closures');
      for (var i = 0; i < 10; i++) {
        mastery = calculator.recompute(
          current: mastery,
          itemType: ItemType.multipleChoice,
          outcome: const AttemptOutcome(
            isCorrect: true,
            selfRating: null,
            hintsUsed: 0,
          ),
        );
      }

      expect(mastery.overallMastery, greaterThanOrEqualTo(0.85));
      expect(mastery.status, MasteryStatus.mastered);
    });

    test('an overdue, previously-strong concept is flagged needsReview', () {
      var mastery = ConceptMastery.empty('python-closures');
      for (var i = 0; i < 5; i++) {
        mastery = calculator.recompute(
          current: mastery,
          itemType: ItemType.explanation,
          outcome: const AttemptOutcome(
            isCorrect: null,
            selfRating: SelfRating.easy,
            hintsUsed: 0,
          ),
        );
      }

      final overdue = calculator.recompute(
        current: mastery,
        itemType: ItemType.explanation,
        outcome: const AttemptOutcome(
          isCorrect: null,
          selfRating: SelfRating.good,
          hintsUsed: 0,
        ),
        isOverdueForReview: true,
      );

      expect(overdue.status, MasteryStatus.needsReview);
    });

    test('a poor attempt still lowers the quality score meaningfully', () {
      final initial = ConceptMastery.empty('python-closures');
      final afterGood = calculator.recompute(
        current: initial,
        itemType: ItemType.debugging,
        outcome: const AttemptOutcome(
          isCorrect: null,
          selfRating: SelfRating.easy,
          hintsUsed: 0,
        ),
      );
      final afterPoor = calculator.recompute(
        current: afterGood,
        itemType: ItemType.debugging,
        outcome: const AttemptOutcome(
          isCorrect: null,
          selfRating: SelfRating.again,
          hintsUsed: 3,
        ),
      );

      expect(afterPoor.debuggingScore, lessThan(afterGood.debuggingScore));
      expect(afterPoor.failureCount, 1);
    });
  });
}
