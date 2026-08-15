import 'package:equatable/equatable.dart';

/// A misconception dynamically detected by the AI teacher from a learner's
/// responses, as opposed to the statically curriculum-authored
/// `Misconception` in `lib/features/curriculum/domain/models/concept.dart`
/// (which has no id/timestamps and is populated from JSON, not the AI).
class DetectedMisconception extends Equatable {
  const DetectedMisconception({
    required this.id,
    required this.conceptId,
    required this.description,
    required this.detectedAt,
    required this.confidence,
    this.resolvedAt,
  });

  final int id;
  final String conceptId;
  final String description;
  final DateTime detectedAt;
  final double confidence;
  final DateTime? resolvedAt;

  bool get isResolved => resolvedAt != null;

  @override
  List<Object?> get props => [
    id,
    conceptId,
    description,
    detectedAt,
    confidence,
    resolvedAt,
  ];
}
