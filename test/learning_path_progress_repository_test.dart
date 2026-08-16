import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/core/database/app_database.dart';
import 'package:teacher/features/progress/data/learning_path_progress_repository_impl.dart';
import 'package:teacher/features/progress/domain/learning_path_progress_repository.dart';

void main() {
  late AppDatabase db;
  late LearningPathProgressRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = LearningPathProgressRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('LearningPathProgressRepositoryImpl', () {
    test('a path is not started until markPathStarted is called', () async {
      expect(await repository.isPathStarted('python'), isFalse);
      expect(await repository.getStartedPathIds(), isEmpty);
    });

    test('marking a path started makes it show up as started', () async {
      await repository.markPathStarted('python');

      expect(await repository.isPathStarted('python'), isTrue);
      expect(await repository.getStartedPathIds(), {'python'});
    });

    test('marking the same path started twice is idempotent', () async {
      await repository.markPathStarted('python');
      await repository.markPathStarted('python');

      expect(await repository.getStartedPathIds(), {'python'});
    });

    test('different paths are tracked independently', () async {
      await repository.markPathStarted('python');
      await repository.markPathStarted('java');

      expect(await repository.isPathStarted('python'), isTrue);
      expect(await repository.isPathStarted('java'), isTrue);
      expect(await repository.isPathStarted('react'), isFalse);
      expect(await repository.getStartedPathIds(), {'python', 'java'});
    });
  });
}
