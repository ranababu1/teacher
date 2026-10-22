import 'package:equatable/equatable.dart';

import '../../../curriculum/domain/models/difficulty.dart';

class ProjectMilestone extends Equatable {
  const ProjectMilestone({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;

  factory ProjectMilestone.fromJson(Map<String, dynamic> json) =>
      ProjectMilestone(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
      );

  @override
  List<Object?> get props => [id, title, description];
}

class RubricCriterion extends Equatable {
  const RubricCriterion({required this.criterion, required this.lookFor});

  final String criterion;
  final String lookFor;

  factory RubricCriterion.fromJson(Map<String, dynamic> json) =>
      RubricCriterion(
        criterion: json['criterion'] as String,
        lookFor: json['lookFor'] as String,
      );

  @override
  List<Object?> get props => [criterion, lookFor];
}

/// A guided, multi-milestone build project (instructions.md section 47),
/// bundled as content in assets/projects/projects.json.
class Project extends Equatable {
  const Project({
    required this.id,
    required this.learningPathId,
    required this.title,
    required this.summary,
    required this.brief,
    required this.difficulty,
    required this.estimatedHours,
    required this.skills,
    required this.milestones,
    required this.rubric,
    required this.stretchGoals,
    this.recommendedAfterModuleId,
  });

  final String id;
  final String learningPathId;
  final String title;
  final String summary;

  /// Markdown.
  final String brief;
  final Difficulty difficulty;
  final int estimatedHours;
  final List<String> skills;
  final List<ProjectMilestone> milestones;
  final List<RubricCriterion> rubric;
  final List<String> stretchGoals;

  /// The topic whose test, once passed, makes this project a good fit.
  final String? recommendedAfterModuleId;

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json['id'] as String,
    learningPathId: json['learningPathId'] as String,
    title: json['title'] as String,
    summary: json['summary'] as String,
    brief: json['brief'] as String,
    difficulty: Difficulty.fromJson(json['difficulty'] as String),
    estimatedHours: json['estimatedHours'] as int,
    skills: (json['skills'] as List<dynamic>? ?? const []).cast<String>(),
    milestones: (json['milestones'] as List<dynamic>)
        .map((m) => ProjectMilestone.fromJson(m as Map<String, dynamic>))
        .toList(),
    rubric: (json['rubric'] as List<dynamic>? ?? const [])
        .map((r) => RubricCriterion.fromJson(r as Map<String, dynamic>))
        .toList(),
    stretchGoals: (json['stretchGoals'] as List<dynamic>? ?? const [])
        .cast<String>(),
    recommendedAfterModuleId: json['recommendedAfterModuleId'] as String?,
  );

  @override
  List<Object?> get props => [id, learningPathId, title, milestones];
}
