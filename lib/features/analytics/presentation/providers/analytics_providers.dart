import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/data_revision_provider.dart';
import '../../../assessment/presentation/providers/assessment_providers.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../domain/learning_analytics_service.dart';
import '../../domain/models/learning_analytics.dart';

/// Injectable clock so tests can pin "today".
final analyticsClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

final learningAnalyticsProvider = FutureProvider<LearningAnalytics>((
  ref,
) async {
  ref.watch(dataRevisionProvider);
  final attempts = await ref.watch(attemptsRepositoryProvider).getAllAttempts();
  final paths = await ref.watch(learningPathsProvider.future);
  return const LearningAnalyticsService().compute(
    attempts: attempts,
    paths: paths,
    now: ref.read(analyticsClockProvider)(),
  );
});
