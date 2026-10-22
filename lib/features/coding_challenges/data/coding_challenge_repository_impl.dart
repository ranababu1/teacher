import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle;

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/coding_challenge_repository.dart';
import '../domain/models/coding_challenge.dart';

const codingChallengesAssetPath = 'assets/coding_challenges/challenges.json';

class CodingChallengeRepositoryImpl implements CodingChallengeRepository {
  CodingChallengeRepositoryImpl(this._bundle);

  final AssetBundle _bundle;
  Future<List<LongFormChallenge>>? _cache;

  @override
  Future<List<LongFormChallenge>> getChallenges() => _cache ??= _load();

  Future<List<LongFormChallenge>> _load() async {
    try {
      final raw = await _bundle.loadString(codingChallengesAssetPath);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return (json['challenges'] as List<dynamic>)
          .map((c) => LongFormChallenge.fromJson(c as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _cache = null;
      throw ContentNotFoundException('Failed to load coding challenges: $e');
    }
  }

  @override
  Future<LongFormChallenge?> getChallenge(String id) async =>
      (await getChallenges()).where((c) => c.id == id).firstOrNull;
}

class CodingChallengeProgressRepositoryImpl
    implements CodingChallengeProgressRepository {
  CodingChallengeProgressRepositoryImpl(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  @override
  Future<void> recordAttempt({
    required String challengeId,
    required int score,
    required int maxScore,
  }) async {
    try {
      await _db
          .into(_db.codingChallengeAttemptsTable)
          .insert(
            CodingChallengeAttemptsTableCompanion.insert(
              challengeId: challengeId,
              score: score,
              maxScore: maxScore,
              completedAt: _clock(),
            ),
          );
    } on Exception catch (e) {
      throw LocalDatabaseException('Failed to save challenge attempt: $e');
    }
  }

  @override
  Future<Map<String, ChallengeRecord>> getRecords() async {
    final rows = await _db.select(_db.codingChallengeAttemptsTable).get();
    final result = <String, ChallengeRecord>{};
    for (final r in rows) {
      final prev = result[r.challengeId];
      final better =
          prev == null || r.score * prev.maxScore > prev.bestScore * r.maxScore;
      result[r.challengeId] = ChallengeRecord(
        attempts: (prev?.attempts ?? 0) + 1,
        bestScore: better ? r.score : prev.bestScore,
        maxScore: better ? r.maxScore : prev.maxScore,
      );
    }
    return result;
  }
}
