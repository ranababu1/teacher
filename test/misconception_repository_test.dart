import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/core/database/app_database.dart';
import 'package:teacher/features/ai_teacher/data/misconception_repository_impl.dart';
import 'package:teacher/features/ai_teacher/domain/misconception_repository.dart';

void main() {
  late AppDatabase db;
  late MisconceptionRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = MisconceptionRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('MisconceptionRepositoryImpl', () {
    test('records a misconception and reads it back as unresolved', () async {
      final recorded = await repository.recordMisconception(
        conceptId: 'python-closures',
        description: 'Thinks closures capture values, not references',
      );

      expect(recorded.conceptId, 'python-closures');
      expect(
        recorded.description,
        'Thinks closures capture values, not references',
      );
      expect(recorded.isResolved, isFalse);

      final unresolved = await repository.getUnresolvedForConcept(
        'python-closures',
      );

      expect(unresolved, hasLength(1));
      expect(unresolved.first.id, recorded.id);
      expect(unresolved.first.conceptId, 'python-closures');
      expect(unresolved.first.isResolved, isFalse);
    });

    test('resolving a misconception removes it from unresolved results', () async {
      final recorded = await repository.recordMisconception(
        conceptId: 'python-closures',
        description: 'Thinks closures capture values, not references',
      );

      await repository.resolveMisconception(recorded.id);

      final unresolved = await repository.getUnresolvedForConcept(
        'python-closures',
      );

      expect(unresolved, isEmpty);
    });

    test('confidence defaults to 1.0 when not provided', () async {
      final recorded = await repository.recordMisconception(
        conceptId: 'python-closures',
        description: 'Thinks closures capture values, not references',
      );

      expect(recorded.confidence, 1.0);

      final unresolved = await repository.getUnresolvedForConcept(
        'python-closures',
      );
      expect(unresolved.first.confidence, 1.0);
    });

    test('an explicit confidence value is persisted', () async {
      final recorded = await repository.recordMisconception(
        conceptId: 'python-closures',
        description: 'Confuses is and ==',
        confidence: 0.42,
      );

      expect(recorded.confidence, 0.42);

      final unresolved = await repository.getUnresolvedForConcept(
        'python-closures',
      );
      expect(unresolved.first.confidence, 0.42);
    });

    test('misconceptions for different concepts do not leak into each other', () async {
      await repository.recordMisconception(
        conceptId: 'python-closures',
        description: 'Closures misconception',
      );
      await repository.recordMisconception(
        conceptId: 'react-hooks',
        description: 'Hooks misconception',
      );

      final closuresUnresolved = await repository.getUnresolvedForConcept(
        'python-closures',
      );
      final hooksUnresolved = await repository.getUnresolvedForConcept(
        'react-hooks',
      );

      expect(closuresUnresolved, hasLength(1));
      expect(closuresUnresolved.first.description, 'Closures misconception');
      expect(hooksUnresolved, hasLength(1));
      expect(hooksUnresolved.first.description, 'Hooks misconception');
    });

    test('most recent unresolved misconception for a concept comes first', () async {
      // Seed rows directly with distinct, deliberately-ordered timestamps
      // rather than relying on two real DateTime.now() calls: drift's
      // default DateTimeColumn storage has whole-second precision, so a
      // short real-time delay between writes isn't guaranteed to produce
      // a different stored value.
      final earlier = DateTime.now().subtract(const Duration(days: 1));
      final later = DateTime.now();

      final firstId = await db
          .into(db.misconceptionsTable)
          .insert(
            MisconceptionsTableCompanion.insert(
              conceptId: 'python-closures',
              description: 'First misconception',
              detectedAt: earlier,
            ),
          );
      final secondId = await db
          .into(db.misconceptionsTable)
          .insert(
            MisconceptionsTableCompanion.insert(
              conceptId: 'python-closures',
              description: 'Second misconception',
              detectedAt: later,
            ),
          );

      final unresolved = await repository.getUnresolvedForConcept(
        'python-closures',
      );

      expect(unresolved, hasLength(2));
      expect(unresolved.first.id, secondId);
      expect(unresolved.last.id, firstId);
    });

    test('resolving one misconception leaves other unresolved ones for the same concept', () async {
      final first = await repository.recordMisconception(
        conceptId: 'python-closures',
        description: 'First misconception',
      );
      final second = await repository.recordMisconception(
        conceptId: 'python-closures',
        description: 'Second misconception',
      );

      await repository.resolveMisconception(first.id);

      final unresolved = await repository.getUnresolvedForConcept(
        'python-closures',
      );

      expect(unresolved, hasLength(1));
      expect(unresolved.first.id, second.id);
    });
  });
}
