import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle;

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/models/system_design_exercise.dart';
import '../domain/system_design_repository.dart';

const systemDesignAssetPath = 'assets/system_design/exercises.json';

class SystemDesignRepositoryImpl implements SystemDesignRepository {
  SystemDesignRepositoryImpl(this._bundle);

  final AssetBundle _bundle;
  Future<List<SystemDesignExercise>>? _cache;

  @override
  Future<List<SystemDesignExercise>> getExercises() => _cache ??= _load();

  Future<List<SystemDesignExercise>> _load() async {
    try {
      final raw = await _bundle.loadString(systemDesignAssetPath);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return (json['exercises'] as List<dynamic>)
          .map((e) => SystemDesignExercise.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _cache = null;
      throw ContentNotFoundException('Failed to load system design: $e');
    }
  }

  @override
  Future<SystemDesignExercise?> getExercise(String id) async =>
      (await getExercises()).where((e) => e.id == id).firstOrNull;
}

class SystemDesignProgressRepositoryImpl
    implements SystemDesignProgressRepository {
  SystemDesignProgressRepositoryImpl(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  @override
  Future<void> recordAttempt({
    required String exerciseId,
    required int score,
    required int maxScore,
  }) async {
    try {
      await _db
          .into(_db.systemDesignAttemptsTable)
          .insert(
            SystemDesignAttemptsTableCompanion.insert(
              exerciseId: exerciseId,
              score: score,
              maxScore: maxScore,
              completedAt: _clock(),
            ),
          );
    } on Exception catch (e) {
      throw LocalDatabaseException('Failed to save design attempt: $e');
    }
  }

  @override
  Future<Map<String, SystemDesignRecord>> getRecords() async {
    final rows = await _db.select(_db.systemDesignAttemptsTable).get();
    final byExercise = <String, List<SystemDesignAttemptsTableData>>{};
    for (final r in rows) {
      byExercise.putIfAbsent(r.exerciseId, () => []).add(r);
    }
    return {
      for (final e in byExercise.entries)
        e.key: () {
          final best = e.value.reduce(
            (a, b) => a.score * b.maxScore >= b.score * a.maxScore ? a : b,
          );
          final last = e.value
              .map((r) => r.completedAt)
              .reduce((a, b) => a.isAfter(b) ? a : b);
          return SystemDesignRecord(
            attempts: e.value.length,
            bestScore: best.score,
            maxScore: best.maxScore,
            lastCompletedAt: last,
          );
        }(),
    };
  }
}
