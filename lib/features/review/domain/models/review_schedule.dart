import 'package:equatable/equatable.dart';

class ReviewSchedule extends Equatable {
  const ReviewSchedule({
    required this.conceptId,
    required this.dueAt,
    required this.intervalDays,
    required this.lastReviewedAt,
    required this.reviewCount,
  });

  final String conceptId;
  final DateTime dueAt;
  final int intervalDays;
  final DateTime? lastReviewedAt;
  final int reviewCount;

  bool get isDue => !dueAt.isAfter(DateTime.now());

  static ReviewSchedule initial(String conceptId) => ReviewSchedule(
    conceptId: conceptId,
    dueAt: DateTime.now(),
    intervalDays: 0,
    lastReviewedAt: null,
    reviewCount: 0,
  );

  @override
  List<Object?> get props => [
    conceptId,
    dueAt,
    intervalDays,
    lastReviewedAt,
    reviewCount,
  ];
}
