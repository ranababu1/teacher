import 'roadmap.dart';

/// One piece of existing app content a roadmap may use.
class CatalogEntry {
  const CatalogEntry({
    required this.kind,
    required this.id,
    required this.title,
    required this.hours,
    this.pathId,
    this.afterModuleId,
    this.difficulty = 'beginner',
    this.order = 0,
  });

  final RoadmapItemKind kind;

  /// `pathId/moduleId` for topics, otherwise the content id.
  final String id;
  final String title;

  /// Rough effort, used to fit items into weekly hours.
  final double hours;

  /// Course this belongs to (null for course-independent content).
  final String? pathId;

  /// Projects: the topic it is recommended after.
  final String? afterModuleId;
  final String difficulty;

  /// Topics: position inside the course.
  final int order;
}

class CatalogCourse {
  const CatalogCourse({
    required this.id,
    required this.title,
    required this.topics,
  });

  final String id;
  final String title;

  /// In course order.
  final List<CatalogEntry> topics;
}

/// Everything a roadmap can be built from. AI output is checked against
/// this so a plan never points at content the app does not have.
class RoadmapCatalog {
  RoadmapCatalog({
    required this.courses,
    required this.projects,
    required this.systemDesign,
    required this.challenges,
  }) : _byKey = {
         for (final e in [
           for (final c in courses) ...c.topics,
           ...projects,
           ...systemDesign,
           ...challenges,
         ])
           '${e.kind.name}:${e.id}': e,
       };

  final List<CatalogCourse> courses;
  final List<CatalogEntry> projects;
  final List<CatalogEntry> systemDesign;
  final List<CatalogEntry> challenges;
  final Map<String, CatalogEntry> _byKey;

  CatalogEntry? lookup(RoadmapItemKind kind, String id) =>
      _byKey['${kind.name}:$id'];

  String courseTitle(String? pathId) {
    for (final c in courses) {
      if (c.id == pathId) return c.title;
    }
    return pathId ?? '';
  }

  bool get isEmpty => _byKey.isEmpty;

  /// Compact, id-first listing for the AI prompt.
  String toPromptText() {
    final b = StringBuffer();
    b.writeln('### Courses and topics (kind "topic", id "course/topic")');
    for (final c in courses) {
      b.writeln('- Course ${c.id}: ${c.title}');
      for (final t in c.topics) {
        b.writeln('  - ${t.id} | ${t.title} | ~${t.hours.round()} h');
      }
    }
    void section(String name, String kind, List<CatalogEntry> list) {
      b.writeln('### $name (kind "$kind")');
      for (final e in list) {
        final course = e.pathId == null ? '' : ' | course ${e.pathId}';
        b.writeln(
          '- ${e.id} | ${e.title} | ${e.difficulty} | ~${e.hours.round()} h$course',
        );
      }
    }

    section('Guided projects', 'project', projects);
    section('System design exercises', 'systemDesign', systemDesign);
    section('Long-form coding challenges', 'challenge', challenges);
    return b.toString();
  }
}

/// What the learner has already finished, from existing progress data.
class RoadmapCompletion {
  const RoadmapCompletion({
    this.passedTopicIds = const {},
    this.completedProjectIds = const {},
    this.finishedDesignIds = const {},
    this.finishedChallengeIds = const {},
  });

  /// `pathId/moduleId` of topics whose test was passed.
  final Set<String> passedTopicIds;
  final Set<String> completedProjectIds;
  final Set<String> finishedDesignIds;
  final Set<String> finishedChallengeIds;

  bool isDone(RoadmapItem item) => switch (item.kind) {
    RoadmapItemKind.topic => passedTopicIds.contains(item.refId),
    RoadmapItemKind.project => completedProjectIds.contains(item.refId),
    RoadmapItemKind.systemDesign => finishedDesignIds.contains(item.refId),
    RoadmapItemKind.challenge => finishedChallengeIds.contains(item.refId),
  };
}
