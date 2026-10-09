// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalStudentsTable extends LocalStudents
    with TableInfo<$LocalStudentsTable, LocalStudentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalStudentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _universityIdMeta = const VerificationMeta(
    'universityId',
  );
  @override
  late final GeneratedColumn<String> universityId = GeneratedColumn<String>(
    'university_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stageIdMeta = const VerificationMeta(
    'stageId',
  );
  @override
  late final GeneratedColumn<String> stageId = GeneratedColumn<String>(
    'stage_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectionMeta = const VerificationMeta(
    'section',
  );
  @override
  late final GeneratedColumn<String> section = GeneratedColumn<String>(
    'section',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carryOverMeta = const VerificationMeta(
    'carryOver',
  );
  @override
  late final GeneratedColumn<bool> carryOver = GeneratedColumn<bool>(
    'carry_over',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("carry_over" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortKeyMeta = const VerificationMeta(
    'sortKey',
  );
  @override
  late final GeneratedColumn<String> sortKey = GeneratedColumn<String>(
    'sort_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    universityId,
    fullName,
    stageId,
    section,
    status,
    carryOver,
    sortKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_students';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalStudentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('university_id')) {
      context.handle(
        _universityIdMeta,
        universityId.isAcceptableOrUnknown(
          data['university_id']!,
          _universityIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_universityIdMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('stage_id')) {
      context.handle(
        _stageIdMeta,
        stageId.isAcceptableOrUnknown(data['stage_id']!, _stageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_stageIdMeta);
    }
    if (data.containsKey('section')) {
      context.handle(
        _sectionMeta,
        section.isAcceptableOrUnknown(data['section']!, _sectionMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('carry_over')) {
      context.handle(
        _carryOverMeta,
        carryOver.isAcceptableOrUnknown(data['carry_over']!, _carryOverMeta),
      );
    }
    if (data.containsKey('sort_key')) {
      context.handle(
        _sortKeyMeta,
        sortKey.isAcceptableOrUnknown(data['sort_key']!, _sortKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_sortKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalStudentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalStudentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      universityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}university_id'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      stageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage_id'],
      )!,
      section: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      carryOver: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}carry_over'],
      )!,
      sortKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sort_key'],
      )!,
    );
  }

  @override
  $LocalStudentsTable createAlias(String alias) {
    return $LocalStudentsTable(attachedDatabase, alias);
  }
}

class LocalStudentRow extends DataClass implements Insertable<LocalStudentRow> {
  final String id;
  final String universityId;
  final String fullName;
  final String stageId;
  final String section;
  final String status;
  final bool carryOver;
  final String sortKey;
  const LocalStudentRow({
    required this.id,
    required this.universityId,
    required this.fullName,
    required this.stageId,
    required this.section,
    required this.status,
    required this.carryOver,
    required this.sortKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['university_id'] = Variable<String>(universityId);
    map['full_name'] = Variable<String>(fullName);
    map['stage_id'] = Variable<String>(stageId);
    map['section'] = Variable<String>(section);
    map['status'] = Variable<String>(status);
    map['carry_over'] = Variable<bool>(carryOver);
    map['sort_key'] = Variable<String>(sortKey);
    return map;
  }

  LocalStudentsCompanion toCompanion(bool nullToAbsent) {
    return LocalStudentsCompanion(
      id: Value(id),
      universityId: Value(universityId),
      fullName: Value(fullName),
      stageId: Value(stageId),
      section: Value(section),
      status: Value(status),
      carryOver: Value(carryOver),
      sortKey: Value(sortKey),
    );
  }

  factory LocalStudentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalStudentRow(
      id: serializer.fromJson<String>(json['id']),
      universityId: serializer.fromJson<String>(json['universityId']),
      fullName: serializer.fromJson<String>(json['fullName']),
      stageId: serializer.fromJson<String>(json['stageId']),
      section: serializer.fromJson<String>(json['section']),
      status: serializer.fromJson<String>(json['status']),
      carryOver: serializer.fromJson<bool>(json['carryOver']),
      sortKey: serializer.fromJson<String>(json['sortKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'universityId': serializer.toJson<String>(universityId),
      'fullName': serializer.toJson<String>(fullName),
      'stageId': serializer.toJson<String>(stageId),
      'section': serializer.toJson<String>(section),
      'status': serializer.toJson<String>(status),
      'carryOver': serializer.toJson<bool>(carryOver),
      'sortKey': serializer.toJson<String>(sortKey),
    };
  }

  LocalStudentRow copyWith({
    String? id,
    String? universityId,
    String? fullName,
    String? stageId,
    String? section,
    String? status,
    bool? carryOver,
    String? sortKey,
  }) => LocalStudentRow(
    id: id ?? this.id,
    universityId: universityId ?? this.universityId,
    fullName: fullName ?? this.fullName,
    stageId: stageId ?? this.stageId,
    section: section ?? this.section,
    status: status ?? this.status,
    carryOver: carryOver ?? this.carryOver,
    sortKey: sortKey ?? this.sortKey,
  );
  LocalStudentRow copyWithCompanion(LocalStudentsCompanion data) {
    return LocalStudentRow(
      id: data.id.present ? data.id.value : this.id,
      universityId: data.universityId.present
          ? data.universityId.value
          : this.universityId,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      stageId: data.stageId.present ? data.stageId.value : this.stageId,
      section: data.section.present ? data.section.value : this.section,
      status: data.status.present ? data.status.value : this.status,
      carryOver: data.carryOver.present ? data.carryOver.value : this.carryOver,
      sortKey: data.sortKey.present ? data.sortKey.value : this.sortKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalStudentRow(')
          ..write('id: $id, ')
          ..write('universityId: $universityId, ')
          ..write('fullName: $fullName, ')
          ..write('stageId: $stageId, ')
          ..write('section: $section, ')
          ..write('status: $status, ')
          ..write('carryOver: $carryOver, ')
          ..write('sortKey: $sortKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    universityId,
    fullName,
    stageId,
    section,
    status,
    carryOver,
    sortKey,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalStudentRow &&
          other.id == this.id &&
          other.universityId == this.universityId &&
          other.fullName == this.fullName &&
          other.stageId == this.stageId &&
          other.section == this.section &&
          other.status == this.status &&
          other.carryOver == this.carryOver &&
          other.sortKey == this.sortKey);
}

class LocalStudentsCompanion extends UpdateCompanion<LocalStudentRow> {
  final Value<String> id;
  final Value<String> universityId;
  final Value<String> fullName;
  final Value<String> stageId;
  final Value<String> section;
  final Value<String> status;
  final Value<bool> carryOver;
  final Value<String> sortKey;
  final Value<int> rowid;
  const LocalStudentsCompanion({
    this.id = const Value.absent(),
    this.universityId = const Value.absent(),
    this.fullName = const Value.absent(),
    this.stageId = const Value.absent(),
    this.section = const Value.absent(),
    this.status = const Value.absent(),
    this.carryOver = const Value.absent(),
    this.sortKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalStudentsCompanion.insert({
    required String id,
    required String universityId,
    required String fullName,
    required String stageId,
    this.section = const Value.absent(),
    required String status,
    this.carryOver = const Value.absent(),
    required String sortKey,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       universityId = Value(universityId),
       fullName = Value(fullName),
       stageId = Value(stageId),
       status = Value(status),
       sortKey = Value(sortKey);
  static Insertable<LocalStudentRow> custom({
    Expression<String>? id,
    Expression<String>? universityId,
    Expression<String>? fullName,
    Expression<String>? stageId,
    Expression<String>? section,
    Expression<String>? status,
    Expression<bool>? carryOver,
    Expression<String>? sortKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (universityId != null) 'university_id': universityId,
      if (fullName != null) 'full_name': fullName,
      if (stageId != null) 'stage_id': stageId,
      if (section != null) 'section': section,
      if (status != null) 'status': status,
      if (carryOver != null) 'carry_over': carryOver,
      if (sortKey != null) 'sort_key': sortKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalStudentsCompanion copyWith({
    Value<String>? id,
    Value<String>? universityId,
    Value<String>? fullName,
    Value<String>? stageId,
    Value<String>? section,
    Value<String>? status,
    Value<bool>? carryOver,
    Value<String>? sortKey,
    Value<int>? rowid,
  }) {
    return LocalStudentsCompanion(
      id: id ?? this.id,
      universityId: universityId ?? this.universityId,
      fullName: fullName ?? this.fullName,
      stageId: stageId ?? this.stageId,
      section: section ?? this.section,
      status: status ?? this.status,
      carryOver: carryOver ?? this.carryOver,
      sortKey: sortKey ?? this.sortKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (universityId.present) {
      map['university_id'] = Variable<String>(universityId.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (stageId.present) {
      map['stage_id'] = Variable<String>(stageId.value);
    }
    if (section.present) {
      map['section'] = Variable<String>(section.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (carryOver.present) {
      map['carry_over'] = Variable<bool>(carryOver.value);
    }
    if (sortKey.present) {
      map['sort_key'] = Variable<String>(sortKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalStudentsCompanion(')
          ..write('id: $id, ')
          ..write('universityId: $universityId, ')
          ..write('fullName: $fullName, ')
          ..write('stageId: $stageId, ')
          ..write('section: $section, ')
          ..write('status: $status, ')
          ..write('carryOver: $carryOver, ')
          ..write('sortKey: $sortKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalCoursesTable extends LocalCourses
    with TableInfo<$LocalCoursesTable, LocalCourseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCoursesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stageIdMeta = const VerificationMeta(
    'stageId',
  );
  @override
  late final GeneratedColumn<String> stageId = GeneratedColumn<String>(
    'stage_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _semesterMeta = const VerificationMeta(
    'semester',
  );
  @override
  late final GeneratedColumn<int> semester = GeneratedColumn<int>(
    'semester',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitsMeta = const VerificationMeta('units');
  @override
  late final GeneratedColumn<int> units = GeneratedColumn<int>(
    'units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hasPracticalMeta = const VerificationMeta(
    'hasPractical',
  );
  @override
  late final GeneratedColumn<bool> hasPractical = GeneratedColumn<bool>(
    'has_practical',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_practical" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    name,
    stageId,
    semester,
    units,
    hasPractical,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_courses';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalCourseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('stage_id')) {
      context.handle(
        _stageIdMeta,
        stageId.isAcceptableOrUnknown(data['stage_id']!, _stageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_stageIdMeta);
    }
    if (data.containsKey('semester')) {
      context.handle(
        _semesterMeta,
        semester.isAcceptableOrUnknown(data['semester']!, _semesterMeta),
      );
    } else if (isInserting) {
      context.missing(_semesterMeta);
    }
    if (data.containsKey('units')) {
      context.handle(
        _unitsMeta,
        units.isAcceptableOrUnknown(data['units']!, _unitsMeta),
      );
    } else if (isInserting) {
      context.missing(_unitsMeta);
    }
    if (data.containsKey('has_practical')) {
      context.handle(
        _hasPracticalMeta,
        hasPractical.isAcceptableOrUnknown(
          data['has_practical']!,
          _hasPracticalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hasPracticalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalCourseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCourseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      stageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage_id'],
      )!,
      semester: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}semester'],
      )!,
      units: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}units'],
      )!,
      hasPractical: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_practical'],
      )!,
    );
  }

  @override
  $LocalCoursesTable createAlias(String alias) {
    return $LocalCoursesTable(attachedDatabase, alias);
  }
}

class LocalCourseRow extends DataClass implements Insertable<LocalCourseRow> {
  final String id;
  final String code;
  final String name;
  final String stageId;
  final int semester;
  final int units;
  final bool hasPractical;
  const LocalCourseRow({
    required this.id,
    required this.code,
    required this.name,
    required this.stageId,
    required this.semester,
    required this.units,
    required this.hasPractical,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['stage_id'] = Variable<String>(stageId);
    map['semester'] = Variable<int>(semester);
    map['units'] = Variable<int>(units);
    map['has_practical'] = Variable<bool>(hasPractical);
    return map;
  }

  LocalCoursesCompanion toCompanion(bool nullToAbsent) {
    return LocalCoursesCompanion(
      id: Value(id),
      code: Value(code),
      name: Value(name),
      stageId: Value(stageId),
      semester: Value(semester),
      units: Value(units),
      hasPractical: Value(hasPractical),
    );
  }

  factory LocalCourseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCourseRow(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      stageId: serializer.fromJson<String>(json['stageId']),
      semester: serializer.fromJson<int>(json['semester']),
      units: serializer.fromJson<int>(json['units']),
      hasPractical: serializer.fromJson<bool>(json['hasPractical']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'stageId': serializer.toJson<String>(stageId),
      'semester': serializer.toJson<int>(semester),
      'units': serializer.toJson<int>(units),
      'hasPractical': serializer.toJson<bool>(hasPractical),
    };
  }

  LocalCourseRow copyWith({
    String? id,
    String? code,
    String? name,
    String? stageId,
    int? semester,
    int? units,
    bool? hasPractical,
  }) => LocalCourseRow(
    id: id ?? this.id,
    code: code ?? this.code,
    name: name ?? this.name,
    stageId: stageId ?? this.stageId,
    semester: semester ?? this.semester,
    units: units ?? this.units,
    hasPractical: hasPractical ?? this.hasPractical,
  );
  LocalCourseRow copyWithCompanion(LocalCoursesCompanion data) {
    return LocalCourseRow(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      stageId: data.stageId.present ? data.stageId.value : this.stageId,
      semester: data.semester.present ? data.semester.value : this.semester,
      units: data.units.present ? data.units.value : this.units,
      hasPractical: data.hasPractical.present
          ? data.hasPractical.value
          : this.hasPractical,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCourseRow(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('stageId: $stageId, ')
          ..write('semester: $semester, ')
          ..write('units: $units, ')
          ..write('hasPractical: $hasPractical')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, code, name, stageId, semester, units, hasPractical);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCourseRow &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.stageId == this.stageId &&
          other.semester == this.semester &&
          other.units == this.units &&
          other.hasPractical == this.hasPractical);
}

class LocalCoursesCompanion extends UpdateCompanion<LocalCourseRow> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> name;
  final Value<String> stageId;
  final Value<int> semester;
  final Value<int> units;
  final Value<bool> hasPractical;
  final Value<int> rowid;
  const LocalCoursesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.stageId = const Value.absent(),
    this.semester = const Value.absent(),
    this.units = const Value.absent(),
    this.hasPractical = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCoursesCompanion.insert({
    required String id,
    required String code,
    required String name,
    required String stageId,
    required int semester,
    required int units,
    required bool hasPractical,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       name = Value(name),
       stageId = Value(stageId),
       semester = Value(semester),
       units = Value(units),
       hasPractical = Value(hasPractical);
  static Insertable<LocalCourseRow> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? stageId,
    Expression<int>? semester,
    Expression<int>? units,
    Expression<bool>? hasPractical,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (stageId != null) 'stage_id': stageId,
      if (semester != null) 'semester': semester,
      if (units != null) 'units': units,
      if (hasPractical != null) 'has_practical': hasPractical,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCoursesCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<String>? name,
    Value<String>? stageId,
    Value<int>? semester,
    Value<int>? units,
    Value<bool>? hasPractical,
    Value<int>? rowid,
  }) {
    return LocalCoursesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      stageId: stageId ?? this.stageId,
      semester: semester ?? this.semester,
      units: units ?? this.units,
      hasPractical: hasPractical ?? this.hasPractical,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (stageId.present) {
      map['stage_id'] = Variable<String>(stageId.value);
    }
    if (semester.present) {
      map['semester'] = Variable<int>(semester.value);
    }
    if (units.present) {
      map['units'] = Variable<int>(units.value);
    }
    if (hasPractical.present) {
      map['has_practical'] = Variable<bool>(hasPractical.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCoursesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('stageId: $stageId, ')
          ..write('semester: $semester, ')
          ..write('units: $units, ')
          ..write('hasPractical: $hasPractical, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalGroupsTable extends LocalGroups
    with TableInfo<$LocalGroupsTable, LocalGroupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _courseIdMeta = const VerificationMeta(
    'courseId',
  );
  @override
  late final GeneratedColumn<String> courseId = GeneratedColumn<String>(
    'course_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stageIdMeta = const VerificationMeta(
    'stageId',
  );
  @override
  late final GeneratedColumn<String> stageId = GeneratedColumn<String>(
    'stage_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdsJsonMeta = const VerificationMeta(
    'studentIdsJson',
  );
  @override
  late final GeneratedColumn<String> studentIdsJson = GeneratedColumn<String>(
    'student_ids_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    courseId,
    stageId,
    name,
    studentIdsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalGroupRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('course_id')) {
      context.handle(
        _courseIdMeta,
        courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_courseIdMeta);
    }
    if (data.containsKey('stage_id')) {
      context.handle(
        _stageIdMeta,
        stageId.isAcceptableOrUnknown(data['stage_id']!, _stageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_stageIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('student_ids_json')) {
      context.handle(
        _studentIdsJsonMeta,
        studentIdsJson.isAcceptableOrUnknown(
          data['student_ids_json']!,
          _studentIdsJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalGroupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalGroupRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      courseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_id'],
      )!,
      stageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      studentIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_ids_json'],
      )!,
    );
  }

  @override
  $LocalGroupsTable createAlias(String alias) {
    return $LocalGroupsTable(attachedDatabase, alias);
  }
}

class LocalGroupRow extends DataClass implements Insertable<LocalGroupRow> {
  final String id;
  final String courseId;
  final String stageId;
  final String name;
  final String studentIdsJson;
  const LocalGroupRow({
    required this.id,
    required this.courseId,
    required this.stageId,
    required this.name,
    required this.studentIdsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['course_id'] = Variable<String>(courseId);
    map['stage_id'] = Variable<String>(stageId);
    map['name'] = Variable<String>(name);
    map['student_ids_json'] = Variable<String>(studentIdsJson);
    return map;
  }

  LocalGroupsCompanion toCompanion(bool nullToAbsent) {
    return LocalGroupsCompanion(
      id: Value(id),
      courseId: Value(courseId),
      stageId: Value(stageId),
      name: Value(name),
      studentIdsJson: Value(studentIdsJson),
    );
  }

  factory LocalGroupRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalGroupRow(
      id: serializer.fromJson<String>(json['id']),
      courseId: serializer.fromJson<String>(json['courseId']),
      stageId: serializer.fromJson<String>(json['stageId']),
      name: serializer.fromJson<String>(json['name']),
      studentIdsJson: serializer.fromJson<String>(json['studentIdsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'courseId': serializer.toJson<String>(courseId),
      'stageId': serializer.toJson<String>(stageId),
      'name': serializer.toJson<String>(name),
      'studentIdsJson': serializer.toJson<String>(studentIdsJson),
    };
  }

  LocalGroupRow copyWith({
    String? id,
    String? courseId,
    String? stageId,
    String? name,
    String? studentIdsJson,
  }) => LocalGroupRow(
    id: id ?? this.id,
    courseId: courseId ?? this.courseId,
    stageId: stageId ?? this.stageId,
    name: name ?? this.name,
    studentIdsJson: studentIdsJson ?? this.studentIdsJson,
  );
  LocalGroupRow copyWithCompanion(LocalGroupsCompanion data) {
    return LocalGroupRow(
      id: data.id.present ? data.id.value : this.id,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      stageId: data.stageId.present ? data.stageId.value : this.stageId,
      name: data.name.present ? data.name.value : this.name,
      studentIdsJson: data.studentIdsJson.present
          ? data.studentIdsJson.value
          : this.studentIdsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalGroupRow(')
          ..write('id: $id, ')
          ..write('courseId: $courseId, ')
          ..write('stageId: $stageId, ')
          ..write('name: $name, ')
          ..write('studentIdsJson: $studentIdsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, courseId, stageId, name, studentIdsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalGroupRow &&
          other.id == this.id &&
          other.courseId == this.courseId &&
          other.stageId == this.stageId &&
          other.name == this.name &&
          other.studentIdsJson == this.studentIdsJson);
}

class LocalGroupsCompanion extends UpdateCompanion<LocalGroupRow> {
  final Value<String> id;
  final Value<String> courseId;
  final Value<String> stageId;
  final Value<String> name;
  final Value<String> studentIdsJson;
  final Value<int> rowid;
  const LocalGroupsCompanion({
    this.id = const Value.absent(),
    this.courseId = const Value.absent(),
    this.stageId = const Value.absent(),
    this.name = const Value.absent(),
    this.studentIdsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalGroupsCompanion.insert({
    required String id,
    required String courseId,
    required String stageId,
    required String name,
    this.studentIdsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       courseId = Value(courseId),
       stageId = Value(stageId),
       name = Value(name);
  static Insertable<LocalGroupRow> custom({
    Expression<String>? id,
    Expression<String>? courseId,
    Expression<String>? stageId,
    Expression<String>? name,
    Expression<String>? studentIdsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (courseId != null) 'course_id': courseId,
      if (stageId != null) 'stage_id': stageId,
      if (name != null) 'name': name,
      if (studentIdsJson != null) 'student_ids_json': studentIdsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalGroupsCompanion copyWith({
    Value<String>? id,
    Value<String>? courseId,
    Value<String>? stageId,
    Value<String>? name,
    Value<String>? studentIdsJson,
    Value<int>? rowid,
  }) {
    return LocalGroupsCompanion(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      stageId: stageId ?? this.stageId,
      name: name ?? this.name,
      studentIdsJson: studentIdsJson ?? this.studentIdsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<String>(courseId.value);
    }
    if (stageId.present) {
      map['stage_id'] = Variable<String>(stageId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (studentIdsJson.present) {
      map['student_ids_json'] = Variable<String>(studentIdsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalGroupsCompanion(')
          ..write('id: $id, ')
          ..write('courseId: $courseId, ')
          ..write('stageId: $stageId, ')
          ..write('name: $name, ')
          ..write('studentIdsJson: $studentIdsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAssignmentsTable extends LocalAssignments
    with TableInfo<$LocalAssignmentsTable, LocalAssignmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAssignmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teacherIdMeta = const VerificationMeta(
    'teacherId',
  );
  @override
  late final GeneratedColumn<String> teacherId = GeneratedColumn<String>(
    'teacher_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _courseIdMeta = const VerificationMeta(
    'courseId',
  );
  @override
  late final GeneratedColumn<String> courseId = GeneratedColumn<String>(
    'course_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stageIdMeta = const VerificationMeta(
    'stageId',
  );
  @override
  late final GeneratedColumn<String> stageId = GeneratedColumn<String>(
    'stage_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<String> target = GeneratedColumn<String>(
    'target',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _courseNameMeta = const VerificationMeta(
    'courseName',
  );
  @override
  late final GeneratedColumn<String> courseName = GeneratedColumn<String>(
    'course_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _teacherNameMeta = const VerificationMeta(
    'teacherName',
  );
  @override
  late final GeneratedColumn<String> teacherName = GeneratedColumn<String>(
    'teacher_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    teacherId,
    courseId,
    stageId,
    type,
    target,
    groupId,
    courseName,
    teacherName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_assignments';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAssignmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('teacher_id')) {
      context.handle(
        _teacherIdMeta,
        teacherId.isAcceptableOrUnknown(data['teacher_id']!, _teacherIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teacherIdMeta);
    }
    if (data.containsKey('course_id')) {
      context.handle(
        _courseIdMeta,
        courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_courseIdMeta);
    }
    if (data.containsKey('stage_id')) {
      context.handle(
        _stageIdMeta,
        stageId.isAcceptableOrUnknown(data['stage_id']!, _stageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_stageIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    } else if (isInserting) {
      context.missing(_targetMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('course_name')) {
      context.handle(
        _courseNameMeta,
        courseName.isAcceptableOrUnknown(data['course_name']!, _courseNameMeta),
      );
    }
    if (data.containsKey('teacher_name')) {
      context.handle(
        _teacherNameMeta,
        teacherName.isAcceptableOrUnknown(
          data['teacher_name']!,
          _teacherNameMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAssignmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAssignmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      teacherId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher_id'],
      )!,
      courseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_id'],
      )!,
      stageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      ),
      courseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_name'],
      )!,
      teacherName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher_name'],
      )!,
    );
  }

  @override
  $LocalAssignmentsTable createAlias(String alias) {
    return $LocalAssignmentsTable(attachedDatabase, alias);
  }
}

class LocalAssignmentRow extends DataClass
    implements Insertable<LocalAssignmentRow> {
  final String id;
  final String teacherId;
  final String courseId;
  final String stageId;
  final String type;
  final String target;
  final String? groupId;
  final String courseName;
  final String teacherName;
  const LocalAssignmentRow({
    required this.id,
    required this.teacherId,
    required this.courseId,
    required this.stageId,
    required this.type,
    required this.target,
    this.groupId,
    required this.courseName,
    required this.teacherName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['teacher_id'] = Variable<String>(teacherId);
    map['course_id'] = Variable<String>(courseId);
    map['stage_id'] = Variable<String>(stageId);
    map['type'] = Variable<String>(type);
    map['target'] = Variable<String>(target);
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    map['course_name'] = Variable<String>(courseName);
    map['teacher_name'] = Variable<String>(teacherName);
    return map;
  }

  LocalAssignmentsCompanion toCompanion(bool nullToAbsent) {
    return LocalAssignmentsCompanion(
      id: Value(id),
      teacherId: Value(teacherId),
      courseId: Value(courseId),
      stageId: Value(stageId),
      type: Value(type),
      target: Value(target),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      courseName: Value(courseName),
      teacherName: Value(teacherName),
    );
  }

  factory LocalAssignmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAssignmentRow(
      id: serializer.fromJson<String>(json['id']),
      teacherId: serializer.fromJson<String>(json['teacherId']),
      courseId: serializer.fromJson<String>(json['courseId']),
      stageId: serializer.fromJson<String>(json['stageId']),
      type: serializer.fromJson<String>(json['type']),
      target: serializer.fromJson<String>(json['target']),
      groupId: serializer.fromJson<String?>(json['groupId']),
      courseName: serializer.fromJson<String>(json['courseName']),
      teacherName: serializer.fromJson<String>(json['teacherName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'teacherId': serializer.toJson<String>(teacherId),
      'courseId': serializer.toJson<String>(courseId),
      'stageId': serializer.toJson<String>(stageId),
      'type': serializer.toJson<String>(type),
      'target': serializer.toJson<String>(target),
      'groupId': serializer.toJson<String?>(groupId),
      'courseName': serializer.toJson<String>(courseName),
      'teacherName': serializer.toJson<String>(teacherName),
    };
  }

  LocalAssignmentRow copyWith({
    String? id,
    String? teacherId,
    String? courseId,
    String? stageId,
    String? type,
    String? target,
    Value<String?> groupId = const Value.absent(),
    String? courseName,
    String? teacherName,
  }) => LocalAssignmentRow(
    id: id ?? this.id,
    teacherId: teacherId ?? this.teacherId,
    courseId: courseId ?? this.courseId,
    stageId: stageId ?? this.stageId,
    type: type ?? this.type,
    target: target ?? this.target,
    groupId: groupId.present ? groupId.value : this.groupId,
    courseName: courseName ?? this.courseName,
    teacherName: teacherName ?? this.teacherName,
  );
  LocalAssignmentRow copyWithCompanion(LocalAssignmentsCompanion data) {
    return LocalAssignmentRow(
      id: data.id.present ? data.id.value : this.id,
      teacherId: data.teacherId.present ? data.teacherId.value : this.teacherId,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      stageId: data.stageId.present ? data.stageId.value : this.stageId,
      type: data.type.present ? data.type.value : this.type,
      target: data.target.present ? data.target.value : this.target,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      courseName: data.courseName.present
          ? data.courseName.value
          : this.courseName,
      teacherName: data.teacherName.present
          ? data.teacherName.value
          : this.teacherName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAssignmentRow(')
          ..write('id: $id, ')
          ..write('teacherId: $teacherId, ')
          ..write('courseId: $courseId, ')
          ..write('stageId: $stageId, ')
          ..write('type: $type, ')
          ..write('target: $target, ')
          ..write('groupId: $groupId, ')
          ..write('courseName: $courseName, ')
          ..write('teacherName: $teacherName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    teacherId,
    courseId,
    stageId,
    type,
    target,
    groupId,
    courseName,
    teacherName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAssignmentRow &&
          other.id == this.id &&
          other.teacherId == this.teacherId &&
          other.courseId == this.courseId &&
          other.stageId == this.stageId &&
          other.type == this.type &&
          other.target == this.target &&
          other.groupId == this.groupId &&
          other.courseName == this.courseName &&
          other.teacherName == this.teacherName);
}

class LocalAssignmentsCompanion extends UpdateCompanion<LocalAssignmentRow> {
  final Value<String> id;
  final Value<String> teacherId;
  final Value<String> courseId;
  final Value<String> stageId;
  final Value<String> type;
  final Value<String> target;
  final Value<String?> groupId;
  final Value<String> courseName;
  final Value<String> teacherName;
  final Value<int> rowid;
  const LocalAssignmentsCompanion({
    this.id = const Value.absent(),
    this.teacherId = const Value.absent(),
    this.courseId = const Value.absent(),
    this.stageId = const Value.absent(),
    this.type = const Value.absent(),
    this.target = const Value.absent(),
    this.groupId = const Value.absent(),
    this.courseName = const Value.absent(),
    this.teacherName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAssignmentsCompanion.insert({
    required String id,
    required String teacherId,
    required String courseId,
    required String stageId,
    required String type,
    required String target,
    this.groupId = const Value.absent(),
    this.courseName = const Value.absent(),
    this.teacherName = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       teacherId = Value(teacherId),
       courseId = Value(courseId),
       stageId = Value(stageId),
       type = Value(type),
       target = Value(target);
  static Insertable<LocalAssignmentRow> custom({
    Expression<String>? id,
    Expression<String>? teacherId,
    Expression<String>? courseId,
    Expression<String>? stageId,
    Expression<String>? type,
    Expression<String>? target,
    Expression<String>? groupId,
    Expression<String>? courseName,
    Expression<String>? teacherName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (teacherId != null) 'teacher_id': teacherId,
      if (courseId != null) 'course_id': courseId,
      if (stageId != null) 'stage_id': stageId,
      if (type != null) 'type': type,
      if (target != null) 'target': target,
      if (groupId != null) 'group_id': groupId,
      if (courseName != null) 'course_name': courseName,
      if (teacherName != null) 'teacher_name': teacherName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAssignmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? teacherId,
    Value<String>? courseId,
    Value<String>? stageId,
    Value<String>? type,
    Value<String>? target,
    Value<String?>? groupId,
    Value<String>? courseName,
    Value<String>? teacherName,
    Value<int>? rowid,
  }) {
    return LocalAssignmentsCompanion(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      courseId: courseId ?? this.courseId,
      stageId: stageId ?? this.stageId,
      type: type ?? this.type,
      target: target ?? this.target,
      groupId: groupId ?? this.groupId,
      courseName: courseName ?? this.courseName,
      teacherName: teacherName ?? this.teacherName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (teacherId.present) {
      map['teacher_id'] = Variable<String>(teacherId.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<String>(courseId.value);
    }
    if (stageId.present) {
      map['stage_id'] = Variable<String>(stageId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (target.present) {
      map['target'] = Variable<String>(target.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (courseName.present) {
      map['course_name'] = Variable<String>(courseName.value);
    }
    if (teacherName.present) {
      map['teacher_name'] = Variable<String>(teacherName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAssignmentsCompanion(')
          ..write('id: $id, ')
          ..write('teacherId: $teacherId, ')
          ..write('courseId: $courseId, ')
          ..write('stageId: $stageId, ')
          ..write('type: $type, ')
          ..write('target: $target, ')
          ..write('groupId: $groupId, ')
          ..write('courseName: $courseName, ')
          ..write('teacherName: $teacherName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSessionsTable extends LocalSessions
    with TableInfo<$LocalSessionsTable, LocalSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _courseIdMeta = const VerificationMeta(
    'courseId',
  );
  @override
  late final GeneratedColumn<String> courseId = GeneratedColumn<String>(
    'course_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stageIdMeta = const VerificationMeta(
    'stageId',
  );
  @override
  late final GeneratedColumn<String> stageId = GeneratedColumn<String>(
    'stage_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearIdMeta = const VerificationMeta('yearId');
  @override
  late final GeneratedColumn<String> yearId = GeneratedColumn<String>(
    'year_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<String> target = GeneratedColumn<String>(
    'target',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateKeyMeta = const VerificationMeta(
    'dateKey',
  );
  @override
  late final GeneratedColumn<String> dateKey = GeneratedColumn<String>(
    'date_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lectureNoMeta = const VerificationMeta(
    'lectureNo',
  );
  @override
  late final GeneratedColumn<int> lectureNo = GeneratedColumn<int>(
    'lecture_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openedByMeta = const VerificationMeta(
    'openedBy',
  );
  @override
  late final GeneratedColumn<String> openedBy = GeneratedColumn<String>(
    'opened_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lockAtMeta = const VerificationMeta('lockAt');
  @override
  late final GeneratedColumn<DateTime> lockAt = GeneratedColumn<DateTime>(
    'lock_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lockedMeta = const VerificationMeta('locked');
  @override
  late final GeneratedColumn<bool> locked = GeneratedColumn<bool>(
    'locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _countsJsonMeta = const VerificationMeta(
    'countsJson',
  );
  @override
  late final GeneratedColumn<String> countsJson = GeneratedColumn<String>(
    'counts_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _deviceCreatedAtMeta = const VerificationMeta(
    'deviceCreatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deviceCreatedAt =
      GeneratedColumn<DateTime>(
        'device_created_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    courseId,
    stageId,
    yearId,
    type,
    target,
    groupId,
    dateKey,
    date,
    lectureNo,
    openedBy,
    lockAt,
    locked,
    countsJson,
    deviceCreatedAt,
    savedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('course_id')) {
      context.handle(
        _courseIdMeta,
        courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_courseIdMeta);
    }
    if (data.containsKey('stage_id')) {
      context.handle(
        _stageIdMeta,
        stageId.isAcceptableOrUnknown(data['stage_id']!, _stageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_stageIdMeta);
    }
    if (data.containsKey('year_id')) {
      context.handle(
        _yearIdMeta,
        yearId.isAcceptableOrUnknown(data['year_id']!, _yearIdMeta),
      );
    } else if (isInserting) {
      context.missing(_yearIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    } else if (isInserting) {
      context.missing(_targetMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('date_key')) {
      context.handle(
        _dateKeyMeta,
        dateKey.isAcceptableOrUnknown(data['date_key']!, _dateKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dateKeyMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('lecture_no')) {
      context.handle(
        _lectureNoMeta,
        lectureNo.isAcceptableOrUnknown(data['lecture_no']!, _lectureNoMeta),
      );
    } else if (isInserting) {
      context.missing(_lectureNoMeta);
    }
    if (data.containsKey('opened_by')) {
      context.handle(
        _openedByMeta,
        openedBy.isAcceptableOrUnknown(data['opened_by']!, _openedByMeta),
      );
    } else if (isInserting) {
      context.missing(_openedByMeta);
    }
    if (data.containsKey('lock_at')) {
      context.handle(
        _lockAtMeta,
        lockAt.isAcceptableOrUnknown(data['lock_at']!, _lockAtMeta),
      );
    } else if (isInserting) {
      context.missing(_lockAtMeta);
    }
    if (data.containsKey('locked')) {
      context.handle(
        _lockedMeta,
        locked.isAcceptableOrUnknown(data['locked']!, _lockedMeta),
      );
    }
    if (data.containsKey('counts_json')) {
      context.handle(
        _countsJsonMeta,
        countsJson.isAcceptableOrUnknown(data['counts_json']!, _countsJsonMeta),
      );
    }
    if (data.containsKey('device_created_at')) {
      context.handle(
        _deviceCreatedAtMeta,
        deviceCreatedAt.isAcceptableOrUnknown(
          data['device_created_at']!,
          _deviceCreatedAtMeta,
        ),
      );
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      courseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_id'],
      )!,
      stageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage_id'],
      )!,
      yearId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}year_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      ),
      dateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_key'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      lectureNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lecture_no'],
      )!,
      openedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opened_by'],
      )!,
      lockAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}lock_at'],
      )!,
      locked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}locked'],
      )!,
      countsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}counts_json'],
      )!,
      deviceCreatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}device_created_at'],
      ),
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      ),
    );
  }

  @override
  $LocalSessionsTable createAlias(String alias) {
    return $LocalSessionsTable(attachedDatabase, alias);
  }
}

class LocalSessionRow extends DataClass implements Insertable<LocalSessionRow> {
  final String id;
  final String courseId;
  final String stageId;
  final String yearId;
  final String type;
  final String target;
  final String? groupId;
  final String dateKey;
  final DateTime date;
  final int lectureNo;
  final String openedBy;
  final DateTime lockAt;
  final bool locked;
  final String countsJson;
  final DateTime? deviceCreatedAt;

  /// Last change on this device (device clock).
  final DateTime? savedAt;
  const LocalSessionRow({
    required this.id,
    required this.courseId,
    required this.stageId,
    required this.yearId,
    required this.type,
    required this.target,
    this.groupId,
    required this.dateKey,
    required this.date,
    required this.lectureNo,
    required this.openedBy,
    required this.lockAt,
    required this.locked,
    required this.countsJson,
    this.deviceCreatedAt,
    this.savedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['course_id'] = Variable<String>(courseId);
    map['stage_id'] = Variable<String>(stageId);
    map['year_id'] = Variable<String>(yearId);
    map['type'] = Variable<String>(type);
    map['target'] = Variable<String>(target);
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    map['date_key'] = Variable<String>(dateKey);
    map['date'] = Variable<DateTime>(date);
    map['lecture_no'] = Variable<int>(lectureNo);
    map['opened_by'] = Variable<String>(openedBy);
    map['lock_at'] = Variable<DateTime>(lockAt);
    map['locked'] = Variable<bool>(locked);
    map['counts_json'] = Variable<String>(countsJson);
    if (!nullToAbsent || deviceCreatedAt != null) {
      map['device_created_at'] = Variable<DateTime>(deviceCreatedAt);
    }
    if (!nullToAbsent || savedAt != null) {
      map['saved_at'] = Variable<DateTime>(savedAt);
    }
    return map;
  }

  LocalSessionsCompanion toCompanion(bool nullToAbsent) {
    return LocalSessionsCompanion(
      id: Value(id),
      courseId: Value(courseId),
      stageId: Value(stageId),
      yearId: Value(yearId),
      type: Value(type),
      target: Value(target),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      dateKey: Value(dateKey),
      date: Value(date),
      lectureNo: Value(lectureNo),
      openedBy: Value(openedBy),
      lockAt: Value(lockAt),
      locked: Value(locked),
      countsJson: Value(countsJson),
      deviceCreatedAt: deviceCreatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceCreatedAt),
      savedAt: savedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(savedAt),
    );
  }

  factory LocalSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSessionRow(
      id: serializer.fromJson<String>(json['id']),
      courseId: serializer.fromJson<String>(json['courseId']),
      stageId: serializer.fromJson<String>(json['stageId']),
      yearId: serializer.fromJson<String>(json['yearId']),
      type: serializer.fromJson<String>(json['type']),
      target: serializer.fromJson<String>(json['target']),
      groupId: serializer.fromJson<String?>(json['groupId']),
      dateKey: serializer.fromJson<String>(json['dateKey']),
      date: serializer.fromJson<DateTime>(json['date']),
      lectureNo: serializer.fromJson<int>(json['lectureNo']),
      openedBy: serializer.fromJson<String>(json['openedBy']),
      lockAt: serializer.fromJson<DateTime>(json['lockAt']),
      locked: serializer.fromJson<bool>(json['locked']),
      countsJson: serializer.fromJson<String>(json['countsJson']),
      deviceCreatedAt: serializer.fromJson<DateTime?>(json['deviceCreatedAt']),
      savedAt: serializer.fromJson<DateTime?>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'courseId': serializer.toJson<String>(courseId),
      'stageId': serializer.toJson<String>(stageId),
      'yearId': serializer.toJson<String>(yearId),
      'type': serializer.toJson<String>(type),
      'target': serializer.toJson<String>(target),
      'groupId': serializer.toJson<String?>(groupId),
      'dateKey': serializer.toJson<String>(dateKey),
      'date': serializer.toJson<DateTime>(date),
      'lectureNo': serializer.toJson<int>(lectureNo),
      'openedBy': serializer.toJson<String>(openedBy),
      'lockAt': serializer.toJson<DateTime>(lockAt),
      'locked': serializer.toJson<bool>(locked),
      'countsJson': serializer.toJson<String>(countsJson),
      'deviceCreatedAt': serializer.toJson<DateTime?>(deviceCreatedAt),
      'savedAt': serializer.toJson<DateTime?>(savedAt),
    };
  }

  LocalSessionRow copyWith({
    String? id,
    String? courseId,
    String? stageId,
    String? yearId,
    String? type,
    String? target,
    Value<String?> groupId = const Value.absent(),
    String? dateKey,
    DateTime? date,
    int? lectureNo,
    String? openedBy,
    DateTime? lockAt,
    bool? locked,
    String? countsJson,
    Value<DateTime?> deviceCreatedAt = const Value.absent(),
    Value<DateTime?> savedAt = const Value.absent(),
  }) => LocalSessionRow(
    id: id ?? this.id,
    courseId: courseId ?? this.courseId,
    stageId: stageId ?? this.stageId,
    yearId: yearId ?? this.yearId,
    type: type ?? this.type,
    target: target ?? this.target,
    groupId: groupId.present ? groupId.value : this.groupId,
    dateKey: dateKey ?? this.dateKey,
    date: date ?? this.date,
    lectureNo: lectureNo ?? this.lectureNo,
    openedBy: openedBy ?? this.openedBy,
    lockAt: lockAt ?? this.lockAt,
    locked: locked ?? this.locked,
    countsJson: countsJson ?? this.countsJson,
    deviceCreatedAt: deviceCreatedAt.present
        ? deviceCreatedAt.value
        : this.deviceCreatedAt,
    savedAt: savedAt.present ? savedAt.value : this.savedAt,
  );
  LocalSessionRow copyWithCompanion(LocalSessionsCompanion data) {
    return LocalSessionRow(
      id: data.id.present ? data.id.value : this.id,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      stageId: data.stageId.present ? data.stageId.value : this.stageId,
      yearId: data.yearId.present ? data.yearId.value : this.yearId,
      type: data.type.present ? data.type.value : this.type,
      target: data.target.present ? data.target.value : this.target,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      dateKey: data.dateKey.present ? data.dateKey.value : this.dateKey,
      date: data.date.present ? data.date.value : this.date,
      lectureNo: data.lectureNo.present ? data.lectureNo.value : this.lectureNo,
      openedBy: data.openedBy.present ? data.openedBy.value : this.openedBy,
      lockAt: data.lockAt.present ? data.lockAt.value : this.lockAt,
      locked: data.locked.present ? data.locked.value : this.locked,
      countsJson: data.countsJson.present
          ? data.countsJson.value
          : this.countsJson,
      deviceCreatedAt: data.deviceCreatedAt.present
          ? data.deviceCreatedAt.value
          : this.deviceCreatedAt,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSessionRow(')
          ..write('id: $id, ')
          ..write('courseId: $courseId, ')
          ..write('stageId: $stageId, ')
          ..write('yearId: $yearId, ')
          ..write('type: $type, ')
          ..write('target: $target, ')
          ..write('groupId: $groupId, ')
          ..write('dateKey: $dateKey, ')
          ..write('date: $date, ')
          ..write('lectureNo: $lectureNo, ')
          ..write('openedBy: $openedBy, ')
          ..write('lockAt: $lockAt, ')
          ..write('locked: $locked, ')
          ..write('countsJson: $countsJson, ')
          ..write('deviceCreatedAt: $deviceCreatedAt, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    courseId,
    stageId,
    yearId,
    type,
    target,
    groupId,
    dateKey,
    date,
    lectureNo,
    openedBy,
    lockAt,
    locked,
    countsJson,
    deviceCreatedAt,
    savedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSessionRow &&
          other.id == this.id &&
          other.courseId == this.courseId &&
          other.stageId == this.stageId &&
          other.yearId == this.yearId &&
          other.type == this.type &&
          other.target == this.target &&
          other.groupId == this.groupId &&
          other.dateKey == this.dateKey &&
          other.date == this.date &&
          other.lectureNo == this.lectureNo &&
          other.openedBy == this.openedBy &&
          other.lockAt == this.lockAt &&
          other.locked == this.locked &&
          other.countsJson == this.countsJson &&
          other.deviceCreatedAt == this.deviceCreatedAt &&
          other.savedAt == this.savedAt);
}

class LocalSessionsCompanion extends UpdateCompanion<LocalSessionRow> {
  final Value<String> id;
  final Value<String> courseId;
  final Value<String> stageId;
  final Value<String> yearId;
  final Value<String> type;
  final Value<String> target;
  final Value<String?> groupId;
  final Value<String> dateKey;
  final Value<DateTime> date;
  final Value<int> lectureNo;
  final Value<String> openedBy;
  final Value<DateTime> lockAt;
  final Value<bool> locked;
  final Value<String> countsJson;
  final Value<DateTime?> deviceCreatedAt;
  final Value<DateTime?> savedAt;
  final Value<int> rowid;
  const LocalSessionsCompanion({
    this.id = const Value.absent(),
    this.courseId = const Value.absent(),
    this.stageId = const Value.absent(),
    this.yearId = const Value.absent(),
    this.type = const Value.absent(),
    this.target = const Value.absent(),
    this.groupId = const Value.absent(),
    this.dateKey = const Value.absent(),
    this.date = const Value.absent(),
    this.lectureNo = const Value.absent(),
    this.openedBy = const Value.absent(),
    this.lockAt = const Value.absent(),
    this.locked = const Value.absent(),
    this.countsJson = const Value.absent(),
    this.deviceCreatedAt = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSessionsCompanion.insert({
    required String id,
    required String courseId,
    required String stageId,
    required String yearId,
    required String type,
    required String target,
    this.groupId = const Value.absent(),
    required String dateKey,
    required DateTime date,
    required int lectureNo,
    required String openedBy,
    required DateTime lockAt,
    this.locked = const Value.absent(),
    this.countsJson = const Value.absent(),
    this.deviceCreatedAt = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       courseId = Value(courseId),
       stageId = Value(stageId),
       yearId = Value(yearId),
       type = Value(type),
       target = Value(target),
       dateKey = Value(dateKey),
       date = Value(date),
       lectureNo = Value(lectureNo),
       openedBy = Value(openedBy),
       lockAt = Value(lockAt);
  static Insertable<LocalSessionRow> custom({
    Expression<String>? id,
    Expression<String>? courseId,
    Expression<String>? stageId,
    Expression<String>? yearId,
    Expression<String>? type,
    Expression<String>? target,
    Expression<String>? groupId,
    Expression<String>? dateKey,
    Expression<DateTime>? date,
    Expression<int>? lectureNo,
    Expression<String>? openedBy,
    Expression<DateTime>? lockAt,
    Expression<bool>? locked,
    Expression<String>? countsJson,
    Expression<DateTime>? deviceCreatedAt,
    Expression<DateTime>? savedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (courseId != null) 'course_id': courseId,
      if (stageId != null) 'stage_id': stageId,
      if (yearId != null) 'year_id': yearId,
      if (type != null) 'type': type,
      if (target != null) 'target': target,
      if (groupId != null) 'group_id': groupId,
      if (dateKey != null) 'date_key': dateKey,
      if (date != null) 'date': date,
      if (lectureNo != null) 'lecture_no': lectureNo,
      if (openedBy != null) 'opened_by': openedBy,
      if (lockAt != null) 'lock_at': lockAt,
      if (locked != null) 'locked': locked,
      if (countsJson != null) 'counts_json': countsJson,
      if (deviceCreatedAt != null) 'device_created_at': deviceCreatedAt,
      if (savedAt != null) 'saved_at': savedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? courseId,
    Value<String>? stageId,
    Value<String>? yearId,
    Value<String>? type,
    Value<String>? target,
    Value<String?>? groupId,
    Value<String>? dateKey,
    Value<DateTime>? date,
    Value<int>? lectureNo,
    Value<String>? openedBy,
    Value<DateTime>? lockAt,
    Value<bool>? locked,
    Value<String>? countsJson,
    Value<DateTime?>? deviceCreatedAt,
    Value<DateTime?>? savedAt,
    Value<int>? rowid,
  }) {
    return LocalSessionsCompanion(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      stageId: stageId ?? this.stageId,
      yearId: yearId ?? this.yearId,
      type: type ?? this.type,
      target: target ?? this.target,
      groupId: groupId ?? this.groupId,
      dateKey: dateKey ?? this.dateKey,
      date: date ?? this.date,
      lectureNo: lectureNo ?? this.lectureNo,
      openedBy: openedBy ?? this.openedBy,
      lockAt: lockAt ?? this.lockAt,
      locked: locked ?? this.locked,
      countsJson: countsJson ?? this.countsJson,
      deviceCreatedAt: deviceCreatedAt ?? this.deviceCreatedAt,
      savedAt: savedAt ?? this.savedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<String>(courseId.value);
    }
    if (stageId.present) {
      map['stage_id'] = Variable<String>(stageId.value);
    }
    if (yearId.present) {
      map['year_id'] = Variable<String>(yearId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (target.present) {
      map['target'] = Variable<String>(target.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (dateKey.present) {
      map['date_key'] = Variable<String>(dateKey.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (lectureNo.present) {
      map['lecture_no'] = Variable<int>(lectureNo.value);
    }
    if (openedBy.present) {
      map['opened_by'] = Variable<String>(openedBy.value);
    }
    if (lockAt.present) {
      map['lock_at'] = Variable<DateTime>(lockAt.value);
    }
    if (locked.present) {
      map['locked'] = Variable<bool>(locked.value);
    }
    if (countsJson.present) {
      map['counts_json'] = Variable<String>(countsJson.value);
    }
    if (deviceCreatedAt.present) {
      map['device_created_at'] = Variable<DateTime>(deviceCreatedAt.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSessionsCompanion(')
          ..write('id: $id, ')
          ..write('courseId: $courseId, ')
          ..write('stageId: $stageId, ')
          ..write('yearId: $yearId, ')
          ..write('type: $type, ')
          ..write('target: $target, ')
          ..write('groupId: $groupId, ')
          ..write('dateKey: $dateKey, ')
          ..write('date: $date, ')
          ..write('lectureNo: $lectureNo, ')
          ..write('openedBy: $openedBy, ')
          ..write('lockAt: $lockAt, ')
          ..write('locked: $locked, ')
          ..write('countsJson: $countsJson, ')
          ..write('deviceCreatedAt: $deviceCreatedAt, ')
          ..write('savedAt: $savedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalRecordsTable extends LocalRecords
    with TableInfo<$LocalRecordsTable, LocalRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceUpdatedAtMeta = const VerificationMeta(
    'deviceUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deviceUpdatedAt =
      GeneratedColumn<DateTime>(
        'device_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    studentId,
    status,
    note,
    updatedBy,
    deviceUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedByMeta);
    }
    if (data.containsKey('device_updated_at')) {
      context.handle(
        _deviceUpdatedAtMeta,
        deviceUpdatedAt.isAcceptableOrUnknown(
          data['device_updated_at']!,
          _deviceUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, studentId};
  @override
  LocalRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalRecordRow(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      )!,
      deviceUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}device_updated_at'],
      ),
    );
  }

  @override
  $LocalRecordsTable createAlias(String alias) {
    return $LocalRecordsTable(attachedDatabase, alias);
  }
}

class LocalRecordRow extends DataClass implements Insertable<LocalRecordRow> {
  final String sessionId;
  final String studentId;
  final String status;
  final String note;
  final String updatedBy;
  final DateTime? deviceUpdatedAt;
  const LocalRecordRow({
    required this.sessionId,
    required this.studentId,
    required this.status,
    required this.note,
    required this.updatedBy,
    this.deviceUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['student_id'] = Variable<String>(studentId);
    map['status'] = Variable<String>(status);
    map['note'] = Variable<String>(note);
    map['updated_by'] = Variable<String>(updatedBy);
    if (!nullToAbsent || deviceUpdatedAt != null) {
      map['device_updated_at'] = Variable<DateTime>(deviceUpdatedAt);
    }
    return map;
  }

  LocalRecordsCompanion toCompanion(bool nullToAbsent) {
    return LocalRecordsCompanion(
      sessionId: Value(sessionId),
      studentId: Value(studentId),
      status: Value(status),
      note: Value(note),
      updatedBy: Value(updatedBy),
      deviceUpdatedAt: deviceUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceUpdatedAt),
    );
  }

  factory LocalRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalRecordRow(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      studentId: serializer.fromJson<String>(json['studentId']),
      status: serializer.fromJson<String>(json['status']),
      note: serializer.fromJson<String>(json['note']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      deviceUpdatedAt: serializer.fromJson<DateTime?>(json['deviceUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'studentId': serializer.toJson<String>(studentId),
      'status': serializer.toJson<String>(status),
      'note': serializer.toJson<String>(note),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'deviceUpdatedAt': serializer.toJson<DateTime?>(deviceUpdatedAt),
    };
  }

  LocalRecordRow copyWith({
    String? sessionId,
    String? studentId,
    String? status,
    String? note,
    String? updatedBy,
    Value<DateTime?> deviceUpdatedAt = const Value.absent(),
  }) => LocalRecordRow(
    sessionId: sessionId ?? this.sessionId,
    studentId: studentId ?? this.studentId,
    status: status ?? this.status,
    note: note ?? this.note,
    updatedBy: updatedBy ?? this.updatedBy,
    deviceUpdatedAt: deviceUpdatedAt.present
        ? deviceUpdatedAt.value
        : this.deviceUpdatedAt,
  );
  LocalRecordRow copyWithCompanion(LocalRecordsCompanion data) {
    return LocalRecordRow(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      status: data.status.present ? data.status.value : this.status,
      note: data.note.present ? data.note.value : this.note,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      deviceUpdatedAt: data.deviceUpdatedAt.present
          ? data.deviceUpdatedAt.value
          : this.deviceUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalRecordRow(')
          ..write('sessionId: $sessionId, ')
          ..write('studentId: $studentId, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceUpdatedAt: $deviceUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    studentId,
    status,
    note,
    updatedBy,
    deviceUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalRecordRow &&
          other.sessionId == this.sessionId &&
          other.studentId == this.studentId &&
          other.status == this.status &&
          other.note == this.note &&
          other.updatedBy == this.updatedBy &&
          other.deviceUpdatedAt == this.deviceUpdatedAt);
}

class LocalRecordsCompanion extends UpdateCompanion<LocalRecordRow> {
  final Value<String> sessionId;
  final Value<String> studentId;
  final Value<String> status;
  final Value<String> note;
  final Value<String> updatedBy;
  final Value<DateTime?> deviceUpdatedAt;
  final Value<int> rowid;
  const LocalRecordsCompanion({
    this.sessionId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalRecordsCompanion.insert({
    required String sessionId,
    required String studentId,
    required String status,
    this.note = const Value.absent(),
    required String updatedBy,
    this.deviceUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       studentId = Value(studentId),
       status = Value(status),
       updatedBy = Value(updatedBy);
  static Insertable<LocalRecordRow> custom({
    Expression<String>? sessionId,
    Expression<String>? studentId,
    Expression<String>? status,
    Expression<String>? note,
    Expression<String>? updatedBy,
    Expression<DateTime>? deviceUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (studentId != null) 'student_id': studentId,
      if (status != null) 'status': status,
      if (note != null) 'note': note,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (deviceUpdatedAt != null) 'device_updated_at': deviceUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalRecordsCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? studentId,
    Value<String>? status,
    Value<String>? note,
    Value<String>? updatedBy,
    Value<DateTime?>? deviceUpdatedAt,
    Value<int>? rowid,
  }) {
    return LocalRecordsCompanion(
      sessionId: sessionId ?? this.sessionId,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
      note: note ?? this.note,
      updatedBy: updatedBy ?? this.updatedBy,
      deviceUpdatedAt: deviceUpdatedAt ?? this.deviceUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (deviceUpdatedAt.present) {
      map['device_updated_at'] = Variable<DateTime>(deviceUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalRecordsCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('studentId: $studentId, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceUpdatedAt: $deviceUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxEntriesTable extends OutboxEntries
    with TableInfo<$OutboxEntriesTable, OutboxEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<OutboxOp, String> op =
      GeneratedColumn<String>(
        'op',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<OutboxOp>($OutboxEntriesTable.$converterop);
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
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
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _failedMeta = const VerificationMeta('failed');
  @override
  late final GeneratedColumn<bool> failed = GeneratedColumn<bool>(
    'failed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("failed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    batchId,
    op,
    path,
    payloadJson,
    createdAt,
    attempts,
    lastError,
    failed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
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
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('failed')) {
      context.handle(
        _failedMeta,
        failed.isAcceptableOrUnknown(data['failed']!, _failedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      op: $OutboxEntriesTable.$converterop.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}op'],
        )!,
      ),
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      failed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}failed'],
      )!,
    );
  }

  @override
  $OutboxEntriesTable createAlias(String alias) {
    return $OutboxEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<OutboxOp, String, String> $converterop =
      const EnumNameConverter<OutboxOp>(OutboxOp.values);
}

class OutboxEntry extends DataClass implements Insertable<OutboxEntry> {
  final int id;
  final String batchId;
  final OutboxOp op;
  final String path;
  final String payloadJson;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;

  /// Rejected by the server (e.g. the session locked before the upload):
  /// kept, shown to the user, skipped until they retry.
  final bool failed;
  const OutboxEntry({
    required this.id,
    required this.batchId,
    required this.op,
    required this.path,
    required this.payloadJson,
    required this.createdAt,
    required this.attempts,
    this.lastError,
    required this.failed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['batch_id'] = Variable<String>(batchId);
    {
      map['op'] = Variable<String>($OutboxEntriesTable.$converterop.toSql(op));
    }
    map['path'] = Variable<String>(path);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['failed'] = Variable<bool>(failed);
    return map;
  }

  OutboxEntriesCompanion toCompanion(bool nullToAbsent) {
    return OutboxEntriesCompanion(
      id: Value(id),
      batchId: Value(batchId),
      op: Value(op),
      path: Value(path),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      failed: Value(failed),
    );
  }

  factory OutboxEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxEntry(
      id: serializer.fromJson<int>(json['id']),
      batchId: serializer.fromJson<String>(json['batchId']),
      op: $OutboxEntriesTable.$converterop.fromJson(
        serializer.fromJson<String>(json['op']),
      ),
      path: serializer.fromJson<String>(json['path']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      failed: serializer.fromJson<bool>(json['failed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'batchId': serializer.toJson<String>(batchId),
      'op': serializer.toJson<String>(
        $OutboxEntriesTable.$converterop.toJson(op),
      ),
      'path': serializer.toJson<String>(path),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
      'failed': serializer.toJson<bool>(failed),
    };
  }

  OutboxEntry copyWith({
    int? id,
    String? batchId,
    OutboxOp? op,
    String? path,
    String? payloadJson,
    DateTime? createdAt,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
    bool? failed,
  }) => OutboxEntry(
    id: id ?? this.id,
    batchId: batchId ?? this.batchId,
    op: op ?? this.op,
    path: path ?? this.path,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    attempts: attempts ?? this.attempts,
    lastError: lastError.present ? lastError.value : this.lastError,
    failed: failed ?? this.failed,
  );
  OutboxEntry copyWithCompanion(OutboxEntriesCompanion data) {
    return OutboxEntry(
      id: data.id.present ? data.id.value : this.id,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      op: data.op.present ? data.op.value : this.op,
      path: data.path.present ? data.path.value : this.path,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      failed: data.failed.present ? data.failed.value : this.failed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntry(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('op: $op, ')
          ..write('path: $path, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('failed: $failed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    batchId,
    op,
    path,
    payloadJson,
    createdAt,
    attempts,
    lastError,
    failed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxEntry &&
          other.id == this.id &&
          other.batchId == this.batchId &&
          other.op == this.op &&
          other.path == this.path &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError &&
          other.failed == this.failed);
}

class OutboxEntriesCompanion extends UpdateCompanion<OutboxEntry> {
  final Value<int> id;
  final Value<String> batchId;
  final Value<OutboxOp> op;
  final Value<String> path;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<int> attempts;
  final Value<String?> lastError;
  final Value<bool> failed;
  const OutboxEntriesCompanion({
    this.id = const Value.absent(),
    this.batchId = const Value.absent(),
    this.op = const Value.absent(),
    this.path = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.failed = const Value.absent(),
  });
  OutboxEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String batchId,
    required OutboxOp op,
    required String path,
    this.payloadJson = const Value.absent(),
    required DateTime createdAt,
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.failed = const Value.absent(),
  }) : batchId = Value(batchId),
       op = Value(op),
       path = Value(path),
       createdAt = Value(createdAt);
  static Insertable<OutboxEntry> custom({
    Expression<int>? id,
    Expression<String>? batchId,
    Expression<String>? op,
    Expression<String>? path,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<int>? attempts,
    Expression<String>? lastError,
    Expression<bool>? failed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (batchId != null) 'batch_id': batchId,
      if (op != null) 'op': op,
      if (path != null) 'path': path,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
      if (failed != null) 'failed': failed,
    });
  }

  OutboxEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? batchId,
    Value<OutboxOp>? op,
    Value<String>? path,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
    Value<int>? attempts,
    Value<String?>? lastError,
    Value<bool>? failed,
  }) {
    return OutboxEntriesCompanion(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      op: op ?? this.op,
      path: path ?? this.path,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      failed: failed ?? this.failed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (op.present) {
      map['op'] = Variable<String>(
        $OutboxEntriesTable.$converterop.toSql(op.value),
      );
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (failed.present) {
      map['failed'] = Variable<bool>(failed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntriesCompanion(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('op: $op, ')
          ..write('path: $path, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('failed: $failed')
          ..write(')'))
        .toString();
  }
}

class $SyncStatesTable extends SyncStates
    with TableInfo<$SyncStatesTable, SyncStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStatesTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'sync_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateRow> instance, {
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
  SyncStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateRow(
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
  $SyncStatesTable createAlias(String alias) {
    return $SyncStatesTable(attachedDatabase, alias);
  }
}

class SyncStateRow extends DataClass implements Insertable<SyncStateRow> {
  final String key;
  final String value;
  const SyncStateRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SyncStatesCompanion toCompanion(bool nullToAbsent) {
    return SyncStatesCompanion(key: Value(key), value: Value(value));
  }

  factory SyncStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateRow(
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

  SyncStateRow copyWith({String? key, String? value}) =>
      SyncStateRow(key: key ?? this.key, value: value ?? this.value);
  SyncStateRow copyWithCompanion(SyncStatesCompanion data) {
    return SyncStateRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateRow(')
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
      (other is SyncStateRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SyncStatesCompanion extends UpdateCompanion<SyncStateRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SyncStatesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStatesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SyncStateRow> custom({
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

  SyncStatesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SyncStatesCompanion(
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
    return (StringBuffer('SyncStatesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalStudentsTable localStudents = $LocalStudentsTable(this);
  late final $LocalCoursesTable localCourses = $LocalCoursesTable(this);
  late final $LocalGroupsTable localGroups = $LocalGroupsTable(this);
  late final $LocalAssignmentsTable localAssignments = $LocalAssignmentsTable(
    this,
  );
  late final $LocalSessionsTable localSessions = $LocalSessionsTable(this);
  late final $LocalRecordsTable localRecords = $LocalRecordsTable(this);
  late final $OutboxEntriesTable outboxEntries = $OutboxEntriesTable(this);
  late final $SyncStatesTable syncStates = $SyncStatesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localStudents,
    localCourses,
    localGroups,
    localAssignments,
    localSessions,
    localRecords,
    outboxEntries,
    syncStates,
  ];
}

typedef $$LocalStudentsTableCreateCompanionBuilder =
    LocalStudentsCompanion Function({
      required String id,
      required String universityId,
      required String fullName,
      required String stageId,
      Value<String> section,
      required String status,
      Value<bool> carryOver,
      required String sortKey,
      Value<int> rowid,
    });
typedef $$LocalStudentsTableUpdateCompanionBuilder =
    LocalStudentsCompanion Function({
      Value<String> id,
      Value<String> universityId,
      Value<String> fullName,
      Value<String> stageId,
      Value<String> section,
      Value<String> status,
      Value<bool> carryOver,
      Value<String> sortKey,
      Value<int> rowid,
    });

class $$LocalStudentsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalStudentsTable> {
  $$LocalStudentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get universityId => $composableBuilder(
    column: $table.universityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stageId => $composableBuilder(
    column: $table.stageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get section => $composableBuilder(
    column: $table.section,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get carryOver => $composableBuilder(
    column: $table.carryOver,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sortKey => $composableBuilder(
    column: $table.sortKey,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalStudentsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalStudentsTable> {
  $$LocalStudentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get universityId => $composableBuilder(
    column: $table.universityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stageId => $composableBuilder(
    column: $table.stageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get section => $composableBuilder(
    column: $table.section,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get carryOver => $composableBuilder(
    column: $table.carryOver,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sortKey => $composableBuilder(
    column: $table.sortKey,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalStudentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalStudentsTable> {
  $$LocalStudentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get universityId => $composableBuilder(
    column: $table.universityId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get stageId =>
      $composableBuilder(column: $table.stageId, builder: (column) => column);

  GeneratedColumn<String> get section =>
      $composableBuilder(column: $table.section, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get carryOver =>
      $composableBuilder(column: $table.carryOver, builder: (column) => column);

  GeneratedColumn<String> get sortKey =>
      $composableBuilder(column: $table.sortKey, builder: (column) => column);
}

class $$LocalStudentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalStudentsTable,
          LocalStudentRow,
          $$LocalStudentsTableFilterComposer,
          $$LocalStudentsTableOrderingComposer,
          $$LocalStudentsTableAnnotationComposer,
          $$LocalStudentsTableCreateCompanionBuilder,
          $$LocalStudentsTableUpdateCompanionBuilder,
          (
            LocalStudentRow,
            BaseReferences<_$AppDatabase, $LocalStudentsTable, LocalStudentRow>,
          ),
          LocalStudentRow,
          PrefetchHooks Function()
        > {
  $$LocalStudentsTableTableManager(_$AppDatabase db, $LocalStudentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalStudentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalStudentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalStudentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> universityId = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String> stageId = const Value.absent(),
                Value<String> section = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> carryOver = const Value.absent(),
                Value<String> sortKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalStudentsCompanion(
                id: id,
                universityId: universityId,
                fullName: fullName,
                stageId: stageId,
                section: section,
                status: status,
                carryOver: carryOver,
                sortKey: sortKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String universityId,
                required String fullName,
                required String stageId,
                Value<String> section = const Value.absent(),
                required String status,
                Value<bool> carryOver = const Value.absent(),
                required String sortKey,
                Value<int> rowid = const Value.absent(),
              }) => LocalStudentsCompanion.insert(
                id: id,
                universityId: universityId,
                fullName: fullName,
                stageId: stageId,
                section: section,
                status: status,
                carryOver: carryOver,
                sortKey: sortKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalStudentsTable, LocalStudentRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalStudentsTable,
                    LocalStudentRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalStudentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalStudentsTable,
      LocalStudentRow,
      $$LocalStudentsTableFilterComposer,
      $$LocalStudentsTableOrderingComposer,
      $$LocalStudentsTableAnnotationComposer,
      $$LocalStudentsTableCreateCompanionBuilder,
      $$LocalStudentsTableUpdateCompanionBuilder,
      (
        LocalStudentRow,
        BaseReferences<_$AppDatabase, $LocalStudentsTable, LocalStudentRow>,
      ),
      LocalStudentRow,
      PrefetchHooks Function()
    >;
typedef $$LocalCoursesTableCreateCompanionBuilder =
    LocalCoursesCompanion Function({
      required String id,
      required String code,
      required String name,
      required String stageId,
      required int semester,
      required int units,
      required bool hasPractical,
      Value<int> rowid,
    });
typedef $$LocalCoursesTableUpdateCompanionBuilder =
    LocalCoursesCompanion Function({
      Value<String> id,
      Value<String> code,
      Value<String> name,
      Value<String> stageId,
      Value<int> semester,
      Value<int> units,
      Value<bool> hasPractical,
      Value<int> rowid,
    });

class $$LocalCoursesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalCoursesTable> {
  $$LocalCoursesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stageId => $composableBuilder(
    column: $table.stageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get semester => $composableBuilder(
    column: $table.semester,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get units => $composableBuilder(
    column: $table.units,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasPractical => $composableBuilder(
    column: $table.hasPractical,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalCoursesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalCoursesTable> {
  $$LocalCoursesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stageId => $composableBuilder(
    column: $table.stageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get semester => $composableBuilder(
    column: $table.semester,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get units => $composableBuilder(
    column: $table.units,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasPractical => $composableBuilder(
    column: $table.hasPractical,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalCoursesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalCoursesTable> {
  $$LocalCoursesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get stageId =>
      $composableBuilder(column: $table.stageId, builder: (column) => column);

  GeneratedColumn<int> get semester =>
      $composableBuilder(column: $table.semester, builder: (column) => column);

  GeneratedColumn<int> get units =>
      $composableBuilder(column: $table.units, builder: (column) => column);

  GeneratedColumn<bool> get hasPractical => $composableBuilder(
    column: $table.hasPractical,
    builder: (column) => column,
  );
}

class $$LocalCoursesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalCoursesTable,
          LocalCourseRow,
          $$LocalCoursesTableFilterComposer,
          $$LocalCoursesTableOrderingComposer,
          $$LocalCoursesTableAnnotationComposer,
          $$LocalCoursesTableCreateCompanionBuilder,
          $$LocalCoursesTableUpdateCompanionBuilder,
          (
            LocalCourseRow,
            BaseReferences<_$AppDatabase, $LocalCoursesTable, LocalCourseRow>,
          ),
          LocalCourseRow,
          PrefetchHooks Function()
        > {
  $$LocalCoursesTableTableManager(_$AppDatabase db, $LocalCoursesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCoursesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCoursesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCoursesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> stageId = const Value.absent(),
                Value<int> semester = const Value.absent(),
                Value<int> units = const Value.absent(),
                Value<bool> hasPractical = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCoursesCompanion(
                id: id,
                code: code,
                name: name,
                stageId: stageId,
                semester: semester,
                units: units,
                hasPractical: hasPractical,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String code,
                required String name,
                required String stageId,
                required int semester,
                required int units,
                required bool hasPractical,
                Value<int> rowid = const Value.absent(),
              }) => LocalCoursesCompanion.insert(
                id: id,
                code: code,
                name: name,
                stageId: stageId,
                semester: semester,
                units: units,
                hasPractical: hasPractical,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalCoursesTable, LocalCourseRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalCoursesTable,
                    LocalCourseRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalCoursesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalCoursesTable,
      LocalCourseRow,
      $$LocalCoursesTableFilterComposer,
      $$LocalCoursesTableOrderingComposer,
      $$LocalCoursesTableAnnotationComposer,
      $$LocalCoursesTableCreateCompanionBuilder,
      $$LocalCoursesTableUpdateCompanionBuilder,
      (
        LocalCourseRow,
        BaseReferences<_$AppDatabase, $LocalCoursesTable, LocalCourseRow>,
      ),
      LocalCourseRow,
      PrefetchHooks Function()
    >;
typedef $$LocalGroupsTableCreateCompanionBuilder =
    LocalGroupsCompanion Function({
      required String id,
      required String courseId,
      required String stageId,
      required String name,
      Value<String> studentIdsJson,
      Value<int> rowid,
    });
typedef $$LocalGroupsTableUpdateCompanionBuilder =
    LocalGroupsCompanion Function({
      Value<String> id,
      Value<String> courseId,
      Value<String> stageId,
      Value<String> name,
      Value<String> studentIdsJson,
      Value<int> rowid,
    });

class $$LocalGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalGroupsTable> {
  $$LocalGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stageId => $composableBuilder(
    column: $table.stageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentIdsJson => $composableBuilder(
    column: $table.studentIdsJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalGroupsTable> {
  $$LocalGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stageId => $composableBuilder(
    column: $table.stageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentIdsJson => $composableBuilder(
    column: $table.studentIdsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalGroupsTable> {
  $$LocalGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get courseId =>
      $composableBuilder(column: $table.courseId, builder: (column) => column);

  GeneratedColumn<String> get stageId =>
      $composableBuilder(column: $table.stageId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get studentIdsJson => $composableBuilder(
    column: $table.studentIdsJson,
    builder: (column) => column,
  );
}

class $$LocalGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalGroupsTable,
          LocalGroupRow,
          $$LocalGroupsTableFilterComposer,
          $$LocalGroupsTableOrderingComposer,
          $$LocalGroupsTableAnnotationComposer,
          $$LocalGroupsTableCreateCompanionBuilder,
          $$LocalGroupsTableUpdateCompanionBuilder,
          (
            LocalGroupRow,
            BaseReferences<_$AppDatabase, $LocalGroupsTable, LocalGroupRow>,
          ),
          LocalGroupRow,
          PrefetchHooks Function()
        > {
  $$LocalGroupsTableTableManager(_$AppDatabase db, $LocalGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> courseId = const Value.absent(),
                Value<String> stageId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> studentIdsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalGroupsCompanion(
                id: id,
                courseId: courseId,
                stageId: stageId,
                name: name,
                studentIdsJson: studentIdsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String courseId,
                required String stageId,
                required String name,
                Value<String> studentIdsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalGroupsCompanion.insert(
                id: id,
                courseId: courseId,
                stageId: stageId,
                name: name,
                studentIdsJson: studentIdsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalGroupsTable, LocalGroupRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalGroupsTable,
                    LocalGroupRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalGroupsTable,
      LocalGroupRow,
      $$LocalGroupsTableFilterComposer,
      $$LocalGroupsTableOrderingComposer,
      $$LocalGroupsTableAnnotationComposer,
      $$LocalGroupsTableCreateCompanionBuilder,
      $$LocalGroupsTableUpdateCompanionBuilder,
      (
        LocalGroupRow,
        BaseReferences<_$AppDatabase, $LocalGroupsTable, LocalGroupRow>,
      ),
      LocalGroupRow,
      PrefetchHooks Function()
    >;
typedef $$LocalAssignmentsTableCreateCompanionBuilder =
    LocalAssignmentsCompanion Function({
      required String id,
      required String teacherId,
      required String courseId,
      required String stageId,
      required String type,
      required String target,
      Value<String?> groupId,
      Value<String> courseName,
      Value<String> teacherName,
      Value<int> rowid,
    });
typedef $$LocalAssignmentsTableUpdateCompanionBuilder =
    LocalAssignmentsCompanion Function({
      Value<String> id,
      Value<String> teacherId,
      Value<String> courseId,
      Value<String> stageId,
      Value<String> type,
      Value<String> target,
      Value<String?> groupId,
      Value<String> courseName,
      Value<String> teacherName,
      Value<int> rowid,
    });

class $$LocalAssignmentsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAssignmentsTable> {
  $$LocalAssignmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teacherId => $composableBuilder(
    column: $table.teacherId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stageId => $composableBuilder(
    column: $table.stageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teacherName => $composableBuilder(
    column: $table.teacherName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAssignmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAssignmentsTable> {
  $$LocalAssignmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teacherId => $composableBuilder(
    column: $table.teacherId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stageId => $composableBuilder(
    column: $table.stageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teacherName => $composableBuilder(
    column: $table.teacherName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAssignmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAssignmentsTable> {
  $$LocalAssignmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get teacherId =>
      $composableBuilder(column: $table.teacherId, builder: (column) => column);

  GeneratedColumn<String> get courseId =>
      $composableBuilder(column: $table.courseId, builder: (column) => column);

  GeneratedColumn<String> get stageId =>
      $composableBuilder(column: $table.stageId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get teacherName => $composableBuilder(
    column: $table.teacherName,
    builder: (column) => column,
  );
}

class $$LocalAssignmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAssignmentsTable,
          LocalAssignmentRow,
          $$LocalAssignmentsTableFilterComposer,
          $$LocalAssignmentsTableOrderingComposer,
          $$LocalAssignmentsTableAnnotationComposer,
          $$LocalAssignmentsTableCreateCompanionBuilder,
          $$LocalAssignmentsTableUpdateCompanionBuilder,
          (
            LocalAssignmentRow,
            BaseReferences<
              _$AppDatabase,
              $LocalAssignmentsTable,
              LocalAssignmentRow
            >,
          ),
          LocalAssignmentRow,
          PrefetchHooks Function()
        > {
  $$LocalAssignmentsTableTableManager(
    _$AppDatabase db,
    $LocalAssignmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAssignmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAssignmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAssignmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> teacherId = const Value.absent(),
                Value<String> courseId = const Value.absent(),
                Value<String> stageId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> target = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<String> courseName = const Value.absent(),
                Value<String> teacherName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAssignmentsCompanion(
                id: id,
                teacherId: teacherId,
                courseId: courseId,
                stageId: stageId,
                type: type,
                target: target,
                groupId: groupId,
                courseName: courseName,
                teacherName: teacherName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String teacherId,
                required String courseId,
                required String stageId,
                required String type,
                required String target,
                Value<String?> groupId = const Value.absent(),
                Value<String> courseName = const Value.absent(),
                Value<String> teacherName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAssignmentsCompanion.insert(
                id: id,
                teacherId: teacherId,
                courseId: courseId,
                stageId: stageId,
                type: type,
                target: target,
                groupId: groupId,
                courseName: courseName,
                teacherName: teacherName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalAssignmentsTable, LocalAssignmentRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalAssignmentsTable,
                    LocalAssignmentRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAssignmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAssignmentsTable,
      LocalAssignmentRow,
      $$LocalAssignmentsTableFilterComposer,
      $$LocalAssignmentsTableOrderingComposer,
      $$LocalAssignmentsTableAnnotationComposer,
      $$LocalAssignmentsTableCreateCompanionBuilder,
      $$LocalAssignmentsTableUpdateCompanionBuilder,
      (
        LocalAssignmentRow,
        BaseReferences<
          _$AppDatabase,
          $LocalAssignmentsTable,
          LocalAssignmentRow
        >,
      ),
      LocalAssignmentRow,
      PrefetchHooks Function()
    >;
typedef $$LocalSessionsTableCreateCompanionBuilder =
    LocalSessionsCompanion Function({
      required String id,
      required String courseId,
      required String stageId,
      required String yearId,
      required String type,
      required String target,
      Value<String?> groupId,
      required String dateKey,
      required DateTime date,
      required int lectureNo,
      required String openedBy,
      required DateTime lockAt,
      Value<bool> locked,
      Value<String> countsJson,
      Value<DateTime?> deviceCreatedAt,
      Value<DateTime?> savedAt,
      Value<int> rowid,
    });
typedef $$LocalSessionsTableUpdateCompanionBuilder =
    LocalSessionsCompanion Function({
      Value<String> id,
      Value<String> courseId,
      Value<String> stageId,
      Value<String> yearId,
      Value<String> type,
      Value<String> target,
      Value<String?> groupId,
      Value<String> dateKey,
      Value<DateTime> date,
      Value<int> lectureNo,
      Value<String> openedBy,
      Value<DateTime> lockAt,
      Value<bool> locked,
      Value<String> countsJson,
      Value<DateTime?> deviceCreatedAt,
      Value<DateTime?> savedAt,
      Value<int> rowid,
    });

class $$LocalSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSessionsTable> {
  $$LocalSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stageId => $composableBuilder(
    column: $table.stageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get yearId => $composableBuilder(
    column: $table.yearId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lectureNo => $composableBuilder(
    column: $table.lectureNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openedBy => $composableBuilder(
    column: $table.openedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lockAt => $composableBuilder(
    column: $table.lockAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get countsJson => $composableBuilder(
    column: $table.countsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deviceCreatedAt => $composableBuilder(
    column: $table.deviceCreatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSessionsTable> {
  $$LocalSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stageId => $composableBuilder(
    column: $table.stageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get yearId => $composableBuilder(
    column: $table.yearId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lectureNo => $composableBuilder(
    column: $table.lectureNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openedBy => $composableBuilder(
    column: $table.openedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lockAt => $composableBuilder(
    column: $table.lockAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get countsJson => $composableBuilder(
    column: $table.countsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deviceCreatedAt => $composableBuilder(
    column: $table.deviceCreatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSessionsTable> {
  $$LocalSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get courseId =>
      $composableBuilder(column: $table.courseId, builder: (column) => column);

  GeneratedColumn<String> get stageId =>
      $composableBuilder(column: $table.stageId, builder: (column) => column);

  GeneratedColumn<String> get yearId =>
      $composableBuilder(column: $table.yearId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get dateKey =>
      $composableBuilder(column: $table.dateKey, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get lectureNo =>
      $composableBuilder(column: $table.lectureNo, builder: (column) => column);

  GeneratedColumn<String> get openedBy =>
      $composableBuilder(column: $table.openedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get lockAt =>
      $composableBuilder(column: $table.lockAt, builder: (column) => column);

  GeneratedColumn<bool> get locked =>
      $composableBuilder(column: $table.locked, builder: (column) => column);

  GeneratedColumn<String> get countsJson => $composableBuilder(
    column: $table.countsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deviceCreatedAt => $composableBuilder(
    column: $table.deviceCreatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);
}

class $$LocalSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSessionsTable,
          LocalSessionRow,
          $$LocalSessionsTableFilterComposer,
          $$LocalSessionsTableOrderingComposer,
          $$LocalSessionsTableAnnotationComposer,
          $$LocalSessionsTableCreateCompanionBuilder,
          $$LocalSessionsTableUpdateCompanionBuilder,
          (
            LocalSessionRow,
            BaseReferences<_$AppDatabase, $LocalSessionsTable, LocalSessionRow>,
          ),
          LocalSessionRow,
          PrefetchHooks Function()
        > {
  $$LocalSessionsTableTableManager(_$AppDatabase db, $LocalSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> courseId = const Value.absent(),
                Value<String> stageId = const Value.absent(),
                Value<String> yearId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> target = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<String> dateKey = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> lectureNo = const Value.absent(),
                Value<String> openedBy = const Value.absent(),
                Value<DateTime> lockAt = const Value.absent(),
                Value<bool> locked = const Value.absent(),
                Value<String> countsJson = const Value.absent(),
                Value<DateTime?> deviceCreatedAt = const Value.absent(),
                Value<DateTime?> savedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSessionsCompanion(
                id: id,
                courseId: courseId,
                stageId: stageId,
                yearId: yearId,
                type: type,
                target: target,
                groupId: groupId,
                dateKey: dateKey,
                date: date,
                lectureNo: lectureNo,
                openedBy: openedBy,
                lockAt: lockAt,
                locked: locked,
                countsJson: countsJson,
                deviceCreatedAt: deviceCreatedAt,
                savedAt: savedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String courseId,
                required String stageId,
                required String yearId,
                required String type,
                required String target,
                Value<String?> groupId = const Value.absent(),
                required String dateKey,
                required DateTime date,
                required int lectureNo,
                required String openedBy,
                required DateTime lockAt,
                Value<bool> locked = const Value.absent(),
                Value<String> countsJson = const Value.absent(),
                Value<DateTime?> deviceCreatedAt = const Value.absent(),
                Value<DateTime?> savedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSessionsCompanion.insert(
                id: id,
                courseId: courseId,
                stageId: stageId,
                yearId: yearId,
                type: type,
                target: target,
                groupId: groupId,
                dateKey: dateKey,
                date: date,
                lectureNo: lectureNo,
                openedBy: openedBy,
                lockAt: lockAt,
                locked: locked,
                countsJson: countsJson,
                deviceCreatedAt: deviceCreatedAt,
                savedAt: savedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalSessionsTable, LocalSessionRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalSessionsTable,
                    LocalSessionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSessionsTable,
      LocalSessionRow,
      $$LocalSessionsTableFilterComposer,
      $$LocalSessionsTableOrderingComposer,
      $$LocalSessionsTableAnnotationComposer,
      $$LocalSessionsTableCreateCompanionBuilder,
      $$LocalSessionsTableUpdateCompanionBuilder,
      (
        LocalSessionRow,
        BaseReferences<_$AppDatabase, $LocalSessionsTable, LocalSessionRow>,
      ),
      LocalSessionRow,
      PrefetchHooks Function()
    >;
typedef $$LocalRecordsTableCreateCompanionBuilder =
    LocalRecordsCompanion Function({
      required String sessionId,
      required String studentId,
      required String status,
      Value<String> note,
      required String updatedBy,
      Value<DateTime?> deviceUpdatedAt,
      Value<int> rowid,
    });
typedef $$LocalRecordsTableUpdateCompanionBuilder =
    LocalRecordsCompanion Function({
      Value<String> sessionId,
      Value<String> studentId,
      Value<String> status,
      Value<String> note,
      Value<String> updatedBy,
      Value<DateTime?> deviceUpdatedAt,
      Value<int> rowid,
    });

class $$LocalRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalRecordsTable> {
  $$LocalRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deviceUpdatedAt => $composableBuilder(
    column: $table.deviceUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalRecordsTable> {
  $$LocalRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deviceUpdatedAt => $composableBuilder(
    column: $table.deviceUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalRecordsTable> {
  $$LocalRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get deviceUpdatedAt => $composableBuilder(
    column: $table.deviceUpdatedAt,
    builder: (column) => column,
  );
}

class $$LocalRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalRecordsTable,
          LocalRecordRow,
          $$LocalRecordsTableFilterComposer,
          $$LocalRecordsTableOrderingComposer,
          $$LocalRecordsTableAnnotationComposer,
          $$LocalRecordsTableCreateCompanionBuilder,
          $$LocalRecordsTableUpdateCompanionBuilder,
          (
            LocalRecordRow,
            BaseReferences<_$AppDatabase, $LocalRecordsTable, LocalRecordRow>,
          ),
          LocalRecordRow,
          PrefetchHooks Function()
        > {
  $$LocalRecordsTableTableManager(_$AppDatabase db, $LocalRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<DateTime?> deviceUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalRecordsCompanion(
                sessionId: sessionId,
                studentId: studentId,
                status: status,
                note: note,
                updatedBy: updatedBy,
                deviceUpdatedAt: deviceUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required String studentId,
                required String status,
                Value<String> note = const Value.absent(),
                required String updatedBy,
                Value<DateTime?> deviceUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalRecordsCompanion.insert(
                sessionId: sessionId,
                studentId: studentId,
                status: status,
                note: note,
                updatedBy: updatedBy,
                deviceUpdatedAt: deviceUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalRecordsTable, LocalRecordRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalRecordsTable,
                    LocalRecordRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalRecordsTable,
      LocalRecordRow,
      $$LocalRecordsTableFilterComposer,
      $$LocalRecordsTableOrderingComposer,
      $$LocalRecordsTableAnnotationComposer,
      $$LocalRecordsTableCreateCompanionBuilder,
      $$LocalRecordsTableUpdateCompanionBuilder,
      (
        LocalRecordRow,
        BaseReferences<_$AppDatabase, $LocalRecordsTable, LocalRecordRow>,
      ),
      LocalRecordRow,
      PrefetchHooks Function()
    >;
typedef $$OutboxEntriesTableCreateCompanionBuilder =
    OutboxEntriesCompanion Function({
      Value<int> id,
      required String batchId,
      required OutboxOp op,
      required String path,
      Value<String> payloadJson,
      required DateTime createdAt,
      Value<int> attempts,
      Value<String?> lastError,
      Value<bool> failed,
    });
typedef $$OutboxEntriesTableUpdateCompanionBuilder =
    OutboxEntriesCompanion Function({
      Value<int> id,
      Value<String> batchId,
      Value<OutboxOp> op,
      Value<String> path,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
      Value<int> attempts,
      Value<String?> lastError,
      Value<bool> failed,
    });

class $$OutboxEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableFilterComposer({
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

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<OutboxOp, OutboxOp, String> get op =>
      $composableBuilder(
        column: $table.op,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get failed => $composableBuilder(
    column: $table.failed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get failed => $composableBuilder(
    column: $table.failed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<OutboxOp, String> get op =>
      $composableBuilder(column: $table.op, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<bool> get failed =>
      $composableBuilder(column: $table.failed, builder: (column) => column);
}

class $$OutboxEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxEntriesTable,
          OutboxEntry,
          $$OutboxEntriesTableFilterComposer,
          $$OutboxEntriesTableOrderingComposer,
          $$OutboxEntriesTableAnnotationComposer,
          $$OutboxEntriesTableCreateCompanionBuilder,
          $$OutboxEntriesTableUpdateCompanionBuilder,
          (
            OutboxEntry,
            BaseReferences<_$AppDatabase, $OutboxEntriesTable, OutboxEntry>,
          ),
          OutboxEntry,
          PrefetchHooks Function()
        > {
  $$OutboxEntriesTableTableManager(_$AppDatabase db, $OutboxEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<OutboxOp> op = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> failed = const Value.absent(),
              }) => OutboxEntriesCompanion(
                id: id,
                batchId: batchId,
                op: op,
                path: path,
                payloadJson: payloadJson,
                createdAt: createdAt,
                attempts: attempts,
                lastError: lastError,
                failed: failed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String batchId,
                required OutboxOp op,
                required String path,
                Value<String> payloadJson = const Value.absent(),
                required DateTime createdAt,
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> failed = const Value.absent(),
              }) => OutboxEntriesCompanion.insert(
                id: id,
                batchId: batchId,
                op: op,
                path: path,
                payloadJson: payloadJson,
                createdAt: createdAt,
                attempts: attempts,
                lastError: lastError,
                failed: failed,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutboxEntriesTable, OutboxEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $OutboxEntriesTable,
                    OutboxEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxEntriesTable,
      OutboxEntry,
      $$OutboxEntriesTableFilterComposer,
      $$OutboxEntriesTableOrderingComposer,
      $$OutboxEntriesTableAnnotationComposer,
      $$OutboxEntriesTableCreateCompanionBuilder,
      $$OutboxEntriesTableUpdateCompanionBuilder,
      (
        OutboxEntry,
        BaseReferences<_$AppDatabase, $OutboxEntriesTable, OutboxEntry>,
      ),
      OutboxEntry,
      PrefetchHooks Function()
    >;
typedef $$SyncStatesTableCreateCompanionBuilder = SyncStatesCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SyncStatesTableUpdateCompanionBuilder = SyncStatesCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SyncStatesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableFilterComposer({
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

class $$SyncStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableOrderingComposer({
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

class $$SyncStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableAnnotationComposer({
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

class $$SyncStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStatesTable,
          SyncStateRow,
          $$SyncStatesTableFilterComposer,
          $$SyncStatesTableOrderingComposer,
          $$SyncStatesTableAnnotationComposer,
          $$SyncStatesTableCreateCompanionBuilder,
          $$SyncStatesTableUpdateCompanionBuilder,
          (
            SyncStateRow,
            BaseReferences<_$AppDatabase, $SyncStatesTable, SyncStateRow>,
          ),
          SyncStateRow,
          PrefetchHooks Function()
        > {
  $$SyncStatesTableTableManager(_$AppDatabase db, $SyncStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SyncStatesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SyncStatesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncStatesTable, SyncStateRow>(table),
                  BaseReferences<_$AppDatabase, $SyncStatesTable, SyncStateRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStatesTable,
      SyncStateRow,
      $$SyncStatesTableFilterComposer,
      $$SyncStatesTableOrderingComposer,
      $$SyncStatesTableAnnotationComposer,
      $$SyncStatesTableCreateCompanionBuilder,
      $$SyncStatesTableUpdateCompanionBuilder,
      (
        SyncStateRow,
        BaseReferences<_$AppDatabase, $SyncStatesTable, SyncStateRow>,
      ),
      SyncStateRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalStudentsTableTableManager get localStudents =>
      $$LocalStudentsTableTableManager(_db, _db.localStudents);
  $$LocalCoursesTableTableManager get localCourses =>
      $$LocalCoursesTableTableManager(_db, _db.localCourses);
  $$LocalGroupsTableTableManager get localGroups =>
      $$LocalGroupsTableTableManager(_db, _db.localGroups);
  $$LocalAssignmentsTableTableManager get localAssignments =>
      $$LocalAssignmentsTableTableManager(_db, _db.localAssignments);
  $$LocalSessionsTableTableManager get localSessions =>
      $$LocalSessionsTableTableManager(_db, _db.localSessions);
  $$LocalRecordsTableTableManager get localRecords =>
      $$LocalRecordsTableTableManager(_db, _db.localRecords);
  $$OutboxEntriesTableTableManager get outboxEntries =>
      $$OutboxEntriesTableTableManager(_db, _db.outboxEntries);
  $$SyncStatesTableTableManager get syncStates =>
      $$SyncStatesTableTableManager(_db, _db.syncStates);
}
