import 'models/concept_mastery.dart';

abstract class ConceptMasteryRepository {
  Future<ConceptMastery> getMastery(String conceptId);

  Future<List<ConceptMastery>> getAllMastery();

  Future<void> saveMastery(ConceptMastery mastery);
}
