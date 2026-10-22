import 'package:equatable/equatable.dart';

/// How much the learner already knows, as they describe it.
enum RoadmapLevel {
  beginner,
  intermediate,
  advanced;

  String get label => switch (this) {
    RoadmapLevel.beginner => 'New to it',
    RoadmapLevel.intermediate => 'Some experience',
    RoadmapLevel.advanced => 'Experienced',
  };

  static RoadmapLevel fromName(String? name) => RoadmapLevel.values.firstWhere(
    (l) => l.name == name,
    orElse: () => RoadmapLevel.beginner,
  );
}

/// What the learner asks for: a goal, where they start and their time.
class RoadmapGoal extends Equatable {
  const RoadmapGoal({
    required this.goal,
    required this.level,
    required this.hoursPerWeek,
    required this.weeks,
  });

  final String goal;
  final RoadmapLevel level;
  final int hoursPerWeek;
  final int weeks;

  static const minHours = 1;
  static const maxHours = 30;
  static const minWeeks = 1;
  static const maxWeeks = 26;

  /// Clamped copy, so stored or AI-echoed values can never go out of range.
  RoadmapGoal normalized() => RoadmapGoal(
    goal: goal.trim(),
    level: level,
    hoursPerWeek: hoursPerWeek.clamp(minHours, maxHours),
    weeks: weeks.clamp(minWeeks, maxWeeks),
  );

  Map<String, dynamic> toJson() => {
    'goal': goal,
    'level': level.name,
    'hoursPerWeek': hoursPerWeek,
    'weeks': weeks,
  };

  factory RoadmapGoal.fromJson(Map<String, dynamic> json) => RoadmapGoal(
    goal: json['goal'] as String? ?? '',
    level: RoadmapLevel.fromName(json['level'] as String?),
    hoursPerWeek: (json['hoursPerWeek'] as num?)?.toInt() ?? 5,
    weeks: (json['weeks'] as num?)?.toInt() ?? 8,
  ).normalized();

  @override
  List<Object?> get props => [goal, level, hoursPerWeek, weeks];
}

/// The kinds of existing app content a roadmap can point at.
enum RoadmapItemKind {
  topic,
  project,
  systemDesign,
  challenge;

  String get label => switch (this) {
    RoadmapItemKind.topic => 'Topic',
    RoadmapItemKind.project => 'Project',
    RoadmapItemKind.systemDesign => 'System design',
    RoadmapItemKind.challenge => 'Coding challenge',
  };

  static RoadmapItemKind? fromName(String? name) {
    for (final k in RoadmapItemKind.values) {
      if (k.name == name) return k;
    }
    return null;
  }
}

/// One step of a roadmap. [refId] is a real content id: `pathId/moduleId`
/// for a topic, otherwise the project, exercise or challenge id.
class RoadmapItem extends Equatable {
  const RoadmapItem({
    required this.kind,
    required this.refId,
    required this.title,
    this.note = '',
  });

  final RoadmapItemKind kind;
  final String refId;
  final String title;

  /// Why this step is here (from the AI or the offline rules).
  final String note;

  String get key => '${kind.name}:$refId';

  Map<String, dynamic> toJson() => {
    'kind': kind.name,
    'refId': refId,
    'title': title,
    'note': note,
  };

  static RoadmapItem? fromJson(Map<String, dynamic> json) {
    final kind = RoadmapItemKind.fromName(json['kind'] as String?);
    final refId = json['refId'] as String?;
    if (kind == null || refId == null || refId.isEmpty) return null;
    return RoadmapItem(
      kind: kind,
      refId: refId,
      title: json['title'] as String? ?? refId,
      note: json['note'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [kind, refId, title, note];
}

class RoadmapWeek extends Equatable {
  const RoadmapWeek({required this.focus, required this.items});

  final String focus;
  final List<RoadmapItem> items;

  RoadmapWeek copyWith({String? focus, List<RoadmapItem>? items}) =>
      RoadmapWeek(focus: focus ?? this.focus, items: items ?? this.items);

  Map<String, dynamic> toJson() => {
    'focus': focus,
    'items': [for (final i in items) i.toJson()],
  };

  factory RoadmapWeek.fromJson(Map<String, dynamic> json) => RoadmapWeek(
    focus: json['focus'] as String? ?? '',
    items: [
      for (final raw in (json['items'] as List<dynamic>? ?? const []))
        if (raw is Map<String, dynamic>) ?RoadmapItem.fromJson(raw),
    ],
  );

  @override
  List<Object?> get props => [focus, items];
}

/// Who built the roadmap.
enum RoadmapSource {
  ai,
  offline;

  static RoadmapSource fromName(String? name) => RoadmapSource.values
      .firstWhere((s) => s.name == name, orElse: () => RoadmapSource.offline);
}

/// A saved, editable plan built only from the app's own content.
class Roadmap extends Equatable {
  const Roadmap({
    required this.goal,
    required this.summary,
    required this.weeks,
    required this.source,
    required this.createdAt,
  });

  final RoadmapGoal goal;
  final String summary;
  final List<RoadmapWeek> weeks;
  final RoadmapSource source;
  final DateTime createdAt;

  List<RoadmapItem> get allItems => [for (final w in weeks) ...w.items];

  bool get isEmpty => allItems.isEmpty;

  Roadmap copyWith({List<RoadmapWeek>? weeks}) => Roadmap(
    goal: goal,
    summary: summary,
    weeks: weeks ?? this.weeks,
    source: source,
    createdAt: createdAt,
  );

  /// Removes the item with [itemKey]; empty weeks stay so numbering holds.
  Roadmap removeItem(String itemKey) => copyWith(
    weeks: [
      for (final w in weeks)
        w.copyWith(
          items: [
            for (final i in w.items)
              if (i.key != itemKey) i,
          ],
        ),
    ],
  );

  /// Moves an item one week earlier (-1) or later (+1), appending it to the
  /// end (or start, when moving earlier) of that week. Out of range: no-op.
  Roadmap moveItem(String itemKey, int delta) {
    final from = weeks.indexWhere((w) => w.items.any((i) => i.key == itemKey));
    final to = from + delta;
    if (from < 0 || to < 0 || to >= weeks.length || delta == 0) return this;
    final item = weeks[from].items.firstWhere((i) => i.key == itemKey);
    return copyWith(
      weeks: [
        for (final (index, w) in weeks.indexed)
          if (index == from)
            w.copyWith(
              items: [
                for (final i in w.items)
                  if (i != item) i,
              ],
            )
          else if (index == to)
            w.copyWith(
              items: delta > 0 ? [item, ...w.items] : [...w.items, item],
            )
          else
            w,
      ],
    );
  }

  Map<String, dynamic> toJson() => {
    'version': 1,
    'goal': goal.toJson(),
    'summary': summary,
    'weeks': [for (final w in weeks) w.toJson()],
    'source': source.name,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Roadmap.fromJson(Map<String, dynamic> json) => Roadmap(
    goal: RoadmapGoal.fromJson(
      json['goal'] as Map<String, dynamic>? ?? const {},
    ),
    summary: json['summary'] as String? ?? '',
    weeks: [
      for (final raw in (json['weeks'] as List<dynamic>? ?? const []))
        if (raw is Map<String, dynamic>) RoadmapWeek.fromJson(raw),
    ],
    source: RoadmapSource.fromName(json['source'] as String?),
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );

  @override
  List<Object?> get props => [goal, summary, weeks, source, createdAt];
}
