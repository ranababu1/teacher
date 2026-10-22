import 'models/roadmap.dart';
import 'models/roadmap_catalog.dart';

/// Progress through a roadmap, derived from existing completion data
/// (nothing is ticked by hand, so it can never drift from reality).
class RoadmapProgress {
  RoadmapProgress(Roadmap roadmap, RoadmapCompletion completion)
    : doneKeys = {
        for (final i in roadmap.allItems)
          if (completion.isDone(i)) i.key,
      },
      total = roadmap.allItems.length,
      next = roadmap.allItems.where((i) => !completion.isDone(i)).firstOrNull;

  final Set<String> doneKeys;
  final int total;

  /// First unfinished item in plan order, or null when all are done.
  final RoadmapItem? next;

  int get done => doneKeys.length;

  double get fraction => total == 0 ? 0 : done / total;

  bool isDone(RoadmapItem item) => doneKeys.contains(item.key);

  int doneInWeek(RoadmapWeek week) => week.items.where(isDone).length;
}
