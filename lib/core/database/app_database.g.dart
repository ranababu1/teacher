// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $StudentProgressTableTable extends StudentProgressTable
    with TableInfo<$StudentProgressTableTable, StudentProgressTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentProgressTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _conceptIdMeta = const VerificationMeta(
    'conceptId',
  );
  @override
  late final GeneratedColumn<String> conceptId = GeneratedColumn<String>(
    'concept_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _learningPathIdMeta = const VerificationMeta(
    'learningPathId',
  );
  @override
  late final GeneratedColumn<String> learningPathId = GeneratedColumn<String>(
    'learning_path_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moduleIdMeta = const VerificationMeta(
    'moduleId',
  );
  @override
  late final GeneratedColumn<String> moduleId = GeneratedColumn<String>(
    'module_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastAccessedAtMeta = const VerificationMeta(
    'lastAccessedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAccessedAt =
      GeneratedColumn<DateTime>(
        'last_accessed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    conceptId,
    learningPathId,
    moduleId,
    startedAt,
    completedAt,
    lastAccessedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'student_progress_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudentProgressTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('concept_id')) {
      context.handle(
        _conceptIdMeta,
        conceptId.isAcceptableOrUnknown(data['concept_id']!, _conceptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_conceptIdMeta);
    }
    if (data.containsKey('learning_path_id')) {
      context.handle(
        _learningPathIdMeta,
        learningPathId.isAcceptableOrUnknown(
          data['learning_path_id']!,
          _learningPathIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_learningPathIdMeta);
    }
    if (data.containsKey('module_id')) {
      context.handle(
        _moduleIdMeta,
        moduleId.isAcceptableOrUnknown(data['module_id']!, _moduleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_moduleIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_accessed_at')) {
      context.handle(
        _lastAccessedAtMeta,
        lastAccessedAt.isAcceptableOrUnknown(
          data['last_accessed_at']!,
          _lastAccessedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {conceptId};
  @override
  StudentProgressTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudentProgressTableData(
      conceptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concept_id'],
      )!,
      learningPathId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}learning_path_id'],
      )!,
      moduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}module_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      lastAccessedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_accessed_at'],
      ),
    );
  }

  @override
  $StudentProgressTableTable createAlias(String alias) {
    return $StudentProgressTableTable(attachedDatabase, alias);
  }
}

class StudentProgressTableData extends DataClass
    implements Insertable<StudentProgressTableData> {
  final String conceptId;
  final String learningPathId;
  final String moduleId;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? lastAccessedAt;
  const StudentProgressTableData({
    required this.conceptId,
    required this.learningPathId,
    required this.moduleId,
    this.startedAt,
    this.completedAt,
    this.lastAccessedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['concept_id'] = Variable<String>(conceptId);
    map['learning_path_id'] = Variable<String>(learningPathId);
    map['module_id'] = Variable<String>(moduleId);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || lastAccessedAt != null) {
      map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt);
    }
    return map;
  }

  StudentProgressTableCompanion toCompanion(bool nullToAbsent) {
    return StudentProgressTableCompanion(
      conceptId: Value(conceptId),
      learningPathId: Value(learningPathId),
      moduleId: Value(moduleId),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      lastAccessedAt: lastAccessedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAccessedAt),
    );
  }

  factory StudentProgressTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudentProgressTableData(
      conceptId: serializer.fromJson<String>(json['conceptId']),
      learningPathId: serializer.fromJson<String>(json['learningPathId']),
      moduleId: serializer.fromJson<String>(json['moduleId']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      lastAccessedAt: serializer.fromJson<DateTime?>(json['lastAccessedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'conceptId': serializer.toJson<String>(conceptId),
      'learningPathId': serializer.toJson<String>(learningPathId),
      'moduleId': serializer.toJson<String>(moduleId),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'lastAccessedAt': serializer.toJson<DateTime?>(lastAccessedAt),
    };
  }

  StudentProgressTableData copyWith({
    String? conceptId,
    String? learningPathId,
    String? moduleId,
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    Value<DateTime?> lastAccessedAt = const Value.absent(),
  }) => StudentProgressTableData(
    conceptId: conceptId ?? this.conceptId,
    learningPathId: learningPathId ?? this.learningPathId,
    moduleId: moduleId ?? this.moduleId,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    lastAccessedAt: lastAccessedAt.present
        ? lastAccessedAt.value
        : this.lastAccessedAt,
  );
  StudentProgressTableData copyWithCompanion(
    StudentProgressTableCompanion data,
  ) {
    return StudentProgressTableData(
      conceptId: data.conceptId.present ? data.conceptId.value : this.conceptId,
      learningPathId: data.learningPathId.present
          ? data.learningPathId.value
          : this.learningPathId,
      moduleId: data.moduleId.present ? data.moduleId.value : this.moduleId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      lastAccessedAt: data.lastAccessedAt.present
          ? data.lastAccessedAt.value
          : this.lastAccessedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudentProgressTableData(')
          ..write('conceptId: $conceptId, ')
          ..write('learningPathId: $learningPathId, ')
          ..write('moduleId: $moduleId, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('lastAccessedAt: $lastAccessedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    conceptId,
    learningPathId,
    moduleId,
    startedAt,
    completedAt,
    lastAccessedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudentProgressTableData &&
          other.conceptId == this.conceptId &&
          other.learningPathId == this.learningPathId &&
          other.moduleId == this.moduleId &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.lastAccessedAt == this.lastAccessedAt);
}

class StudentProgressTableCompanion
    extends UpdateCompanion<StudentProgressTableData> {
  final Value<String> conceptId;
  final Value<String> learningPathId;
  final Value<String> moduleId;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> completedAt;
  final Value<DateTime?> lastAccessedAt;
  final Value<int> rowid;
  const StudentProgressTableCompanion({
    this.conceptId = const Value.absent(),
    this.learningPathId = const Value.absent(),
    this.moduleId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudentProgressTableCompanion.insert({
    required String conceptId,
    required String learningPathId,
    required String moduleId,
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : conceptId = Value(conceptId),
       learningPathId = Value(learningPathId),
       moduleId = Value(moduleId);
  static Insertable<StudentProgressTableData> custom({
    Expression<String>? conceptId,
    Expression<String>? learningPathId,
    Expression<String>? moduleId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? lastAccessedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (conceptId != null) 'concept_id': conceptId,
      if (learningPathId != null) 'learning_path_id': learningPathId,
      if (moduleId != null) 'module_id': moduleId,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (lastAccessedAt != null) 'last_accessed_at': lastAccessedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudentProgressTableCompanion copyWith({
    Value<String>? conceptId,
    Value<String>? learningPathId,
    Value<String>? moduleId,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? completedAt,
    Value<DateTime?>? lastAccessedAt,
    Value<int>? rowid,
  }) {
    return StudentProgressTableCompanion(
      conceptId: conceptId ?? this.conceptId,
      learningPathId: learningPathId ?? this.learningPathId,
      moduleId: moduleId ?? this.moduleId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (conceptId.present) {
      map['concept_id'] = Variable<String>(conceptId.value);
    }
    if (learningPathId.present) {
      map['learning_path_id'] = Variable<String>(learningPathId.value);
    }
    if (moduleId.present) {
      map['module_id'] = Variable<String>(moduleId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (lastAccessedAt.present) {
      map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentProgressTableCompanion(')
          ..write('conceptId: $conceptId, ')
          ..write('learningPathId: $learningPathId, ')
          ..write('moduleId: $moduleId, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConceptMasteryTableTable extends ConceptMasteryTable
    with TableInfo<$ConceptMasteryTableTable, ConceptMasteryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConceptMasteryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _conceptIdMeta = const VerificationMeta(
    'conceptId',
  );
  @override
  late final GeneratedColumn<String> conceptId = GeneratedColumn<String>(
    'concept_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recallScoreMeta = const VerificationMeta(
    'recallScore',
  );
  @override
  late final GeneratedColumn<double> recallScore = GeneratedColumn<double>(
    'recall_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _understandingScoreMeta =
      const VerificationMeta('understandingScore');
  @override
  late final GeneratedColumn<double> understandingScore =
      GeneratedColumn<double>(
        'understanding_score',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _applicationScoreMeta = const VerificationMeta(
    'applicationScore',
  );
  @override
  late final GeneratedColumn<double> applicationScore = GeneratedColumn<double>(
    'application_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _explanationScoreMeta = const VerificationMeta(
    'explanationScore',
  );
  @override
  late final GeneratedColumn<double> explanationScore = GeneratedColumn<double>(
    'explanation_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _codingScoreMeta = const VerificationMeta(
    'codingScore',
  );
  @override
  late final GeneratedColumn<double> codingScore = GeneratedColumn<double>(
    'coding_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _debuggingScoreMeta = const VerificationMeta(
    'debuggingScore',
  );
  @override
  late final GeneratedColumn<double> debuggingScore = GeneratedColumn<double>(
    'debugging_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _overallMasteryMeta = const VerificationMeta(
    'overallMastery',
  );
  @override
  late final GeneratedColumn<double> overallMastery = GeneratedColumn<double>(
    'overall_mastery',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _successCountMeta = const VerificationMeta(
    'successCount',
  );
  @override
  late final GeneratedColumn<int> successCount = GeneratedColumn<int>(
    'success_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _failureCountMeta = const VerificationMeta(
    'failureCount',
  );
  @override
  late final GeneratedColumn<int> failureCount = GeneratedColumn<int>(
    'failure_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastReviewedAtMeta = const VerificationMeta(
    'lastReviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReviewedAt =
      GeneratedColumn<DateTime>(
        'last_reviewed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _nextReviewAtMeta = const VerificationMeta(
    'nextReviewAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextReviewAt = GeneratedColumn<DateTime>(
    'next_review_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('not_started'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    conceptId,
    recallScore,
    understandingScore,
    applicationScore,
    explanationScore,
    codingScore,
    debuggingScore,
    overallMastery,
    attemptCount,
    successCount,
    failureCount,
    confidence,
    lastReviewedAt,
    nextReviewAt,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'concept_mastery_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConceptMasteryTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('concept_id')) {
      context.handle(
        _conceptIdMeta,
        conceptId.isAcceptableOrUnknown(data['concept_id']!, _conceptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_conceptIdMeta);
    }
    if (data.containsKey('recall_score')) {
      context.handle(
        _recallScoreMeta,
        recallScore.isAcceptableOrUnknown(
          data['recall_score']!,
          _recallScoreMeta,
        ),
      );
    }
    if (data.containsKey('understanding_score')) {
      context.handle(
        _understandingScoreMeta,
        understandingScore.isAcceptableOrUnknown(
          data['understanding_score']!,
          _understandingScoreMeta,
        ),
      );
    }
    if (data.containsKey('application_score')) {
      context.handle(
        _applicationScoreMeta,
        applicationScore.isAcceptableOrUnknown(
          data['application_score']!,
          _applicationScoreMeta,
        ),
      );
    }
    if (data.containsKey('explanation_score')) {
      context.handle(
        _explanationScoreMeta,
        explanationScore.isAcceptableOrUnknown(
          data['explanation_score']!,
          _explanationScoreMeta,
        ),
      );
    }
    if (data.containsKey('coding_score')) {
      context.handle(
        _codingScoreMeta,
        codingScore.isAcceptableOrUnknown(
          data['coding_score']!,
          _codingScoreMeta,
        ),
      );
    }
    if (data.containsKey('debugging_score')) {
      context.handle(
        _debuggingScoreMeta,
        debuggingScore.isAcceptableOrUnknown(
          data['debugging_score']!,
          _debuggingScoreMeta,
        ),
      );
    }
    if (data.containsKey('overall_mastery')) {
      context.handle(
        _overallMasteryMeta,
        overallMastery.isAcceptableOrUnknown(
          data['overall_mastery']!,
          _overallMasteryMeta,
        ),
      );
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('success_count')) {
      context.handle(
        _successCountMeta,
        successCount.isAcceptableOrUnknown(
          data['success_count']!,
          _successCountMeta,
        ),
      );
    }
    if (data.containsKey('failure_count')) {
      context.handle(
        _failureCountMeta,
        failureCount.isAcceptableOrUnknown(
          data['failure_count']!,
          _failureCountMeta,
        ),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('last_reviewed_at')) {
      context.handle(
        _lastReviewedAtMeta,
        lastReviewedAt.isAcceptableOrUnknown(
          data['last_reviewed_at']!,
          _lastReviewedAtMeta,
        ),
      );
    }
    if (data.containsKey('next_review_at')) {
      context.handle(
        _nextReviewAtMeta,
        nextReviewAt.isAcceptableOrUnknown(
          data['next_review_at']!,
          _nextReviewAtMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {conceptId};
  @override
  ConceptMasteryTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConceptMasteryTableData(
      conceptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concept_id'],
      )!,
      recallScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}recall_score'],
      )!,
      understandingScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}understanding_score'],
      )!,
      applicationScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}application_score'],
      )!,
      explanationScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}explanation_score'],
      )!,
      codingScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}coding_score'],
      )!,
      debuggingScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}debugging_score'],
      )!,
      overallMastery: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}overall_mastery'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      successCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}success_count'],
      )!,
      failureCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}failure_count'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      lastReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reviewed_at'],
      ),
      nextReviewAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_review_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $ConceptMasteryTableTable createAlias(String alias) {
    return $ConceptMasteryTableTable(attachedDatabase, alias);
  }
}

class ConceptMasteryTableData extends DataClass
    implements Insertable<ConceptMasteryTableData> {
  final String conceptId;
  final double recallScore;
  final double understandingScore;
  final double applicationScore;
  final double explanationScore;
  final double codingScore;
  final double debuggingScore;
  final double overallMastery;
  final int attemptCount;
  final int successCount;
  final int failureCount;
  final double confidence;
  final DateTime? lastReviewedAt;
  final DateTime? nextReviewAt;

  /// One of: not_started, learning, developing, proficient, mastered, needs_review
  final String status;
  const ConceptMasteryTableData({
    required this.conceptId,
    required this.recallScore,
    required this.understandingScore,
    required this.applicationScore,
    required this.explanationScore,
    required this.codingScore,
    required this.debuggingScore,
    required this.overallMastery,
    required this.attemptCount,
    required this.successCount,
    required this.failureCount,
    required this.confidence,
    this.lastReviewedAt,
    this.nextReviewAt,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['concept_id'] = Variable<String>(conceptId);
    map['recall_score'] = Variable<double>(recallScore);
    map['understanding_score'] = Variable<double>(understandingScore);
    map['application_score'] = Variable<double>(applicationScore);
    map['explanation_score'] = Variable<double>(explanationScore);
    map['coding_score'] = Variable<double>(codingScore);
    map['debugging_score'] = Variable<double>(debuggingScore);
    map['overall_mastery'] = Variable<double>(overallMastery);
    map['attempt_count'] = Variable<int>(attemptCount);
    map['success_count'] = Variable<int>(successCount);
    map['failure_count'] = Variable<int>(failureCount);
    map['confidence'] = Variable<double>(confidence);
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt);
    }
    if (!nullToAbsent || nextReviewAt != null) {
      map['next_review_at'] = Variable<DateTime>(nextReviewAt);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  ConceptMasteryTableCompanion toCompanion(bool nullToAbsent) {
    return ConceptMasteryTableCompanion(
      conceptId: Value(conceptId),
      recallScore: Value(recallScore),
      understandingScore: Value(understandingScore),
      applicationScore: Value(applicationScore),
      explanationScore: Value(explanationScore),
      codingScore: Value(codingScore),
      debuggingScore: Value(debuggingScore),
      overallMastery: Value(overallMastery),
      attemptCount: Value(attemptCount),
      successCount: Value(successCount),
      failureCount: Value(failureCount),
      confidence: Value(confidence),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
      nextReviewAt: nextReviewAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextReviewAt),
      status: Value(status),
    );
  }

  factory ConceptMasteryTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConceptMasteryTableData(
      conceptId: serializer.fromJson<String>(json['conceptId']),
      recallScore: serializer.fromJson<double>(json['recallScore']),
      understandingScore: serializer.fromJson<double>(
        json['understandingScore'],
      ),
      applicationScore: serializer.fromJson<double>(json['applicationScore']),
      explanationScore: serializer.fromJson<double>(json['explanationScore']),
      codingScore: serializer.fromJson<double>(json['codingScore']),
      debuggingScore: serializer.fromJson<double>(json['debuggingScore']),
      overallMastery: serializer.fromJson<double>(json['overallMastery']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      successCount: serializer.fromJson<int>(json['successCount']),
      failureCount: serializer.fromJson<int>(json['failureCount']),
      confidence: serializer.fromJson<double>(json['confidence']),
      lastReviewedAt: serializer.fromJson<DateTime?>(json['lastReviewedAt']),
      nextReviewAt: serializer.fromJson<DateTime?>(json['nextReviewAt']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'conceptId': serializer.toJson<String>(conceptId),
      'recallScore': serializer.toJson<double>(recallScore),
      'understandingScore': serializer.toJson<double>(understandingScore),
      'applicationScore': serializer.toJson<double>(applicationScore),
      'explanationScore': serializer.toJson<double>(explanationScore),
      'codingScore': serializer.toJson<double>(codingScore),
      'debuggingScore': serializer.toJson<double>(debuggingScore),
      'overallMastery': serializer.toJson<double>(overallMastery),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'successCount': serializer.toJson<int>(successCount),
      'failureCount': serializer.toJson<int>(failureCount),
      'confidence': serializer.toJson<double>(confidence),
      'lastReviewedAt': serializer.toJson<DateTime?>(lastReviewedAt),
      'nextReviewAt': serializer.toJson<DateTime?>(nextReviewAt),
      'status': serializer.toJson<String>(status),
    };
  }

  ConceptMasteryTableData copyWith({
    String? conceptId,
    double? recallScore,
    double? understandingScore,
    double? applicationScore,
    double? explanationScore,
    double? codingScore,
    double? debuggingScore,
    double? overallMastery,
    int? attemptCount,
    int? successCount,
    int? failureCount,
    double? confidence,
    Value<DateTime?> lastReviewedAt = const Value.absent(),
    Value<DateTime?> nextReviewAt = const Value.absent(),
    String? status,
  }) => ConceptMasteryTableData(
    conceptId: conceptId ?? this.conceptId,
    recallScore: recallScore ?? this.recallScore,
    understandingScore: understandingScore ?? this.understandingScore,
    applicationScore: applicationScore ?? this.applicationScore,
    explanationScore: explanationScore ?? this.explanationScore,
    codingScore: codingScore ?? this.codingScore,
    debuggingScore: debuggingScore ?? this.debuggingScore,
    overallMastery: overallMastery ?? this.overallMastery,
    attemptCount: attemptCount ?? this.attemptCount,
    successCount: successCount ?? this.successCount,
    failureCount: failureCount ?? this.failureCount,
    confidence: confidence ?? this.confidence,
    lastReviewedAt: lastReviewedAt.present
        ? lastReviewedAt.value
        : this.lastReviewedAt,
    nextReviewAt: nextReviewAt.present ? nextReviewAt.value : this.nextReviewAt,
    status: status ?? this.status,
  );
  ConceptMasteryTableData copyWithCompanion(ConceptMasteryTableCompanion data) {
    return ConceptMasteryTableData(
      conceptId: data.conceptId.present ? data.conceptId.value : this.conceptId,
      recallScore: data.recallScore.present
          ? data.recallScore.value
          : this.recallScore,
      understandingScore: data.understandingScore.present
          ? data.understandingScore.value
          : this.understandingScore,
      applicationScore: data.applicationScore.present
          ? data.applicationScore.value
          : this.applicationScore,
      explanationScore: data.explanationScore.present
          ? data.explanationScore.value
          : this.explanationScore,
      codingScore: data.codingScore.present
          ? data.codingScore.value
          : this.codingScore,
      debuggingScore: data.debuggingScore.present
          ? data.debuggingScore.value
          : this.debuggingScore,
      overallMastery: data.overallMastery.present
          ? data.overallMastery.value
          : this.overallMastery,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      successCount: data.successCount.present
          ? data.successCount.value
          : this.successCount,
      failureCount: data.failureCount.present
          ? data.failureCount.value
          : this.failureCount,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
      nextReviewAt: data.nextReviewAt.present
          ? data.nextReviewAt.value
          : this.nextReviewAt,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConceptMasteryTableData(')
          ..write('conceptId: $conceptId, ')
          ..write('recallScore: $recallScore, ')
          ..write('understandingScore: $understandingScore, ')
          ..write('applicationScore: $applicationScore, ')
          ..write('explanationScore: $explanationScore, ')
          ..write('codingScore: $codingScore, ')
          ..write('debuggingScore: $debuggingScore, ')
          ..write('overallMastery: $overallMastery, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('successCount: $successCount, ')
          ..write('failureCount: $failureCount, ')
          ..write('confidence: $confidence, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    conceptId,
    recallScore,
    understandingScore,
    applicationScore,
    explanationScore,
    codingScore,
    debuggingScore,
    overallMastery,
    attemptCount,
    successCount,
    failureCount,
    confidence,
    lastReviewedAt,
    nextReviewAt,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConceptMasteryTableData &&
          other.conceptId == this.conceptId &&
          other.recallScore == this.recallScore &&
          other.understandingScore == this.understandingScore &&
          other.applicationScore == this.applicationScore &&
          other.explanationScore == this.explanationScore &&
          other.codingScore == this.codingScore &&
          other.debuggingScore == this.debuggingScore &&
          other.overallMastery == this.overallMastery &&
          other.attemptCount == this.attemptCount &&
          other.successCount == this.successCount &&
          other.failureCount == this.failureCount &&
          other.confidence == this.confidence &&
          other.lastReviewedAt == this.lastReviewedAt &&
          other.nextReviewAt == this.nextReviewAt &&
          other.status == this.status);
}

class ConceptMasteryTableCompanion
    extends UpdateCompanion<ConceptMasteryTableData> {
  final Value<String> conceptId;
  final Value<double> recallScore;
  final Value<double> understandingScore;
  final Value<double> applicationScore;
  final Value<double> explanationScore;
  final Value<double> codingScore;
  final Value<double> debuggingScore;
  final Value<double> overallMastery;
  final Value<int> attemptCount;
  final Value<int> successCount;
  final Value<int> failureCount;
  final Value<double> confidence;
  final Value<DateTime?> lastReviewedAt;
  final Value<DateTime?> nextReviewAt;
  final Value<String> status;
  final Value<int> rowid;
  const ConceptMasteryTableCompanion({
    this.conceptId = const Value.absent(),
    this.recallScore = const Value.absent(),
    this.understandingScore = const Value.absent(),
    this.applicationScore = const Value.absent(),
    this.explanationScore = const Value.absent(),
    this.codingScore = const Value.absent(),
    this.debuggingScore = const Value.absent(),
    this.overallMastery = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.successCount = const Value.absent(),
    this.failureCount = const Value.absent(),
    this.confidence = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConceptMasteryTableCompanion.insert({
    required String conceptId,
    this.recallScore = const Value.absent(),
    this.understandingScore = const Value.absent(),
    this.applicationScore = const Value.absent(),
    this.explanationScore = const Value.absent(),
    this.codingScore = const Value.absent(),
    this.debuggingScore = const Value.absent(),
    this.overallMastery = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.successCount = const Value.absent(),
    this.failureCount = const Value.absent(),
    this.confidence = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : conceptId = Value(conceptId);
  static Insertable<ConceptMasteryTableData> custom({
    Expression<String>? conceptId,
    Expression<double>? recallScore,
    Expression<double>? understandingScore,
    Expression<double>? applicationScore,
    Expression<double>? explanationScore,
    Expression<double>? codingScore,
    Expression<double>? debuggingScore,
    Expression<double>? overallMastery,
    Expression<int>? attemptCount,
    Expression<int>? successCount,
    Expression<int>? failureCount,
    Expression<double>? confidence,
    Expression<DateTime>? lastReviewedAt,
    Expression<DateTime>? nextReviewAt,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (conceptId != null) 'concept_id': conceptId,
      if (recallScore != null) 'recall_score': recallScore,
      if (understandingScore != null) 'understanding_score': understandingScore,
      if (applicationScore != null) 'application_score': applicationScore,
      if (explanationScore != null) 'explanation_score': explanationScore,
      if (codingScore != null) 'coding_score': codingScore,
      if (debuggingScore != null) 'debugging_score': debuggingScore,
      if (overallMastery != null) 'overall_mastery': overallMastery,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (successCount != null) 'success_count': successCount,
      if (failureCount != null) 'failure_count': failureCount,
      if (confidence != null) 'confidence': confidence,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (nextReviewAt != null) 'next_review_at': nextReviewAt,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConceptMasteryTableCompanion copyWith({
    Value<String>? conceptId,
    Value<double>? recallScore,
    Value<double>? understandingScore,
    Value<double>? applicationScore,
    Value<double>? explanationScore,
    Value<double>? codingScore,
    Value<double>? debuggingScore,
    Value<double>? overallMastery,
    Value<int>? attemptCount,
    Value<int>? successCount,
    Value<int>? failureCount,
    Value<double>? confidence,
    Value<DateTime?>? lastReviewedAt,
    Value<DateTime?>? nextReviewAt,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return ConceptMasteryTableCompanion(
      conceptId: conceptId ?? this.conceptId,
      recallScore: recallScore ?? this.recallScore,
      understandingScore: understandingScore ?? this.understandingScore,
      applicationScore: applicationScore ?? this.applicationScore,
      explanationScore: explanationScore ?? this.explanationScore,
      codingScore: codingScore ?? this.codingScore,
      debuggingScore: debuggingScore ?? this.debuggingScore,
      overallMastery: overallMastery ?? this.overallMastery,
      attemptCount: attemptCount ?? this.attemptCount,
      successCount: successCount ?? this.successCount,
      failureCount: failureCount ?? this.failureCount,
      confidence: confidence ?? this.confidence,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (conceptId.present) {
      map['concept_id'] = Variable<String>(conceptId.value);
    }
    if (recallScore.present) {
      map['recall_score'] = Variable<double>(recallScore.value);
    }
    if (understandingScore.present) {
      map['understanding_score'] = Variable<double>(understandingScore.value);
    }
    if (applicationScore.present) {
      map['application_score'] = Variable<double>(applicationScore.value);
    }
    if (explanationScore.present) {
      map['explanation_score'] = Variable<double>(explanationScore.value);
    }
    if (codingScore.present) {
      map['coding_score'] = Variable<double>(codingScore.value);
    }
    if (debuggingScore.present) {
      map['debugging_score'] = Variable<double>(debuggingScore.value);
    }
    if (overallMastery.present) {
      map['overall_mastery'] = Variable<double>(overallMastery.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (successCount.present) {
      map['success_count'] = Variable<int>(successCount.value);
    }
    if (failureCount.present) {
      map['failure_count'] = Variable<int>(failureCount.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt.value);
    }
    if (nextReviewAt.present) {
      map['next_review_at'] = Variable<DateTime>(nextReviewAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConceptMasteryTableCompanion(')
          ..write('conceptId: $conceptId, ')
          ..write('recallScore: $recallScore, ')
          ..write('understandingScore: $understandingScore, ')
          ..write('applicationScore: $applicationScore, ')
          ..write('explanationScore: $explanationScore, ')
          ..write('codingScore: $codingScore, ')
          ..write('debuggingScore: $debuggingScore, ')
          ..write('overallMastery: $overallMastery, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('successCount: $successCount, ')
          ..write('failureCount: $failureCount, ')
          ..write('confidence: $confidence, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttemptsTableTable extends AttemptsTable
    with TableInfo<$AttemptsTableTable, AttemptsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttemptsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _conceptIdMeta = const VerificationMeta(
    'conceptId',
  );
  @override
  late final GeneratedColumn<String> conceptId = GeneratedColumn<String>(
    'concept_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemKindMeta = const VerificationMeta(
    'itemKind',
  );
  @override
  late final GeneratedColumn<String> itemKind = GeneratedColumn<String>(
    'item_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemTypeMeta = const VerificationMeta(
    'itemType',
  );
  @override
  late final GeneratedColumn<String> itemType = GeneratedColumn<String>(
    'item_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCorrectMeta = const VerificationMeta(
    'isCorrect',
  );
  @override
  late final GeneratedColumn<bool> isCorrect = GeneratedColumn<bool>(
    'is_correct',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _selfRatingMeta = const VerificationMeta(
    'selfRating',
  );
  @override
  late final GeneratedColumn<int> selfRating = GeneratedColumn<int>(
    'self_rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hintsUsedMeta = const VerificationMeta(
    'hintsUsed',
  );
  @override
  late final GeneratedColumn<int> hintsUsed = GeneratedColumn<int>(
    'hints_used',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _userResponseMeta = const VerificationMeta(
    'userResponse',
  );
  @override
  late final GeneratedColumn<String> userResponse = GeneratedColumn<String>(
    'user_response',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    conceptId,
    itemId,
    itemKind,
    itemType,
    isCorrect,
    selfRating,
    hintsUsed,
    userResponse,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attempts_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttemptsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('concept_id')) {
      context.handle(
        _conceptIdMeta,
        conceptId.isAcceptableOrUnknown(data['concept_id']!, _conceptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_conceptIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('item_kind')) {
      context.handle(
        _itemKindMeta,
        itemKind.isAcceptableOrUnknown(data['item_kind']!, _itemKindMeta),
      );
    } else if (isInserting) {
      context.missing(_itemKindMeta);
    }
    if (data.containsKey('item_type')) {
      context.handle(
        _itemTypeMeta,
        itemType.isAcceptableOrUnknown(data['item_type']!, _itemTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_itemTypeMeta);
    }
    if (data.containsKey('is_correct')) {
      context.handle(
        _isCorrectMeta,
        isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta),
      );
    }
    if (data.containsKey('self_rating')) {
      context.handle(
        _selfRatingMeta,
        selfRating.isAcceptableOrUnknown(data['self_rating']!, _selfRatingMeta),
      );
    }
    if (data.containsKey('hints_used')) {
      context.handle(
        _hintsUsedMeta,
        hintsUsed.isAcceptableOrUnknown(data['hints_used']!, _hintsUsedMeta),
      );
    }
    if (data.containsKey('user_response')) {
      context.handle(
        _userResponseMeta,
        userResponse.isAcceptableOrUnknown(
          data['user_response']!,
          _userResponseMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttemptsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttemptsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      conceptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concept_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      itemKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_kind'],
      )!,
      itemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_type'],
      )!,
      isCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_correct'],
      ),
      selfRating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}self_rating'],
      ),
      hintsUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hints_used'],
      )!,
      userResponse: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_response'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AttemptsTableTable createAlias(String alias) {
    return $AttemptsTableTable(attachedDatabase, alias);
  }
}

class AttemptsTableData extends DataClass
    implements Insertable<AttemptsTableData> {
  final int id;
  final String conceptId;
  final String itemId;

  /// "exercise" or "assessment"
  final String itemKind;

  /// Matches ItemType: multipleChoice, shortAnswer, predictOutput,
  /// debugging, coding, explanation, scenario.
  final String itemType;

  /// Null when the item isn't auto-gradable and hasn't been self-rated yet.
  final bool? isCorrect;

  /// Self-rating on a 1-4 scale (Again/Hard/Good/Easy) for ungraded items.
  final int? selfRating;
  final int hintsUsed;
  final String? userResponse;
  final DateTime createdAt;
  const AttemptsTableData({
    required this.id,
    required this.conceptId,
    required this.itemId,
    required this.itemKind,
    required this.itemType,
    this.isCorrect,
    this.selfRating,
    required this.hintsUsed,
    this.userResponse,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['concept_id'] = Variable<String>(conceptId);
    map['item_id'] = Variable<String>(itemId);
    map['item_kind'] = Variable<String>(itemKind);
    map['item_type'] = Variable<String>(itemType);
    if (!nullToAbsent || isCorrect != null) {
      map['is_correct'] = Variable<bool>(isCorrect);
    }
    if (!nullToAbsent || selfRating != null) {
      map['self_rating'] = Variable<int>(selfRating);
    }
    map['hints_used'] = Variable<int>(hintsUsed);
    if (!nullToAbsent || userResponse != null) {
      map['user_response'] = Variable<String>(userResponse);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AttemptsTableCompanion toCompanion(bool nullToAbsent) {
    return AttemptsTableCompanion(
      id: Value(id),
      conceptId: Value(conceptId),
      itemId: Value(itemId),
      itemKind: Value(itemKind),
      itemType: Value(itemType),
      isCorrect: isCorrect == null && nullToAbsent
          ? const Value.absent()
          : Value(isCorrect),
      selfRating: selfRating == null && nullToAbsent
          ? const Value.absent()
          : Value(selfRating),
      hintsUsed: Value(hintsUsed),
      userResponse: userResponse == null && nullToAbsent
          ? const Value.absent()
          : Value(userResponse),
      createdAt: Value(createdAt),
    );
  }

  factory AttemptsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttemptsTableData(
      id: serializer.fromJson<int>(json['id']),
      conceptId: serializer.fromJson<String>(json['conceptId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      itemKind: serializer.fromJson<String>(json['itemKind']),
      itemType: serializer.fromJson<String>(json['itemType']),
      isCorrect: serializer.fromJson<bool?>(json['isCorrect']),
      selfRating: serializer.fromJson<int?>(json['selfRating']),
      hintsUsed: serializer.fromJson<int>(json['hintsUsed']),
      userResponse: serializer.fromJson<String?>(json['userResponse']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'conceptId': serializer.toJson<String>(conceptId),
      'itemId': serializer.toJson<String>(itemId),
      'itemKind': serializer.toJson<String>(itemKind),
      'itemType': serializer.toJson<String>(itemType),
      'isCorrect': serializer.toJson<bool?>(isCorrect),
      'selfRating': serializer.toJson<int?>(selfRating),
      'hintsUsed': serializer.toJson<int>(hintsUsed),
      'userResponse': serializer.toJson<String?>(userResponse),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AttemptsTableData copyWith({
    int? id,
    String? conceptId,
    String? itemId,
    String? itemKind,
    String? itemType,
    Value<bool?> isCorrect = const Value.absent(),
    Value<int?> selfRating = const Value.absent(),
    int? hintsUsed,
    Value<String?> userResponse = const Value.absent(),
    DateTime? createdAt,
  }) => AttemptsTableData(
    id: id ?? this.id,
    conceptId: conceptId ?? this.conceptId,
    itemId: itemId ?? this.itemId,
    itemKind: itemKind ?? this.itemKind,
    itemType: itemType ?? this.itemType,
    isCorrect: isCorrect.present ? isCorrect.value : this.isCorrect,
    selfRating: selfRating.present ? selfRating.value : this.selfRating,
    hintsUsed: hintsUsed ?? this.hintsUsed,
    userResponse: userResponse.present ? userResponse.value : this.userResponse,
    createdAt: createdAt ?? this.createdAt,
  );
  AttemptsTableData copyWithCompanion(AttemptsTableCompanion data) {
    return AttemptsTableData(
      id: data.id.present ? data.id.value : this.id,
      conceptId: data.conceptId.present ? data.conceptId.value : this.conceptId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      itemKind: data.itemKind.present ? data.itemKind.value : this.itemKind,
      itemType: data.itemType.present ? data.itemType.value : this.itemType,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
      selfRating: data.selfRating.present
          ? data.selfRating.value
          : this.selfRating,
      hintsUsed: data.hintsUsed.present ? data.hintsUsed.value : this.hintsUsed,
      userResponse: data.userResponse.present
          ? data.userResponse.value
          : this.userResponse,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttemptsTableData(')
          ..write('id: $id, ')
          ..write('conceptId: $conceptId, ')
          ..write('itemId: $itemId, ')
          ..write('itemKind: $itemKind, ')
          ..write('itemType: $itemType, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('selfRating: $selfRating, ')
          ..write('hintsUsed: $hintsUsed, ')
          ..write('userResponse: $userResponse, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    conceptId,
    itemId,
    itemKind,
    itemType,
    isCorrect,
    selfRating,
    hintsUsed,
    userResponse,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttemptsTableData &&
          other.id == this.id &&
          other.conceptId == this.conceptId &&
          other.itemId == this.itemId &&
          other.itemKind == this.itemKind &&
          other.itemType == this.itemType &&
          other.isCorrect == this.isCorrect &&
          other.selfRating == this.selfRating &&
          other.hintsUsed == this.hintsUsed &&
          other.userResponse == this.userResponse &&
          other.createdAt == this.createdAt);
}

class AttemptsTableCompanion extends UpdateCompanion<AttemptsTableData> {
  final Value<int> id;
  final Value<String> conceptId;
  final Value<String> itemId;
  final Value<String> itemKind;
  final Value<String> itemType;
  final Value<bool?> isCorrect;
  final Value<int?> selfRating;
  final Value<int> hintsUsed;
  final Value<String?> userResponse;
  final Value<DateTime> createdAt;
  const AttemptsTableCompanion({
    this.id = const Value.absent(),
    this.conceptId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.itemKind = const Value.absent(),
    this.itemType = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.selfRating = const Value.absent(),
    this.hintsUsed = const Value.absent(),
    this.userResponse = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AttemptsTableCompanion.insert({
    this.id = const Value.absent(),
    required String conceptId,
    required String itemId,
    required String itemKind,
    required String itemType,
    this.isCorrect = const Value.absent(),
    this.selfRating = const Value.absent(),
    this.hintsUsed = const Value.absent(),
    this.userResponse = const Value.absent(),
    required DateTime createdAt,
  }) : conceptId = Value(conceptId),
       itemId = Value(itemId),
       itemKind = Value(itemKind),
       itemType = Value(itemType),
       createdAt = Value(createdAt);
  static Insertable<AttemptsTableData> custom({
    Expression<int>? id,
    Expression<String>? conceptId,
    Expression<String>? itemId,
    Expression<String>? itemKind,
    Expression<String>? itemType,
    Expression<bool>? isCorrect,
    Expression<int>? selfRating,
    Expression<int>? hintsUsed,
    Expression<String>? userResponse,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conceptId != null) 'concept_id': conceptId,
      if (itemId != null) 'item_id': itemId,
      if (itemKind != null) 'item_kind': itemKind,
      if (itemType != null) 'item_type': itemType,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (selfRating != null) 'self_rating': selfRating,
      if (hintsUsed != null) 'hints_used': hintsUsed,
      if (userResponse != null) 'user_response': userResponse,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AttemptsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? conceptId,
    Value<String>? itemId,
    Value<String>? itemKind,
    Value<String>? itemType,
    Value<bool?>? isCorrect,
    Value<int?>? selfRating,
    Value<int>? hintsUsed,
    Value<String?>? userResponse,
    Value<DateTime>? createdAt,
  }) {
    return AttemptsTableCompanion(
      id: id ?? this.id,
      conceptId: conceptId ?? this.conceptId,
      itemId: itemId ?? this.itemId,
      itemKind: itemKind ?? this.itemKind,
      itemType: itemType ?? this.itemType,
      isCorrect: isCorrect ?? this.isCorrect,
      selfRating: selfRating ?? this.selfRating,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      userResponse: userResponse ?? this.userResponse,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (conceptId.present) {
      map['concept_id'] = Variable<String>(conceptId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (itemKind.present) {
      map['item_kind'] = Variable<String>(itemKind.value);
    }
    if (itemType.present) {
      map['item_type'] = Variable<String>(itemType.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<bool>(isCorrect.value);
    }
    if (selfRating.present) {
      map['self_rating'] = Variable<int>(selfRating.value);
    }
    if (hintsUsed.present) {
      map['hints_used'] = Variable<int>(hintsUsed.value);
    }
    if (userResponse.present) {
      map['user_response'] = Variable<String>(userResponse.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttemptsTableCompanion(')
          ..write('id: $id, ')
          ..write('conceptId: $conceptId, ')
          ..write('itemId: $itemId, ')
          ..write('itemKind: $itemKind, ')
          ..write('itemType: $itemType, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('selfRating: $selfRating, ')
          ..write('hintsUsed: $hintsUsed, ')
          ..write('userResponse: $userResponse, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MisconceptionsTableTable extends MisconceptionsTable
    with TableInfo<$MisconceptionsTableTable, MisconceptionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MisconceptionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _conceptIdMeta = const VerificationMeta(
    'conceptId',
  );
  @override
  late final GeneratedColumn<String> conceptId = GeneratedColumn<String>(
    'concept_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detectedAtMeta = const VerificationMeta(
    'detectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> detectedAt = GeneratedColumn<DateTime>(
    'detected_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    conceptId,
    description,
    detectedAt,
    confidence,
    resolvedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'misconceptions_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MisconceptionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('concept_id')) {
      context.handle(
        _conceptIdMeta,
        conceptId.isAcceptableOrUnknown(data['concept_id']!, _conceptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_conceptIdMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('detected_at')) {
      context.handle(
        _detectedAtMeta,
        detectedAt.isAcceptableOrUnknown(data['detected_at']!, _detectedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_detectedAtMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MisconceptionsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MisconceptionsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      conceptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concept_id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      detectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}detected_at'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
    );
  }

  @override
  $MisconceptionsTableTable createAlias(String alias) {
    return $MisconceptionsTableTable(attachedDatabase, alias);
  }
}

class MisconceptionsTableData extends DataClass
    implements Insertable<MisconceptionsTableData> {
  final int id;
  final String conceptId;
  final String description;
  final DateTime detectedAt;
  final double confidence;
  final DateTime? resolvedAt;
  const MisconceptionsTableData({
    required this.id,
    required this.conceptId,
    required this.description,
    required this.detectedAt,
    required this.confidence,
    this.resolvedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['concept_id'] = Variable<String>(conceptId);
    map['description'] = Variable<String>(description);
    map['detected_at'] = Variable<DateTime>(detectedAt);
    map['confidence'] = Variable<double>(confidence);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    return map;
  }

  MisconceptionsTableCompanion toCompanion(bool nullToAbsent) {
    return MisconceptionsTableCompanion(
      id: Value(id),
      conceptId: Value(conceptId),
      description: Value(description),
      detectedAt: Value(detectedAt),
      confidence: Value(confidence),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
    );
  }

  factory MisconceptionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MisconceptionsTableData(
      id: serializer.fromJson<int>(json['id']),
      conceptId: serializer.fromJson<String>(json['conceptId']),
      description: serializer.fromJson<String>(json['description']),
      detectedAt: serializer.fromJson<DateTime>(json['detectedAt']),
      confidence: serializer.fromJson<double>(json['confidence']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'conceptId': serializer.toJson<String>(conceptId),
      'description': serializer.toJson<String>(description),
      'detectedAt': serializer.toJson<DateTime>(detectedAt),
      'confidence': serializer.toJson<double>(confidence),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
    };
  }

  MisconceptionsTableData copyWith({
    int? id,
    String? conceptId,
    String? description,
    DateTime? detectedAt,
    double? confidence,
    Value<DateTime?> resolvedAt = const Value.absent(),
  }) => MisconceptionsTableData(
    id: id ?? this.id,
    conceptId: conceptId ?? this.conceptId,
    description: description ?? this.description,
    detectedAt: detectedAt ?? this.detectedAt,
    confidence: confidence ?? this.confidence,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
  );
  MisconceptionsTableData copyWithCompanion(MisconceptionsTableCompanion data) {
    return MisconceptionsTableData(
      id: data.id.present ? data.id.value : this.id,
      conceptId: data.conceptId.present ? data.conceptId.value : this.conceptId,
      description: data.description.present
          ? data.description.value
          : this.description,
      detectedAt: data.detectedAt.present
          ? data.detectedAt.value
          : this.detectedAt,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MisconceptionsTableData(')
          ..write('id: $id, ')
          ..write('conceptId: $conceptId, ')
          ..write('description: $description, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('confidence: $confidence, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    conceptId,
    description,
    detectedAt,
    confidence,
    resolvedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MisconceptionsTableData &&
          other.id == this.id &&
          other.conceptId == this.conceptId &&
          other.description == this.description &&
          other.detectedAt == this.detectedAt &&
          other.confidence == this.confidence &&
          other.resolvedAt == this.resolvedAt);
}

class MisconceptionsTableCompanion
    extends UpdateCompanion<MisconceptionsTableData> {
  final Value<int> id;
  final Value<String> conceptId;
  final Value<String> description;
  final Value<DateTime> detectedAt;
  final Value<double> confidence;
  final Value<DateTime?> resolvedAt;
  const MisconceptionsTableCompanion({
    this.id = const Value.absent(),
    this.conceptId = const Value.absent(),
    this.description = const Value.absent(),
    this.detectedAt = const Value.absent(),
    this.confidence = const Value.absent(),
    this.resolvedAt = const Value.absent(),
  });
  MisconceptionsTableCompanion.insert({
    this.id = const Value.absent(),
    required String conceptId,
    required String description,
    required DateTime detectedAt,
    this.confidence = const Value.absent(),
    this.resolvedAt = const Value.absent(),
  }) : conceptId = Value(conceptId),
       description = Value(description),
       detectedAt = Value(detectedAt);
  static Insertable<MisconceptionsTableData> custom({
    Expression<int>? id,
    Expression<String>? conceptId,
    Expression<String>? description,
    Expression<DateTime>? detectedAt,
    Expression<double>? confidence,
    Expression<DateTime>? resolvedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conceptId != null) 'concept_id': conceptId,
      if (description != null) 'description': description,
      if (detectedAt != null) 'detected_at': detectedAt,
      if (confidence != null) 'confidence': confidence,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
    });
  }

  MisconceptionsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? conceptId,
    Value<String>? description,
    Value<DateTime>? detectedAt,
    Value<double>? confidence,
    Value<DateTime?>? resolvedAt,
  }) {
    return MisconceptionsTableCompanion(
      id: id ?? this.id,
      conceptId: conceptId ?? this.conceptId,
      description: description ?? this.description,
      detectedAt: detectedAt ?? this.detectedAt,
      confidence: confidence ?? this.confidence,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (conceptId.present) {
      map['concept_id'] = Variable<String>(conceptId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (detectedAt.present) {
      map['detected_at'] = Variable<DateTime>(detectedAt.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MisconceptionsTableCompanion(')
          ..write('id: $id, ')
          ..write('conceptId: $conceptId, ')
          ..write('description: $description, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('confidence: $confidence, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }
}

class $ReviewScheduleTableTable extends ReviewScheduleTable
    with TableInfo<$ReviewScheduleTableTable, ReviewScheduleTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewScheduleTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _conceptIdMeta = const VerificationMeta(
    'conceptId',
  );
  @override
  late final GeneratedColumn<String> conceptId = GeneratedColumn<String>(
    'concept_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
    'interval_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _lastReviewedAtMeta = const VerificationMeta(
    'lastReviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReviewedAt =
      GeneratedColumn<DateTime>(
        'last_reviewed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _reviewCountMeta = const VerificationMeta(
    'reviewCount',
  );
  @override
  late final GeneratedColumn<int> reviewCount = GeneratedColumn<int>(
    'review_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    conceptId,
    dueAt,
    intervalDays,
    lastReviewedAt,
    reviewCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_schedule_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewScheduleTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('concept_id')) {
      context.handle(
        _conceptIdMeta,
        conceptId.isAcceptableOrUnknown(data['concept_id']!, _conceptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_conceptIdMeta);
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    } else if (isInserting) {
      context.missing(_dueAtMeta);
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('last_reviewed_at')) {
      context.handle(
        _lastReviewedAtMeta,
        lastReviewedAt.isAcceptableOrUnknown(
          data['last_reviewed_at']!,
          _lastReviewedAtMeta,
        ),
      );
    }
    if (data.containsKey('review_count')) {
      context.handle(
        _reviewCountMeta,
        reviewCount.isAcceptableOrUnknown(
          data['review_count']!,
          _reviewCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {conceptId};
  @override
  ReviewScheduleTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewScheduleTableData(
      conceptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concept_id'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      )!,
      intervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_days'],
      )!,
      lastReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reviewed_at'],
      ),
      reviewCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}review_count'],
      )!,
    );
  }

  @override
  $ReviewScheduleTableTable createAlias(String alias) {
    return $ReviewScheduleTableTable(attachedDatabase, alias);
  }
}

class ReviewScheduleTableData extends DataClass
    implements Insertable<ReviewScheduleTableData> {
  final String conceptId;
  final DateTime dueAt;
  final int intervalDays;
  final DateTime? lastReviewedAt;
  final int reviewCount;
  const ReviewScheduleTableData({
    required this.conceptId,
    required this.dueAt,
    required this.intervalDays,
    this.lastReviewedAt,
    required this.reviewCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['concept_id'] = Variable<String>(conceptId);
    map['due_at'] = Variable<DateTime>(dueAt);
    map['interval_days'] = Variable<int>(intervalDays);
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt);
    }
    map['review_count'] = Variable<int>(reviewCount);
    return map;
  }

  ReviewScheduleTableCompanion toCompanion(bool nullToAbsent) {
    return ReviewScheduleTableCompanion(
      conceptId: Value(conceptId),
      dueAt: Value(dueAt),
      intervalDays: Value(intervalDays),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
      reviewCount: Value(reviewCount),
    );
  }

  factory ReviewScheduleTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewScheduleTableData(
      conceptId: serializer.fromJson<String>(json['conceptId']),
      dueAt: serializer.fromJson<DateTime>(json['dueAt']),
      intervalDays: serializer.fromJson<int>(json['intervalDays']),
      lastReviewedAt: serializer.fromJson<DateTime?>(json['lastReviewedAt']),
      reviewCount: serializer.fromJson<int>(json['reviewCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'conceptId': serializer.toJson<String>(conceptId),
      'dueAt': serializer.toJson<DateTime>(dueAt),
      'intervalDays': serializer.toJson<int>(intervalDays),
      'lastReviewedAt': serializer.toJson<DateTime?>(lastReviewedAt),
      'reviewCount': serializer.toJson<int>(reviewCount),
    };
  }

  ReviewScheduleTableData copyWith({
    String? conceptId,
    DateTime? dueAt,
    int? intervalDays,
    Value<DateTime?> lastReviewedAt = const Value.absent(),
    int? reviewCount,
  }) => ReviewScheduleTableData(
    conceptId: conceptId ?? this.conceptId,
    dueAt: dueAt ?? this.dueAt,
    intervalDays: intervalDays ?? this.intervalDays,
    lastReviewedAt: lastReviewedAt.present
        ? lastReviewedAt.value
        : this.lastReviewedAt,
    reviewCount: reviewCount ?? this.reviewCount,
  );
  ReviewScheduleTableData copyWithCompanion(ReviewScheduleTableCompanion data) {
    return ReviewScheduleTableData(
      conceptId: data.conceptId.present ? data.conceptId.value : this.conceptId,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
      reviewCount: data.reviewCount.present
          ? data.reviewCount.value
          : this.reviewCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewScheduleTableData(')
          ..write('conceptId: $conceptId, ')
          ..write('dueAt: $dueAt, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('reviewCount: $reviewCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(conceptId, dueAt, intervalDays, lastReviewedAt, reviewCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewScheduleTableData &&
          other.conceptId == this.conceptId &&
          other.dueAt == this.dueAt &&
          other.intervalDays == this.intervalDays &&
          other.lastReviewedAt == this.lastReviewedAt &&
          other.reviewCount == this.reviewCount);
}

class ReviewScheduleTableCompanion
    extends UpdateCompanion<ReviewScheduleTableData> {
  final Value<String> conceptId;
  final Value<DateTime> dueAt;
  final Value<int> intervalDays;
  final Value<DateTime?> lastReviewedAt;
  final Value<int> reviewCount;
  final Value<int> rowid;
  const ReviewScheduleTableCompanion({
    this.conceptId = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.reviewCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewScheduleTableCompanion.insert({
    required String conceptId,
    required DateTime dueAt,
    this.intervalDays = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.reviewCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : conceptId = Value(conceptId),
       dueAt = Value(dueAt);
  static Insertable<ReviewScheduleTableData> custom({
    Expression<String>? conceptId,
    Expression<DateTime>? dueAt,
    Expression<int>? intervalDays,
    Expression<DateTime>? lastReviewedAt,
    Expression<int>? reviewCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (conceptId != null) 'concept_id': conceptId,
      if (dueAt != null) 'due_at': dueAt,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (reviewCount != null) 'review_count': reviewCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReviewScheduleTableCompanion copyWith({
    Value<String>? conceptId,
    Value<DateTime>? dueAt,
    Value<int>? intervalDays,
    Value<DateTime?>? lastReviewedAt,
    Value<int>? reviewCount,
    Value<int>? rowid,
  }) {
    return ReviewScheduleTableCompanion(
      conceptId: conceptId ?? this.conceptId,
      dueAt: dueAt ?? this.dueAt,
      intervalDays: intervalDays ?? this.intervalDays,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      reviewCount: reviewCount ?? this.reviewCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (conceptId.present) {
      map['concept_id'] = Variable<String>(conceptId.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt.value);
    }
    if (reviewCount.present) {
      map['review_count'] = Variable<int>(reviewCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewScheduleTableCompanion(')
          ..write('conceptId: $conceptId, ')
          ..write('dueAt: $dueAt, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('reviewCount: $reviewCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTableTable extends SettingsTable
    with TableInfo<$SettingsTableTable, SettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsTableData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTableTable createAlias(String alias) {
    return $SettingsTableTable(attachedDatabase, alias);
  }
}

class SettingsTableData extends DataClass
    implements Insertable<SettingsTableData> {
  final String key;
  final String value;
  const SettingsTableData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsTableCompanion toCompanion(bool nullToAbsent) {
    return SettingsTableCompanion(key: Value(key), value: Value(value));
  }

  factory SettingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsTableData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingsTableData copyWith({String? key, String? value}) =>
      SettingsTableData(key: key ?? this.key, value: value ?? this.value);
  SettingsTableData copyWithCompanion(SettingsTableCompanion data) {
    return SettingsTableData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsTableData &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsTableCompanion extends UpdateCompanion<SettingsTableData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsTableCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingsTableData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsTableCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsTableCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LearningPathProgressTableTable extends LearningPathProgressTable
    with
        TableInfo<
          $LearningPathProgressTableTable,
          LearningPathProgressTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LearningPathProgressTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _learningPathIdMeta = const VerificationMeta(
    'learningPathId',
  );
  @override
  late final GeneratedColumn<String> learningPathId = GeneratedColumn<String>(
    'learning_path_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [learningPathId, startedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'learning_path_progress_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<LearningPathProgressTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('learning_path_id')) {
      context.handle(
        _learningPathIdMeta,
        learningPathId.isAcceptableOrUnknown(
          data['learning_path_id']!,
          _learningPathIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_learningPathIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {learningPathId};
  @override
  LearningPathProgressTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LearningPathProgressTableData(
      learningPathId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}learning_path_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
    );
  }

  @override
  $LearningPathProgressTableTable createAlias(String alias) {
    return $LearningPathProgressTableTable(attachedDatabase, alias);
  }
}

class LearningPathProgressTableData extends DataClass
    implements Insertable<LearningPathProgressTableData> {
  final String learningPathId;
  final DateTime startedAt;
  const LearningPathProgressTableData({
    required this.learningPathId,
    required this.startedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['learning_path_id'] = Variable<String>(learningPathId);
    map['started_at'] = Variable<DateTime>(startedAt);
    return map;
  }

  LearningPathProgressTableCompanion toCompanion(bool nullToAbsent) {
    return LearningPathProgressTableCompanion(
      learningPathId: Value(learningPathId),
      startedAt: Value(startedAt),
    );
  }

  factory LearningPathProgressTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LearningPathProgressTableData(
      learningPathId: serializer.fromJson<String>(json['learningPathId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'learningPathId': serializer.toJson<String>(learningPathId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
    };
  }

  LearningPathProgressTableData copyWith({
    String? learningPathId,
    DateTime? startedAt,
  }) => LearningPathProgressTableData(
    learningPathId: learningPathId ?? this.learningPathId,
    startedAt: startedAt ?? this.startedAt,
  );
  LearningPathProgressTableData copyWithCompanion(
    LearningPathProgressTableCompanion data,
  ) {
    return LearningPathProgressTableData(
      learningPathId: data.learningPathId.present
          ? data.learningPathId.value
          : this.learningPathId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LearningPathProgressTableData(')
          ..write('learningPathId: $learningPathId, ')
          ..write('startedAt: $startedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(learningPathId, startedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LearningPathProgressTableData &&
          other.learningPathId == this.learningPathId &&
          other.startedAt == this.startedAt);
}

class LearningPathProgressTableCompanion
    extends UpdateCompanion<LearningPathProgressTableData> {
  final Value<String> learningPathId;
  final Value<DateTime> startedAt;
  final Value<int> rowid;
  const LearningPathProgressTableCompanion({
    this.learningPathId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LearningPathProgressTableCompanion.insert({
    required String learningPathId,
    required DateTime startedAt,
    this.rowid = const Value.absent(),
  }) : learningPathId = Value(learningPathId),
       startedAt = Value(startedAt);
  static Insertable<LearningPathProgressTableData> custom({
    Expression<String>? learningPathId,
    Expression<DateTime>? startedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (learningPathId != null) 'learning_path_id': learningPathId,
      if (startedAt != null) 'started_at': startedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LearningPathProgressTableCompanion copyWith({
    Value<String>? learningPathId,
    Value<DateTime>? startedAt,
    Value<int>? rowid,
  }) {
    return LearningPathProgressTableCompanion(
      learningPathId: learningPathId ?? this.learningPathId,
      startedAt: startedAt ?? this.startedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (learningPathId.present) {
      map['learning_path_id'] = Variable<String>(learningPathId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LearningPathProgressTableCompanion(')
          ..write('learningPathId: $learningPathId, ')
          ..write('startedAt: $startedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ModuleTestProgressTableTable extends ModuleTestProgressTable
    with TableInfo<$ModuleTestProgressTableTable, ModuleTestProgressTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModuleTestProgressTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _learningPathIdMeta = const VerificationMeta(
    'learningPathId',
  );
  @override
  late final GeneratedColumn<String> learningPathId = GeneratedColumn<String>(
    'learning_path_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moduleIdMeta = const VerificationMeta(
    'moduleId',
  );
  @override
  late final GeneratedColumn<String> moduleId = GeneratedColumn<String>(
    'module_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passedAtMeta = const VerificationMeta(
    'passedAt',
  );
  @override
  late final GeneratedColumn<DateTime> passedAt = GeneratedColumn<DateTime>(
    'passed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scorePercentMeta = const VerificationMeta(
    'scorePercent',
  );
  @override
  late final GeneratedColumn<int> scorePercent = GeneratedColumn<int>(
    'score_percent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionCountMeta = const VerificationMeta(
    'questionCount',
  );
  @override
  late final GeneratedColumn<int> questionCount = GeneratedColumn<int>(
    'question_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isGrandfatheredMeta = const VerificationMeta(
    'isGrandfathered',
  );
  @override
  late final GeneratedColumn<bool> isGrandfathered = GeneratedColumn<bool>(
    'is_grandfathered',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_grandfathered" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    learningPathId,
    moduleId,
    passedAt,
    scorePercent,
    questionCount,
    isGrandfathered,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'module_test_progress_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ModuleTestProgressTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('learning_path_id')) {
      context.handle(
        _learningPathIdMeta,
        learningPathId.isAcceptableOrUnknown(
          data['learning_path_id']!,
          _learningPathIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_learningPathIdMeta);
    }
    if (data.containsKey('module_id')) {
      context.handle(
        _moduleIdMeta,
        moduleId.isAcceptableOrUnknown(data['module_id']!, _moduleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_moduleIdMeta);
    }
    if (data.containsKey('passed_at')) {
      context.handle(
        _passedAtMeta,
        passedAt.isAcceptableOrUnknown(data['passed_at']!, _passedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_passedAtMeta);
    }
    if (data.containsKey('score_percent')) {
      context.handle(
        _scorePercentMeta,
        scorePercent.isAcceptableOrUnknown(
          data['score_percent']!,
          _scorePercentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scorePercentMeta);
    }
    if (data.containsKey('question_count')) {
      context.handle(
        _questionCountMeta,
        questionCount.isAcceptableOrUnknown(
          data['question_count']!,
          _questionCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionCountMeta);
    }
    if (data.containsKey('is_grandfathered')) {
      context.handle(
        _isGrandfatheredMeta,
        isGrandfathered.isAcceptableOrUnknown(
          data['is_grandfathered']!,
          _isGrandfatheredMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {learningPathId, moduleId};
  @override
  ModuleTestProgressTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ModuleTestProgressTableData(
      learningPathId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}learning_path_id'],
      )!,
      moduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}module_id'],
      )!,
      passedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}passed_at'],
      )!,
      scorePercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score_percent'],
      )!,
      questionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_count'],
      )!,
      isGrandfathered: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_grandfathered'],
      )!,
    );
  }

  @override
  $ModuleTestProgressTableTable createAlias(String alias) {
    return $ModuleTestProgressTableTable(attachedDatabase, alias);
  }
}

class ModuleTestProgressTableData extends DataClass
    implements Insertable<ModuleTestProgressTableData> {
  final String learningPathId;
  final String moduleId;
  final DateTime passedAt;
  final int scorePercent;
  final int questionCount;

  /// True for rows backfilled during the v2->v3 migration for learners
  /// who had already started a module under the old, gate-free rules —
  /// never a real test attempt. Kept as a real column (not inferred)
  /// so this decision stays introspectable/reversible later.
  final bool isGrandfathered;
  const ModuleTestProgressTableData({
    required this.learningPathId,
    required this.moduleId,
    required this.passedAt,
    required this.scorePercent,
    required this.questionCount,
    required this.isGrandfathered,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['learning_path_id'] = Variable<String>(learningPathId);
    map['module_id'] = Variable<String>(moduleId);
    map['passed_at'] = Variable<DateTime>(passedAt);
    map['score_percent'] = Variable<int>(scorePercent);
    map['question_count'] = Variable<int>(questionCount);
    map['is_grandfathered'] = Variable<bool>(isGrandfathered);
    return map;
  }

  ModuleTestProgressTableCompanion toCompanion(bool nullToAbsent) {
    return ModuleTestProgressTableCompanion(
      learningPathId: Value(learningPathId),
      moduleId: Value(moduleId),
      passedAt: Value(passedAt),
      scorePercent: Value(scorePercent),
      questionCount: Value(questionCount),
      isGrandfathered: Value(isGrandfathered),
    );
  }

  factory ModuleTestProgressTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ModuleTestProgressTableData(
      learningPathId: serializer.fromJson<String>(json['learningPathId']),
      moduleId: serializer.fromJson<String>(json['moduleId']),
      passedAt: serializer.fromJson<DateTime>(json['passedAt']),
      scorePercent: serializer.fromJson<int>(json['scorePercent']),
      questionCount: serializer.fromJson<int>(json['questionCount']),
      isGrandfathered: serializer.fromJson<bool>(json['isGrandfathered']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'learningPathId': serializer.toJson<String>(learningPathId),
      'moduleId': serializer.toJson<String>(moduleId),
      'passedAt': serializer.toJson<DateTime>(passedAt),
      'scorePercent': serializer.toJson<int>(scorePercent),
      'questionCount': serializer.toJson<int>(questionCount),
      'isGrandfathered': serializer.toJson<bool>(isGrandfathered),
    };
  }

  ModuleTestProgressTableData copyWith({
    String? learningPathId,
    String? moduleId,
    DateTime? passedAt,
    int? scorePercent,
    int? questionCount,
    bool? isGrandfathered,
  }) => ModuleTestProgressTableData(
    learningPathId: learningPathId ?? this.learningPathId,
    moduleId: moduleId ?? this.moduleId,
    passedAt: passedAt ?? this.passedAt,
    scorePercent: scorePercent ?? this.scorePercent,
    questionCount: questionCount ?? this.questionCount,
    isGrandfathered: isGrandfathered ?? this.isGrandfathered,
  );
  ModuleTestProgressTableData copyWithCompanion(
    ModuleTestProgressTableCompanion data,
  ) {
    return ModuleTestProgressTableData(
      learningPathId: data.learningPathId.present
          ? data.learningPathId.value
          : this.learningPathId,
      moduleId: data.moduleId.present ? data.moduleId.value : this.moduleId,
      passedAt: data.passedAt.present ? data.passedAt.value : this.passedAt,
      scorePercent: data.scorePercent.present
          ? data.scorePercent.value
          : this.scorePercent,
      questionCount: data.questionCount.present
          ? data.questionCount.value
          : this.questionCount,
      isGrandfathered: data.isGrandfathered.present
          ? data.isGrandfathered.value
          : this.isGrandfathered,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ModuleTestProgressTableData(')
          ..write('learningPathId: $learningPathId, ')
          ..write('moduleId: $moduleId, ')
          ..write('passedAt: $passedAt, ')
          ..write('scorePercent: $scorePercent, ')
          ..write('questionCount: $questionCount, ')
          ..write('isGrandfathered: $isGrandfathered')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    learningPathId,
    moduleId,
    passedAt,
    scorePercent,
    questionCount,
    isGrandfathered,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModuleTestProgressTableData &&
          other.learningPathId == this.learningPathId &&
          other.moduleId == this.moduleId &&
          other.passedAt == this.passedAt &&
          other.scorePercent == this.scorePercent &&
          other.questionCount == this.questionCount &&
          other.isGrandfathered == this.isGrandfathered);
}

class ModuleTestProgressTableCompanion
    extends UpdateCompanion<ModuleTestProgressTableData> {
  final Value<String> learningPathId;
  final Value<String> moduleId;
  final Value<DateTime> passedAt;
  final Value<int> scorePercent;
  final Value<int> questionCount;
  final Value<bool> isGrandfathered;
  final Value<int> rowid;
  const ModuleTestProgressTableCompanion({
    this.learningPathId = const Value.absent(),
    this.moduleId = const Value.absent(),
    this.passedAt = const Value.absent(),
    this.scorePercent = const Value.absent(),
    this.questionCount = const Value.absent(),
    this.isGrandfathered = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ModuleTestProgressTableCompanion.insert({
    required String learningPathId,
    required String moduleId,
    required DateTime passedAt,
    required int scorePercent,
    required int questionCount,
    this.isGrandfathered = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : learningPathId = Value(learningPathId),
       moduleId = Value(moduleId),
       passedAt = Value(passedAt),
       scorePercent = Value(scorePercent),
       questionCount = Value(questionCount);
  static Insertable<ModuleTestProgressTableData> custom({
    Expression<String>? learningPathId,
    Expression<String>? moduleId,
    Expression<DateTime>? passedAt,
    Expression<int>? scorePercent,
    Expression<int>? questionCount,
    Expression<bool>? isGrandfathered,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (learningPathId != null) 'learning_path_id': learningPathId,
      if (moduleId != null) 'module_id': moduleId,
      if (passedAt != null) 'passed_at': passedAt,
      if (scorePercent != null) 'score_percent': scorePercent,
      if (questionCount != null) 'question_count': questionCount,
      if (isGrandfathered != null) 'is_grandfathered': isGrandfathered,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ModuleTestProgressTableCompanion copyWith({
    Value<String>? learningPathId,
    Value<String>? moduleId,
    Value<DateTime>? passedAt,
    Value<int>? scorePercent,
    Value<int>? questionCount,
    Value<bool>? isGrandfathered,
    Value<int>? rowid,
  }) {
    return ModuleTestProgressTableCompanion(
      learningPathId: learningPathId ?? this.learningPathId,
      moduleId: moduleId ?? this.moduleId,
      passedAt: passedAt ?? this.passedAt,
      scorePercent: scorePercent ?? this.scorePercent,
      questionCount: questionCount ?? this.questionCount,
      isGrandfathered: isGrandfathered ?? this.isGrandfathered,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (learningPathId.present) {
      map['learning_path_id'] = Variable<String>(learningPathId.value);
    }
    if (moduleId.present) {
      map['module_id'] = Variable<String>(moduleId.value);
    }
    if (passedAt.present) {
      map['passed_at'] = Variable<DateTime>(passedAt.value);
    }
    if (scorePercent.present) {
      map['score_percent'] = Variable<int>(scorePercent.value);
    }
    if (questionCount.present) {
      map['question_count'] = Variable<int>(questionCount.value);
    }
    if (isGrandfathered.present) {
      map['is_grandfathered'] = Variable<bool>(isGrandfathered.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModuleTestProgressTableCompanion(')
          ..write('learningPathId: $learningPathId, ')
          ..write('moduleId: $moduleId, ')
          ..write('passedAt: $passedAt, ')
          ..write('scorePercent: $scorePercent, ')
          ..write('questionCount: $questionCount, ')
          ..write('isGrandfathered: $isGrandfathered, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $StudentProgressTableTable studentProgressTable =
      $StudentProgressTableTable(this);
  late final $ConceptMasteryTableTable conceptMasteryTable =
      $ConceptMasteryTableTable(this);
  late final $AttemptsTableTable attemptsTable = $AttemptsTableTable(this);
  late final $MisconceptionsTableTable misconceptionsTable =
      $MisconceptionsTableTable(this);
  late final $ReviewScheduleTableTable reviewScheduleTable =
      $ReviewScheduleTableTable(this);
  late final $SettingsTableTable settingsTable = $SettingsTableTable(this);
  late final $LearningPathProgressTableTable learningPathProgressTable =
      $LearningPathProgressTableTable(this);
  late final $ModuleTestProgressTableTable moduleTestProgressTable =
      $ModuleTestProgressTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    studentProgressTable,
    conceptMasteryTable,
    attemptsTable,
    misconceptionsTable,
    reviewScheduleTable,
    settingsTable,
    learningPathProgressTable,
    moduleTestProgressTable,
  ];
}

typedef $$StudentProgressTableTableCreateCompanionBuilder =
    StudentProgressTableCompanion Function({
      required String conceptId,
      required String learningPathId,
      required String moduleId,
      Value<DateTime?> startedAt,
      Value<DateTime?> completedAt,
      Value<DateTime?> lastAccessedAt,
      Value<int> rowid,
    });
typedef $$StudentProgressTableTableUpdateCompanionBuilder =
    StudentProgressTableCompanion Function({
      Value<String> conceptId,
      Value<String> learningPathId,
      Value<String> moduleId,
      Value<DateTime?> startedAt,
      Value<DateTime?> completedAt,
      Value<DateTime?> lastAccessedAt,
      Value<int> rowid,
    });

class $$StudentProgressTableTableFilterComposer
    extends Composer<_$AppDatabase, $StudentProgressTableTable> {
  $$StudentProgressTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get conceptId => $composableBuilder(
    column: $table.conceptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get learningPathId => $composableBuilder(
    column: $table.learningPathId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moduleId => $composableBuilder(
    column: $table.moduleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StudentProgressTableTableOrderingComposer
    extends Composer<_$AppDatabase, $StudentProgressTableTable> {
  $$StudentProgressTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get conceptId => $composableBuilder(
    column: $table.conceptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get learningPathId => $composableBuilder(
    column: $table.learningPathId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moduleId => $composableBuilder(
    column: $table.moduleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudentProgressTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudentProgressTableTable> {
  $$StudentProgressTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get conceptId =>
      $composableBuilder(column: $table.conceptId, builder: (column) => column);

  GeneratedColumn<String> get learningPathId => $composableBuilder(
    column: $table.learningPathId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get moduleId =>
      $composableBuilder(column: $table.moduleId, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => column,
  );
}

class $$StudentProgressTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudentProgressTableTable,
          StudentProgressTableData,
          $$StudentProgressTableTableFilterComposer,
          $$StudentProgressTableTableOrderingComposer,
          $$StudentProgressTableTableAnnotationComposer,
          $$StudentProgressTableTableCreateCompanionBuilder,
          $$StudentProgressTableTableUpdateCompanionBuilder,
          (
            StudentProgressTableData,
            BaseReferences<
              _$AppDatabase,
              $StudentProgressTableTable,
              StudentProgressTableData
            >,
          ),
          StudentProgressTableData,
          PrefetchHooks Function()
        > {
  $$StudentProgressTableTableTableManager(
    _$AppDatabase db,
    $StudentProgressTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentProgressTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudentProgressTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StudentProgressTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> conceptId = const Value.absent(),
                Value<String> learningPathId = const Value.absent(),
                Value<String> moduleId = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> lastAccessedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudentProgressTableCompanion(
                conceptId: conceptId,
                learningPathId: learningPathId,
                moduleId: moduleId,
                startedAt: startedAt,
                completedAt: completedAt,
                lastAccessedAt: lastAccessedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String conceptId,
                required String learningPathId,
                required String moduleId,
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> lastAccessedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudentProgressTableCompanion.insert(
                conceptId: conceptId,
                learningPathId: learningPathId,
                moduleId: moduleId,
                startedAt: startedAt,
                completedAt: completedAt,
                lastAccessedAt: lastAccessedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StudentProgressTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudentProgressTableTable,
      StudentProgressTableData,
      $$StudentProgressTableTableFilterComposer,
      $$StudentProgressTableTableOrderingComposer,
      $$StudentProgressTableTableAnnotationComposer,
      $$StudentProgressTableTableCreateCompanionBuilder,
      $$StudentProgressTableTableUpdateCompanionBuilder,
      (
        StudentProgressTableData,
        BaseReferences<
          _$AppDatabase,
          $StudentProgressTableTable,
          StudentProgressTableData
        >,
      ),
      StudentProgressTableData,
      PrefetchHooks Function()
    >;
typedef $$ConceptMasteryTableTableCreateCompanionBuilder =
    ConceptMasteryTableCompanion Function({
      required String conceptId,
      Value<double> recallScore,
      Value<double> understandingScore,
      Value<double> applicationScore,
      Value<double> explanationScore,
      Value<double> codingScore,
      Value<double> debuggingScore,
      Value<double> overallMastery,
      Value<int> attemptCount,
      Value<int> successCount,
      Value<int> failureCount,
      Value<double> confidence,
      Value<DateTime?> lastReviewedAt,
      Value<DateTime?> nextReviewAt,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$ConceptMasteryTableTableUpdateCompanionBuilder =
    ConceptMasteryTableCompanion Function({
      Value<String> conceptId,
      Value<double> recallScore,
      Value<double> understandingScore,
      Value<double> applicationScore,
      Value<double> explanationScore,
      Value<double> codingScore,
      Value<double> debuggingScore,
      Value<double> overallMastery,
      Value<int> attemptCount,
      Value<int> successCount,
      Value<int> failureCount,
      Value<double> confidence,
      Value<DateTime?> lastReviewedAt,
      Value<DateTime?> nextReviewAt,
      Value<String> status,
      Value<int> rowid,
    });

class $$ConceptMasteryTableTableFilterComposer
    extends Composer<_$AppDatabase, $ConceptMasteryTableTable> {
  $$ConceptMasteryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get conceptId => $composableBuilder(
    column: $table.conceptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get recallScore => $composableBuilder(
    column: $table.recallScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get understandingScore => $composableBuilder(
    column: $table.understandingScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get applicationScore => $composableBuilder(
    column: $table.applicationScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get explanationScore => $composableBuilder(
    column: $table.explanationScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get codingScore => $composableBuilder(
    column: $table.codingScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get debuggingScore => $composableBuilder(
    column: $table.debuggingScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get overallMastery => $composableBuilder(
    column: $table.overallMastery,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get successCount => $composableBuilder(
    column: $table.successCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get failureCount => $composableBuilder(
    column: $table.failureCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConceptMasteryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ConceptMasteryTableTable> {
  $$ConceptMasteryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get conceptId => $composableBuilder(
    column: $table.conceptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get recallScore => $composableBuilder(
    column: $table.recallScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get understandingScore => $composableBuilder(
    column: $table.understandingScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get applicationScore => $composableBuilder(
    column: $table.applicationScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get explanationScore => $composableBuilder(
    column: $table.explanationScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get codingScore => $composableBuilder(
    column: $table.codingScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get debuggingScore => $composableBuilder(
    column: $table.debuggingScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get overallMastery => $composableBuilder(
    column: $table.overallMastery,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get successCount => $composableBuilder(
    column: $table.successCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get failureCount => $composableBuilder(
    column: $table.failureCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConceptMasteryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConceptMasteryTableTable> {
  $$ConceptMasteryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get conceptId =>
      $composableBuilder(column: $table.conceptId, builder: (column) => column);

  GeneratedColumn<double> get recallScore => $composableBuilder(
    column: $table.recallScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get understandingScore => $composableBuilder(
    column: $table.understandingScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get applicationScore => $composableBuilder(
    column: $table.applicationScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get explanationScore => $composableBuilder(
    column: $table.explanationScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get codingScore => $composableBuilder(
    column: $table.codingScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get debuggingScore => $composableBuilder(
    column: $table.debuggingScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get overallMastery => $composableBuilder(
    column: $table.overallMastery,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get successCount => $composableBuilder(
    column: $table.successCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get failureCount => $composableBuilder(
    column: $table.failureCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$ConceptMasteryTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConceptMasteryTableTable,
          ConceptMasteryTableData,
          $$ConceptMasteryTableTableFilterComposer,
          $$ConceptMasteryTableTableOrderingComposer,
          $$ConceptMasteryTableTableAnnotationComposer,
          $$ConceptMasteryTableTableCreateCompanionBuilder,
          $$ConceptMasteryTableTableUpdateCompanionBuilder,
          (
            ConceptMasteryTableData,
            BaseReferences<
              _$AppDatabase,
              $ConceptMasteryTableTable,
              ConceptMasteryTableData
            >,
          ),
          ConceptMasteryTableData,
          PrefetchHooks Function()
        > {
  $$ConceptMasteryTableTableTableManager(
    _$AppDatabase db,
    $ConceptMasteryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConceptMasteryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConceptMasteryTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ConceptMasteryTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> conceptId = const Value.absent(),
                Value<double> recallScore = const Value.absent(),
                Value<double> understandingScore = const Value.absent(),
                Value<double> applicationScore = const Value.absent(),
                Value<double> explanationScore = const Value.absent(),
                Value<double> codingScore = const Value.absent(),
                Value<double> debuggingScore = const Value.absent(),
                Value<double> overallMastery = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<int> successCount = const Value.absent(),
                Value<int> failureCount = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<DateTime?> nextReviewAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConceptMasteryTableCompanion(
                conceptId: conceptId,
                recallScore: recallScore,
                understandingScore: understandingScore,
                applicationScore: applicationScore,
                explanationScore: explanationScore,
                codingScore: codingScore,
                debuggingScore: debuggingScore,
                overallMastery: overallMastery,
                attemptCount: attemptCount,
                successCount: successCount,
                failureCount: failureCount,
                confidence: confidence,
                lastReviewedAt: lastReviewedAt,
                nextReviewAt: nextReviewAt,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String conceptId,
                Value<double> recallScore = const Value.absent(),
                Value<double> understandingScore = const Value.absent(),
                Value<double> applicationScore = const Value.absent(),
                Value<double> explanationScore = const Value.absent(),
                Value<double> codingScore = const Value.absent(),
                Value<double> debuggingScore = const Value.absent(),
                Value<double> overallMastery = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<int> successCount = const Value.absent(),
                Value<int> failureCount = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<DateTime?> nextReviewAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConceptMasteryTableCompanion.insert(
                conceptId: conceptId,
                recallScore: recallScore,
                understandingScore: understandingScore,
                applicationScore: applicationScore,
                explanationScore: explanationScore,
                codingScore: codingScore,
                debuggingScore: debuggingScore,
                overallMastery: overallMastery,
                attemptCount: attemptCount,
                successCount: successCount,
                failureCount: failureCount,
                confidence: confidence,
                lastReviewedAt: lastReviewedAt,
                nextReviewAt: nextReviewAt,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConceptMasteryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConceptMasteryTableTable,
      ConceptMasteryTableData,
      $$ConceptMasteryTableTableFilterComposer,
      $$ConceptMasteryTableTableOrderingComposer,
      $$ConceptMasteryTableTableAnnotationComposer,
      $$ConceptMasteryTableTableCreateCompanionBuilder,
      $$ConceptMasteryTableTableUpdateCompanionBuilder,
      (
        ConceptMasteryTableData,
        BaseReferences<
          _$AppDatabase,
          $ConceptMasteryTableTable,
          ConceptMasteryTableData
        >,
      ),
      ConceptMasteryTableData,
      PrefetchHooks Function()
    >;
typedef $$AttemptsTableTableCreateCompanionBuilder =
    AttemptsTableCompanion Function({
      Value<int> id,
      required String conceptId,
      required String itemId,
      required String itemKind,
      required String itemType,
      Value<bool?> isCorrect,
      Value<int?> selfRating,
      Value<int> hintsUsed,
      Value<String?> userResponse,
      required DateTime createdAt,
    });
typedef $$AttemptsTableTableUpdateCompanionBuilder =
    AttemptsTableCompanion Function({
      Value<int> id,
      Value<String> conceptId,
      Value<String> itemId,
      Value<String> itemKind,
      Value<String> itemType,
      Value<bool?> isCorrect,
      Value<int?> selfRating,
      Value<int> hintsUsed,
      Value<String?> userResponse,
      Value<DateTime> createdAt,
    });

class $$AttemptsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AttemptsTableTable> {
  $$AttemptsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conceptId => $composableBuilder(
    column: $table.conceptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemKind => $composableBuilder(
    column: $table.itemKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get selfRating => $composableBuilder(
    column: $table.selfRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hintsUsed => $composableBuilder(
    column: $table.hintsUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userResponse => $composableBuilder(
    column: $table.userResponse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttemptsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AttemptsTableTable> {
  $$AttemptsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conceptId => $composableBuilder(
    column: $table.conceptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemKind => $composableBuilder(
    column: $table.itemKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get selfRating => $composableBuilder(
    column: $table.selfRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hintsUsed => $composableBuilder(
    column: $table.hintsUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userResponse => $composableBuilder(
    column: $table.userResponse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttemptsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttemptsTableTable> {
  $$AttemptsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get conceptId =>
      $composableBuilder(column: $table.conceptId, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get itemKind =>
      $composableBuilder(column: $table.itemKind, builder: (column) => column);

  GeneratedColumn<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);

  GeneratedColumn<bool> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  GeneratedColumn<int> get selfRating => $composableBuilder(
    column: $table.selfRating,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hintsUsed =>
      $composableBuilder(column: $table.hintsUsed, builder: (column) => column);

  GeneratedColumn<String> get userResponse => $composableBuilder(
    column: $table.userResponse,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AttemptsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttemptsTableTable,
          AttemptsTableData,
          $$AttemptsTableTableFilterComposer,
          $$AttemptsTableTableOrderingComposer,
          $$AttemptsTableTableAnnotationComposer,
          $$AttemptsTableTableCreateCompanionBuilder,
          $$AttemptsTableTableUpdateCompanionBuilder,
          (
            AttemptsTableData,
            BaseReferences<
              _$AppDatabase,
              $AttemptsTableTable,
              AttemptsTableData
            >,
          ),
          AttemptsTableData,
          PrefetchHooks Function()
        > {
  $$AttemptsTableTableTableManager(_$AppDatabase db, $AttemptsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttemptsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttemptsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttemptsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> conceptId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> itemKind = const Value.absent(),
                Value<String> itemType = const Value.absent(),
                Value<bool?> isCorrect = const Value.absent(),
                Value<int?> selfRating = const Value.absent(),
                Value<int> hintsUsed = const Value.absent(),
                Value<String?> userResponse = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AttemptsTableCompanion(
                id: id,
                conceptId: conceptId,
                itemId: itemId,
                itemKind: itemKind,
                itemType: itemType,
                isCorrect: isCorrect,
                selfRating: selfRating,
                hintsUsed: hintsUsed,
                userResponse: userResponse,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String conceptId,
                required String itemId,
                required String itemKind,
                required String itemType,
                Value<bool?> isCorrect = const Value.absent(),
                Value<int?> selfRating = const Value.absent(),
                Value<int> hintsUsed = const Value.absent(),
                Value<String?> userResponse = const Value.absent(),
                required DateTime createdAt,
              }) => AttemptsTableCompanion.insert(
                id: id,
                conceptId: conceptId,
                itemId: itemId,
                itemKind: itemKind,
                itemType: itemType,
                isCorrect: isCorrect,
                selfRating: selfRating,
                hintsUsed: hintsUsed,
                userResponse: userResponse,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttemptsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttemptsTableTable,
      AttemptsTableData,
      $$AttemptsTableTableFilterComposer,
      $$AttemptsTableTableOrderingComposer,
      $$AttemptsTableTableAnnotationComposer,
      $$AttemptsTableTableCreateCompanionBuilder,
      $$AttemptsTableTableUpdateCompanionBuilder,
      (
        AttemptsTableData,
        BaseReferences<_$AppDatabase, $AttemptsTableTable, AttemptsTableData>,
      ),
      AttemptsTableData,
      PrefetchHooks Function()
    >;
typedef $$MisconceptionsTableTableCreateCompanionBuilder =
    MisconceptionsTableCompanion Function({
      Value<int> id,
      required String conceptId,
      required String description,
      required DateTime detectedAt,
      Value<double> confidence,
      Value<DateTime?> resolvedAt,
    });
typedef $$MisconceptionsTableTableUpdateCompanionBuilder =
    MisconceptionsTableCompanion Function({
      Value<int> id,
      Value<String> conceptId,
      Value<String> description,
      Value<DateTime> detectedAt,
      Value<double> confidence,
      Value<DateTime?> resolvedAt,
    });

class $$MisconceptionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $MisconceptionsTableTable> {
  $$MisconceptionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conceptId => $composableBuilder(
    column: $table.conceptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MisconceptionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MisconceptionsTableTable> {
  $$MisconceptionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conceptId => $composableBuilder(
    column: $table.conceptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MisconceptionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MisconceptionsTableTable> {
  $$MisconceptionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get conceptId =>
      $composableBuilder(column: $table.conceptId, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );
}

class $$MisconceptionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MisconceptionsTableTable,
          MisconceptionsTableData,
          $$MisconceptionsTableTableFilterComposer,
          $$MisconceptionsTableTableOrderingComposer,
          $$MisconceptionsTableTableAnnotationComposer,
          $$MisconceptionsTableTableCreateCompanionBuilder,
          $$MisconceptionsTableTableUpdateCompanionBuilder,
          (
            MisconceptionsTableData,
            BaseReferences<
              _$AppDatabase,
              $MisconceptionsTableTable,
              MisconceptionsTableData
            >,
          ),
          MisconceptionsTableData,
          PrefetchHooks Function()
        > {
  $$MisconceptionsTableTableTableManager(
    _$AppDatabase db,
    $MisconceptionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MisconceptionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MisconceptionsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MisconceptionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> conceptId = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> detectedAt = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
              }) => MisconceptionsTableCompanion(
                id: id,
                conceptId: conceptId,
                description: description,
                detectedAt: detectedAt,
                confidence: confidence,
                resolvedAt: resolvedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String conceptId,
                required String description,
                required DateTime detectedAt,
                Value<double> confidence = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
              }) => MisconceptionsTableCompanion.insert(
                id: id,
                conceptId: conceptId,
                description: description,
                detectedAt: detectedAt,
                confidence: confidence,
                resolvedAt: resolvedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MisconceptionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MisconceptionsTableTable,
      MisconceptionsTableData,
      $$MisconceptionsTableTableFilterComposer,
      $$MisconceptionsTableTableOrderingComposer,
      $$MisconceptionsTableTableAnnotationComposer,
      $$MisconceptionsTableTableCreateCompanionBuilder,
      $$MisconceptionsTableTableUpdateCompanionBuilder,
      (
        MisconceptionsTableData,
        BaseReferences<
          _$AppDatabase,
          $MisconceptionsTableTable,
          MisconceptionsTableData
        >,
      ),
      MisconceptionsTableData,
      PrefetchHooks Function()
    >;
typedef $$ReviewScheduleTableTableCreateCompanionBuilder =
    ReviewScheduleTableCompanion Function({
      required String conceptId,
      required DateTime dueAt,
      Value<int> intervalDays,
      Value<DateTime?> lastReviewedAt,
      Value<int> reviewCount,
      Value<int> rowid,
    });
typedef $$ReviewScheduleTableTableUpdateCompanionBuilder =
    ReviewScheduleTableCompanion Function({
      Value<String> conceptId,
      Value<DateTime> dueAt,
      Value<int> intervalDays,
      Value<DateTime?> lastReviewedAt,
      Value<int> reviewCount,
      Value<int> rowid,
    });

class $$ReviewScheduleTableTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewScheduleTableTable> {
  $$ReviewScheduleTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get conceptId => $composableBuilder(
    column: $table.conceptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReviewScheduleTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewScheduleTableTable> {
  $$ReviewScheduleTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get conceptId => $composableBuilder(
    column: $table.conceptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReviewScheduleTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewScheduleTableTable> {
  $$ReviewScheduleTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get conceptId =>
      $composableBuilder(column: $table.conceptId, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => column,
  );
}

class $$ReviewScheduleTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReviewScheduleTableTable,
          ReviewScheduleTableData,
          $$ReviewScheduleTableTableFilterComposer,
          $$ReviewScheduleTableTableOrderingComposer,
          $$ReviewScheduleTableTableAnnotationComposer,
          $$ReviewScheduleTableTableCreateCompanionBuilder,
          $$ReviewScheduleTableTableUpdateCompanionBuilder,
          (
            ReviewScheduleTableData,
            BaseReferences<
              _$AppDatabase,
              $ReviewScheduleTableTable,
              ReviewScheduleTableData
            >,
          ),
          ReviewScheduleTableData,
          PrefetchHooks Function()
        > {
  $$ReviewScheduleTableTableTableManager(
    _$AppDatabase db,
    $ReviewScheduleTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewScheduleTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewScheduleTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ReviewScheduleTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> conceptId = const Value.absent(),
                Value<DateTime> dueAt = const Value.absent(),
                Value<int> intervalDays = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<int> reviewCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewScheduleTableCompanion(
                conceptId: conceptId,
                dueAt: dueAt,
                intervalDays: intervalDays,
                lastReviewedAt: lastReviewedAt,
                reviewCount: reviewCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String conceptId,
                required DateTime dueAt,
                Value<int> intervalDays = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<int> reviewCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewScheduleTableCompanion.insert(
                conceptId: conceptId,
                dueAt: dueAt,
                intervalDays: intervalDays,
                lastReviewedAt: lastReviewedAt,
                reviewCount: reviewCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReviewScheduleTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReviewScheduleTableTable,
      ReviewScheduleTableData,
      $$ReviewScheduleTableTableFilterComposer,
      $$ReviewScheduleTableTableOrderingComposer,
      $$ReviewScheduleTableTableAnnotationComposer,
      $$ReviewScheduleTableTableCreateCompanionBuilder,
      $$ReviewScheduleTableTableUpdateCompanionBuilder,
      (
        ReviewScheduleTableData,
        BaseReferences<
          _$AppDatabase,
          $ReviewScheduleTableTable,
          ReviewScheduleTableData
        >,
      ),
      ReviewScheduleTableData,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableTableCreateCompanionBuilder =
    SettingsTableCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsTableTableUpdateCompanionBuilder =
    SettingsTableCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTableTable,
          SettingsTableData,
          $$SettingsTableTableFilterComposer,
          $$SettingsTableTableOrderingComposer,
          $$SettingsTableTableAnnotationComposer,
          $$SettingsTableTableCreateCompanionBuilder,
          $$SettingsTableTableUpdateCompanionBuilder,
          (
            SettingsTableData,
            BaseReferences<
              _$AppDatabase,
              $SettingsTableTable,
              SettingsTableData
            >,
          ),
          SettingsTableData,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableTableManager(_$AppDatabase db, $SettingsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsTableCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsTableCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTableTable,
      SettingsTableData,
      $$SettingsTableTableFilterComposer,
      $$SettingsTableTableOrderingComposer,
      $$SettingsTableTableAnnotationComposer,
      $$SettingsTableTableCreateCompanionBuilder,
      $$SettingsTableTableUpdateCompanionBuilder,
      (
        SettingsTableData,
        BaseReferences<_$AppDatabase, $SettingsTableTable, SettingsTableData>,
      ),
      SettingsTableData,
      PrefetchHooks Function()
    >;
typedef $$LearningPathProgressTableTableCreateCompanionBuilder =
    LearningPathProgressTableCompanion Function({
      required String learningPathId,
      required DateTime startedAt,
      Value<int> rowid,
    });
typedef $$LearningPathProgressTableTableUpdateCompanionBuilder =
    LearningPathProgressTableCompanion Function({
      Value<String> learningPathId,
      Value<DateTime> startedAt,
      Value<int> rowid,
    });

class $$LearningPathProgressTableTableFilterComposer
    extends Composer<_$AppDatabase, $LearningPathProgressTableTable> {
  $$LearningPathProgressTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get learningPathId => $composableBuilder(
    column: $table.learningPathId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LearningPathProgressTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LearningPathProgressTableTable> {
  $$LearningPathProgressTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get learningPathId => $composableBuilder(
    column: $table.learningPathId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LearningPathProgressTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LearningPathProgressTableTable> {
  $$LearningPathProgressTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get learningPathId => $composableBuilder(
    column: $table.learningPathId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);
}

class $$LearningPathProgressTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LearningPathProgressTableTable,
          LearningPathProgressTableData,
          $$LearningPathProgressTableTableFilterComposer,
          $$LearningPathProgressTableTableOrderingComposer,
          $$LearningPathProgressTableTableAnnotationComposer,
          $$LearningPathProgressTableTableCreateCompanionBuilder,
          $$LearningPathProgressTableTableUpdateCompanionBuilder,
          (
            LearningPathProgressTableData,
            BaseReferences<
              _$AppDatabase,
              $LearningPathProgressTableTable,
              LearningPathProgressTableData
            >,
          ),
          LearningPathProgressTableData,
          PrefetchHooks Function()
        > {
  $$LearningPathProgressTableTableTableManager(
    _$AppDatabase db,
    $LearningPathProgressTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LearningPathProgressTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LearningPathProgressTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LearningPathProgressTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> learningPathId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LearningPathProgressTableCompanion(
                learningPathId: learningPathId,
                startedAt: startedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String learningPathId,
                required DateTime startedAt,
                Value<int> rowid = const Value.absent(),
              }) => LearningPathProgressTableCompanion.insert(
                learningPathId: learningPathId,
                startedAt: startedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LearningPathProgressTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LearningPathProgressTableTable,
      LearningPathProgressTableData,
      $$LearningPathProgressTableTableFilterComposer,
      $$LearningPathProgressTableTableOrderingComposer,
      $$LearningPathProgressTableTableAnnotationComposer,
      $$LearningPathProgressTableTableCreateCompanionBuilder,
      $$LearningPathProgressTableTableUpdateCompanionBuilder,
      (
        LearningPathProgressTableData,
        BaseReferences<
          _$AppDatabase,
          $LearningPathProgressTableTable,
          LearningPathProgressTableData
        >,
      ),
      LearningPathProgressTableData,
      PrefetchHooks Function()
    >;
typedef $$ModuleTestProgressTableTableCreateCompanionBuilder =
    ModuleTestProgressTableCompanion Function({
      required String learningPathId,
      required String moduleId,
      required DateTime passedAt,
      required int scorePercent,
      required int questionCount,
      Value<bool> isGrandfathered,
      Value<int> rowid,
    });
typedef $$ModuleTestProgressTableTableUpdateCompanionBuilder =
    ModuleTestProgressTableCompanion Function({
      Value<String> learningPathId,
      Value<String> moduleId,
      Value<DateTime> passedAt,
      Value<int> scorePercent,
      Value<int> questionCount,
      Value<bool> isGrandfathered,
      Value<int> rowid,
    });

class $$ModuleTestProgressTableTableFilterComposer
    extends Composer<_$AppDatabase, $ModuleTestProgressTableTable> {
  $$ModuleTestProgressTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get learningPathId => $composableBuilder(
    column: $table.learningPathId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moduleId => $composableBuilder(
    column: $table.moduleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get passedAt => $composableBuilder(
    column: $table.passedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scorePercent => $composableBuilder(
    column: $table.scorePercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get questionCount => $composableBuilder(
    column: $table.questionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGrandfathered => $composableBuilder(
    column: $table.isGrandfathered,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ModuleTestProgressTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ModuleTestProgressTableTable> {
  $$ModuleTestProgressTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get learningPathId => $composableBuilder(
    column: $table.learningPathId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moduleId => $composableBuilder(
    column: $table.moduleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get passedAt => $composableBuilder(
    column: $table.passedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scorePercent => $composableBuilder(
    column: $table.scorePercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get questionCount => $composableBuilder(
    column: $table.questionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGrandfathered => $composableBuilder(
    column: $table.isGrandfathered,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ModuleTestProgressTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ModuleTestProgressTableTable> {
  $$ModuleTestProgressTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get learningPathId => $composableBuilder(
    column: $table.learningPathId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get moduleId =>
      $composableBuilder(column: $table.moduleId, builder: (column) => column);

  GeneratedColumn<DateTime> get passedAt =>
      $composableBuilder(column: $table.passedAt, builder: (column) => column);

  GeneratedColumn<int> get scorePercent => $composableBuilder(
    column: $table.scorePercent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get questionCount => $composableBuilder(
    column: $table.questionCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isGrandfathered => $composableBuilder(
    column: $table.isGrandfathered,
    builder: (column) => column,
  );
}

class $$ModuleTestProgressTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ModuleTestProgressTableTable,
          ModuleTestProgressTableData,
          $$ModuleTestProgressTableTableFilterComposer,
          $$ModuleTestProgressTableTableOrderingComposer,
          $$ModuleTestProgressTableTableAnnotationComposer,
          $$ModuleTestProgressTableTableCreateCompanionBuilder,
          $$ModuleTestProgressTableTableUpdateCompanionBuilder,
          (
            ModuleTestProgressTableData,
            BaseReferences<
              _$AppDatabase,
              $ModuleTestProgressTableTable,
              ModuleTestProgressTableData
            >,
          ),
          ModuleTestProgressTableData,
          PrefetchHooks Function()
        > {
  $$ModuleTestProgressTableTableTableManager(
    _$AppDatabase db,
    $ModuleTestProgressTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModuleTestProgressTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ModuleTestProgressTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ModuleTestProgressTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> learningPathId = const Value.absent(),
                Value<String> moduleId = const Value.absent(),
                Value<DateTime> passedAt = const Value.absent(),
                Value<int> scorePercent = const Value.absent(),
                Value<int> questionCount = const Value.absent(),
                Value<bool> isGrandfathered = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModuleTestProgressTableCompanion(
                learningPathId: learningPathId,
                moduleId: moduleId,
                passedAt: passedAt,
                scorePercent: scorePercent,
                questionCount: questionCount,
                isGrandfathered: isGrandfathered,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String learningPathId,
                required String moduleId,
                required DateTime passedAt,
                required int scorePercent,
                required int questionCount,
                Value<bool> isGrandfathered = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModuleTestProgressTableCompanion.insert(
                learningPathId: learningPathId,
                moduleId: moduleId,
                passedAt: passedAt,
                scorePercent: scorePercent,
                questionCount: questionCount,
                isGrandfathered: isGrandfathered,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ModuleTestProgressTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ModuleTestProgressTableTable,
      ModuleTestProgressTableData,
      $$ModuleTestProgressTableTableFilterComposer,
      $$ModuleTestProgressTableTableOrderingComposer,
      $$ModuleTestProgressTableTableAnnotationComposer,
      $$ModuleTestProgressTableTableCreateCompanionBuilder,
      $$ModuleTestProgressTableTableUpdateCompanionBuilder,
      (
        ModuleTestProgressTableData,
        BaseReferences<
          _$AppDatabase,
          $ModuleTestProgressTableTable,
          ModuleTestProgressTableData
        >,
      ),
      ModuleTestProgressTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$StudentProgressTableTableTableManager get studentProgressTable =>
      $$StudentProgressTableTableTableManager(_db, _db.studentProgressTable);
  $$ConceptMasteryTableTableTableManager get conceptMasteryTable =>
      $$ConceptMasteryTableTableTableManager(_db, _db.conceptMasteryTable);
  $$AttemptsTableTableTableManager get attemptsTable =>
      $$AttemptsTableTableTableManager(_db, _db.attemptsTable);
  $$MisconceptionsTableTableTableManager get misconceptionsTable =>
      $$MisconceptionsTableTableTableManager(_db, _db.misconceptionsTable);
  $$ReviewScheduleTableTableTableManager get reviewScheduleTable =>
      $$ReviewScheduleTableTableTableManager(_db, _db.reviewScheduleTable);
  $$SettingsTableTableTableManager get settingsTable =>
      $$SettingsTableTableTableManager(_db, _db.settingsTable);
  $$LearningPathProgressTableTableTableManager get learningPathProgressTable =>
      $$LearningPathProgressTableTableTableManager(
        _db,
        _db.learningPathProgressTable,
      );
  $$ModuleTestProgressTableTableTableManager get moduleTestProgressTable =>
      $$ModuleTestProgressTableTableTableManager(
        _db,
        _db.moduleTestProgressTable,
      );
}
