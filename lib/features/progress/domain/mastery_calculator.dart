import '../../assessment/domain/models/attempt_outcome.dart';
import '../../curriculum/domain/models/item_type.dart';
import 'models/concept_mastery.dart';
import 'models/mastery_status.dart';

/// Turns a single attempt into an updated, evidence-based mastery record.
///
/// Each [ItemType] feeds a specific mastery dimension (see instructions.md
/// section 2 for the dimensions and section 15 for the model). Scores move
/// via an exponential moving average so recent performance matters more
/// than the full history, which keeps the model adaptive without needing a
/// full history scan on every attempt.
class MasteryCalculator {
  static const _emaAlpha = 0.3;

  ConceptMastery recompute({
    required ConceptMastery current,
    required ItemType itemType,
    required AttemptOutcome outcome,
    bool isOverdueForReview = false,
  }) {
    final quality = outcome.qualityScore;

    double ema(double previous) => _emaAlpha * quality + (1 - _emaAlpha) * previous;

    var recall = current.recallScore;
    var understanding = current.understandingScore;
    var application = current.applicationScore;
    var explanation = current.explanationScore;
    var coding = current.codingScore;
    var debugging = current.debuggingScore;

    switch (itemType) {
      case ItemType.multipleChoice:
        recall = ema(recall);
      case ItemType.shortAnswer:
      case ItemType.predictOutput:
        understanding = ema(understanding);
      case ItemType.scenario:
        application = ema(application);
      case ItemType.explanation:
        explanation = ema(explanation);
      case ItemType.coding:
        coding = ema(coding);
      case ItemType.debugging:
        debugging = ema(debugging);
    }

    final touchedScores = [recall, understanding, application, explanation, coding, debugging]
        .where((s) => s > 0)
        .toList();
    final overall = touchedScores.isEmpty
        ? 0.0
        : touchedScores.reduce((a, b) => a + b) / touchedScores.length;

    final attemptCount = current.attemptCount + 1;
    final isSuccess = quality >= 0.6;

    final status = _statusFor(
      overallMastery: overall,
      attemptCount: attemptCount,
      isOverdueForReview: isOverdueForReview,
    );

    return current.copyWith(
      recallScore: recall,
      understandingScore: understanding,
      applicationScore: application,
      explanationScore: explanation,
      codingScore: coding,
      debuggingScore: debugging,
      overallMastery: overall,
      attemptCount: attemptCount,
      successCount: current.successCount + (isSuccess ? 1 : 0),
      failureCount: current.failureCount + (isSuccess ? 0 : 1),
      confidence: (attemptCount / 5).clamp(0, 1).toDouble(),
      status: status,
    );
  }

  MasteryStatus _statusFor({
    required double overallMastery,
    required int attemptCount,
    required bool isOverdueForReview,
  }) {
    if (attemptCount == 0) return MasteryStatus.notStarted;

    if (overallMastery >= 0.65 && isOverdueForReview) {
      return MasteryStatus.needsReview;
    }
    if (overallMastery >= 0.85) return MasteryStatus.mastered;
    if (overallMastery >= 0.65) return MasteryStatus.proficient;
    if (overallMastery >= 0.35) return MasteryStatus.developing;
    return MasteryStatus.learning;
  }
}
