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
