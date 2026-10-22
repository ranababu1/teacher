import '../../../core/errors/app_exception.dart';
import '../../ai_teacher/domain/models/roadmap_generation.dart';
import 'models/roadmap.dart';
import 'models/roadmap_catalog.dart';

/// A validated roadmap plus how many AI items were thrown away.
typedef ValidatedRoadmap = ({Roadmap roadmap, int droppedItems});

/// Turns an AI draft into a [Roadmap] that only references real content:
/// unknown kinds or ids and duplicates are dropped, titles come from the
/// catalog (never from the AI), and extra weeks are cut to the goal.
class RoadmapValidator {
  const RoadmapValidator();

  ValidatedRoadmap validate({
    required RoadmapDraft draft,
    required RoadmapCatalog catalog,
    required RoadmapGoal goal,
    required DateTime now,
  }) {
    var dropped = 0;
    final seen = <String>{};
    final weeks = <RoadmapWeek>[];
    for (final (index, w) in draft.weeks.indexed) {
      if (index >= goal.weeks) {
        dropped += w.items.length;
        continue;
      }
      final items = <RoadmapItem>[];
      for (final d in w.items) {
        final kind = RoadmapItemKind.fromName(d.kind.trim());
        final id = d.id.trim();
        final entry = kind == null ? null : catalog.lookup(kind, id);
        if (kind == null || entry == null || !seen.add('${kind.name}:$id')) {
          dropped++;
          continue;
        }
        items.add(
          RoadmapItem(
            kind: kind,
            refId: entry.id,
            title: entry.title,
            note: _clip(d.note.trim(), 160),
          ),
        );
      }
      weeks.add(
        RoadmapWeek(
          focus: _clip(
            w.focus.trim().isEmpty ? 'Week ${index + 1}' : w.focus.trim(),
            80,
          ),
          items: items,
        ),
      );
    }
    if (weeks.every((w) => w.items.isEmpty)) {
      throw const InvalidAIResponseException(
        'AI roadmap referenced no content that exists in the app',
      );
    }
    return (
      roadmap: Roadmap(
        goal: goal,
        summary: _clip(draft.summary.trim(), 600),
        weeks: weeks,
        source: RoadmapSource.ai,
        createdAt: now,
      ),
      droppedItems: dropped,
    );
  }

  static String _clip(String s, int max) =>
      s.length <= max ? s : '${s.substring(0, max - 1).trimRight()}…';
}
