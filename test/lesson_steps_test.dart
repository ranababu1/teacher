import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/curriculum/domain/models/assessment.dart';
import 'package:teacher/features/curriculum/domain/models/concept.dart';
import 'package:teacher/features/curriculum/domain/models/item_type.dart';
import 'package:teacher/features/learning/domain/explanation_chunker.dart';
import 'package:teacher/features/learning/domain/lesson_flow.dart';
import 'package:teacher/features/learning/domain/lesson_step.dart';
import 'package:teacher/features/learning/domain/lesson_step_builder.dart';

import 'support/lesson_fixtures.dart';

void main() {
  group('splitBlocks', () {
    test('splits on blank lines but keeps code fences whole', () {
      const md =
          'One.\n\nTwo\nlines.\n\n```python\na = 1\n\nb = 2\n```\nAfter.';
      expect(splitBlocks(md), [
        'One.',
        'Two\nlines.',
        '```python\na = 1\n\nb = 2\n```',
        'After.',
      ]);
    });
  });

  group('chunkExplanation', () {
    test('packs short paragraphs together and splits long sections', () {
      final chunks = chunkExplanation([
        ExplanationSection(
          heading: 'Long',
          body: [
            para('alpha'),
            para('bravo'),
            para('charlie'),
            para('delta'),
          ].join('\n\n'),
        ),
        const ExplanationSection(heading: 'Short', body: 'One.\n\nTwo.'),
      ]);
      final long = chunks.where((c) => c.heading == 'Long').toList();
      expect(long.length, greaterThan(1));
      expect(long.every((c) => c.partCount == long.length), isTrue);
      expect(long.map((c) => c.part), [
        for (var i = 1; i <= long.length; i++) i,
      ]);
      expect(long.every((c) => c.body.length <= 650), isTrue);
      final short = chunks.singleWhere((c) => c.heading == 'Short');
      expect(short.body, 'One.\n\nTwo.');
      expect(short.partCount, 1);
    });

    test('keeps a code block with the paragraph before it when it fits', () {
      final chunks = chunkExplanation([
        ExplanationSection(
          heading: 'Code',
          body: '${para('intro', 60)}\n\n```python\nprint(1)\n```',
        ),
      ]);
      expect(chunks, hasLength(1));
      expect(chunks.single.body, contains('```python'));
    });

    test('never loses text', () {
      final body = [
        para('a'),
        para('b'),
        '```\ncode\n```',
        para('c'),
      ].join('\n\n');
      final chunks = chunkExplanation([
        ExplanationSection(heading: 'H', body: body),
      ]);
      expect(chunks.map((c) => c.body).join('\n\n'), body);
    });
  });

  group('LessonStepBuilder', () {
    test('builds steps in order with one example per step', () {
      final steps = const LessonStepBuilder().build(lessonConcept());
      expect(steps.first, isA<GoalsStep>());
      expect(steps.whereType<ExampleStep>(), hasLength(2));
      final kinds = steps.map((s) => s.runtimeType).toList();
      expect(
        kinds.indexOf(ExampleStep),
        greaterThan(kinds.indexOf(ExplanationStep)),
      );
      expect(kinds.sublist(kinds.length - 3), [
        MisconceptionsStep,
        TryItStep,
        CheckUnderstandingStep,
      ]);
      expect(steps.map((s) => s.id).toSet(), hasLength(steps.length));
    });

    test('places quick checks between chunks, never after the last one', () {
      final steps = const LessonStepBuilder().build(lessonConcept());
      final explanationAndChecks = steps
          .where((s) => s is ExplanationStep || s is QuickCheckStep)
          .toList();
      expect(explanationAndChecks.last, isA<ExplanationStep>());
      final checks = steps.whereType<QuickCheckStep>().toList();
      expect(checks, isNotEmpty);
      // The first check comes from the misconception, as true/false.
      expect(checks.first.check.options, ['True', 'False']);
      expect(checks.first.check.correctIndex, 1);
      expect(checks.first.check.prompt, contains('Assignment copies'));
    });

    test('skips empty steps and quick checks when there is no data', () {
      final steps = const LessonStepBuilder().build(
        lessonConcept(
          objectives: const [],
          examples: const [],
          misconceptions: const [],
          exercises: const [],
          assessments: const [
            Assessment(
              id: 'x',
              type: ItemType.explanation,
              prompt: 'Explain.',
              modelAnswer: 'Because.',
            ),
          ],
        ),
      );
      expect(steps.whereType<GoalsStep>(), isEmpty);
      expect(steps.whereType<QuickCheckStep>(), isEmpty);
      expect(steps.whereType<ExampleStep>(), isEmpty);
      expect(steps.whereType<MisconceptionsStep>(), isEmpty);
      expect(steps.whereType<TryItStep>(), isEmpty);
      expect(steps.last, isA<CheckUnderstandingStep>());
    });

    test('is deterministic', () {
      final a = const LessonStepBuilder().build(lessonConcept());
      final b = const LessonStepBuilder().build(lessonConcept());
      expect(a.map((s) => s.id), b.map((s) => s.id));
    });

    test('a goals step appears for prerequisites alone', () {
      final steps = const LessonStepBuilder().build(
        lessonConcept(objectives: const [], prerequisites: const ['c0']),
      );
      expect((steps.first as GoalsStep).hasPrerequisites, isTrue);
    });
  });

  group('LessonFlow', () {
    late List<LessonStep> steps;
    setUp(() => steps = const LessonStepBuilder().build(lessonConcept()));

    int checkIndex(List<LessonStep> s) =>
        s.indexWhere((x) => x is QuickCheckStep);

    test('next is gated by an unanswered quick check, any answer unlocks', () {
      var flow = LessonFlow(steps: steps, index: checkIndex(steps));
      expect(flow.canGoNext, isFalse);
      expect(flow.next().index, flow.index);
      flow = flow.answer(0); // wrong answer still unlocks
      expect(flow.canGoNext, isTrue);
      expect(flow.next().index, flow.index + 1);
      // The first answer sticks.
      expect(flow.answer(1).answers.values.single, 0);
    });

    test('back stops at the first step', () {
      var flow = LessonFlow(steps: steps, index: 1);
      flow = flow.back();
      expect(flow.isFirst, isTrue);
      expect(flow.back().index, 0);
    });

    test('jumping cannot skip an unanswered quick check', () {
      final flow = LessonFlow(steps: steps);
      final gate = checkIndex(steps);
      expect(flow.furthestReachable, gate);
      expect(flow.jumpTo(steps.length - 1).index, 0);
      expect(flow.jumpTo(gate).index, gate);
    });

    test('resumes at a saved step and treats earlier checks as passed', () {
      final last = steps.length - 1;
      final flow = LessonFlow.resume(steps, steps[last].id);
      expect(flow.index, last);
      expect(flow.isLast, isTrue);
      expect(flow.furthestReachable, last);
      expect(LessonFlow.resume(steps, 'gone').index, 0);
      expect(LessonFlow.resume(steps, null).index, 0);
    });

    test('progress reports step X of N', () {
      final flow = LessonFlow(steps: steps, index: 1);
      expect(flow.progress, 2 / steps.length);
    });
  });

  test('every curriculum concept builds steps without losing text', () {
    var concepts = 0;
    for (final file in Directory(
      'assets/curriculum',
    ).listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.json')) continue;
      final json = jsonDecode(file.readAsStringSync());
      if (json is! Map<String, dynamic> || json['concepts'] is! List) continue;
      for (final raw in json['concepts'] as List) {
        final concept = Concept.fromJson(
          raw as Map<String, dynamic>,
          learningPathId: json['learningPathId'] as String,
        );
        concepts++;
        final steps = const LessonStepBuilder().build(concept);
        expect(steps, isNotEmpty, reason: concept.id);
        expect(steps.map((s) => s.id).toSet(), hasLength(steps.length));
        for (final section in concept.explanation.sections) {
          final joined = steps
              .whereType<ExplanationStep>()
              .where((s) => s.heading == section.heading)
              .map((s) => s.body)
              .join('\n\n');
          expect(
            joined,
            contains(splitBlocks(section.body).first),
            reason: concept.id,
          );
        }
      }
    }
    expect(concepts, greaterThan(100));
  });
}
