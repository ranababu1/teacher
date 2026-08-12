import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../curriculum/domain/models/concept.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../data/review_schedule_repository_impl.dart';
import '../../domain/models/review_schedule.dart';
import '../../domain/review_schedule_repository.dart';

final reviewScheduleRepositoryProvider = Provider<ReviewScheduleRepository>((
  ref,
) {
  return ReviewScheduleRepositoryImpl(ref.watch(appDatabaseProvider));
});

final dueSchedulesProvider = FutureProvider<List<ReviewSchedule>>((ref) {
  return ref.watch(reviewScheduleRepositoryProvider).getDueSchedules();
});

/// Concepts due for review right now, resolved against curriculum content.
final dueForReviewProvider = FutureProvider<List<Concept>>((ref) async {
  final schedules = await ref.watch(dueSchedulesProvider.future);
  final repository = ref.watch(curriculumRepositoryProvider);

  final concepts = <Concept>[];
  for (final schedule in schedules) {
    final concept = await repository.getConcept(schedule.conceptId);
    if (concept != null) concepts.add(concept);
  }
  return concepts;
});
