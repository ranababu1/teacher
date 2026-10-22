import 'package:drift/drift.dart';

/// One completed milestone of a guided project (see assets/projects).
/// A row exists only while the milestone is ticked.
class ProjectMilestoneProgressTable extends Table {
  TextColumn get projectId => text()();
  TextColumn get milestoneId => text()();
  DateTimeColumn get completedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {projectId, milestoneId};
}
