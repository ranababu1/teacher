import 'package:equatable/equatable.dart';

import 'concept.dart';
import 'curriculum_module.dart';
import 'difficulty.dart';

/// Best-effort code-display language for a learning path, keyed by id.
/// Concept examples always specify their own `language` explicitly; this
/// is only a fallback for items (like exercises) that don't.
String languageForLearningPathId(String learningPathId) =>
    learningPathId == 'react' ? 'javascript' : 'python';

/// A full subject (e.g. Python, ReactJS) — see instructions.md section 9.
class LearningPath extends Equatable {
  const LearningPath({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.iconName,
    required this.estimatedHours,
    required this.modules,
  });

  final String id;
  final String title;
  final String description;
  final Difficulty difficulty;
  final String iconName;
  final int estimatedHours;
  final List<CurriculumModule> modules;

  List<Concept> get allConcepts => modules.expand((m) => m.concepts).toList();

  int get conceptCount => allConcepts.length;

  /// Best-effort language tag for code display when an item (e.g. an
  /// exercise) doesn't carry its own `language` field. Concept examples
  /// always specify their own language explicitly.
  String get primaryLanguage => languageForLearningPathId(id);

  Concept? findConcept(String conceptId) {
    for (final concept in allConcepts) {
      if (concept.id == conceptId) return concept;
    }
    return null;
  }

  CurriculumModule? findModule(String moduleId) {
    for (final module in modules) {
      if (module.id == moduleId) return module;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    difficulty,
    iconName,
    estimatedHours,
    modules,
  ];
}

/// Lightweight manifest entry — just enough to know what to load.
class LearningPathManifestEntry extends Equatable {
  const LearningPathManifestEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.iconName,
    required this.estimatedHours,
    required this.moduleFiles,
  });

  final String id;
  final String title;
  final String description;
  final Difficulty difficulty;
  final String iconName;
  final int estimatedHours;
  final List<String> moduleFiles;

  factory LearningPathManifestEntry.fromJson(Map<String, dynamic> json) {
    return LearningPathManifestEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      difficulty: Difficulty.fromJson(json['difficulty'] as String),
      iconName: json['iconName'] as String,
      estimatedHours: json['estimatedHours'] as int,
      moduleFiles: (json['moduleFiles'] as List<dynamic>).cast<String>(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    difficulty,
    iconName,
    estimatedHours,
    moduleFiles,
  ];
}
