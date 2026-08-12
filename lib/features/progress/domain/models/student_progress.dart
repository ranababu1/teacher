import 'package:equatable/equatable.dart';

/// Whether a learner has been through a concept's lesson — distinct from
/// [ConceptMastery], which tracks whether they actually understand it.
class StudentProgress extends Equatable {
  const StudentProgress({
    required this.conceptId,
    required this.learningPathId,
    required this.moduleId,
    required this.startedAt,
    required this.completedAt,
    required this.lastAccessedAt,
  });

  final String conceptId;
  final String learningPathId;
  final String moduleId;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? lastAccessedAt;

  bool get isStarted => startedAt != null;
  bool get isCompleted => completedAt != null;

  StudentProgress copyWith({
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? lastAccessedAt,
  }) {
    return StudentProgress(
      conceptId: conceptId,
      learningPathId: learningPathId,
      moduleId: moduleId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    );
  }

  @override
  List<Object?> get props => [
    conceptId,
    learningPathId,
    moduleId,
    startedAt,
    completedAt,
    lastAccessedAt,
  ];
}
