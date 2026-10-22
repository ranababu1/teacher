import '../../../core/errors/app_exception.dart';
import '../../ai_teacher/domain/ai_provider.dart';
import '../../ai_teacher/domain/models/roadmap_generation.dart';
import 'models/roadmap.dart';
import 'models/roadmap_catalog.dart';
import 'offline_roadmap_builder.dart';
import 'roadmap_validator.dart';

/// Outcome of building a roadmap.
class RoadmapGenerationResult {
  const RoadmapGenerationResult({
    required this.roadmap,
    this.droppedItems = 0,
    this.fellBackOffline = false,
  });

  final Roadmap roadmap;

  /// AI suggestions removed because they did not match real content.
  final int droppedItems;

  /// True when the AI was asked but no key or network was available, so
  /// the rule-based plan was used instead.
  final bool fellBackOffline;
}

/// Builds a roadmap with the AI (validated against the catalog), or the
/// rule-based offline builder.
class GenerateRoadmapUseCase {
  GenerateRoadmapUseCase({
    required AIProvider aiProvider,
    this.validator = const RoadmapValidator(),
    this.offlineBuilder = const OfflineRoadmapBuilder(),
  }) : _ai = aiProvider;

  final AIProvider _ai;
  final RoadmapValidator validator;
  final OfflineRoadmapBuilder offlineBuilder;

  Roadmap buildOffline({
    required RoadmapGoal goal,
    required RoadmapCatalog catalog,
    required RoadmapCompletion completion,
    DateTime? now,
  }) {
    if (catalog.isEmpty) {
      throw const ContentNotFoundException('No course content is available');
    }
    return offlineBuilder.build(
      goal: goal.normalized(),
      catalog: catalog,
      completion: completion,
      now: now ?? DateTime.now(),
    );
  }

  /// Asks the AI. Falls back to [buildOffline] only when the AI cannot be
  /// reached at all (no key, no network); other failures are rethrown so
  /// the screen can offer a retry.
  Future<RoadmapGenerationResult> generate({
    required RoadmapGoal goal,
    required RoadmapCatalog catalog,
    required RoadmapCompletion completion,
    DateTime? now,
  }) async {
    final normalized = goal.normalized();
    final at = now ?? DateTime.now();
    if (catalog.isEmpty) {
      throw const ContentNotFoundException('No course content is available');
    }
    try {
      final draft = await _ai.generateRoadmap(
        RoadmapGenerationRequest(
          goal: normalized.goal,
          level: normalized.level.name,
          hoursPerWeek: normalized.hoursPerWeek,
          weeks: normalized.weeks,
          catalog: catalog.toPromptText(),
          learnerSummary: learnerSummary(catalog, completion),
        ),
      );
      final result = validator.validate(
        draft: draft,
        catalog: catalog,
        goal: normalized,
        now: at,
      );
      return RoadmapGenerationResult(
        roadmap: result.roadmap,
        droppedItems: result.droppedItems,
      );
    } on AIUnavailableException {
      return _fallback(normalized, catalog, completion, at);
    } on NetworkUnavailableException {
      return _fallback(normalized, catalog, completion, at);
    }
  }

  RoadmapGenerationResult _fallback(
    RoadmapGoal goal,
    RoadmapCatalog catalog,
    RoadmapCompletion completion,
    DateTime now,
  ) => RoadmapGenerationResult(
    roadmap: offlineBuilder.build(
      goal: goal,
      catalog: catalog,
      completion: completion,
      now: now,
    ),
    fellBackOffline: true,
  );

  /// Short progress summary so the AI can skip what is already done.
  static String learnerSummary(
    RoadmapCatalog catalog,
    RoadmapCompletion completion,
  ) {
    final lines = <String>[];
    for (final c in catalog.courses) {
      final passed = c.topics
          .where((t) => completion.passedTopicIds.contains(t.id))
          .map((t) => t.id)
          .toList();
      if (passed.isEmpty) continue;
      lines.add(
        '${c.id}: passed ${passed.length} of ${c.topics.length} topics '
        '(${passed.join(', ')})',
      );
    }
    final done = [
      ...completion.completedProjectIds,
      ...completion.finishedDesignIds,
      ...completion.finishedChallengeIds,
    ];
    if (done.isNotEmpty) lines.add('Finished: ${done.join(', ')}');
    if (lines.isEmpty) return 'Progress so far: nothing completed yet.';
    return 'Progress so far (do not plan these again):\n${lines.join('\n')}';
  }
}
