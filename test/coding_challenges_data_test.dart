import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/core/database/app_database.dart';
import 'package:teacher/features/coding_challenges/data/coding_challenge_repository_impl.dart';
import 'package:teacher/features/coding_challenges/domain/models/coding_challenge.dart';

void main() {
  test('bundled challenges parse and point at real courses', () {
    final json = jsonDecode(
      File(codingChallengesAssetPath).readAsStringSync(),
    ) as Map<String, dynamic>;
    final challenges = (json['challenges'] as List<dynamic>)
        .map((c) => LongFormChallenge.fromJson(c as Map<String, dynamic>))
        .toList();
    final manifest = jsonDecode(
      File('assets/curriculum/manifest.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final pathIds = {
      for (final p in manifest['learningPaths'] as List<dynamic>)
        p['id'] as String,
    };
    expect(challenges.length, greaterThanOrEqualTo(5));
    expect(challenges.map((c) => c.id).toSet(), hasLength(challenges.length));
    for (final c in challenges) {
      expect(pathIds, contains(c.learningPathId), reason: c.id);
      expect(c.parts.length, greaterThanOrEqualTo(3), reason: c.id);
      expect(c.parts.map((p) => p.id).toSet(), hasLength(c.parts.length));
      for (final p in c.parts) {
        expect(p.solution.trim(), isNotEmpty, reason: '${c.id}/${p.id}');
        expect(p.checks, isNotEmpty, reason: '${c.id}/${p.id}');
        expect(p.hints, isNotEmpty, reason: '${c.id}/${p.id}');
      }
    }
  });

  test('records count attempts and keep the best ratio', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = CodingChallengeProgressRepositoryImpl(db);
    await repo.recordAttempt(challengeId: 'a', score: 2, maxScore: 6);
    await repo.recordAttempt(challengeId: 'a', score: 5, maxScore: 6);
    await repo.recordAttempt(challengeId: 'a', score: 3, maxScore: 6);
    final records = await repo.getRecords();
    expect(
      records['a'],
      const ChallengeRecord(attempts: 3, bestScore: 5, maxScore: 6),
    );
    expect(records['a']!.bestPercent, 83);
    expect(records.containsKey('b'), isFalse);
  });
}
