import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_config.dart';

/// Provided via override in `main.dart` once `.env` has been loaded and
/// [AppConfig.fromEnv] has run. Reading this before the override is applied
/// is a programming error.
final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError('appConfigProvider must be overridden in main()');
});
