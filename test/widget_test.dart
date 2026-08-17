import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/curriculum/domain/models/difficulty.dart';
import 'package:teacher/shared/widgets/difficulty_chip.dart';
import 'package:teacher/shared/widgets/gradient_card.dart';
import 'package:teacher/shared/widgets/labeled_progress_bar.dart';

void main() {
  testWidgets('LabeledProgressBar shows its label and rounded percentage', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LabeledProgressBar(label: 'Python', progress: 0.72),
        ),
      ),
    );

    expect(find.text('Python'), findsOneWidget);
    expect(find.text('72%'), findsOneWidget);
  });

  testWidgets(
    'DifficultyChip renders the human-readable label for each difficulty',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DifficultyChip(difficulty: Difficulty.advanced)),
        ),
      );

      expect(find.text('Advanced'), findsOneWidget);
    },
  );

  testWidgets('GradientCard renders its child inside a Card', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: GradientCard(child: Text('Hello'))),
      ),
    );

    expect(find.text('Hello'), findsOneWidget);
    expect(find.byType(Card), findsOneWidget);
  });
}
