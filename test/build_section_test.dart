import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/build_hub/domain/build_progress.dart';
import 'package:teacher/features/build_hub/presentation/build_progress_provider.dart';
import 'package:teacher/features/build_hub/presentation/build_section.dart';

Widget _host(Override override) => ProviderScope(
  overrides: [override],
  child: const MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: BuildSection())),
  ),
);

void main() {
  testWidgets('shows per-track progress once loaded', (tester) async {
    await tester.pumpWidget(
      _host(
        buildProgressProvider.overrideWith(
          (ref) async => const BuildProgress(
            projects: TrackProgress(total: 10, done: 2, inProgress: 1),
            systemDesign: TrackProgress(total: 6, done: 0),
            codingChallenges: TrackProgress(total: 6, done: 3),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('BUILD AND DESIGN'), findsOneWidget);
    expect(find.text('2 of 10 done, 1 in progress'), findsOneWidget);
    expect(
      find.text('Staged design walkthroughs with model answers'),
      findsOneWidget,
    );
    expect(find.text('3 of 6 done'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
  });

  testWidgets('keeps the entry points while loading or on error', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        buildProgressProvider.overrideWith(
          (ref) => Future<BuildProgress>.error(StateError('boom')),
        ),
      ),
    );
    expect(find.text('Projects'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Projects'), findsOneWidget);
    expect(find.text('System Design'), findsOneWidget);
    expect(find.text('Long-form challenges'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });
}
