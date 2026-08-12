import 'package:equatable/equatable.dart';

import 'concept.dart';

/// A group of concepts within a [LearningPath]. In v1 this also stands in
/// for "topic" — see instructions.md section 10; topic-level subdivision
/// within a module can be introduced later without changing this shape.
class CurriculumModule extends Equatable {
  const CurriculumModule({
    required this.learningPathId,
    required this.id,
    required this.title,
    required this.order,
    required this.concepts,
  });

  final String learningPathId;
  final String id;
  final String title;
  final int order;
  final List<Concept> concepts;

  factory CurriculumModule.fromJson(Map<String, dynamic> json) {
    final learningPathId = json['learningPathId'] as String;
    return CurriculumModule(
      learningPathId: learningPathId,
      id: json['moduleId'] as String,
      title: json['title'] as String,
      order: json['order'] as int,
      concepts: (json['concepts'] as List<dynamic>)
          .map((c) => Concept.fromJson(c as Map<String, dynamic>, learningPathId: learningPathId))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [learningPathId, id, title, order, concepts];
}
