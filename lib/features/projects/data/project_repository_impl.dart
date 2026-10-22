import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show AssetBundle;

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/models/project.dart';
import '../domain/project_repository.dart';

const projectsAssetPath = 'assets/projects/projects.json';

class ProjectRepositoryImpl implements ProjectRepository {
  ProjectRepositoryImpl(this._bundle);

  final AssetBundle _bundle;
  Future<List<Project>>? _cache;

  @override
  Future<List<Project>> getProjects() => _cache ??= _load();

  Future<List<Project>> _load() async {
    try {
      final raw = await _bundle.loadString(projectsAssetPath);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return (json['projects'] as List<dynamic>)
          .map((p) => Project.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _cache = null;
      throw ContentNotFoundException('Failed to load projects: $e');
    }
  }

  @override
  Future<Project?> getProject(String projectId) async {
    final projects = await getProjects();
    return projects.where((p) => p.id == projectId).firstOrNull;
  }
}

class ProjectProgressRepositoryImpl implements ProjectProgressRepository {
  ProjectProgressRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<Map<String, Set<String>>> getAllCompletedMilestones() async {
    final rows = await _db.select(_db.projectMilestoneProgressTable).get();
    final result = <String, Set<String>>{};
    for (final r in rows) {
      result.putIfAbsent(r.projectId, () => {}).add(r.milestoneId);
    }
    return result;
  }

  @override
  Future<Set<String>> getCompletedMilestones(String projectId) async {
    final rows = await (_db.select(
      _db.projectMilestoneProgressTable,
    )..where((t) => t.projectId.equals(projectId))).get();
    return rows.map((r) => r.milestoneId).toSet();
  }

  @override
  Future<void> setMilestoneCompleted({
    required String projectId,
    required String milestoneId,
    required bool completed,
  }) async {
    try {
      if (completed) {
        await _db
            .into(_db.projectMilestoneProgressTable)
            .insertOnConflictUpdate(
              ProjectMilestoneProgressTableCompanion.insert(
                projectId: projectId,
                milestoneId: milestoneId,
                completedAt: DateTime.now(),
              ),
            );
      } else {
        await (_db.delete(_db.projectMilestoneProgressTable)..where(
              (t) =>
                  t.projectId.equals(projectId) &
                  t.milestoneId.equals(milestoneId),
            ))
            .go();
      }
    } on Exception catch (e) {
      throw LocalDatabaseException(
        'Failed to update milestone $milestoneId of $projectId: $e',
      );
    }
  }
}
