import '../../coding_challenges/domain/models/coding_challenge.dart';
import '../../curriculum/domain/models/learning_path.dart';
import '../../projects/domain/models/project.dart';
import '../../system_design/domain/models/system_design_exercise.dart';
import 'models/roadmap.dart';
import 'models/roadmap_catalog.dart';

/// Turns the app's content into a [RoadmapCatalog]. Pure, so it is easy to
/// test and the same catalog feeds both the AI prompt and the offline
/// builder.
class RoadmapCatalogBuilder {
  const RoadmapCatalogBuilder();

  RoadmapCatalog build({
    required List<LearningPath> paths,
    required List<Project> projects,
    required List<SystemDesignExercise> systemDesign,
    required List<LongFormChallenge> challenges,
  }) {
    double hoursFromMinutes(int minutes) => minutes <= 0 ? 1 : minutes / 60;
    return RoadmapCatalog(
      courses: [
        for (final p in paths)
          CatalogCourse(
            id: p.id,
            title: p.title,
            topics: [
              for (final m in [
                ...p.modules,
              ]..sort((a, b) => a.order.compareTo(b.order)))
                CatalogEntry(
                  kind: RoadmapItemKind.topic,
                  id: '${p.id}/${m.id}',
                  title: m.title,
                  // About half an hour per concept, at least an hour.
                  hours: m.concepts.length * 0.5 < 1
                      ? 1
                      : m.concepts.length * 0.5,
                  pathId: p.id,
                  difficulty: p.difficulty.name,
                  order: m.order,
                ),
            ],
          ),
      ],
      projects: [
        for (final p in projects)
          CatalogEntry(
            kind: RoadmapItemKind.project,
            id: p.id,
            title: p.title,
            hours: p.estimatedHours <= 0 ? 4 : p.estimatedHours.toDouble(),
            pathId: p.learningPathId,
            afterModuleId: p.recommendedAfterModuleId,
            difficulty: p.difficulty.name,
          ),
      ],
      systemDesign: [
        for (final e in systemDesign)
          CatalogEntry(
            kind: RoadmapItemKind.systemDesign,
            id: e.id,
            title: e.title,
            hours: hoursFromMinutes(e.estimatedMinutes),
            difficulty: e.difficulty.name,
          ),
      ],
      challenges: [
        for (final c in challenges)
          CatalogEntry(
            kind: RoadmapItemKind.challenge,
            id: c.id,
            title: c.title,
            hours: hoursFromMinutes(c.estimatedMinutes),
            pathId: c.learningPathId,
            difficulty: c.difficulty.name,
          ),
      ],
    );
  }
}
