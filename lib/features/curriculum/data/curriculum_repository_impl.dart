import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle;

import '../../../core/errors/app_exception.dart';
import '../domain/curriculum_repository.dart';
import '../domain/models/concept.dart';
import '../domain/models/curriculum_module.dart';
import '../domain/models/learning_path.dart';

const _manifestPath = 'assets/curriculum/manifest.json';

/// Loads curriculum content from bundled JSON assets.
///
/// Curriculum is authoritative, versioned-with-the-app content — not
/// something stored in the local database. It's parsed once and cached in
/// memory for the process lifetime. See instructions.md sections 25 and 56.
class CurriculumRepositoryImpl implements CurriculumRepository {
  CurriculumRepositoryImpl(this._assetBundle);

  final AssetBundle _assetBundle;

  Future<List<LearningPath>>? _cache;

  @override
  Future<List<LearningPath>> getLearningPaths() {
    return _cache ??= _load();
  }

  @override
  Future<LearningPath?> getLearningPath(String learningPathId) async {
    final paths = await getLearningPaths();
    for (final path in paths) {
      if (path.id == learningPathId) return path;
    }
    return null;
  }

  @override
  Future<Concept?> getConcept(String conceptId) async {
    final paths = await getLearningPaths();
    for (final path in paths) {
      final concept = path.findConcept(conceptId);
      if (concept != null) return concept;
    }
    return null;
  }

  @override
  Future<List<Concept>> getPrerequisiteConcepts(String conceptId) async {
    final concept = await getConcept(conceptId);
    if (concept == null) return const [];

    final resolved = <Concept>[];
    for (final prereqId in concept.prerequisites) {
      final prereq = await getConcept(prereqId);
      if (prereq != null) resolved.add(prereq);
    }
    return resolved;
  }

  Future<List<LearningPath>> _load() async {
    final manifestJson = await _readJson(_manifestPath);
    final entries = (manifestJson['learningPaths'] as List<dynamic>)
        .map(
          (e) => LearningPathManifestEntry.fromJson(e as Map<String, dynamic>),
        )
        .toList();

    final paths = <LearningPath>[];
    for (final entry in entries) {
      final modules = <CurriculumModule>[];
      for (final moduleFile in entry.moduleFiles) {
        final moduleJson = await _readJson('assets/curriculum/$moduleFile');
        modules.add(CurriculumModule.fromJson(moduleJson));
      }
      modules.sort((a, b) => a.order.compareTo(b.order));

      paths.add(
        LearningPath(
          id: entry.id,
          title: entry.title,
          description: entry.description,
          difficulty: entry.difficulty,
          iconName: entry.iconName,
          estimatedHours: entry.estimatedHours,
          modules: modules,
        ),
      );
    }
    return paths;
  }

  Future<Map<String, dynamic>> _readJson(String assetPath) async {
    try {
      final raw = await _assetBundle.loadString(assetPath);
      return jsonDecode(raw) as Map<String, dynamic>;
    } on Exception catch (e) {
      throw ContentNotFoundException('Failed to load/parse $assetPath: $e');
    }
  }
}
