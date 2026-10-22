import 'package:equatable/equatable.dart';

/// What the AI sees when building a personalised roadmap: the learner's
/// goal and the app's own content catalog (ids and titles only). The AI
/// may only choose from that catalog; its answer is validated afterwards.
class RoadmapGenerationRequest extends Equatable {
  const RoadmapGenerationRequest({
    required this.goal,
    required this.level,
    required this.hoursPerWeek,
    required this.weeks,
    required this.catalog,
    this.learnerSummary = '',
  });

  final String goal;

  /// "beginner", "intermediate" or "advanced".
  final String level;
  final int hoursPerWeek;
  final int weeks;

  /// Plain-text listing of every usable item, id first.
  final String catalog;

  /// Short note on what the learner has already finished.
  final String learnerSummary;

  @override
  List<Object?> get props => [
    goal,
    level,
    hoursPerWeek,
    weeks,
    catalog,
    learnerSummary,
  ];
}

class RoadmapDraftItem extends Equatable {
  const RoadmapDraftItem({
    required this.kind,
    required this.id,
    this.note = '',
  });

  final String kind;
  final String id;
  final String note;

  @override
  List<Object?> get props => [kind, id, note];
}

class RoadmapDraftWeek extends Equatable {
  const RoadmapDraftWeek({required this.focus, required this.items});

  final String focus;
  final List<RoadmapDraftItem> items;

  @override
  List<Object?> get props => [focus, items];
}

/// The AI's unvalidated plan.
class RoadmapDraft extends Equatable {
  const RoadmapDraft({required this.summary, required this.weeks});

  final String summary;
  final List<RoadmapDraftWeek> weeks;

  @override
  List<Object?> get props => [summary, weeks];
}
