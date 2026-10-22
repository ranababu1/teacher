import 'project.dart';

/// A project joined with the learner's progress and readiness.
class ProjectOverview {
  const ProjectOverview({
    required this.project,
    required this.courseTitle,
    required this.completedMilestoneIds,
    required this.isRecommendedTopicPassed,
    this.recommendedTopicTitle,
  });

  final Project project;
  final String courseTitle;
  final Set<String> completedMilestoneIds;

  /// Title of [Project.recommendedAfterModuleId], when it resolves.
  final String? recommendedTopicTitle;

  /// True when there is no recommended topic or its test has been passed.
  final bool isRecommendedTopicPassed;

  int get completedCount => project.milestones
      .where((m) => completedMilestoneIds.contains(m.id))
      .length;

  int get totalCount => project.milestones.length;

  double get fraction => totalCount == 0 ? 0 : completedCount / totalCount;

  bool get isStarted => completedCount > 0;

  bool get isComplete => totalCount > 0 && completedCount == totalCount;
}
