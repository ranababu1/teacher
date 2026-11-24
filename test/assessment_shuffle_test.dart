import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/curriculum/domain/models/assessment.dart';
import 'package:teacher/features/curriculum/domain/models/item_type.dart';

Assessment _mcq({String explanation = 'Because.'}) => Assessment(
  id: 'q',
  type: ItemType.multipleChoice,
  prompt: 'Which?',
  options: const ['w1', 'right', 'w2', 'w3'],
  correctOptionIndex: 1,
  explanation: explanation,
);

void main() {
  test('the correct option follows its text to every position', () {
    final random = Random(1);
    final seen = <int, int>{};
    for (var i = 0; i < 4000; i++) {
      final a = _mcq().withShuffledOptions(random);
      expect(a.options![a.correctOptionIndex!], 'right');
      expect(a.options!.toSet(), {'w1', 'right', 'w2', 'w3'});
      expect(a.explanation, 'Because.');
      seen[a.correctOptionIndex!] = (seen[a.correctOptionIndex!] ?? 0) + 1;
    }
    expect(seen.keys.toSet(), {0, 1, 2, 3});
    for (final n in seen.values) {
      expect(n, inInclusiveRange(850, 1150));
    }
  });

  test('text that names a position keeps its order', () {
    final a = _mcq(explanation: 'Option B is right.');
    expect(identical(a.withShuffledOptions(Random(1)), a), isTrue);
  });

  test('items that are not multiple choice are unchanged', () {
    const a = Assessment(id: 'e', type: ItemType.explanation, prompt: 'Why?');
    expect(identical(a.withShuffledOptions(Random(1)), a), isTrue);
  });

  test('almost every bundled question can be reshuffled', () {
    var total = 0;
    final fixed = <String>[];
    for (final f in Directory(
      'assets/curriculum',
    ).listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.json')) continue;
      final json = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      for (final c in json['concepts'] as List? ?? const []) {
        for (final raw in c['assessments'] as List) {
          final a = Assessment.fromJson(raw as Map<String, dynamic>);
          if (a.type != ItemType.multipleChoice) continue;
          total++;
          if (identical(a.withShuffledOptions(Random(1)), a)) fixed.add(a.id);
        }
      }
    }
    expect(total, greaterThan(1300));
    expect(fixed.length, lessThan(15), reason: '$fixed');
  });
}
