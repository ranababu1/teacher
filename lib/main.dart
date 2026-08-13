import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/services/app_logger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.info('Teacher starting up');

  runApp(const ProviderScope(child: TeacherApp()));
}
