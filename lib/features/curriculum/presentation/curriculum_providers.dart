import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/curriculum_repository_impl.dart';
import '../domain/curriculum_repository.dart';
import '../domain/models/concept.dart';
import '../domain/models/learning_path.dart';

final curriculumRepositoryProvider = Provider<CurriculumRepository>((ref) {
  return CurriculumRepositoryImpl(rootBundle);
});

final learningPathsProvider = FutureProvider<List<LearningPath>>((ref) {
  return ref.watch(curriculumRepositoryProvider).getLearningPaths();
});

final learningPathProvider = FutureProvider.family<LearningPath?, String>((
  ref,
  pathId,
) {
  return ref.watch(curriculumRepositoryProvider).getLearningPath(pathId);
});

final conceptProvider = FutureProvider.family<Concept?, String>((
  ref,
  conceptId,
) {
  return ref.watch(curriculumRepositoryProvider).getConcept(conceptId);
});

final prerequisiteConceptsProvider =
    FutureProvider.family<List<Concept>, String>((ref, conceptId) {
      return ref
          .watch(curriculumRepositoryProvider)
          .getPrerequisiteConcepts(conceptId);
    });
