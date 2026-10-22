import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/code_runner_repository_impl.dart';
import '../../data/remote_code_runner.dart';
import '../../domain/code_runner_repository.dart';

final codeRunnerRepositoryProvider = Provider<CodeRunnerRepository>(
  (ref) => CodeRunnerRepositoryImpl(
    ref.watch(appDatabaseProvider),
    runnerFactory: RemoteCodeRunner.new,
  ),
);

/// The configured runner URL, or null while the feature is off (default).
final codeRunnerEndpointProvider = FutureProvider<Uri?>(
  (ref) => ref.watch(codeRunnerRepositoryProvider).endpoint(),
);
