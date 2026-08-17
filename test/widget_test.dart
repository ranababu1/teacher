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

  testWidgets('GradientCard renders its child inside a clipped glass shell', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: GradientCard(child: Text('Hello'))),
      ),
    );

    expect(find.text('Hello'), findsOneWidget);
    expect(find.byType(ClipRRect), findsWidgets);
    // No longer wraps a Card — glass has no opaque Material surface.
    expect(find.byType(Card), findsNothing);
    // The default adaptive tint fakes the glass look without paying for a
    // real blur (see gradient_card.dart's GlassTint doc comment).
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('GradientCard with GlassTint.dark applies a real blur', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GradientCard(
            tint: GlassTint.dark,
            child: Text('Featured'),
          ),
        ),
      ),
    );

    expect(find.text('Featured'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
  });
}
