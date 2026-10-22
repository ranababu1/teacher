import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../coding_challenges/presentation/providers/coding_challenge_providers.dart';
import '../../projects/presentation/providers/project_providers.dart';
import '../../system_design/presentation/providers/system_design_providers.dart';
import '../domain/build_progress.dart';

/// Progress across projects, system design and long-form challenges.
final buildProgressProvider = FutureProvider<BuildProgress>((ref) async {
  final projects = await ref.watch(projectOverviewsProvider.future);
  final designs = await ref.watch(systemDesignListProvider.future);
  final challenges = await ref.watch(codingChallengeListProvider.future);
  return BuildProgress.fromItems(
    projects: [
      for (final p in projects) (started: p.isStarted, complete: p.isComplete),
    ],
    systemDesignFinished: [for (final d in designs) d.record != null],
    challengesFinished: [for (final c in challenges) c.record != null],
  );
});
