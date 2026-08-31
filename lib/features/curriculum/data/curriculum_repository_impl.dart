import 'dart:convert';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart' show AssetBundle;

import '../../../core/errors/app_exception.dart';
import '../../../core/services/app_logger.dart';
import '../domain/curriculum_repository.dart';
import '../domain/models/concept.dart';
import '../domain/models/curriculum_module.dart';
import '../domain/models/learning_path.dart';

const _manifestPath = 'assets/curriculum/manifest.json';

/// Decodes every raw JSON string in [rawByAssetPath]. Run inside a
/// background isolate via [compute] in [CurriculumRepositoryImpl._load] —
/// parsing the curriculum's ~11MB of bundled JSON is the single most
/// expensive part of loading it, and this keeps that off the UI thread
/// so it can never cause a jank/dropped-frame right after app launch. A
/// string that fails to decode maps to `null` rather than throwing, so
/// one malformed file can't take down the whole batch — the caller
/// treats a `null` exactly like the file being unreadable.
Map<String, dynamic> _decodeAll(Map<String, String> rawByAssetPath) {
  final result = <String, dynamic>{};
  for (final entry in rawByAssetPath.entries) {
    try {
      result[entry.key] = jsonDecode(entry.value);
    } catch (_) {
      result[entry.key] = null;
    }
  }
  return result;
}

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

    // Read every module file concurrently instead of one at a time — this
    // is I/O, not CPU work, so it stays on the main isolate; only the
    // decode step below needs to move off it. A file that fails to read
    // (missing/corrupt asset) is logged and simply absent from the map,
    // exactly as a single skipped module used to be handled inline.
    final allAssetPaths = [
      for (final entry in entries)
        for (final moduleFile in entry.moduleFiles)
          'assets/curriculum/$moduleFile',
    ];
    final rawByAssetPath = <String, String>{};
    await Future.wait(
      allAssetPaths.map((assetPath) async {
        try {
          rawByAssetPath[assetPath] = await _assetBundle.loadString(
            assetPath,
          );
        } catch (e) {
          AppLogger.error('Failed to read $assetPath', e);
        }
      }),
    );

    final decodedByAssetPath = await compute(_decodeAll, rawByAssetPath);

    final paths = <LearningPath>[];
    for (final entry in entries) {
      final modules = <CurriculumModule>[];
      for (final moduleFile in entry.moduleFiles) {
        final assetPath = 'assets/curriculum/$moduleFile';
        if (!rawByAssetPath.containsKey(assetPath)) {
          continue; // read failure — already logged above
        }
        final decoded = decodedByAssetPath[assetPath];
        if (decoded == null) {
          AppLogger.error(
            'Skipping unreadable module $moduleFile',
            const FormatException('invalid JSON'),
          );
          continue;
        }

        try {
          modules.add(
            CurriculumModule.fromJson(decoded as Map<String, dynamic>),
          );
        } catch (e) {
          // A single malformed module shouldn't take down the whole path —
          // skip it and keep going so the rest of the curriculum still
          // loads. See instructions.md rule 10 (handle error states) —
          // this is the content-loading equivalent: partial content beats
          // no content. Catches everything, not just Exception: a schema
          // mismatch surfaces as a TypeError (an Error, not an Exception)
          // from a failed `as String`/`as int` cast during parsing.
          AppLogger.error('Skipping unreadable module $moduleFile', e);
        }
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
    } catch (e) {
      throw ContentNotFoundException('Failed to load/parse $assetPath: $e');
    }
  }
}
