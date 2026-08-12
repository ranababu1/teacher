import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bumped whenever persisted progress/mastery/review/attempt data changes.
///
/// Read-side FutureProviders (mastery, student progress, due reviews,
/// learning stats) `ref.watch` this so they refetch after a write instead
/// of serving their first cached result for the rest of the app session.
/// See [RecordAttemptUseCase] and the providers that wrap it.
class DataRevision extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final dataRevisionProvider = NotifierProvider<DataRevision, int>(
  DataRevision.new,
);
