import 'package:equatable/equatable.dart';

import 'assessment.dart';
import 'difficulty.dart';
import 'exercise.dart';

class ExplanationSection extends Equatable {
  const ExplanationSection({required this.heading, required this.body});

  final String heading;
  final String body;

  factory ExplanationSection.fromJson(Map<String, dynamic> json) {
    return ExplanationSection(
      heading: json['heading'] as String,
      body: json['body'] as String,
    );
  }

  @override
  List<Object?> get props => [heading, body];
}

class ConceptExplanation extends Equatable {
  const ConceptExplanation({required this.sections});

  final List<ExplanationSection> sections;

  factory ConceptExplanation.fromJson(Map<String, dynamic> json) {
    return ConceptExplanation(
      sections: (json['sections'] as List<dynamic>)
          .map((s) => ExplanationSection.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [sections];
}

class ConceptExample extends Equatable {
  const ConceptExample({
    required this.title,
    required this.language,
    required this.code,
    required this.explanation,
  });

  final String title;
  final String language;
  final String code;
  final String explanation;

  factory ConceptExample.fromJson(Map<String, dynamic> json) {
    return ConceptExample(
      title: json['title'] as String,
      language: json['language'] as String,
      code: json['code'] as String,
      explanation: json['explanation'] as String,
    );
  }

  @override
  List<Object?> get props => [title, language, code, explanation];
}

class Misconception extends Equatable {
  const Misconception({required this.description, required this.clarification});

  final String description;
  final String clarification;

  factory Misconception.fromJson(Map<String, dynamic> json) {
    return Misconception(
      description: json['description'] as String,
      clarification: json['clarification'] as String,
    );
  }

  @override
  List<Object?> get props => [description, clarification];
}

/// A single teachable unit — the core content model of the app.
///
/// See instructions.md section 13. Deliberately does not assume every
/// concept needs identical content shape (examples/exercises/assessments
/// can be empty for a lightly-covered concept).
class Concept extends Equatable {
  const Concept({
    required this.id,
    required this.title,
    required this.description,
    required this.learningPathId,
    required this.moduleId,
    required this.topicId,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.prerequisites,
    required this.learningObjectives,
    required this.explanation,
    required this.examples,
    required this.misconceptions,
    required this.exercises,
    required this.assessments,
  });

  final String id;
  final String title;
  final String description;
  final String learningPathId;
  final String moduleId;
  final String topicId;
  final Difficulty difficulty;
  final int estimatedMinutes;
  final List<String> prerequisites;
  final List<String> learningObjectives;
  final ConceptExplanation explanation;
  final List<ConceptExample> examples;
  final List<Misconception> misconceptions;
  final List<Exercise> exercises;
  final List<Assessment> assessments;

  factory Concept.fromJson(
    Map<String, dynamic> json, {
    required String learningPathId,
  }) {
    return Concept(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      learningPathId: learningPathId,
      moduleId: json['moduleId'] as String,
      topicId: json['topicId'] as String? ?? json['moduleId'] as String,
      difficulty: Difficulty.fromJson(json['difficulty'] as String),
      estimatedMinutes: json['estimatedMinutes'] as int,
      prerequisites: (json['prerequisites'] as List<dynamic>? ?? const []).cast<String>(),
      learningObjectives:
          (json['learningObjectives'] as List<dynamic>? ?? const []).cast<String>(),
      explanation: ConceptExplanation.fromJson(json['explanation'] as Map<String, dynamic>),
      examples: (json['examples'] as List<dynamic>? ?? const [])
          .map((e) => ConceptExample.fromJson(e as Map<String, dynamic>))
          .toList(),
      misconceptions: (json['misconceptions'] as List<dynamic>? ?? const [])
          .map((m) => Misconception.fromJson(m as Map<String, dynamic>))
          .toList(),
      exercises: (json['exercises'] as List<dynamic>? ?? const [])
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      assessments: (json['assessments'] as List<dynamic>? ?? const [])
          .map((a) => Assessment.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, title, description, learningPathId, moduleId, topicId,
      difficulty, estimatedMinutes, prerequisites, learningObjectives, explanation, examples,
      misconceptions, exercises, assessments];
}
