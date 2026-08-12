import 'package:equatable/equatable.dart';

import 'mastery_status.dart';

/// Evidence-based, multi-dimensional mastery for a single concept.
///
/// See instructions.md section 15 — deliberately not a single percentage.
class ConceptMastery extends Equatable {
  const ConceptMastery({
    required this.conceptId,
    required this.recallScore,
    required this.understandingScore,
    required this.applicationScore,
    required this.explanationScore,
    required this.codingScore,
    required this.debuggingScore,
    required this.overallMastery,
    required this.attemptCount,
    required this.successCount,
    required this.failureCount,
    required this.confidence,
    required this.lastReviewedAt,
    required this.nextReviewAt,
    required this.status,
  });

  final String conceptId;
  final double recallScore;
  final double understandingScore;
  final double applicationScore;
  final double explanationScore;
  final double codingScore;
  final double debuggingScore;
  final double overallMastery;
  final int attemptCount;
  final int successCount;
  final int failureCount;
  final double confidence;
  final DateTime? lastReviewedAt;
  final DateTime? nextReviewAt;
  final MasteryStatus status;

  static ConceptMastery empty(String conceptId) => ConceptMastery(
    conceptId: conceptId,
    recallScore: 0,
    understandingScore: 0,
    applicationScore: 0,
    explanationScore: 0,
    codingScore: 0,
    debuggingScore: 0,
    overallMastery: 0,
    attemptCount: 0,
    successCount: 0,
    failureCount: 0,
    confidence: 0,
    lastReviewedAt: null,
    nextReviewAt: null,
    status: MasteryStatus.notStarted,
  );

  ConceptMastery copyWith({
    double? recallScore,
    double? understandingScore,
    double? applicationScore,
    double? explanationScore,
    double? codingScore,
    double? debuggingScore,
    double? overallMastery,
    int? attemptCount,
    int? successCount,
    int? failureCount,
    double? confidence,
    DateTime? lastReviewedAt,
    DateTime? nextReviewAt,
    MasteryStatus? status,
  }) {
    return ConceptMastery(
      conceptId: conceptId,
      recallScore: recallScore ?? this.recallScore,
      understandingScore: understandingScore ?? this.understandingScore,
      applicationScore: applicationScore ?? this.applicationScore,
      explanationScore: explanationScore ?? this.explanationScore,
      codingScore: codingScore ?? this.codingScore,
      debuggingScore: debuggingScore ?? this.debuggingScore,
      overallMastery: overallMastery ?? this.overallMastery,
      attemptCount: attemptCount ?? this.attemptCount,
      successCount: successCount ?? this.successCount,
      failureCount: failureCount ?? this.failureCount,
      confidence: confidence ?? this.confidence,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    conceptId,
    recallScore,
    understandingScore,
    applicationScore,
    explanationScore,
    codingScore,
    debuggingScore,
    overallMastery,
    attemptCount,
    successCount,
    failureCount,
    confidence,
    lastReviewedAt,
    nextReviewAt,
    status,
  ];
}
