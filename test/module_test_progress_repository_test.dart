import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/core/database/app_database.dart';
import 'package:teacher/features/progress/data/module_test_progress_repository_impl.dart';
import 'package:teacher/features/progress/domain/module_test_progress_repository.dart';

void main() {
  late AppDatabase db;
  late ModuleTestProgressRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = ModuleTestProgressRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('ModuleTestProgressRepositoryImpl', () {
    test('a module is not passed until markModulePassed is called', () async {
      expect(await repository.isModulePassed('python', 'basics-and-io'), isFalse);
      expect(await repository.getPassedModuleIds('python'), isEmpty);
    });

    test('marking a module passed makes it show up as passed', () async {
      await repository.markModulePassed(
        learningPathId: 'python',
        moduleId: 'basics-and-io',
        scorePercent: 80,
        questionCount: 10,
      );

      expect(await repository.isModulePassed('python', 'basics-and-io'), isTrue);
      expect(await repository.getPassedModuleIds('python'), {'basics-and-io'});
    });

    test('marking the same module passed twice is idempotent', () async {
      await repository.markModulePassed(
        learningPathId: 'python',
        moduleId: 'basics-and-io',
        scorePercent: 70,
        questionCount: 10,
      );
      await repository.markModulePassed(
        learningPathId: 'python',
        moduleId: 'basics-and-io',
        scorePercent: 100,
        questionCount: 10,
      );

      expect(await repository.getPassedModuleIds('python'), {'basics-and-io'});
    });

    test('the same module id in different paths is tracked independently', () async {
      await repository.markModulePassed(
        learningPathId: 'python',
        moduleId: 'foundations',
        scorePercent: 80,
        questionCount: 10,
      );

      expect(await repository.isModulePassed('python', 'foundations'), isTrue);
      expect(await repository.isModulePassed('java', 'foundations'), isFalse);
      expect(await repository.getPassedModuleIds('java'), isEmpty);
    });

    test('different modules in the same path are tracked independently', () async {
      await repository.markModulePassed(
        learningPathId: 'python',
        moduleId: 'basics-and-io',
        scorePercent: 80,
        questionCount: 10,
      );
      await repository.markModulePassed(
        learningPathId: 'python',
        moduleId: 'functions',
        scorePercent: 90,
        questionCount: 10,
      );

      expect(
        await repository.getPassedModuleIds('python'),
        {'basics-and-io', 'functions'},
      );
    });
  });
}
