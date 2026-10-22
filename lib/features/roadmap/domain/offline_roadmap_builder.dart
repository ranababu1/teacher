import 'models/roadmap.dart';
import 'models/roadmap_catalog.dart';

/// Rule-based roadmap used when there is no AI key or no network. Uses the
/// same inputs and the same catalog as the AI path, so the result is
/// always valid and works fully offline.
class OfflineRoadmapBuilder {
  const OfflineRoadmapBuilder();

  /// Goal keywords mapped to course ids, most relevant first.
  static const _tracks = <(List<String>, List<String>)>[
    (
      ['llm', 'genai', 'gen ai', 'rag', 'prompt', 'chatbot', 'agent'],
      ['python', 'llm-engineering', 'vector-databases'],
    ),
    (
      ['machine learning', 'ml ', ' ml', 'data scien', 'ai engineer', 'ai/ml'],
      ['python', 'statistics', 'ai-ml'],
    ),
    (
      ['devops', 'sre', 'platform', 'infrastructure', 'cloud', 'kubernetes'],
      ['docker', 'kubernetes', 'devops', 'cloud-aws'],
    ),
    (
      ['frontend', 'front-end', 'front end', 'react', 'web ui'],
      ['react', 'nodejs'],
    ),
    (
      ['full stack', 'fullstack', 'full-stack'],
      ['react', 'nodejs', 'databases'],
    ),
    (['spring', 'java'], ['java', 'spring-boot', 'databases']),
    (['golang', ' go ', 'go developer'], ['go', 'databases', 'docker']),
    (['node', 'javascript'], ['nodejs', 'databases']),
    (
      ['backend', 'back-end', 'back end', 'api', 'server'],
      ['python', 'databases', 'docker', 'system-design'],
    ),
    (['system design', 'architect'], ['system-design', 'databases']),
    (
      ['data', 'sql', 'database', 'analyst'],
      ['databases', 'python', 'statistics'],
    ),
    (['python'], ['python']),
  ];

  static const _fallbackTrack = ['python', 'databases'];

  /// Picks courses for [goal]: courses named in the goal first, then the
  /// keyword track(s), keeping only courses the catalog actually has.
  List<String> chooseCourses(String goal, RoadmapCatalog catalog) {
    final text = ' ${goal.toLowerCase()} ';
    final chosen = <String>[];
    for (final c in catalog.courses) {
      if (text.contains(c.title.toLowerCase())) chosen.add(c.id);
    }
    for (final (keywords, ids) in _tracks) {
      if (keywords.any(text.contains)) chosen.addAll(ids);
    }
    if (chosen.isEmpty) chosen.addAll(_fallbackTrack);
    final available = {for (final c in catalog.courses) c.id};
    final seen = <String>{};
    return [
      for (final id in chosen)
        if (available.contains(id) && seen.add(id)) id,
    ];
  }

  Roadmap build({
    required RoadmapGoal goal,
    required RoadmapCatalog catalog,
    required RoadmapCompletion completion,
    required DateTime now,
  }) {
    final g = goal.normalized();
    final courseIds = chooseCourses(g.goal, catalog);
    final queue = <(CatalogEntry, String)>[];

    for (final courseId in courseIds) {
      final course = catalog.courses.firstWhere((c) => c.id == courseId);
      final skip = switch (g.level) {
        RoadmapLevel.beginner => 0,
        RoadmapLevel.intermediate => course.topics.length ~/ 3,
        RoadmapLevel.advanced => course.topics.length ~/ 2,
      };
      for (final (i, topic) in course.topics.indexed) {
        if (i < skip || completion.passedTopicIds.contains(topic.id)) continue;
        queue.add((topic, 'Core topic in ${course.title}.'));
        for (final p in catalog.projects) {
          final moduleId = topic.id.split('/').last;
          if (p.pathId == courseId &&
              p.afterModuleId == moduleId &&
              !completion.completedProjectIds.contains(p.id)) {
            queue.add((p, 'Apply ${course.title} in a real build.'));
          }
        }
      }
      for (final ch in catalog.challenges) {
        if (ch.pathId == courseId &&
            !completion.finishedChallengeIds.contains(ch.id)) {
          queue.add((ch, 'Practise ${course.title} on a multi-part problem.'));
        }
      }
      if (courseId == 'system-design') {
        final designs = catalog.systemDesign
            .where((d) => !completion.finishedDesignIds.contains(d.id))
            .where(
              (d) =>
                  g.level != RoadmapLevel.beginner ||
                  d.difficulty != 'advanced',
            )
            .take(3);
        for (final d in designs) {
          queue.add((d, 'Interview-style design walkthrough.'));
        }
      }
    }

    final weeks = _pack(queue, g, catalog);
    final courseTitles = courseIds.map(catalog.courseTitle).join(', ');
    return Roadmap(
      goal: g,
      summary:
          'A ${g.weeks}-week plan for "${g.goal}" at about ${g.hoursPerWeek} '
          'h a week, built from $courseTitles. Made offline from your goal '
          'and progress; add an AI key in Settings for a tailored plan.',
      weeks: weeks,
      source: RoadmapSource.offline,
      createdAt: now,
    );
  }

  /// Fills weeks in order up to the weekly hours. An item bigger than a
  /// whole week gets a week to itself. Leftover items are not scheduled.
  List<RoadmapWeek> _pack(
    List<(CatalogEntry, String)> queue,
    RoadmapGoal goal,
    RoadmapCatalog catalog,
  ) {
    final weeks = <RoadmapWeek>[];
    var index = 0;
    for (var w = 0; w < goal.weeks; w++) {
      final items = <RoadmapItem>[];
      final focus = <String>[];
      var used = 0.0;
      while (index < queue.length) {
        final (entry, note) = queue[index];
        final cost = entry.hours <= 0 ? 1.0 : entry.hours;
        if (items.isNotEmpty && used + cost > goal.hoursPerWeek) break;
        items.add(
          RoadmapItem(
            kind: entry.kind,
            refId: entry.id,
            title: entry.title,
            note: note,
          ),
        );
        final label = switch (entry.kind) {
          RoadmapItemKind.topic => catalog.courseTitle(entry.pathId),
          RoadmapItemKind.project => 'Project',
          RoadmapItemKind.systemDesign => 'System design',
          RoadmapItemKind.challenge => 'Challenge',
        };
        if (!focus.contains(label)) focus.add(label);
        used += cost;
        index++;
      }
      weeks.add(
        RoadmapWeek(
          focus: focus.isEmpty ? 'Review and catch up' : focus.join(' + '),
          items: items,
        ),
      );
    }
    return weeks;
  }
}
