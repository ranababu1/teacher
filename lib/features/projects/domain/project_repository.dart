import 'models/project.dart';

/// Read-only access to bundled project content.
abstract class ProjectRepository {
  Future<List<Project>> getProjects();

  Future<Project?> getProject(String projectId);
}

/// Persisted milestone completion for projects.
abstract class ProjectProgressRepository {
  /// projectId -> completed milestone ids, for every project with progress.
  Future<Map<String, Set<String>>> getAllCompletedMilestones();

  Future<Set<String>> getCompletedMilestones(String projectId);

  Future<void> setMilestoneCompleted({
    required String projectId,
    required String milestoneId,
    required bool completed,
  });
}
