import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the content gaps closed in 0.30.0 so they do not reopen: every
/// course has scenario interview questions and a solid set of debugging
/// exercises, and item ids stay unique.
void main() {
  final courses = Directory('assets/curriculum')
      .listSync()
      .whereType<Directory>()
      .toList();

  Iterable<Map<String, dynamic>> conceptsOf(Directory course) sync* {
    for (final f in course.listSync().whereType<File>()) {
      if (!f.path.endsWith('.json')) continue;
      final module = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      for (final c in module['concepts'] as List) {
        yield c as Map<String, dynamic>;
      }
    }
  }

  test('every course has scenario interview questions with answers', () {
    for (final course in courses) {
      final scenarios = [
        for (final c in conceptsOf(course))
          for (final a in c['assessments'] as List)
            if (a['type'] == 'scenario' &&
                (a['modelAnswer'] as String? ?? '').trim().isNotEmpty)
              a,
      ];
      expect(scenarios.length, greaterThanOrEqualTo(2), reason: course.path);
    }
  });

  test('every course has at least 15 debugging exercises', () {
    for (final course in courses) {
      var count = 0;
      for (final c in conceptsOf(course)) {
        for (final e in [
          ...c['exercises'] as List,
          ...c['assessments'] as List,
        ]) {
          if (e['type'] == 'debugging') count++;
        }
      }
      expect(count, greaterThanOrEqualTo(15), reason: course.path);
    }
  });

  test('multiple-choice text never refers to an option by position', () {
    final position = RegExp(
      r'\b[Oo]ptions? ([A-D]|[1-4])\b|\b(first|last|previous) option\b|of the above\b',
    );
    for (final course in courses) {
      for (final c in conceptsOf(course)) {
        for (final a in c['assessments'] as List) {
          if (a['type'] != 'multipleChoice') continue;
          for (final text in [
            a['explanation'] as String,
            ...(a['options'] as List).cast<String>(),
          ]) {
            expect(position.hasMatch(text), isFalse, reason: '${a['id']}: $text');
          }
        }
      }
    }
  });

  test('no answer position dominates any topic', () {
    for (final course in courses) {
      for (final f in course.listSync().whereType<File>()) {
        if (!f.path.endsWith('.json')) continue;
        final module = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
        final counts = <int, int>{};
        var total = 0;
        for (final c in module['concepts'] as List) {
          for (final a in c['assessments'] as List) {
            if (a['type'] != 'multipleChoice') continue;
            final i = a['correctOptionIndex'] as int;
            counts[i] = (counts[i] ?? 0) + 1;
            total++;
          }
        }
        for (final n in counts.values) {
          expect(n / total, lessThan(0.4), reason: '${f.path} $counts');
        }
      }
    }
  });

  test('no topic can be passed by picking the longest or shortest option', () {
    for (final course in courses) {
      for (final f in course.listSync().whereType<File>()) {
        if (!f.path.endsWith('.json')) continue;
        final module = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
        var longest = 0, shortest = 0, total = 0;
        for (final c in module['concepts'] as List) {
          for (final a in c['assessments'] as List) {
            if (a['type'] != 'multipleChoice') continue;
            final lengths = [
              for (final o in a['options'] as List) (o as String).length,
            ];
            final correct = lengths[a['correctOptionIndex'] as int];
            total++;
            if (lengths.every((l) => l <= correct)) longest++;
            if (lengths.every((l) => l >= correct)) shortest++;
          }
        }
        // Topic tests pass at 70%.
        expect(longest / total, lessThan(0.7), reason: f.path);
        expect(shortest / total, lessThan(0.7), reason: f.path);
      }
    }
  });

  test('every course has both true and false statements', () {
    for (final course in courses) {
      final facts = [
        for (final c in conceptsOf(course))
          for (final m in c['misconceptions'] as List) m['fact'] != null,
      ];
      final share = facts.where((f) => f).length / facts.length;
      expect(share, inInclusiveRange(0.2, 0.8), reason: course.path);
    }
  });

  test('a shortened option quote identifies exactly one wrong option', () {
    String plain(String s) => s
        .replaceAll('```', ' ')
        .replaceAll('`', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    for (final course in courses) {
      for (final c in conceptsOf(course)) {
        for (final a in c['assessments'] as List) {
          if (a['type'] != 'multipleChoice') continue;
          final options = [for (final o in a['options'] as List) plain(o as String)];
          for (final m in RegExp(
            '“([^”]*)…”',
          ).allMatches(a['explanation'] as String)) {
            final matches = [
              for (final (i, o) in options.indexed)
                if (o.startsWith(plain(m[1]!))) i,
            ];
            expect(matches, hasLength(1), reason: '${a['id']}: ${m[0]}');
            expect(
              matches.single,
              isNot(a['correctOptionIndex']),
              reason: '${a['id']}: ${m[0]}',
            );
          }
        }
      }
    }
  });

  test('exercise and assessment ids are unique', () {
    final seen = <String>{};
    for (final course in courses) {
      for (final c in conceptsOf(course)) {
        for (final e in [
          ...c['exercises'] as List,
          ...c['assessments'] as List,
        ]) {
          final id = e['id'] as String;
          expect(seen.add(id), isTrue, reason: 'duplicate id $id');
        }
      }
    }
  });
}
