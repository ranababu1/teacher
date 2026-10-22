import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/code_runner.dart';
import '../domain/code_runner_repository.dart';
import '../domain/models/code_run.dart';

typedef CodeRunnerFactory = CodeRunner Function(Uri endpoint);

/// Stores the runner URL in the settings key/value table and builds a
/// [CodeRunner] for it on demand.
class CodeRunnerRepositoryImpl implements CodeRunnerRepository {
  CodeRunnerRepositoryImpl(this._db, {required this.runnerFactory});

  final AppDatabase _db;
  final CodeRunnerFactory runnerFactory;

  static const storageKey = 'code_runner_url';

  @override
  Future<Uri?> endpoint() async {
    final row = await (_db.select(
      _db.settingsTable,
    )..where((t) => t.key.equals(storageKey))).getSingleOrNull();
    if (row == null) return null;
    return parseCodeRunnerUrl(row.value);
  }

  @override
  Future<void> setEndpoint(String? url) async {
    try {
      if (url == null || url.trim().isEmpty) {
        await (_db.delete(
          _db.settingsTable,
        )..where((t) => t.key.equals(storageKey))).go();
        return;
      }
      final uri = parseCodeRunnerUrl(url);
      if (uri == null) {
        throw ArgumentError.value(url, 'url', 'must be an https URL');
      }
      await _db
          .into(_db.settingsTable)
          .insertOnConflictUpdate(
            SettingsTableCompanion.insert(
              key: storageKey,
              value: uri.toString(),
            ),
          );
    } on ArgumentError {
      rethrow;
    } on Exception catch (e) {
      throw LocalDatabaseException('Failed to save code runner URL: $e');
    }
  }

  @override
  Future<CodeRunResult> run(CodeRunRequest request) async {
    final uri = await endpoint();
    if (uri == null) {
      throw const ConfigurationException('Code runner is not configured');
    }
    return runnerFactory(uri).run(request);
  }
}
