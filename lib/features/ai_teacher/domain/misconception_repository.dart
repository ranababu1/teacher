import 'models/detected_misconception.dart';

abstract class MisconceptionRepository {
  /// Unresolved misconceptions for this concept, most recent first.
  Future<List<DetectedMisconception>> getUnresolvedForConcept(
    String conceptId,
  );

  /// Records a newly AI-detected misconception. Confidence defaults to 1.0
  /// (matches the table's SQL default) when the AI doesn't provide one.
  Future<DetectedMisconception> recordMisconception({
    required String conceptId,
    required String description,
    double confidence = 1.0,
  });

  Future<void> resolveMisconception(int id);
}
