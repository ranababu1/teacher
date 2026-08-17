import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../domain/generate_module_test_use_case.dart';
import 'teach_providers.dart';

/// AI-authored topic-test question batches — see
/// [GenerateModuleTestUseCase] for why these are never persisted back
/// into curriculum content.
final generateModuleTestUseCaseProvider = Provider<GenerateModuleTestUseCase>(
  (ref) {
    return GenerateModuleTestUseCase(
      curriculumRepository: ref.watch(curriculumRepositoryProvider),
      contextBuilder: ref.watch(teachingContextBuilderProvider),
      aiProvider: ref.watch(aiProviderProvider),
      requestLoggingEnabled: ref.watch(aiRequestLoggingEnabledProvider),
    );
  },
);
