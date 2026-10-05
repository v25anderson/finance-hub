// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    name,
    color,
    icon,
    isDefault,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String deviceId;
  final String name;
  final int color;
  final String icon;
  final bool isDefault;
  final int sortOrder;
  const CategoryRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.deviceId,
    required this.name,
    required this.color,
    required this.icon,
    required this.isDefault,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    map['device_id'] = Variable<String>(deviceId);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<int>(color);
    map['icon'] = Variable<String>(icon);
    map['is_default'] = Variable<bool>(isDefault);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      deviceId: Value(deviceId),
      name: Value(name),
      color: Value(color),
      icon: Value(icon),
      isDefault: Value(isDefault),
      sortOrder: Value(sortOrder),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int>(json['color']),
      icon: serializer.fromJson<String>(json['icon']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String>(deviceId),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int>(color),
      'icon': serializer.toJson<String>(icon),
      'isDefault': serializer.toJson<bool>(isDefault),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  CategoryRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
    String? deviceId,
    String? name,
    int? color,
    String? icon,
    bool? isDefault,
    int? sortOrder,
  }) => CategoryRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    deviceId: deviceId ?? this.deviceId,
    name: name ?? this.name,
    color: color ?? this.color,
    icon: icon ?? this.icon,
    isDefault: isDefault ?? this.isDefault,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('isDefault: $isDefault, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    name,
    color,
    icon,
    isDefault,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.deviceId == this.deviceId &&
          other.name == this.name &&
          other.color == this.color &&
          other.icon == this.icon &&
          other.isDefault == this.isDefault &&
          other.sortOrder == this.sortOrder);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<String> deviceId;
  final Value<String> name;
  final Value<int> color;
  final Value<String> icon;
  final Value<bool> isDefault;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    required String name,
    required int color,
    required String icon,
    this.isDefault = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       color = Value(color),
       icon = Value(icon);
  static Insertable<CategoryRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<String>? name,
    Expression<int>? color,
    Expression<String>? icon,
    Expression<bool>? isDefault,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (isDefault != null) 'is_default': isDefault,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<String>? deviceId,
    Value<String>? name,
    Value<int>? color,
    Value<String>? icon,
    Value<bool>? isDefault,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('isDefault: $isDefault, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringTransactionsTable extends RecurringTransactions
    with TableInfo<$RecurringTransactionsTable, RecurringRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
  static const VerificationMeta _baseAmountCentsMeta = const VerificationMeta(
    'baseAmountCents',
  );
  @override
  late final GeneratedColumn<int> baseAmountCents = GeneratedColumn<int>(
    'base_amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ExpenseType, String> expenseType =
      GeneratedColumn<String>(
        'expense_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ExpenseType>(
        $RecurringTransactionsTable.$converterexpenseType,
      );
  @override
  late final GeneratedColumnWithTypeConverter<Frequency, String> frequency =
      GeneratedColumn<String>(
        'frequency',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Frequency>(
        $RecurringTransactionsTable.$converterfrequency,
      );
  static const VerificationMeta _intervalCountMeta = const VerificationMeta(
    'intervalCount',
  );
  @override
  late final GeneratedColumn<int> intervalCount = GeneratedColumn<int>(
    'interval_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _dueDayMeta = const VerificationMeta('dueDay');
  @override
  late final GeneratedColumn<int> dueDay = GeneratedColumn<int>(
    'due_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseMinCentsMeta = const VerificationMeta(
    'baseMinCents',
  );
  @override
  late final GeneratedColumn<int> baseMinCents = GeneratedColumn<int>(
    'base_min_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _baseMaxCentsMeta = const VerificationMeta(
    'baseMaxCents',
  );
  @override
  late final GeneratedColumn<int> baseMaxCents = GeneratedColumn<int>(
    'base_max_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _favoriteMeta = const VerificationMeta(
    'favorite',
  );
  @override
  late final GeneratedColumn<bool> favorite = GeneratedColumn<bool>(
    'favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    name,
    baseAmountCents,
    categoryId,
    expenseType,
    frequency,
    intervalCount,
    dueDay,
    baseMinCents,
    baseMaxCents,
    startDate,
    endDate,
    favorite,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('base_amount_cents')) {
      context.handle(
        _baseAmountCentsMeta,
        baseAmountCents.isAcceptableOrUnknown(
          data['base_amount_cents']!,
          _baseAmountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseAmountCentsMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('interval_count')) {
      context.handle(
        _intervalCountMeta,
        intervalCount.isAcceptableOrUnknown(
          data['interval_count']!,
          _intervalCountMeta,
        ),
      );
    }
    if (data.containsKey('due_day')) {
      context.handle(
        _dueDayMeta,
        dueDay.isAcceptableOrUnknown(data['due_day']!, _dueDayMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDayMeta);
    }
    if (data.containsKey('base_min_cents')) {
      context.handle(
        _baseMinCentsMeta,
        baseMinCents.isAcceptableOrUnknown(
          data['base_min_cents']!,
          _baseMinCentsMeta,
        ),
      );
    }
    if (data.containsKey('base_max_cents')) {
      context.handle(
        _baseMaxCentsMeta,
        baseMaxCents.isAcceptableOrUnknown(
          data['base_max_cents']!,
          _baseMaxCentsMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('favorite')) {
      context.handle(
        _favoriteMeta,
        favorite.isAcceptableOrUnknown(data['favorite']!, _favoriteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      baseAmountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_amount_cents'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      expenseType: $RecurringTransactionsTable.$converterexpenseType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}expense_type'],
        )!,
      ),
      frequency: $RecurringTransactionsTable.$converterfrequency.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}frequency'],
        )!,
      ),
      intervalCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_count'],
      )!,
      dueDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_day'],
      )!,
      baseMinCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_min_cents'],
      ),
      baseMaxCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_max_cents'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_date'],
      ),
      favorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favorite'],
      )!,
    );
  }

  @override
  $RecurringTransactionsTable createAlias(String alias) {
    return $RecurringTransactionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ExpenseType, String, String> $converterexpenseType =
      const EnumNameConverter<ExpenseType>(ExpenseType.values);
  static JsonTypeConverter2<Frequency, String, String> $converterfrequency =
      const EnumNameConverter<Frequency>(Frequency.values);
}

class RecurringRow extends DataClass implements Insertable<RecurringRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String deviceId;
  final String name;
  final int baseAmountCents;
  final String categoryId;
  final ExpenseType expenseType;
  final Frequency frequency;
  final int intervalCount;
  final int dueDay;

  /// Faixa de valor informada (gasto variável), v4. Ambas nulas = sem faixa.
  final int? baseMinCents;
  final int? baseMaxCents;

  /// Datas puras em ISO `yyyy-MM-dd`.
  final String startDate;
  final String? endDate;
  final bool favorite;
  const RecurringRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.deviceId,
    required this.name,
    required this.baseAmountCents,
    required this.categoryId,
    required this.expenseType,
    required this.frequency,
    required this.intervalCount,
    required this.dueDay,
    this.baseMinCents,
    this.baseMaxCents,
    required this.startDate,
    this.endDate,
    required this.favorite,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    map['device_id'] = Variable<String>(deviceId);
    map['name'] = Variable<String>(name);
    map['base_amount_cents'] = Variable<int>(baseAmountCents);
    map['category_id'] = Variable<String>(categoryId);
    {
      map['expense_type'] = Variable<String>(
        $RecurringTransactionsTable.$converterexpenseType.toSql(expenseType),
      );
    }
    {
      map['frequency'] = Variable<String>(
        $RecurringTransactionsTable.$converterfrequency.toSql(frequency),
      );
    }
    map['interval_count'] = Variable<int>(intervalCount);
    map['due_day'] = Variable<int>(dueDay);
    if (!nullToAbsent || baseMinCents != null) {
      map['base_min_cents'] = Variable<int>(baseMinCents);
    }
    if (!nullToAbsent || baseMaxCents != null) {
      map['base_max_cents'] = Variable<int>(baseMaxCents);
    }
    map['start_date'] = Variable<String>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(endDate);
    }
    map['favorite'] = Variable<bool>(favorite);
    return map;
  }

  RecurringTransactionsCompanion toCompanion(bool nullToAbsent) {
    return RecurringTransactionsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      deviceId: Value(deviceId),
      name: Value(name),
      baseAmountCents: Value(baseAmountCents),
      categoryId: Value(categoryId),
      expenseType: Value(expenseType),
      frequency: Value(frequency),
      intervalCount: Value(intervalCount),
      dueDay: Value(dueDay),
      baseMinCents: baseMinCents == null && nullToAbsent
          ? const Value.absent()
          : Value(baseMinCents),
      baseMaxCents: baseMaxCents == null && nullToAbsent
          ? const Value.absent()
          : Value(baseMaxCents),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      favorite: Value(favorite),
    );
  }

  factory RecurringRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      name: serializer.fromJson<String>(json['name']),
      baseAmountCents: serializer.fromJson<int>(json['baseAmountCents']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      expenseType: $RecurringTransactionsTable.$converterexpenseType.fromJson(
        serializer.fromJson<String>(json['expenseType']),
      ),
      frequency: $RecurringTransactionsTable.$converterfrequency.fromJson(
        serializer.fromJson<String>(json['frequency']),
      ),
      intervalCount: serializer.fromJson<int>(json['intervalCount']),
      dueDay: serializer.fromJson<int>(json['dueDay']),
      baseMinCents: serializer.fromJson<int?>(json['baseMinCents']),
      baseMaxCents: serializer.fromJson<int?>(json['baseMaxCents']),
      startDate: serializer.fromJson<String>(json['startDate']),
      endDate: serializer.fromJson<String?>(json['endDate']),
      favorite: serializer.fromJson<bool>(json['favorite']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String>(deviceId),
      'name': serializer.toJson<String>(name),
      'baseAmountCents': serializer.toJson<int>(baseAmountCents),
      'categoryId': serializer.toJson<String>(categoryId),
      'expenseType': serializer.toJson<String>(
        $RecurringTransactionsTable.$converterexpenseType.toJson(expenseType),
      ),
      'frequency': serializer.toJson<String>(
        $RecurringTransactionsTable.$converterfrequency.toJson(frequency),
      ),
      'intervalCount': serializer.toJson<int>(intervalCount),
      'dueDay': serializer.toJson<int>(dueDay),
      'baseMinCents': serializer.toJson<int?>(baseMinCents),
      'baseMaxCents': serializer.toJson<int?>(baseMaxCents),
      'startDate': serializer.toJson<String>(startDate),
      'endDate': serializer.toJson<String?>(endDate),
      'favorite': serializer.toJson<bool>(favorite),
    };
  }

  RecurringRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
    String? deviceId,
    String? name,
    int? baseAmountCents,
    String? categoryId,
    ExpenseType? expenseType,
    Frequency? frequency,
    int? intervalCount,
    int? dueDay,
    Value<int?> baseMinCents = const Value.absent(),
    Value<int?> baseMaxCents = const Value.absent(),
    String? startDate,
    Value<String?> endDate = const Value.absent(),
    bool? favorite,
  }) => RecurringRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    deviceId: deviceId ?? this.deviceId,
    name: name ?? this.name,
    baseAmountCents: baseAmountCents ?? this.baseAmountCents,
    categoryId: categoryId ?? this.categoryId,
    expenseType: expenseType ?? this.expenseType,
    frequency: frequency ?? this.frequency,
    intervalCount: intervalCount ?? this.intervalCount,
    dueDay: dueDay ?? this.dueDay,
    baseMinCents: baseMinCents.present ? baseMinCents.value : this.baseMinCents,
    baseMaxCents: baseMaxCents.present ? baseMaxCents.value : this.baseMaxCents,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    favorite: favorite ?? this.favorite,
  );
  RecurringRow copyWithCompanion(RecurringTransactionsCompanion data) {
    return RecurringRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      name: data.name.present ? data.name.value : this.name,
      baseAmountCents: data.baseAmountCents.present
          ? data.baseAmountCents.value
          : this.baseAmountCents,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      expenseType: data.expenseType.present
          ? data.expenseType.value
          : this.expenseType,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      intervalCount: data.intervalCount.present
          ? data.intervalCount.value
          : this.intervalCount,
      dueDay: data.dueDay.present ? data.dueDay.value : this.dueDay,
      baseMinCents: data.baseMinCents.present
          ? data.baseMinCents.value
          : this.baseMinCents,
      baseMaxCents: data.baseMaxCents.present
          ? data.baseMaxCents.value
          : this.baseMaxCents,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      favorite: data.favorite.present ? data.favorite.value : this.favorite,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('baseAmountCents: $baseAmountCents, ')
          ..write('categoryId: $categoryId, ')
          ..write('expenseType: $expenseType, ')
          ..write('frequency: $frequency, ')
          ..write('intervalCount: $intervalCount, ')
          ..write('dueDay: $dueDay, ')
          ..write('baseMinCents: $baseMinCents, ')
          ..write('baseMaxCents: $baseMaxCents, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('favorite: $favorite')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    name,
    baseAmountCents,
    categoryId,
    expenseType,
    frequency,
    intervalCount,
    dueDay,
    baseMinCents,
    baseMaxCents,
    startDate,
    endDate,
    favorite,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.deviceId == this.deviceId &&
          other.name == this.name &&
          other.baseAmountCents == this.baseAmountCents &&
          other.categoryId == this.categoryId &&
          other.expenseType == this.expenseType &&
          other.frequency == this.frequency &&
          other.intervalCount == this.intervalCount &&
          other.dueDay == this.dueDay &&
          other.baseMinCents == this.baseMinCents &&
          other.baseMaxCents == this.baseMaxCents &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.favorite == this.favorite);
}

class RecurringTransactionsCompanion extends UpdateCompanion<RecurringRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<String> deviceId;
  final Value<String> name;
  final Value<int> baseAmountCents;
  final Value<String> categoryId;
  final Value<ExpenseType> expenseType;
  final Value<Frequency> frequency;
  final Value<int> intervalCount;
  final Value<int> dueDay;
  final Value<int?> baseMinCents;
  final Value<int?> baseMaxCents;
  final Value<String> startDate;
  final Value<String?> endDate;
  final Value<bool> favorite;
  final Value<int> rowid;
  const RecurringTransactionsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.name = const Value.absent(),
    this.baseAmountCents = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.expenseType = const Value.absent(),
    this.frequency = const Value.absent(),
    this.intervalCount = const Value.absent(),
    this.dueDay = const Value.absent(),
    this.baseMinCents = const Value.absent(),
    this.baseMaxCents = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.favorite = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringTransactionsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    required String name,
    required int baseAmountCents,
    required String categoryId,
    required ExpenseType expenseType,
    required Frequency frequency,
    this.intervalCount = const Value.absent(),
    required int dueDay,
    this.baseMinCents = const Value.absent(),
    this.baseMaxCents = const Value.absent(),
    required String startDate,
    this.endDate = const Value.absent(),
    this.favorite = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       baseAmountCents = Value(baseAmountCents),
       categoryId = Value(categoryId),
       expenseType = Value(expenseType),
       frequency = Value(frequency),
       dueDay = Value(dueDay),
       startDate = Value(startDate);
  static Insertable<RecurringRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<String>? name,
    Expression<int>? baseAmountCents,
    Expression<String>? categoryId,
    Expression<String>? expenseType,
    Expression<String>? frequency,
    Expression<int>? intervalCount,
    Expression<int>? dueDay,
    Expression<int>? baseMinCents,
    Expression<int>? baseMaxCents,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<bool>? favorite,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (name != null) 'name': name,
      if (baseAmountCents != null) 'base_amount_cents': baseAmountCents,
      if (categoryId != null) 'category_id': categoryId,
      if (expenseType != null) 'expense_type': expenseType,
      if (frequency != null) 'frequency': frequency,
      if (intervalCount != null) 'interval_count': intervalCount,
      if (dueDay != null) 'due_day': dueDay,
      if (baseMinCents != null) 'base_min_cents': baseMinCents,
      if (baseMaxCents != null) 'base_max_cents': baseMaxCents,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (favorite != null) 'favorite': favorite,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringTransactionsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<String>? deviceId,
    Value<String>? name,
    Value<int>? baseAmountCents,
    Value<String>? categoryId,
    Value<ExpenseType>? expenseType,
    Value<Frequency>? frequency,
    Value<int>? intervalCount,
    Value<int>? dueDay,
    Value<int?>? baseMinCents,
    Value<int?>? baseMaxCents,
    Value<String>? startDate,
    Value<String?>? endDate,
    Value<bool>? favorite,
    Value<int>? rowid,
  }) {
    return RecurringTransactionsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      baseAmountCents: baseAmountCents ?? this.baseAmountCents,
      categoryId: categoryId ?? this.categoryId,
      expenseType: expenseType ?? this.expenseType,
      frequency: frequency ?? this.frequency,
      intervalCount: intervalCount ?? this.intervalCount,
      dueDay: dueDay ?? this.dueDay,
      baseMinCents: baseMinCents ?? this.baseMinCents,
      baseMaxCents: baseMaxCents ?? this.baseMaxCents,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      favorite: favorite ?? this.favorite,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (baseAmountCents.present) {
      map['base_amount_cents'] = Variable<int>(baseAmountCents.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (expenseType.present) {
      map['expense_type'] = Variable<String>(
        $RecurringTransactionsTable.$converterexpenseType.toSql(
          expenseType.value,
        ),
      );
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(
        $RecurringTransactionsTable.$converterfrequency.toSql(frequency.value),
      );
    }
    if (intervalCount.present) {
      map['interval_count'] = Variable<int>(intervalCount.value);
    }
    if (dueDay.present) {
      map['due_day'] = Variable<int>(dueDay.value);
    }
    if (baseMinCents.present) {
      map['base_min_cents'] = Variable<int>(baseMinCents.value);
    }
    if (baseMaxCents.present) {
      map['base_max_cents'] = Variable<int>(baseMaxCents.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(endDate.value);
    }
    if (favorite.present) {
      map['favorite'] = Variable<bool>(favorite.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('baseAmountCents: $baseAmountCents, ')
          ..write('categoryId: $categoryId, ')
          ..write('expenseType: $expenseType, ')
          ..write('frequency: $frequency, ')
          ..write('intervalCount: $intervalCount, ')
          ..write('dueDay: $dueDay, ')
          ..write('baseMinCents: $baseMinCents, ')
          ..write('baseMaxCents: $baseMaxCents, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('favorite: $favorite, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, TransactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
  static const VerificationMeta _plannedAmountCentsMeta =
      const VerificationMeta('plannedAmountCents');
  @override
  late final GeneratedColumn<int> plannedAmountCents = GeneratedColumn<int>(
    'planned_amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ExpenseType, String> expenseType =
      GeneratedColumn<String>(
        'expense_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ExpenseType>($TransactionsTable.$converterexpenseType);
  static const VerificationMeta _favoriteMeta = const VerificationMeta(
    'favorite',
  );
  @override
  late final GeneratedColumn<bool> favorite = GeneratedColumn<bool>(
    'favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _canceledAtMeta = const VerificationMeta(
    'canceledAt',
  );
  @override
  late final GeneratedColumn<DateTime> canceledAt = GeneratedColumn<DateTime>(
    'canceled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurringIdMeta = const VerificationMeta(
    'recurringId',
  );
  @override
  late final GeneratedColumn<String> recurringId = GeneratedColumn<String>(
    'recurring_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recurring_transactions (id)',
    ),
  );
  static const VerificationMeta _occurrenceDateMeta = const VerificationMeta(
    'occurrenceDate',
  );
  @override
  late final GeneratedColumn<String> occurrenceDate = GeneratedColumn<String>(
    'occurrence_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _overriddenMeta = const VerificationMeta(
    'overridden',
  );
  @override
  late final GeneratedColumn<bool> overridden = GeneratedColumn<bool>(
    'overridden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("overridden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _plannedMinCentsMeta = const VerificationMeta(
    'plannedMinCents',
  );
  @override
  late final GeneratedColumn<int> plannedMinCents = GeneratedColumn<int>(
    'planned_min_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedMaxCentsMeta = const VerificationMeta(
    'plannedMaxCents',
  );
  @override
  late final GeneratedColumn<int> plannedMaxCents = GeneratedColumn<int>(
    'planned_max_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    name,
    plannedAmountCents,
    dueDate,
    categoryId,
    expenseType,
    favorite,
    note,
    canceledAt,
    recurringId,
    occurrenceDate,
    overridden,
    plannedMinCents,
    plannedMaxCents,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('planned_amount_cents')) {
      context.handle(
        _plannedAmountCentsMeta,
        plannedAmountCents.isAcceptableOrUnknown(
          data['planned_amount_cents']!,
          _plannedAmountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedAmountCentsMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('favorite')) {
      context.handle(
        _favoriteMeta,
        favorite.isAcceptableOrUnknown(data['favorite']!, _favoriteMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('canceled_at')) {
      context.handle(
        _canceledAtMeta,
        canceledAt.isAcceptableOrUnknown(data['canceled_at']!, _canceledAtMeta),
      );
    }
    if (data.containsKey('recurring_id')) {
      context.handle(
        _recurringIdMeta,
        recurringId.isAcceptableOrUnknown(
          data['recurring_id']!,
          _recurringIdMeta,
        ),
      );
    }
    if (data.containsKey('occurrence_date')) {
      context.handle(
        _occurrenceDateMeta,
        occurrenceDate.isAcceptableOrUnknown(
          data['occurrence_date']!,
          _occurrenceDateMeta,
        ),
      );
    }
    if (data.containsKey('overridden')) {
      context.handle(
        _overriddenMeta,
        overridden.isAcceptableOrUnknown(data['overridden']!, _overriddenMeta),
      );
    }
    if (data.containsKey('planned_min_cents')) {
      context.handle(
        _plannedMinCentsMeta,
        plannedMinCents.isAcceptableOrUnknown(
          data['planned_min_cents']!,
          _plannedMinCentsMeta,
        ),
      );
    }
    if (data.containsKey('planned_max_cents')) {
      context.handle(
        _plannedMaxCentsMeta,
        plannedMaxCents.isAcceptableOrUnknown(
          data['planned_max_cents']!,
          _plannedMaxCentsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      plannedAmountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_amount_cents'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_date'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      expenseType: $TransactionsTable.$converterexpenseType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}expense_type'],
        )!,
      ),
      favorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favorite'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      canceledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}canceled_at'],
      ),
      recurringId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurring_id'],
      ),
      occurrenceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occurrence_date'],
      ),
      overridden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}overridden'],
      )!,
      plannedMinCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_min_cents'],
      ),
      plannedMaxCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_max_cents'],
      ),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ExpenseType, String, String> $converterexpenseType =
      const EnumNameConverter<ExpenseType>(ExpenseType.values);
}

class TransactionRow extends DataClass implements Insertable<TransactionRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String deviceId;
  final String name;
  final int plannedAmountCents;

  /// Data pura ISO `yyyy-MM-dd` (sem hora, sem fuso).
  final String dueDate;
  final String categoryId;
  final ExpenseType expenseType;
  final bool favorite;
  final String note;
  final DateTime? canceledAt;
  final String? recurringId;
  final String? occurrenceDate;

  /// Ocorrência editada manualmente: não é regenerada pela regra.
  final bool overridden;

  /// Faixa de valor informada (gasto variável), v4. Ambas nulas = sem faixa.
  final int? plannedMinCents;
  final int? plannedMaxCents;
  const TransactionRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.deviceId,
    required this.name,
    required this.plannedAmountCents,
    required this.dueDate,
    required this.categoryId,
    required this.expenseType,
    required this.favorite,
    required this.note,
    this.canceledAt,
    this.recurringId,
    this.occurrenceDate,
    required this.overridden,
    this.plannedMinCents,
    this.plannedMaxCents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    map['device_id'] = Variable<String>(deviceId);
    map['name'] = Variable<String>(name);
    map['planned_amount_cents'] = Variable<int>(plannedAmountCents);
    map['due_date'] = Variable<String>(dueDate);
    map['category_id'] = Variable<String>(categoryId);
    {
      map['expense_type'] = Variable<String>(
        $TransactionsTable.$converterexpenseType.toSql(expenseType),
      );
    }
    map['favorite'] = Variable<bool>(favorite);
    map['note'] = Variable<String>(note);
    if (!nullToAbsent || canceledAt != null) {
      map['canceled_at'] = Variable<DateTime>(canceledAt);
    }
    if (!nullToAbsent || recurringId != null) {
      map['recurring_id'] = Variable<String>(recurringId);
    }
    if (!nullToAbsent || occurrenceDate != null) {
      map['occurrence_date'] = Variable<String>(occurrenceDate);
    }
    map['overridden'] = Variable<bool>(overridden);
    if (!nullToAbsent || plannedMinCents != null) {
      map['planned_min_cents'] = Variable<int>(plannedMinCents);
    }
    if (!nullToAbsent || plannedMaxCents != null) {
      map['planned_max_cents'] = Variable<int>(plannedMaxCents);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      deviceId: Value(deviceId),
      name: Value(name),
      plannedAmountCents: Value(plannedAmountCents),
      dueDate: Value(dueDate),
      categoryId: Value(categoryId),
      expenseType: Value(expenseType),
      favorite: Value(favorite),
      note: Value(note),
      canceledAt: canceledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(canceledAt),
      recurringId: recurringId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringId),
      occurrenceDate: occurrenceDate == null && nullToAbsent
          ? const Value.absent()
          : Value(occurrenceDate),
      overridden: Value(overridden),
      plannedMinCents: plannedMinCents == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedMinCents),
      plannedMaxCents: plannedMaxCents == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedMaxCents),
    );
  }

  factory TransactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      name: serializer.fromJson<String>(json['name']),
      plannedAmountCents: serializer.fromJson<int>(json['plannedAmountCents']),
      dueDate: serializer.fromJson<String>(json['dueDate']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      expenseType: $TransactionsTable.$converterexpenseType.fromJson(
        serializer.fromJson<String>(json['expenseType']),
      ),
      favorite: serializer.fromJson<bool>(json['favorite']),
      note: serializer.fromJson<String>(json['note']),
      canceledAt: serializer.fromJson<DateTime?>(json['canceledAt']),
      recurringId: serializer.fromJson<String?>(json['recurringId']),
      occurrenceDate: serializer.fromJson<String?>(json['occurrenceDate']),
      overridden: serializer.fromJson<bool>(json['overridden']),
      plannedMinCents: serializer.fromJson<int?>(json['plannedMinCents']),
      plannedMaxCents: serializer.fromJson<int?>(json['plannedMaxCents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String>(deviceId),
      'name': serializer.toJson<String>(name),
      'plannedAmountCents': serializer.toJson<int>(plannedAmountCents),
      'dueDate': serializer.toJson<String>(dueDate),
      'categoryId': serializer.toJson<String>(categoryId),
      'expenseType': serializer.toJson<String>(
        $TransactionsTable.$converterexpenseType.toJson(expenseType),
      ),
      'favorite': serializer.toJson<bool>(favorite),
      'note': serializer.toJson<String>(note),
      'canceledAt': serializer.toJson<DateTime?>(canceledAt),
      'recurringId': serializer.toJson<String?>(recurringId),
      'occurrenceDate': serializer.toJson<String?>(occurrenceDate),
      'overridden': serializer.toJson<bool>(overridden),
      'plannedMinCents': serializer.toJson<int?>(plannedMinCents),
      'plannedMaxCents': serializer.toJson<int?>(plannedMaxCents),
    };
  }

  TransactionRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
    String? deviceId,
    String? name,
    int? plannedAmountCents,
    String? dueDate,
    String? categoryId,
    ExpenseType? expenseType,
    bool? favorite,
    String? note,
    Value<DateTime?> canceledAt = const Value.absent(),
    Value<String?> recurringId = const Value.absent(),
    Value<String?> occurrenceDate = const Value.absent(),
    bool? overridden,
    Value<int?> plannedMinCents = const Value.absent(),
    Value<int?> plannedMaxCents = const Value.absent(),
  }) => TransactionRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    deviceId: deviceId ?? this.deviceId,
    name: name ?? this.name,
    plannedAmountCents: plannedAmountCents ?? this.plannedAmountCents,
    dueDate: dueDate ?? this.dueDate,
    categoryId: categoryId ?? this.categoryId,
    expenseType: expenseType ?? this.expenseType,
    favorite: favorite ?? this.favorite,
    note: note ?? this.note,
    canceledAt: canceledAt.present ? canceledAt.value : this.canceledAt,
    recurringId: recurringId.present ? recurringId.value : this.recurringId,
    occurrenceDate: occurrenceDate.present
        ? occurrenceDate.value
        : this.occurrenceDate,
    overridden: overridden ?? this.overridden,
    plannedMinCents: plannedMinCents.present
        ? plannedMinCents.value
        : this.plannedMinCents,
    plannedMaxCents: plannedMaxCents.present
        ? plannedMaxCents.value
        : this.plannedMaxCents,
  );
  TransactionRow copyWithCompanion(TransactionsCompanion data) {
    return TransactionRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      name: data.name.present ? data.name.value : this.name,
      plannedAmountCents: data.plannedAmountCents.present
          ? data.plannedAmountCents.value
          : this.plannedAmountCents,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      expenseType: data.expenseType.present
          ? data.expenseType.value
          : this.expenseType,
      favorite: data.favorite.present ? data.favorite.value : this.favorite,
      note: data.note.present ? data.note.value : this.note,
      canceledAt: data.canceledAt.present
          ? data.canceledAt.value
          : this.canceledAt,
      recurringId: data.recurringId.present
          ? data.recurringId.value
          : this.recurringId,
      occurrenceDate: data.occurrenceDate.present
          ? data.occurrenceDate.value
          : this.occurrenceDate,
      overridden: data.overridden.present
          ? data.overridden.value
          : this.overridden,
      plannedMinCents: data.plannedMinCents.present
          ? data.plannedMinCents.value
          : this.plannedMinCents,
      plannedMaxCents: data.plannedMaxCents.present
          ? data.plannedMaxCents.value
          : this.plannedMaxCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('plannedAmountCents: $plannedAmountCents, ')
          ..write('dueDate: $dueDate, ')
          ..write('categoryId: $categoryId, ')
          ..write('expenseType: $expenseType, ')
          ..write('favorite: $favorite, ')
          ..write('note: $note, ')
          ..write('canceledAt: $canceledAt, ')
          ..write('recurringId: $recurringId, ')
          ..write('occurrenceDate: $occurrenceDate, ')
          ..write('overridden: $overridden, ')
          ..write('plannedMinCents: $plannedMinCents, ')
          ..write('plannedMaxCents: $plannedMaxCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    name,
    plannedAmountCents,
    dueDate,
    categoryId,
    expenseType,
    favorite,
    note,
    canceledAt,
    recurringId,
    occurrenceDate,
    overridden,
    plannedMinCents,
    plannedMaxCents,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.deviceId == this.deviceId &&
          other.name == this.name &&
          other.plannedAmountCents == this.plannedAmountCents &&
          other.dueDate == this.dueDate &&
          other.categoryId == this.categoryId &&
          other.expenseType == this.expenseType &&
          other.favorite == this.favorite &&
          other.note == this.note &&
          other.canceledAt == this.canceledAt &&
          other.recurringId == this.recurringId &&
          other.occurrenceDate == this.occurrenceDate &&
          other.overridden == this.overridden &&
          other.plannedMinCents == this.plannedMinCents &&
          other.plannedMaxCents == this.plannedMaxCents);
}

class TransactionsCompanion extends UpdateCompanion<TransactionRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<String> deviceId;
  final Value<String> name;
  final Value<int> plannedAmountCents;
  final Value<String> dueDate;
  final Value<String> categoryId;
  final Value<ExpenseType> expenseType;
  final Value<bool> favorite;
  final Value<String> note;
  final Value<DateTime?> canceledAt;
  final Value<String?> recurringId;
  final Value<String?> occurrenceDate;
  final Value<bool> overridden;
  final Value<int?> plannedMinCents;
  final Value<int?> plannedMaxCents;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.name = const Value.absent(),
    this.plannedAmountCents = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.expenseType = const Value.absent(),
    this.favorite = const Value.absent(),
    this.note = const Value.absent(),
    this.canceledAt = const Value.absent(),
    this.recurringId = const Value.absent(),
    this.occurrenceDate = const Value.absent(),
    this.overridden = const Value.absent(),
    this.plannedMinCents = const Value.absent(),
    this.plannedMaxCents = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    required String name,
    required int plannedAmountCents,
    required String dueDate,
    required String categoryId,
    required ExpenseType expenseType,
    this.favorite = const Value.absent(),
    this.note = const Value.absent(),
    this.canceledAt = const Value.absent(),
    this.recurringId = const Value.absent(),
    this.occurrenceDate = const Value.absent(),
    this.overridden = const Value.absent(),
    this.plannedMinCents = const Value.absent(),
    this.plannedMaxCents = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       plannedAmountCents = Value(plannedAmountCents),
       dueDate = Value(dueDate),
       categoryId = Value(categoryId),
       expenseType = Value(expenseType);
  static Insertable<TransactionRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<String>? name,
    Expression<int>? plannedAmountCents,
    Expression<String>? dueDate,
    Expression<String>? categoryId,
    Expression<String>? expenseType,
    Expression<bool>? favorite,
    Expression<String>? note,
    Expression<DateTime>? canceledAt,
    Expression<String>? recurringId,
    Expression<String>? occurrenceDate,
    Expression<bool>? overridden,
    Expression<int>? plannedMinCents,
    Expression<int>? plannedMaxCents,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (name != null) 'name': name,
      if (plannedAmountCents != null)
        'planned_amount_cents': plannedAmountCents,
      if (dueDate != null) 'due_date': dueDate,
      if (categoryId != null) 'category_id': categoryId,
      if (expenseType != null) 'expense_type': expenseType,
      if (favorite != null) 'favorite': favorite,
      if (note != null) 'note': note,
      if (canceledAt != null) 'canceled_at': canceledAt,
      if (recurringId != null) 'recurring_id': recurringId,
      if (occurrenceDate != null) 'occurrence_date': occurrenceDate,
      if (overridden != null) 'overridden': overridden,
      if (plannedMinCents != null) 'planned_min_cents': plannedMinCents,
      if (plannedMaxCents != null) 'planned_max_cents': plannedMaxCents,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<String>? deviceId,
    Value<String>? name,
    Value<int>? plannedAmountCents,
    Value<String>? dueDate,
    Value<String>? categoryId,
    Value<ExpenseType>? expenseType,
    Value<bool>? favorite,
    Value<String>? note,
    Value<DateTime?>? canceledAt,
    Value<String?>? recurringId,
    Value<String?>? occurrenceDate,
    Value<bool>? overridden,
    Value<int?>? plannedMinCents,
    Value<int?>? plannedMaxCents,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      plannedAmountCents: plannedAmountCents ?? this.plannedAmountCents,
      dueDate: dueDate ?? this.dueDate,
      categoryId: categoryId ?? this.categoryId,
      expenseType: expenseType ?? this.expenseType,
      favorite: favorite ?? this.favorite,
      note: note ?? this.note,
      canceledAt: canceledAt ?? this.canceledAt,
      recurringId: recurringId ?? this.recurringId,
      occurrenceDate: occurrenceDate ?? this.occurrenceDate,
      overridden: overridden ?? this.overridden,
      plannedMinCents: plannedMinCents ?? this.plannedMinCents,
      plannedMaxCents: plannedMaxCents ?? this.plannedMaxCents,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (plannedAmountCents.present) {
      map['planned_amount_cents'] = Variable<int>(plannedAmountCents.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (expenseType.present) {
      map['expense_type'] = Variable<String>(
        $TransactionsTable.$converterexpenseType.toSql(expenseType.value),
      );
    }
    if (favorite.present) {
      map['favorite'] = Variable<bool>(favorite.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (canceledAt.present) {
      map['canceled_at'] = Variable<DateTime>(canceledAt.value);
    }
    if (recurringId.present) {
      map['recurring_id'] = Variable<String>(recurringId.value);
    }
    if (occurrenceDate.present) {
      map['occurrence_date'] = Variable<String>(occurrenceDate.value);
    }
    if (overridden.present) {
      map['overridden'] = Variable<bool>(overridden.value);
    }
    if (plannedMinCents.present) {
      map['planned_min_cents'] = Variable<int>(plannedMinCents.value);
    }
    if (plannedMaxCents.present) {
      map['planned_max_cents'] = Variable<int>(plannedMaxCents.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('plannedAmountCents: $plannedAmountCents, ')
          ..write('dueDate: $dueDate, ')
          ..write('categoryId: $categoryId, ')
          ..write('expenseType: $expenseType, ')
          ..write('favorite: $favorite, ')
          ..write('note: $note, ')
          ..write('canceledAt: $canceledAt, ')
          ..write('recurringId: $recurringId, ')
          ..write('occurrenceDate: $occurrenceDate, ')
          ..write('overridden: $overridden, ')
          ..write('plannedMinCents: $plannedMinCents, ')
          ..write('plannedMaxCents: $plannedMaxCents, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments
    with TableInfo<$PaymentsTable, PaymentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions (id)',
    ),
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidAtMeta = const VerificationMeta('paidAt');
  @override
  late final GeneratedColumn<DateTime> paidAt = GeneratedColumn<DateTime>(
    'paid_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    transactionId,
    amountCents,
    paidAt,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('paid_at')) {
      context.handle(
        _paidAtMeta,
        paidAt.isAcceptableOrUnknown(data['paid_at']!, _paidAtMeta),
      );
    } else if (isInserting) {
      context.missing(_paidAtMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      paidAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paid_at'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class PaymentRow extends DataClass implements Insertable<PaymentRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String deviceId;
  final String transactionId;
  final int amountCents;
  final DateTime paidAt;
  final String note;
  const PaymentRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.deviceId,
    required this.transactionId,
    required this.amountCents,
    required this.paidAt,
    required this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    map['device_id'] = Variable<String>(deviceId);
    map['transaction_id'] = Variable<String>(transactionId);
    map['amount_cents'] = Variable<int>(amountCents);
    map['paid_at'] = Variable<DateTime>(paidAt);
    map['note'] = Variable<String>(note);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      deviceId: Value(deviceId),
      transactionId: Value(transactionId),
      amountCents: Value(amountCents),
      paidAt: Value(paidAt),
      note: Value(note),
    );
  }

  factory PaymentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      paidAt: serializer.fromJson<DateTime>(json['paidAt']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String>(deviceId),
      'transactionId': serializer.toJson<String>(transactionId),
      'amountCents': serializer.toJson<int>(amountCents),
      'paidAt': serializer.toJson<DateTime>(paidAt),
      'note': serializer.toJson<String>(note),
    };
  }

  PaymentRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
    String? deviceId,
    String? transactionId,
    int? amountCents,
    DateTime? paidAt,
    String? note,
  }) => PaymentRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    deviceId: deviceId ?? this.deviceId,
    transactionId: transactionId ?? this.transactionId,
    amountCents: amountCents ?? this.amountCents,
    paidAt: paidAt ?? this.paidAt,
    note: note ?? this.note,
  );
  PaymentRow copyWithCompanion(PaymentsCompanion data) {
    return PaymentRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      paidAt: data.paidAt.present ? data.paidAt.value : this.paidAt,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('transactionId: $transactionId, ')
          ..write('amountCents: $amountCents, ')
          ..write('paidAt: $paidAt, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    transactionId,
    amountCents,
    paidAt,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.deviceId == this.deviceId &&
          other.transactionId == this.transactionId &&
          other.amountCents == this.amountCents &&
          other.paidAt == this.paidAt &&
          other.note == this.note);
}

class PaymentsCompanion extends UpdateCompanion<PaymentRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<String> deviceId;
  final Value<String> transactionId;
  final Value<int> amountCents;
  final Value<DateTime> paidAt;
  final Value<String> note;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    required String transactionId,
    required int amountCents,
    required DateTime paidAt,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       transactionId = Value(transactionId),
       amountCents = Value(amountCents),
       paidAt = Value(paidAt);
  static Insertable<PaymentRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<String>? transactionId,
    Expression<int>? amountCents,
    Expression<DateTime>? paidAt,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (transactionId != null) 'transaction_id': transactionId,
      if (amountCents != null) 'amount_cents': amountCents,
      if (paidAt != null) 'paid_at': paidAt,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<String>? deviceId,
    Value<String>? transactionId,
    Value<int>? amountCents,
    Value<DateTime>? paidAt,
    Value<String>? note,
    Value<int>? rowid,
  }) {
    return PaymentsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      transactionId: transactionId ?? this.transactionId,
      amountCents: amountCents ?? this.amountCents,
      paidAt: paidAt ?? this.paidAt,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (paidAt.present) {
      map['paid_at'] = Variable<DateTime>(paidAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('transactionId: $transactionId, ')
          ..write('amountCents: $amountCents, ')
          ..write('paidAt: $paidAt, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, AttachmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<AttachmentOwner, String>
  ownerType = GeneratedColumn<String>(
    'owner_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<AttachmentOwner>($AttachmentsTable.$converterownerType);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalNameMeta = const VerificationMeta(
    'originalName',
  );
  @override
  late final GeneratedColumn<String> originalName = GeneratedColumn<String>(
    'original_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeMeta = const VerificationMeta('mime');
  @override
  late final GeneratedColumn<String> mime = GeneratedColumn<String>(
    'mime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hashMeta = const VerificationMeta('hash');
  @override
  late final GeneratedColumn<String> hash = GeneratedColumn<String>(
    'hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _driveFileIdMeta = const VerificationMeta(
    'driveFileId',
  );
  @override
  late final GeneratedColumn<String> driveFileId = GeneratedColumn<String>(
    'drive_file_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<UploadStatus, String>
  uploadStatus = GeneratedColumn<String>(
    'upload_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('localOnly'),
  ).withConverter<UploadStatus>($AttachmentsTable.$converteruploadStatus);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    ownerType,
    ownerId,
    localPath,
    originalName,
    mime,
    hash,
    driveFileId,
    uploadStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttachmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('original_name')) {
      context.handle(
        _originalNameMeta,
        originalName.isAcceptableOrUnknown(
          data['original_name']!,
          _originalNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalNameMeta);
    }
    if (data.containsKey('mime')) {
      context.handle(
        _mimeMeta,
        mime.isAcceptableOrUnknown(data['mime']!, _mimeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeMeta);
    }
    if (data.containsKey('hash')) {
      context.handle(
        _hashMeta,
        hash.isAcceptableOrUnknown(data['hash']!, _hashMeta),
      );
    }
    if (data.containsKey('drive_file_id')) {
      context.handle(
        _driveFileIdMeta,
        driveFileId.isAcceptableOrUnknown(
          data['drive_file_id']!,
          _driveFileIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttachmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttachmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      ownerType: $AttachmentsTable.$converterownerType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}owner_type'],
        )!,
      ),
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      originalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_name'],
      )!,
      mime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime'],
      )!,
      hash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hash'],
      )!,
      driveFileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drive_file_id'],
      ),
      uploadStatus: $AttachmentsTable.$converteruploadStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}upload_status'],
        )!,
      ),
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AttachmentOwner, String, String>
  $converterownerType = const EnumNameConverter<AttachmentOwner>(
    AttachmentOwner.values,
  );
  static JsonTypeConverter2<UploadStatus, String, String>
  $converteruploadStatus = const EnumNameConverter<UploadStatus>(
    UploadStatus.values,
  );
}

class AttachmentRow extends DataClass implements Insertable<AttachmentRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String deviceId;
  final AttachmentOwner ownerType;
  final String ownerId;
  final String localPath;
  final String originalName;
  final String mime;
  final String hash;
  final String? driveFileId;
  final UploadStatus uploadStatus;
  const AttachmentRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.deviceId,
    required this.ownerType,
    required this.ownerId,
    required this.localPath,
    required this.originalName,
    required this.mime,
    required this.hash,
    this.driveFileId,
    required this.uploadStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    map['device_id'] = Variable<String>(deviceId);
    {
      map['owner_type'] = Variable<String>(
        $AttachmentsTable.$converterownerType.toSql(ownerType),
      );
    }
    map['owner_id'] = Variable<String>(ownerId);
    map['local_path'] = Variable<String>(localPath);
    map['original_name'] = Variable<String>(originalName);
    map['mime'] = Variable<String>(mime);
    map['hash'] = Variable<String>(hash);
    if (!nullToAbsent || driveFileId != null) {
      map['drive_file_id'] = Variable<String>(driveFileId);
    }
    {
      map['upload_status'] = Variable<String>(
        $AttachmentsTable.$converteruploadStatus.toSql(uploadStatus),
      );
    }
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      deviceId: Value(deviceId),
      ownerType: Value(ownerType),
      ownerId: Value(ownerId),
      localPath: Value(localPath),
      originalName: Value(originalName),
      mime: Value(mime),
      hash: Value(hash),
      driveFileId: driveFileId == null && nullToAbsent
          ? const Value.absent()
          : Value(driveFileId),
      uploadStatus: Value(uploadStatus),
    );
  }

  factory AttachmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttachmentRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      ownerType: $AttachmentsTable.$converterownerType.fromJson(
        serializer.fromJson<String>(json['ownerType']),
      ),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      localPath: serializer.fromJson<String>(json['localPath']),
      originalName: serializer.fromJson<String>(json['originalName']),
      mime: serializer.fromJson<String>(json['mime']),
      hash: serializer.fromJson<String>(json['hash']),
      driveFileId: serializer.fromJson<String?>(json['driveFileId']),
      uploadStatus: $AttachmentsTable.$converteruploadStatus.fromJson(
        serializer.fromJson<String>(json['uploadStatus']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String>(deviceId),
      'ownerType': serializer.toJson<String>(
        $AttachmentsTable.$converterownerType.toJson(ownerType),
      ),
      'ownerId': serializer.toJson<String>(ownerId),
      'localPath': serializer.toJson<String>(localPath),
      'originalName': serializer.toJson<String>(originalName),
      'mime': serializer.toJson<String>(mime),
      'hash': serializer.toJson<String>(hash),
      'driveFileId': serializer.toJson<String?>(driveFileId),
      'uploadStatus': serializer.toJson<String>(
        $AttachmentsTable.$converteruploadStatus.toJson(uploadStatus),
      ),
    };
  }

  AttachmentRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
    String? deviceId,
    AttachmentOwner? ownerType,
    String? ownerId,
    String? localPath,
    String? originalName,
    String? mime,
    String? hash,
    Value<String?> driveFileId = const Value.absent(),
    UploadStatus? uploadStatus,
  }) => AttachmentRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    deviceId: deviceId ?? this.deviceId,
    ownerType: ownerType ?? this.ownerType,
    ownerId: ownerId ?? this.ownerId,
    localPath: localPath ?? this.localPath,
    originalName: originalName ?? this.originalName,
    mime: mime ?? this.mime,
    hash: hash ?? this.hash,
    driveFileId: driveFileId.present ? driveFileId.value : this.driveFileId,
    uploadStatus: uploadStatus ?? this.uploadStatus,
  );
  AttachmentRow copyWithCompanion(AttachmentsCompanion data) {
    return AttachmentRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      ownerType: data.ownerType.present ? data.ownerType.value : this.ownerType,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      originalName: data.originalName.present
          ? data.originalName.value
          : this.originalName,
      mime: data.mime.present ? data.mime.value : this.mime,
      hash: data.hash.present ? data.hash.value : this.hash,
      driveFileId: data.driveFileId.present
          ? data.driveFileId.value
          : this.driveFileId,
      uploadStatus: data.uploadStatus.present
          ? data.uploadStatus.value
          : this.uploadStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('ownerType: $ownerType, ')
          ..write('ownerId: $ownerId, ')
          ..write('localPath: $localPath, ')
          ..write('originalName: $originalName, ')
          ..write('mime: $mime, ')
          ..write('hash: $hash, ')
          ..write('driveFileId: $driveFileId, ')
          ..write('uploadStatus: $uploadStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    ownerType,
    ownerId,
    localPath,
    originalName,
    mime,
    hash,
    driveFileId,
    uploadStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttachmentRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.deviceId == this.deviceId &&
          other.ownerType == this.ownerType &&
          other.ownerId == this.ownerId &&
          other.localPath == this.localPath &&
          other.originalName == this.originalName &&
          other.mime == this.mime &&
          other.hash == this.hash &&
          other.driveFileId == this.driveFileId &&
          other.uploadStatus == this.uploadStatus);
}

class AttachmentsCompanion extends UpdateCompanion<AttachmentRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<String> deviceId;
  final Value<AttachmentOwner> ownerType;
  final Value<String> ownerId;
  final Value<String> localPath;
  final Value<String> originalName;
  final Value<String> mime;
  final Value<String> hash;
  final Value<String?> driveFileId;
  final Value<UploadStatus> uploadStatus;
  final Value<int> rowid;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.ownerType = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.originalName = const Value.absent(),
    this.mime = const Value.absent(),
    this.hash = const Value.absent(),
    this.driveFileId = const Value.absent(),
    this.uploadStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    required AttachmentOwner ownerType,
    required String ownerId,
    required String localPath,
    required String originalName,
    required String mime,
    this.hash = const Value.absent(),
    this.driveFileId = const Value.absent(),
    this.uploadStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       ownerType = Value(ownerType),
       ownerId = Value(ownerId),
       localPath = Value(localPath),
       originalName = Value(originalName),
       mime = Value(mime);
  static Insertable<AttachmentRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<String>? ownerType,
    Expression<String>? ownerId,
    Expression<String>? localPath,
    Expression<String>? originalName,
    Expression<String>? mime,
    Expression<String>? hash,
    Expression<String>? driveFileId,
    Expression<String>? uploadStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (ownerType != null) 'owner_type': ownerType,
      if (ownerId != null) 'owner_id': ownerId,
      if (localPath != null) 'local_path': localPath,
      if (originalName != null) 'original_name': originalName,
      if (mime != null) 'mime': mime,
      if (hash != null) 'hash': hash,
      if (driveFileId != null) 'drive_file_id': driveFileId,
      if (uploadStatus != null) 'upload_status': uploadStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<String>? deviceId,
    Value<AttachmentOwner>? ownerType,
    Value<String>? ownerId,
    Value<String>? localPath,
    Value<String>? originalName,
    Value<String>? mime,
    Value<String>? hash,
    Value<String?>? driveFileId,
    Value<UploadStatus>? uploadStatus,
    Value<int>? rowid,
  }) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      ownerType: ownerType ?? this.ownerType,
      ownerId: ownerId ?? this.ownerId,
      localPath: localPath ?? this.localPath,
      originalName: originalName ?? this.originalName,
      mime: mime ?? this.mime,
      hash: hash ?? this.hash,
      driveFileId: driveFileId ?? this.driveFileId,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (ownerType.present) {
      map['owner_type'] = Variable<String>(
        $AttachmentsTable.$converterownerType.toSql(ownerType.value),
      );
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (originalName.present) {
      map['original_name'] = Variable<String>(originalName.value);
    }
    if (mime.present) {
      map['mime'] = Variable<String>(mime.value);
    }
    if (hash.present) {
      map['hash'] = Variable<String>(hash.value);
    }
    if (driveFileId.present) {
      map['drive_file_id'] = Variable<String>(driveFileId.value);
    }
    if (uploadStatus.present) {
      map['upload_status'] = Variable<String>(
        $AttachmentsTable.$converteruploadStatus.toSql(uploadStatus.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('ownerType: $ownerType, ')
          ..write('ownerId: $ownerId, ')
          ..write('localPath: $localPath, ')
          ..write('originalName: $originalName, ')
          ..write('mime: $mime, ')
          ..write('hash: $hash, ')
          ..write('driveFileId: $driveFileId, ')
          ..write('uploadStatus: $uploadStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IncomesTable extends Incomes with TableInfo<$IncomesTable, IncomeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IncomesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _yearMonthMeta = const VerificationMeta(
    'yearMonth',
  );
  @override
  late final GeneratedColumn<String> yearMonth = GeneratedColumn<String>(
    'year_month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<IncomeKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<IncomeKind>($IncomesTable.$converterkind);
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _receivedMeta = const VerificationMeta(
    'received',
  );
  @override
  late final GeneratedColumn<bool> received = GeneratedColumn<bool>(
    'received',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("received" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    yearMonth,
    kind,
    amountCents,
    description,
    received,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'incomes';
  @override
  VerificationContext validateIntegrity(
    Insertable<IncomeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('year_month')) {
      context.handle(
        _yearMonthMeta,
        yearMonth.isAcceptableOrUnknown(data['year_month']!, _yearMonthMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMonthMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('received')) {
      context.handle(
        _receivedMeta,
        received.isAcceptableOrUnknown(data['received']!, _receivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IncomeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IncomeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      yearMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}year_month'],
      )!,
      kind: $IncomesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      received: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}received'],
      )!,
    );
  }

  @override
  $IncomesTable createAlias(String alias) {
    return $IncomesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<IncomeKind, String, String> $converterkind =
      const EnumNameConverter<IncomeKind>(IncomeKind.values);
}

class IncomeRow extends DataClass implements Insertable<IncomeRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String deviceId;

  /// `yyyy-MM`.
  final String yearMonth;
  final IncomeKind kind;
  final int amountCents;
  final String description;
  final bool received;
  const IncomeRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.deviceId,
    required this.yearMonth,
    required this.kind,
    required this.amountCents,
    required this.description,
    required this.received,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    map['device_id'] = Variable<String>(deviceId);
    map['year_month'] = Variable<String>(yearMonth);
    {
      map['kind'] = Variable<String>($IncomesTable.$converterkind.toSql(kind));
    }
    map['amount_cents'] = Variable<int>(amountCents);
    map['description'] = Variable<String>(description);
    map['received'] = Variable<bool>(received);
    return map;
  }

  IncomesCompanion toCompanion(bool nullToAbsent) {
    return IncomesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      deviceId: Value(deviceId),
      yearMonth: Value(yearMonth),
      kind: Value(kind),
      amountCents: Value(amountCents),
      description: Value(description),
      received: Value(received),
    );
  }

  factory IncomeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IncomeRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      yearMonth: serializer.fromJson<String>(json['yearMonth']),
      kind: $IncomesTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      description: serializer.fromJson<String>(json['description']),
      received: serializer.fromJson<bool>(json['received']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String>(deviceId),
      'yearMonth': serializer.toJson<String>(yearMonth),
      'kind': serializer.toJson<String>(
        $IncomesTable.$converterkind.toJson(kind),
      ),
      'amountCents': serializer.toJson<int>(amountCents),
      'description': serializer.toJson<String>(description),
      'received': serializer.toJson<bool>(received),
    };
  }

  IncomeRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
    String? deviceId,
    String? yearMonth,
    IncomeKind? kind,
    int? amountCents,
    String? description,
    bool? received,
  }) => IncomeRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    deviceId: deviceId ?? this.deviceId,
    yearMonth: yearMonth ?? this.yearMonth,
    kind: kind ?? this.kind,
    amountCents: amountCents ?? this.amountCents,
    description: description ?? this.description,
    received: received ?? this.received,
  );
  IncomeRow copyWithCompanion(IncomesCompanion data) {
    return IncomeRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      yearMonth: data.yearMonth.present ? data.yearMonth.value : this.yearMonth,
      kind: data.kind.present ? data.kind.value : this.kind,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      description: data.description.present
          ? data.description.value
          : this.description,
      received: data.received.present ? data.received.value : this.received,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IncomeRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('yearMonth: $yearMonth, ')
          ..write('kind: $kind, ')
          ..write('amountCents: $amountCents, ')
          ..write('description: $description, ')
          ..write('received: $received')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    yearMonth,
    kind,
    amountCents,
    description,
    received,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IncomeRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.deviceId == this.deviceId &&
          other.yearMonth == this.yearMonth &&
          other.kind == this.kind &&
          other.amountCents == this.amountCents &&
          other.description == this.description &&
          other.received == this.received);
}

class IncomesCompanion extends UpdateCompanion<IncomeRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<String> deviceId;
  final Value<String> yearMonth;
  final Value<IncomeKind> kind;
  final Value<int> amountCents;
  final Value<String> description;
  final Value<bool> received;
  final Value<int> rowid;
  const IncomesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.yearMonth = const Value.absent(),
    this.kind = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.description = const Value.absent(),
    this.received = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IncomesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    required String yearMonth,
    required IncomeKind kind,
    required int amountCents,
    this.description = const Value.absent(),
    this.received = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       yearMonth = Value(yearMonth),
       kind = Value(kind),
       amountCents = Value(amountCents);
  static Insertable<IncomeRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<String>? yearMonth,
    Expression<String>? kind,
    Expression<int>? amountCents,
    Expression<String>? description,
    Expression<bool>? received,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (yearMonth != null) 'year_month': yearMonth,
      if (kind != null) 'kind': kind,
      if (amountCents != null) 'amount_cents': amountCents,
      if (description != null) 'description': description,
      if (received != null) 'received': received,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IncomesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<String>? deviceId,
    Value<String>? yearMonth,
    Value<IncomeKind>? kind,
    Value<int>? amountCents,
    Value<String>? description,
    Value<bool>? received,
    Value<int>? rowid,
  }) {
    return IncomesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      yearMonth: yearMonth ?? this.yearMonth,
      kind: kind ?? this.kind,
      amountCents: amountCents ?? this.amountCents,
      description: description ?? this.description,
      received: received ?? this.received,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (yearMonth.present) {
      map['year_month'] = Variable<String>(yearMonth.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $IncomesTable.$converterkind.toSql(kind.value),
      );
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (received.present) {
      map['received'] = Variable<bool>(received.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncomesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('yearMonth: $yearMonth, ')
          ..write('kind: $kind, ')
          ..write('amountCents: $amountCents, ')
          ..write('description: $description, ')
          ..write('received: $received, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvestmentsTable extends Investments
    with TableInfo<$InvestmentsTable, InvestmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvestmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _yearMonthMeta = const VerificationMeta(
    'yearMonth',
  );
  @override
  late final GeneratedColumn<String> yearMonth = GeneratedColumn<String>(
    'year_month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedCentsMeta = const VerificationMeta(
    'plannedCents',
  );
  @override
  late final GeneratedColumn<int> plannedCents = GeneratedColumn<int>(
    'planned_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _realizedCentsMeta = const VerificationMeta(
    'realizedCents',
  );
  @override
  late final GeneratedColumn<int> realizedCents = GeneratedColumn<int>(
    'realized_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    yearMonth,
    plannedCents,
    realizedCents,
    description,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'investments';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvestmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('year_month')) {
      context.handle(
        _yearMonthMeta,
        yearMonth.isAcceptableOrUnknown(data['year_month']!, _yearMonthMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMonthMeta);
    }
    if (data.containsKey('planned_cents')) {
      context.handle(
        _plannedCentsMeta,
        plannedCents.isAcceptableOrUnknown(
          data['planned_cents']!,
          _plannedCentsMeta,
        ),
      );
    }
    if (data.containsKey('realized_cents')) {
      context.handle(
        _realizedCentsMeta,
        realizedCents.isAcceptableOrUnknown(
          data['realized_cents']!,
          _realizedCentsMeta,
        ),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvestmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvestmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      yearMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}year_month'],
      )!,
      plannedCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_cents'],
      )!,
      realizedCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}realized_cents'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
    );
  }

  @override
  $InvestmentsTable createAlias(String alias) {
    return $InvestmentsTable(attachedDatabase, alias);
  }
}

class InvestmentRow extends DataClass implements Insertable<InvestmentRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String deviceId;
  final String yearMonth;
  final int plannedCents;
  final int realizedCents;
  final String description;
  const InvestmentRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.deviceId,
    required this.yearMonth,
    required this.plannedCents,
    required this.realizedCents,
    required this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    map['device_id'] = Variable<String>(deviceId);
    map['year_month'] = Variable<String>(yearMonth);
    map['planned_cents'] = Variable<int>(plannedCents);
    map['realized_cents'] = Variable<int>(realizedCents);
    map['description'] = Variable<String>(description);
    return map;
  }

  InvestmentsCompanion toCompanion(bool nullToAbsent) {
    return InvestmentsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      deviceId: Value(deviceId),
      yearMonth: Value(yearMonth),
      plannedCents: Value(plannedCents),
      realizedCents: Value(realizedCents),
      description: Value(description),
    );
  }

  factory InvestmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvestmentRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      yearMonth: serializer.fromJson<String>(json['yearMonth']),
      plannedCents: serializer.fromJson<int>(json['plannedCents']),
      realizedCents: serializer.fromJson<int>(json['realizedCents']),
      description: serializer.fromJson<String>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String>(deviceId),
      'yearMonth': serializer.toJson<String>(yearMonth),
      'plannedCents': serializer.toJson<int>(plannedCents),
      'realizedCents': serializer.toJson<int>(realizedCents),
      'description': serializer.toJson<String>(description),
    };
  }

  InvestmentRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
    String? deviceId,
    String? yearMonth,
    int? plannedCents,
    int? realizedCents,
    String? description,
  }) => InvestmentRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    deviceId: deviceId ?? this.deviceId,
    yearMonth: yearMonth ?? this.yearMonth,
    plannedCents: plannedCents ?? this.plannedCents,
    realizedCents: realizedCents ?? this.realizedCents,
    description: description ?? this.description,
  );
  InvestmentRow copyWithCompanion(InvestmentsCompanion data) {
    return InvestmentRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      yearMonth: data.yearMonth.present ? data.yearMonth.value : this.yearMonth,
      plannedCents: data.plannedCents.present
          ? data.plannedCents.value
          : this.plannedCents,
      realizedCents: data.realizedCents.present
          ? data.realizedCents.value
          : this.realizedCents,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('yearMonth: $yearMonth, ')
          ..write('plannedCents: $plannedCents, ')
          ..write('realizedCents: $realizedCents, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    yearMonth,
    plannedCents,
    realizedCents,
    description,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvestmentRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.deviceId == this.deviceId &&
          other.yearMonth == this.yearMonth &&
          other.plannedCents == this.plannedCents &&
          other.realizedCents == this.realizedCents &&
          other.description == this.description);
}

class InvestmentsCompanion extends UpdateCompanion<InvestmentRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<String> deviceId;
  final Value<String> yearMonth;
  final Value<int> plannedCents;
  final Value<int> realizedCents;
  final Value<String> description;
  final Value<int> rowid;
  const InvestmentsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.yearMonth = const Value.absent(),
    this.plannedCents = const Value.absent(),
    this.realizedCents = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvestmentsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    required String yearMonth,
    this.plannedCents = const Value.absent(),
    this.realizedCents = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       yearMonth = Value(yearMonth);
  static Insertable<InvestmentRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<String>? yearMonth,
    Expression<int>? plannedCents,
    Expression<int>? realizedCents,
    Expression<String>? description,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (yearMonth != null) 'year_month': yearMonth,
      if (plannedCents != null) 'planned_cents': plannedCents,
      if (realizedCents != null) 'realized_cents': realizedCents,
      if (description != null) 'description': description,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvestmentsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<String>? deviceId,
    Value<String>? yearMonth,
    Value<int>? plannedCents,
    Value<int>? realizedCents,
    Value<String>? description,
    Value<int>? rowid,
  }) {
    return InvestmentsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      yearMonth: yearMonth ?? this.yearMonth,
      plannedCents: plannedCents ?? this.plannedCents,
      realizedCents: realizedCents ?? this.realizedCents,
      description: description ?? this.description,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (yearMonth.present) {
      map['year_month'] = Variable<String>(yearMonth.value);
    }
    if (plannedCents.present) {
      map['planned_cents'] = Variable<int>(plannedCents.value);
    }
    if (realizedCents.present) {
      map['realized_cents'] = Variable<int>(realizedCents.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('yearMonth: $yearMonth, ')
          ..write('plannedCents: $plannedCents, ')
          ..write('realizedCents: $realizedCents, ')
          ..write('description: $description, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanningsTable extends Plannings
    with TableInfo<$PlanningsTable, PlanningRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanningsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _defaultSalaryCentsMeta =
      const VerificationMeta('defaultSalaryCents');
  @override
  late final GeneratedColumn<int> defaultSalaryCents = GeneratedColumn<int>(
    'default_salary_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _defaultExtraIncomeCentsMeta =
      const VerificationMeta('defaultExtraIncomeCents');
  @override
  late final GeneratedColumn<int> defaultExtraIncomeCents =
      GeneratedColumn<int>(
        'default_extra_income_cents',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _defaultSavingsGoalCentsMeta =
      const VerificationMeta('defaultSavingsGoalCents');
  @override
  late final GeneratedColumn<int> defaultSavingsGoalCents =
      GeneratedColumn<int>(
        'default_savings_goal_cents',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _defaultInvestmentCentsMeta =
      const VerificationMeta('defaultInvestmentCents');
  @override
  late final GeneratedColumn<int> defaultInvestmentCents = GeneratedColumn<int>(
    'default_investment_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    defaultSalaryCents,
    defaultExtraIncomeCents,
    defaultSavingsGoalCents,
    defaultInvestmentCents,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plannings';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanningRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('default_salary_cents')) {
      context.handle(
        _defaultSalaryCentsMeta,
        defaultSalaryCents.isAcceptableOrUnknown(
          data['default_salary_cents']!,
          _defaultSalaryCentsMeta,
        ),
      );
    }
    if (data.containsKey('default_extra_income_cents')) {
      context.handle(
        _defaultExtraIncomeCentsMeta,
        defaultExtraIncomeCents.isAcceptableOrUnknown(
          data['default_extra_income_cents']!,
          _defaultExtraIncomeCentsMeta,
        ),
      );
    }
    if (data.containsKey('default_savings_goal_cents')) {
      context.handle(
        _defaultSavingsGoalCentsMeta,
        defaultSavingsGoalCents.isAcceptableOrUnknown(
          data['default_savings_goal_cents']!,
          _defaultSavingsGoalCentsMeta,
        ),
      );
    }
    if (data.containsKey('default_investment_cents')) {
      context.handle(
        _defaultInvestmentCentsMeta,
        defaultInvestmentCents.isAcceptableOrUnknown(
          data['default_investment_cents']!,
          _defaultInvestmentCentsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanningRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanningRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      defaultSalaryCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_salary_cents'],
      )!,
      defaultExtraIncomeCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_extra_income_cents'],
      )!,
      defaultSavingsGoalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_savings_goal_cents'],
      )!,
      defaultInvestmentCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_investment_cents'],
      )!,
    );
  }

  @override
  $PlanningsTable createAlias(String alias) {
    return $PlanningsTable(attachedDatabase, alias);
  }
}

class PlanningRow extends DataClass implements Insertable<PlanningRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String deviceId;
  final int defaultSalaryCents;
  final int defaultExtraIncomeCents;
  final int defaultSavingsGoalCents;
  final int defaultInvestmentCents;
  const PlanningRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.deviceId,
    required this.defaultSalaryCents,
    required this.defaultExtraIncomeCents,
    required this.defaultSavingsGoalCents,
    required this.defaultInvestmentCents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    map['device_id'] = Variable<String>(deviceId);
    map['default_salary_cents'] = Variable<int>(defaultSalaryCents);
    map['default_extra_income_cents'] = Variable<int>(defaultExtraIncomeCents);
    map['default_savings_goal_cents'] = Variable<int>(defaultSavingsGoalCents);
    map['default_investment_cents'] = Variable<int>(defaultInvestmentCents);
    return map;
  }

  PlanningsCompanion toCompanion(bool nullToAbsent) {
    return PlanningsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      deviceId: Value(deviceId),
      defaultSalaryCents: Value(defaultSalaryCents),
      defaultExtraIncomeCents: Value(defaultExtraIncomeCents),
      defaultSavingsGoalCents: Value(defaultSavingsGoalCents),
      defaultInvestmentCents: Value(defaultInvestmentCents),
    );
  }

  factory PlanningRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanningRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      defaultSalaryCents: serializer.fromJson<int>(json['defaultSalaryCents']),
      defaultExtraIncomeCents: serializer.fromJson<int>(
        json['defaultExtraIncomeCents'],
      ),
      defaultSavingsGoalCents: serializer.fromJson<int>(
        json['defaultSavingsGoalCents'],
      ),
      defaultInvestmentCents: serializer.fromJson<int>(
        json['defaultInvestmentCents'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String>(deviceId),
      'defaultSalaryCents': serializer.toJson<int>(defaultSalaryCents),
      'defaultExtraIncomeCents': serializer.toJson<int>(
        defaultExtraIncomeCents,
      ),
      'defaultSavingsGoalCents': serializer.toJson<int>(
        defaultSavingsGoalCents,
      ),
      'defaultInvestmentCents': serializer.toJson<int>(defaultInvestmentCents),
    };
  }

  PlanningRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
    String? deviceId,
    int? defaultSalaryCents,
    int? defaultExtraIncomeCents,
    int? defaultSavingsGoalCents,
    int? defaultInvestmentCents,
  }) => PlanningRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    deviceId: deviceId ?? this.deviceId,
    defaultSalaryCents: defaultSalaryCents ?? this.defaultSalaryCents,
    defaultExtraIncomeCents:
        defaultExtraIncomeCents ?? this.defaultExtraIncomeCents,
    defaultSavingsGoalCents:
        defaultSavingsGoalCents ?? this.defaultSavingsGoalCents,
    defaultInvestmentCents:
        defaultInvestmentCents ?? this.defaultInvestmentCents,
  );
  PlanningRow copyWithCompanion(PlanningsCompanion data) {
    return PlanningRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      defaultSalaryCents: data.defaultSalaryCents.present
          ? data.defaultSalaryCents.value
          : this.defaultSalaryCents,
      defaultExtraIncomeCents: data.defaultExtraIncomeCents.present
          ? data.defaultExtraIncomeCents.value
          : this.defaultExtraIncomeCents,
      defaultSavingsGoalCents: data.defaultSavingsGoalCents.present
          ? data.defaultSavingsGoalCents.value
          : this.defaultSavingsGoalCents,
      defaultInvestmentCents: data.defaultInvestmentCents.present
          ? data.defaultInvestmentCents.value
          : this.defaultInvestmentCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanningRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('defaultSalaryCents: $defaultSalaryCents, ')
          ..write('defaultExtraIncomeCents: $defaultExtraIncomeCents, ')
          ..write('defaultSavingsGoalCents: $defaultSavingsGoalCents, ')
          ..write('defaultInvestmentCents: $defaultInvestmentCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    defaultSalaryCents,
    defaultExtraIncomeCents,
    defaultSavingsGoalCents,
    defaultInvestmentCents,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanningRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.deviceId == this.deviceId &&
          other.defaultSalaryCents == this.defaultSalaryCents &&
          other.defaultExtraIncomeCents == this.defaultExtraIncomeCents &&
          other.defaultSavingsGoalCents == this.defaultSavingsGoalCents &&
          other.defaultInvestmentCents == this.defaultInvestmentCents);
}

class PlanningsCompanion extends UpdateCompanion<PlanningRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<String> deviceId;
  final Value<int> defaultSalaryCents;
  final Value<int> defaultExtraIncomeCents;
  final Value<int> defaultSavingsGoalCents;
  final Value<int> defaultInvestmentCents;
  final Value<int> rowid;
  const PlanningsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.defaultSalaryCents = const Value.absent(),
    this.defaultExtraIncomeCents = const Value.absent(),
    this.defaultSavingsGoalCents = const Value.absent(),
    this.defaultInvestmentCents = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanningsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.defaultSalaryCents = const Value.absent(),
    this.defaultExtraIncomeCents = const Value.absent(),
    this.defaultSavingsGoalCents = const Value.absent(),
    this.defaultInvestmentCents = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PlanningRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<int>? defaultSalaryCents,
    Expression<int>? defaultExtraIncomeCents,
    Expression<int>? defaultSavingsGoalCents,
    Expression<int>? defaultInvestmentCents,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (defaultSalaryCents != null)
        'default_salary_cents': defaultSalaryCents,
      if (defaultExtraIncomeCents != null)
        'default_extra_income_cents': defaultExtraIncomeCents,
      if (defaultSavingsGoalCents != null)
        'default_savings_goal_cents': defaultSavingsGoalCents,
      if (defaultInvestmentCents != null)
        'default_investment_cents': defaultInvestmentCents,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanningsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<String>? deviceId,
    Value<int>? defaultSalaryCents,
    Value<int>? defaultExtraIncomeCents,
    Value<int>? defaultSavingsGoalCents,
    Value<int>? defaultInvestmentCents,
    Value<int>? rowid,
  }) {
    return PlanningsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      defaultSalaryCents: defaultSalaryCents ?? this.defaultSalaryCents,
      defaultExtraIncomeCents:
          defaultExtraIncomeCents ?? this.defaultExtraIncomeCents,
      defaultSavingsGoalCents:
          defaultSavingsGoalCents ?? this.defaultSavingsGoalCents,
      defaultInvestmentCents:
          defaultInvestmentCents ?? this.defaultInvestmentCents,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (defaultSalaryCents.present) {
      map['default_salary_cents'] = Variable<int>(defaultSalaryCents.value);
    }
    if (defaultExtraIncomeCents.present) {
      map['default_extra_income_cents'] = Variable<int>(
        defaultExtraIncomeCents.value,
      );
    }
    if (defaultSavingsGoalCents.present) {
      map['default_savings_goal_cents'] = Variable<int>(
        defaultSavingsGoalCents.value,
      );
    }
    if (defaultInvestmentCents.present) {
      map['default_investment_cents'] = Variable<int>(
        defaultInvestmentCents.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanningsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('defaultSalaryCents: $defaultSalaryCents, ')
          ..write('defaultExtraIncomeCents: $defaultExtraIncomeCents, ')
          ..write('defaultSavingsGoalCents: $defaultSavingsGoalCents, ')
          ..write('defaultInvestmentCents: $defaultInvestmentCents, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MonthConfigurationsTable extends MonthConfigurations
    with TableInfo<$MonthConfigurationsTable, MonthConfigRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MonthConfigurationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _yearMonthMeta = const VerificationMeta(
    'yearMonth',
  );
  @override
  late final GeneratedColumn<String> yearMonth = GeneratedColumn<String>(
    'year_month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _salaryCentsMeta = const VerificationMeta(
    'salaryCents',
  );
  @override
  late final GeneratedColumn<int> salaryCents = GeneratedColumn<int>(
    'salary_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extraIncomeCentsMeta = const VerificationMeta(
    'extraIncomeCents',
  );
  @override
  late final GeneratedColumn<int> extraIncomeCents = GeneratedColumn<int>(
    'extra_income_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _savingsGoalCentsMeta = const VerificationMeta(
    'savingsGoalCents',
  );
  @override
  late final GeneratedColumn<int> savingsGoalCents = GeneratedColumn<int>(
    'savings_goal_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _investmentCentsMeta = const VerificationMeta(
    'investmentCents',
  );
  @override
  late final GeneratedColumn<int> investmentCents = GeneratedColumn<int>(
    'investment_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    yearMonth,
    salaryCents,
    extraIncomeCents,
    savingsGoalCents,
    investmentCents,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'month_configurations';
  @override
  VerificationContext validateIntegrity(
    Insertable<MonthConfigRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('year_month')) {
      context.handle(
        _yearMonthMeta,
        yearMonth.isAcceptableOrUnknown(data['year_month']!, _yearMonthMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMonthMeta);
    }
    if (data.containsKey('salary_cents')) {
      context.handle(
        _salaryCentsMeta,
        salaryCents.isAcceptableOrUnknown(
          data['salary_cents']!,
          _salaryCentsMeta,
        ),
      );
    }
    if (data.containsKey('extra_income_cents')) {
      context.handle(
        _extraIncomeCentsMeta,
        extraIncomeCents.isAcceptableOrUnknown(
          data['extra_income_cents']!,
          _extraIncomeCentsMeta,
        ),
      );
    }
    if (data.containsKey('savings_goal_cents')) {
      context.handle(
        _savingsGoalCentsMeta,
        savingsGoalCents.isAcceptableOrUnknown(
          data['savings_goal_cents']!,
          _savingsGoalCentsMeta,
        ),
      );
    }
    if (data.containsKey('investment_cents')) {
      context.handle(
        _investmentCentsMeta,
        investmentCents.isAcceptableOrUnknown(
          data['investment_cents']!,
          _investmentCentsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MonthConfigRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MonthConfigRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      yearMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}year_month'],
      )!,
      salaryCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}salary_cents'],
      ),
      extraIncomeCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}extra_income_cents'],
      ),
      savingsGoalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}savings_goal_cents'],
      ),
      investmentCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}investment_cents'],
      ),
    );
  }

  @override
  $MonthConfigurationsTable createAlias(String alias) {
    return $MonthConfigurationsTable(attachedDatabase, alias);
  }
}

class MonthConfigRow extends DataClass implements Insertable<MonthConfigRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String deviceId;
  final String yearMonth;
  final int? salaryCents;
  final int? extraIncomeCents;
  final int? savingsGoalCents;
  final int? investmentCents;
  const MonthConfigRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.deviceId,
    required this.yearMonth,
    this.salaryCents,
    this.extraIncomeCents,
    this.savingsGoalCents,
    this.investmentCents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    map['device_id'] = Variable<String>(deviceId);
    map['year_month'] = Variable<String>(yearMonth);
    if (!nullToAbsent || salaryCents != null) {
      map['salary_cents'] = Variable<int>(salaryCents);
    }
    if (!nullToAbsent || extraIncomeCents != null) {
      map['extra_income_cents'] = Variable<int>(extraIncomeCents);
    }
    if (!nullToAbsent || savingsGoalCents != null) {
      map['savings_goal_cents'] = Variable<int>(savingsGoalCents);
    }
    if (!nullToAbsent || investmentCents != null) {
      map['investment_cents'] = Variable<int>(investmentCents);
    }
    return map;
  }

  MonthConfigurationsCompanion toCompanion(bool nullToAbsent) {
    return MonthConfigurationsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      deviceId: Value(deviceId),
      yearMonth: Value(yearMonth),
      salaryCents: salaryCents == null && nullToAbsent
          ? const Value.absent()
          : Value(salaryCents),
      extraIncomeCents: extraIncomeCents == null && nullToAbsent
          ? const Value.absent()
          : Value(extraIncomeCents),
      savingsGoalCents: savingsGoalCents == null && nullToAbsent
          ? const Value.absent()
          : Value(savingsGoalCents),
      investmentCents: investmentCents == null && nullToAbsent
          ? const Value.absent()
          : Value(investmentCents),
    );
  }

  factory MonthConfigRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MonthConfigRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      yearMonth: serializer.fromJson<String>(json['yearMonth']),
      salaryCents: serializer.fromJson<int?>(json['salaryCents']),
      extraIncomeCents: serializer.fromJson<int?>(json['extraIncomeCents']),
      savingsGoalCents: serializer.fromJson<int?>(json['savingsGoalCents']),
      investmentCents: serializer.fromJson<int?>(json['investmentCents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String>(deviceId),
      'yearMonth': serializer.toJson<String>(yearMonth),
      'salaryCents': serializer.toJson<int?>(salaryCents),
      'extraIncomeCents': serializer.toJson<int?>(extraIncomeCents),
      'savingsGoalCents': serializer.toJson<int?>(savingsGoalCents),
      'investmentCents': serializer.toJson<int?>(investmentCents),
    };
  }

  MonthConfigRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
    String? deviceId,
    String? yearMonth,
    Value<int?> salaryCents = const Value.absent(),
    Value<int?> extraIncomeCents = const Value.absent(),
    Value<int?> savingsGoalCents = const Value.absent(),
    Value<int?> investmentCents = const Value.absent(),
  }) => MonthConfigRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    deviceId: deviceId ?? this.deviceId,
    yearMonth: yearMonth ?? this.yearMonth,
    salaryCents: salaryCents.present ? salaryCents.value : this.salaryCents,
    extraIncomeCents: extraIncomeCents.present
        ? extraIncomeCents.value
        : this.extraIncomeCents,
    savingsGoalCents: savingsGoalCents.present
        ? savingsGoalCents.value
        : this.savingsGoalCents,
    investmentCents: investmentCents.present
        ? investmentCents.value
        : this.investmentCents,
  );
  MonthConfigRow copyWithCompanion(MonthConfigurationsCompanion data) {
    return MonthConfigRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      yearMonth: data.yearMonth.present ? data.yearMonth.value : this.yearMonth,
      salaryCents: data.salaryCents.present
          ? data.salaryCents.value
          : this.salaryCents,
      extraIncomeCents: data.extraIncomeCents.present
          ? data.extraIncomeCents.value
          : this.extraIncomeCents,
      savingsGoalCents: data.savingsGoalCents.present
          ? data.savingsGoalCents.value
          : this.savingsGoalCents,
      investmentCents: data.investmentCents.present
          ? data.investmentCents.value
          : this.investmentCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MonthConfigRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('yearMonth: $yearMonth, ')
          ..write('salaryCents: $salaryCents, ')
          ..write('extraIncomeCents: $extraIncomeCents, ')
          ..write('savingsGoalCents: $savingsGoalCents, ')
          ..write('investmentCents: $investmentCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    yearMonth,
    salaryCents,
    extraIncomeCents,
    savingsGoalCents,
    investmentCents,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonthConfigRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.deviceId == this.deviceId &&
          other.yearMonth == this.yearMonth &&
          other.salaryCents == this.salaryCents &&
          other.extraIncomeCents == this.extraIncomeCents &&
          other.savingsGoalCents == this.savingsGoalCents &&
          other.investmentCents == this.investmentCents);
}

class MonthConfigurationsCompanion extends UpdateCompanion<MonthConfigRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<String> deviceId;
  final Value<String> yearMonth;
  final Value<int?> salaryCents;
  final Value<int?> extraIncomeCents;
  final Value<int?> savingsGoalCents;
  final Value<int?> investmentCents;
  final Value<int> rowid;
  const MonthConfigurationsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.yearMonth = const Value.absent(),
    this.salaryCents = const Value.absent(),
    this.extraIncomeCents = const Value.absent(),
    this.savingsGoalCents = const Value.absent(),
    this.investmentCents = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MonthConfigurationsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    required String yearMonth,
    this.salaryCents = const Value.absent(),
    this.extraIncomeCents = const Value.absent(),
    this.savingsGoalCents = const Value.absent(),
    this.investmentCents = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       yearMonth = Value(yearMonth);
  static Insertable<MonthConfigRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<String>? yearMonth,
    Expression<int>? salaryCents,
    Expression<int>? extraIncomeCents,
    Expression<int>? savingsGoalCents,
    Expression<int>? investmentCents,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (yearMonth != null) 'year_month': yearMonth,
      if (salaryCents != null) 'salary_cents': salaryCents,
      if (extraIncomeCents != null) 'extra_income_cents': extraIncomeCents,
      if (savingsGoalCents != null) 'savings_goal_cents': savingsGoalCents,
      if (investmentCents != null) 'investment_cents': investmentCents,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MonthConfigurationsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<String>? deviceId,
    Value<String>? yearMonth,
    Value<int?>? salaryCents,
    Value<int?>? extraIncomeCents,
    Value<int?>? savingsGoalCents,
    Value<int?>? investmentCents,
    Value<int>? rowid,
  }) {
    return MonthConfigurationsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      yearMonth: yearMonth ?? this.yearMonth,
      salaryCents: salaryCents ?? this.salaryCents,
      extraIncomeCents: extraIncomeCents ?? this.extraIncomeCents,
      savingsGoalCents: savingsGoalCents ?? this.savingsGoalCents,
      investmentCents: investmentCents ?? this.investmentCents,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (yearMonth.present) {
      map['year_month'] = Variable<String>(yearMonth.value);
    }
    if (salaryCents.present) {
      map['salary_cents'] = Variable<int>(salaryCents.value);
    }
    if (extraIncomeCents.present) {
      map['extra_income_cents'] = Variable<int>(extraIncomeCents.value);
    }
    if (savingsGoalCents.present) {
      map['savings_goal_cents'] = Variable<int>(savingsGoalCents.value);
    }
    if (investmentCents.present) {
      map['investment_cents'] = Variable<int>(investmentCents.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MonthConfigurationsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('yearMonth: $yearMonth, ')
          ..write('salaryCents: $salaryCents, ')
          ..write('extraIncomeCents: $extraIncomeCents, ')
          ..write('savingsGoalCents: $savingsGoalCents, ')
          ..write('investmentCents: $investmentCents, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTable extends SyncMetadata
    with TableInfo<$SyncMetadataTable, SyncMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _lastSyncAtMeta = const VerificationMeta(
    'lastSyncAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
    'last_sync_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remoteCursorMeta = const VerificationMeta(
    'remoteCursor',
  );
  @override
  late final GeneratedColumn<String> remoteCursor = GeneratedColumn<String>(
    'remote_cursor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncState, String> state =
      GeneratedColumn<String>(
        'state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('disconnected'),
      ).withConverter<SyncState>($SyncMetadataTable.$converterstate);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    lastSyncAt,
    remoteCursor,
    state,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
        _lastSyncAtMeta,
        lastSyncAt.isAcceptableOrUnknown(
          data['last_sync_at']!,
          _lastSyncAtMeta,
        ),
      );
    }
    if (data.containsKey('remote_cursor')) {
      context.handle(
        _remoteCursorMeta,
        remoteCursor.isAcceptableOrUnknown(
          data['remote_cursor']!,
          _remoteCursorMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      lastSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_at'],
      ),
      remoteCursor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_cursor'],
      ),
      state: $SyncMetadataTable.$converterstate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}state'],
        )!,
      ),
    );
  }

  @override
  $SyncMetadataTable createAlias(String alias) {
    return $SyncMetadataTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncState, String, String> $converterstate =
      const EnumNameConverter<SyncState>(SyncState.values);
}

class SyncMetaRow extends DataClass implements Insertable<SyncMetaRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String deviceId;
  final DateTime? lastSyncAt;
  final String? remoteCursor;
  final SyncState state;
  const SyncMetaRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.deviceId,
    this.lastSyncAt,
    this.remoteCursor,
    required this.state,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    if (!nullToAbsent || remoteCursor != null) {
      map['remote_cursor'] = Variable<String>(remoteCursor);
    }
    {
      map['state'] = Variable<String>(
        $SyncMetadataTable.$converterstate.toSql(state),
      );
    }
    return map;
  }

  SyncMetadataCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      deviceId: Value(deviceId),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
      remoteCursor: remoteCursor == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteCursor),
      state: Value(state),
    );
  }

  factory SyncMetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetaRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
      remoteCursor: serializer.fromJson<String?>(json['remoteCursor']),
      state: $SyncMetadataTable.$converterstate.fromJson(
        serializer.fromJson<String>(json['state']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String>(deviceId),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
      'remoteCursor': serializer.toJson<String?>(remoteCursor),
      'state': serializer.toJson<String>(
        $SyncMetadataTable.$converterstate.toJson(state),
      ),
    };
  }

  SyncMetaRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
    String? deviceId,
    Value<DateTime?> lastSyncAt = const Value.absent(),
    Value<String?> remoteCursor = const Value.absent(),
    SyncState? state,
  }) => SyncMetaRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    deviceId: deviceId ?? this.deviceId,
    lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
    remoteCursor: remoteCursor.present ? remoteCursor.value : this.remoteCursor,
    state: state ?? this.state,
  );
  SyncMetaRow copyWithCompanion(SyncMetadataCompanion data) {
    return SyncMetaRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      lastSyncAt: data.lastSyncAt.present
          ? data.lastSyncAt.value
          : this.lastSyncAt,
      remoteCursor: data.remoteCursor.present
          ? data.remoteCursor.value
          : this.remoteCursor,
      state: data.state.present ? data.state.value : this.state,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('remoteCursor: $remoteCursor, ')
          ..write('state: $state')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    lastSyncAt,
    remoteCursor,
    state,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetaRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.deviceId == this.deviceId &&
          other.lastSyncAt == this.lastSyncAt &&
          other.remoteCursor == this.remoteCursor &&
          other.state == this.state);
}

class SyncMetadataCompanion extends UpdateCompanion<SyncMetaRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<String> deviceId;
  final Value<DateTime?> lastSyncAt;
  final Value<String?> remoteCursor;
  final Value<SyncState> state;
  final Value<int> rowid;
  const SyncMetadataCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.remoteCursor = const Value.absent(),
    this.state = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetadataCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.remoteCursor = const Value.absent(),
    this.state = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SyncMetaRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<DateTime>? lastSyncAt,
    Expression<String>? remoteCursor,
    Expression<String>? state,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (remoteCursor != null) 'remote_cursor': remoteCursor,
      if (state != null) 'state': state,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetadataCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<String>? deviceId,
    Value<DateTime?>? lastSyncAt,
    Value<String?>? remoteCursor,
    Value<SyncState>? state,
    Value<int>? rowid,
  }) {
    return SyncMetadataCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      remoteCursor: remoteCursor ?? this.remoteCursor,
      state: state ?? this.state,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (remoteCursor.present) {
      map['remote_cursor'] = Variable<String>(remoteCursor.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(
        $SyncMetadataTable.$converterstate.toSql(state.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('remoteCursor: $remoteCursor, ')
          ..write('state: $state, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncConflictsTable extends SyncConflicts
    with TableInfo<$SyncConflictsTable, SyncConflictRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncConflictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localJsonMeta = const VerificationMeta(
    'localJson',
  );
  @override
  late final GeneratedColumn<String> localJson = GeneratedColumn<String>(
    'local_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteJsonMeta = const VerificationMeta(
    'remoteJson',
  );
  @override
  late final GeneratedColumn<String> remoteJson = GeneratedColumn<String>(
    'remote_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    entity,
    recordId,
    localJson,
    remoteJson,
    resolvedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncConflictRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('local_json')) {
      context.handle(
        _localJsonMeta,
        localJson.isAcceptableOrUnknown(data['local_json']!, _localJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_localJsonMeta);
    }
    if (data.containsKey('remote_json')) {
      context.handle(
        _remoteJsonMeta,
        remoteJson.isAcceptableOrUnknown(data['remote_json']!, _remoteJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteJsonMeta);
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
  SyncConflictRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncConflictRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      localJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_json'],
      )!,
      remoteJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_json'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
    );
  }

  @override
  $SyncConflictsTable createAlias(String alias) {
    return $SyncConflictsTable(attachedDatabase, alias);
  }
}

class SyncConflictRow extends DataClass implements Insertable<SyncConflictRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String deviceId;
  final String entity;
  final String recordId;
  final String localJson;
  final String remoteJson;
  final DateTime? resolvedAt;
  const SyncConflictRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.deviceId,
    required this.entity,
    required this.recordId,
    required this.localJson,
    required this.remoteJson,
    this.resolvedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    map['device_id'] = Variable<String>(deviceId);
    map['entity'] = Variable<String>(entity);
    map['record_id'] = Variable<String>(recordId);
    map['local_json'] = Variable<String>(localJson);
    map['remote_json'] = Variable<String>(remoteJson);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    return map;
  }

  SyncConflictsCompanion toCompanion(bool nullToAbsent) {
    return SyncConflictsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      deviceId: Value(deviceId),
      entity: Value(entity),
      recordId: Value(recordId),
      localJson: Value(localJson),
      remoteJson: Value(remoteJson),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
    );
  }

  factory SyncConflictRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncConflictRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      entity: serializer.fromJson<String>(json['entity']),
      recordId: serializer.fromJson<String>(json['recordId']),
      localJson: serializer.fromJson<String>(json['localJson']),
      remoteJson: serializer.fromJson<String>(json['remoteJson']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String>(deviceId),
      'entity': serializer.toJson<String>(entity),
      'recordId': serializer.toJson<String>(recordId),
      'localJson': serializer.toJson<String>(localJson),
      'remoteJson': serializer.toJson<String>(remoteJson),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
    };
  }

  SyncConflictRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
    String? deviceId,
    String? entity,
    String? recordId,
    String? localJson,
    String? remoteJson,
    Value<DateTime?> resolvedAt = const Value.absent(),
  }) => SyncConflictRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    deviceId: deviceId ?? this.deviceId,
    entity: entity ?? this.entity,
    recordId: recordId ?? this.recordId,
    localJson: localJson ?? this.localJson,
    remoteJson: remoteJson ?? this.remoteJson,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
  );
  SyncConflictRow copyWithCompanion(SyncConflictsCompanion data) {
    return SyncConflictRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      entity: data.entity.present ? data.entity.value : this.entity,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      localJson: data.localJson.present ? data.localJson.value : this.localJson,
      remoteJson: data.remoteJson.present
          ? data.remoteJson.value
          : this.remoteJson,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('entity: $entity, ')
          ..write('recordId: $recordId, ')
          ..write('localJson: $localJson, ')
          ..write('remoteJson: $remoteJson, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    entity,
    recordId,
    localJson,
    remoteJson,
    resolvedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncConflictRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.deviceId == this.deviceId &&
          other.entity == this.entity &&
          other.recordId == this.recordId &&
          other.localJson == this.localJson &&
          other.remoteJson == this.remoteJson &&
          other.resolvedAt == this.resolvedAt);
}

class SyncConflictsCompanion extends UpdateCompanion<SyncConflictRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<String> deviceId;
  final Value<String> entity;
  final Value<String> recordId;
  final Value<String> localJson;
  final Value<String> remoteJson;
  final Value<DateTime?> resolvedAt;
  final Value<int> rowid;
  const SyncConflictsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.entity = const Value.absent(),
    this.recordId = const Value.absent(),
    this.localJson = const Value.absent(),
    this.remoteJson = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncConflictsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    required String entity,
    required String recordId,
    required String localJson,
    required String remoteJson,
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       entity = Value(entity),
       recordId = Value(recordId),
       localJson = Value(localJson),
       remoteJson = Value(remoteJson);
  static Insertable<SyncConflictRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<String>? entity,
    Expression<String>? recordId,
    Expression<String>? localJson,
    Expression<String>? remoteJson,
    Expression<DateTime>? resolvedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (entity != null) 'entity': entity,
      if (recordId != null) 'record_id': recordId,
      if (localJson != null) 'local_json': localJson,
      if (remoteJson != null) 'remote_json': remoteJson,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncConflictsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<String>? deviceId,
    Value<String>? entity,
    Value<String>? recordId,
    Value<String>? localJson,
    Value<String>? remoteJson,
    Value<DateTime?>? resolvedAt,
    Value<int>? rowid,
  }) {
    return SyncConflictsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      entity: entity ?? this.entity,
      recordId: recordId ?? this.recordId,
      localJson: localJson ?? this.localJson,
      remoteJson: remoteJson ?? this.remoteJson,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (localJson.present) {
      map['local_json'] = Variable<String>(localJson.value);
    }
    if (remoteJson.present) {
      map['remote_json'] = Variable<String>(remoteJson.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('entity: $entity, ')
          ..write('recordId: $recordId, ')
          ..write('localJson: $localJson, ')
          ..write('remoteJson: $remoteJson, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncBaseTable extends SyncBase
    with TableInfo<$SyncBaseTable, SyncBaseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncBaseTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [entity, recordId, json];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_base';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncBaseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entity, recordId};
  @override
  SyncBaseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncBaseRow(
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
    );
  }

  @override
  $SyncBaseTable createAlias(String alias) {
    return $SyncBaseTable(attachedDatabase, alias);
  }
}

class SyncBaseRow extends DataClass implements Insertable<SyncBaseRow> {
  final String entity;
  final String recordId;
  final String json;
  const SyncBaseRow({
    required this.entity,
    required this.recordId,
    required this.json,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity'] = Variable<String>(entity);
    map['record_id'] = Variable<String>(recordId);
    map['json'] = Variable<String>(json);
    return map;
  }

  SyncBaseCompanion toCompanion(bool nullToAbsent) {
    return SyncBaseCompanion(
      entity: Value(entity),
      recordId: Value(recordId),
      json: Value(json),
    );
  }

  factory SyncBaseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncBaseRow(
      entity: serializer.fromJson<String>(json['entity']),
      recordId: serializer.fromJson<String>(json['recordId']),
      json: serializer.fromJson<String>(json['json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entity': serializer.toJson<String>(entity),
      'recordId': serializer.toJson<String>(recordId),
      'json': serializer.toJson<String>(json),
    };
  }

  SyncBaseRow copyWith({String? entity, String? recordId, String? json}) =>
      SyncBaseRow(
        entity: entity ?? this.entity,
        recordId: recordId ?? this.recordId,
        json: json ?? this.json,
      );
  SyncBaseRow copyWithCompanion(SyncBaseCompanion data) {
    return SyncBaseRow(
      entity: data.entity.present ? data.entity.value : this.entity,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      json: data.json.present ? data.json.value : this.json,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncBaseRow(')
          ..write('entity: $entity, ')
          ..write('recordId: $recordId, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entity, recordId, json);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncBaseRow &&
          other.entity == this.entity &&
          other.recordId == this.recordId &&
          other.json == this.json);
}

class SyncBaseCompanion extends UpdateCompanion<SyncBaseRow> {
  final Value<String> entity;
  final Value<String> recordId;
  final Value<String> json;
  final Value<int> rowid;
  const SyncBaseCompanion({
    this.entity = const Value.absent(),
    this.recordId = const Value.absent(),
    this.json = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncBaseCompanion.insert({
    required String entity,
    required String recordId,
    required String json,
    this.rowid = const Value.absent(),
  }) : entity = Value(entity),
       recordId = Value(recordId),
       json = Value(json);
  static Insertable<SyncBaseRow> custom({
    Expression<String>? entity,
    Expression<String>? recordId,
    Expression<String>? json,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entity != null) 'entity': entity,
      if (recordId != null) 'record_id': recordId,
      if (json != null) 'json': json,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncBaseCompanion copyWith({
    Value<String>? entity,
    Value<String>? recordId,
    Value<String>? json,
    Value<int>? rowid,
  }) {
    return SyncBaseCompanion(
      entity: entity ?? this.entity,
      recordId: recordId ?? this.recordId,
      json: json ?? this.json,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncBaseCompanion(')
          ..write('entity: $entity, ')
          ..write('recordId: $recordId, ')
          ..write('json: $json, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanningDefaultsVersionsTable extends PlanningDefaultsVersions
    with TableInfo<$PlanningDefaultsVersionsTable, DefaultsVersionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanningDefaultsVersionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _effectiveFromMeta = const VerificationMeta(
    'effectiveFrom',
  );
  @override
  late final GeneratedColumn<String> effectiveFrom = GeneratedColumn<String>(
    'effective_from',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _salaryCentsMeta = const VerificationMeta(
    'salaryCents',
  );
  @override
  late final GeneratedColumn<int> salaryCents = GeneratedColumn<int>(
    'salary_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _extraIncomeCentsMeta = const VerificationMeta(
    'extraIncomeCents',
  );
  @override
  late final GeneratedColumn<int> extraIncomeCents = GeneratedColumn<int>(
    'extra_income_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _savingsGoalCentsMeta = const VerificationMeta(
    'savingsGoalCents',
  );
  @override
  late final GeneratedColumn<int> savingsGoalCents = GeneratedColumn<int>(
    'savings_goal_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _investmentCentsMeta = const VerificationMeta(
    'investmentCents',
  );
  @override
  late final GeneratedColumn<int> investmentCents = GeneratedColumn<int>(
    'investment_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    effectiveFrom,
    salaryCents,
    extraIncomeCents,
    savingsGoalCents,
    investmentCents,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'planning_defaults_versions';
  @override
  VerificationContext validateIntegrity(
    Insertable<DefaultsVersionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('effective_from')) {
      context.handle(
        _effectiveFromMeta,
        effectiveFrom.isAcceptableOrUnknown(
          data['effective_from']!,
          _effectiveFromMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveFromMeta);
    }
    if (data.containsKey('salary_cents')) {
      context.handle(
        _salaryCentsMeta,
        salaryCents.isAcceptableOrUnknown(
          data['salary_cents']!,
          _salaryCentsMeta,
        ),
      );
    }
    if (data.containsKey('extra_income_cents')) {
      context.handle(
        _extraIncomeCentsMeta,
        extraIncomeCents.isAcceptableOrUnknown(
          data['extra_income_cents']!,
          _extraIncomeCentsMeta,
        ),
      );
    }
    if (data.containsKey('savings_goal_cents')) {
      context.handle(
        _savingsGoalCentsMeta,
        savingsGoalCents.isAcceptableOrUnknown(
          data['savings_goal_cents']!,
          _savingsGoalCentsMeta,
        ),
      );
    }
    if (data.containsKey('investment_cents')) {
      context.handle(
        _investmentCentsMeta,
        investmentCents.isAcceptableOrUnknown(
          data['investment_cents']!,
          _investmentCentsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DefaultsVersionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DefaultsVersionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      effectiveFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}effective_from'],
      )!,
      salaryCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}salary_cents'],
      )!,
      extraIncomeCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}extra_income_cents'],
      )!,
      savingsGoalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}savings_goal_cents'],
      )!,
      investmentCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}investment_cents'],
      )!,
    );
  }

  @override
  $PlanningDefaultsVersionsTable createAlias(String alias) {
    return $PlanningDefaultsVersionsTable(attachedDatabase, alias);
  }
}

class DefaultsVersionRow extends DataClass
    implements Insertable<DefaultsVersionRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String deviceId;

  /// `yyyy-MM`.
  final String effectiveFrom;
  final int salaryCents;
  final int extraIncomeCents;
  final int savingsGoalCents;
  final int investmentCents;
  const DefaultsVersionRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.deviceId,
    required this.effectiveFrom,
    required this.salaryCents,
    required this.extraIncomeCents,
    required this.savingsGoalCents,
    required this.investmentCents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    map['device_id'] = Variable<String>(deviceId);
    map['effective_from'] = Variable<String>(effectiveFrom);
    map['salary_cents'] = Variable<int>(salaryCents);
    map['extra_income_cents'] = Variable<int>(extraIncomeCents);
    map['savings_goal_cents'] = Variable<int>(savingsGoalCents);
    map['investment_cents'] = Variable<int>(investmentCents);
    return map;
  }

  PlanningDefaultsVersionsCompanion toCompanion(bool nullToAbsent) {
    return PlanningDefaultsVersionsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      deviceId: Value(deviceId),
      effectiveFrom: Value(effectiveFrom),
      salaryCents: Value(salaryCents),
      extraIncomeCents: Value(extraIncomeCents),
      savingsGoalCents: Value(savingsGoalCents),
      investmentCents: Value(investmentCents),
    );
  }

  factory DefaultsVersionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DefaultsVersionRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      effectiveFrom: serializer.fromJson<String>(json['effectiveFrom']),
      salaryCents: serializer.fromJson<int>(json['salaryCents']),
      extraIncomeCents: serializer.fromJson<int>(json['extraIncomeCents']),
      savingsGoalCents: serializer.fromJson<int>(json['savingsGoalCents']),
      investmentCents: serializer.fromJson<int>(json['investmentCents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String>(deviceId),
      'effectiveFrom': serializer.toJson<String>(effectiveFrom),
      'salaryCents': serializer.toJson<int>(salaryCents),
      'extraIncomeCents': serializer.toJson<int>(extraIncomeCents),
      'savingsGoalCents': serializer.toJson<int>(savingsGoalCents),
      'investmentCents': serializer.toJson<int>(investmentCents),
    };
  }

  DefaultsVersionRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
    String? deviceId,
    String? effectiveFrom,
    int? salaryCents,
    int? extraIncomeCents,
    int? savingsGoalCents,
    int? investmentCents,
  }) => DefaultsVersionRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    deviceId: deviceId ?? this.deviceId,
    effectiveFrom: effectiveFrom ?? this.effectiveFrom,
    salaryCents: salaryCents ?? this.salaryCents,
    extraIncomeCents: extraIncomeCents ?? this.extraIncomeCents,
    savingsGoalCents: savingsGoalCents ?? this.savingsGoalCents,
    investmentCents: investmentCents ?? this.investmentCents,
  );
  DefaultsVersionRow copyWithCompanion(PlanningDefaultsVersionsCompanion data) {
    return DefaultsVersionRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      effectiveFrom: data.effectiveFrom.present
          ? data.effectiveFrom.value
          : this.effectiveFrom,
      salaryCents: data.salaryCents.present
          ? data.salaryCents.value
          : this.salaryCents,
      extraIncomeCents: data.extraIncomeCents.present
          ? data.extraIncomeCents.value
          : this.extraIncomeCents,
      savingsGoalCents: data.savingsGoalCents.present
          ? data.savingsGoalCents.value
          : this.savingsGoalCents,
      investmentCents: data.investmentCents.present
          ? data.investmentCents.value
          : this.investmentCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DefaultsVersionRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('salaryCents: $salaryCents, ')
          ..write('extraIncomeCents: $extraIncomeCents, ')
          ..write('savingsGoalCents: $savingsGoalCents, ')
          ..write('investmentCents: $investmentCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    effectiveFrom,
    salaryCents,
    extraIncomeCents,
    savingsGoalCents,
    investmentCents,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DefaultsVersionRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.deviceId == this.deviceId &&
          other.effectiveFrom == this.effectiveFrom &&
          other.salaryCents == this.salaryCents &&
          other.extraIncomeCents == this.extraIncomeCents &&
          other.savingsGoalCents == this.savingsGoalCents &&
          other.investmentCents == this.investmentCents);
}

class PlanningDefaultsVersionsCompanion
    extends UpdateCompanion<DefaultsVersionRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<String> deviceId;
  final Value<String> effectiveFrom;
  final Value<int> salaryCents;
  final Value<int> extraIncomeCents;
  final Value<int> savingsGoalCents;
  final Value<int> investmentCents;
  final Value<int> rowid;
  const PlanningDefaultsVersionsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.effectiveFrom = const Value.absent(),
    this.salaryCents = const Value.absent(),
    this.extraIncomeCents = const Value.absent(),
    this.savingsGoalCents = const Value.absent(),
    this.investmentCents = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanningDefaultsVersionsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    required String effectiveFrom,
    this.salaryCents = const Value.absent(),
    this.extraIncomeCents = const Value.absent(),
    this.savingsGoalCents = const Value.absent(),
    this.investmentCents = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       effectiveFrom = Value(effectiveFrom);
  static Insertable<DefaultsVersionRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<String>? effectiveFrom,
    Expression<int>? salaryCents,
    Expression<int>? extraIncomeCents,
    Expression<int>? savingsGoalCents,
    Expression<int>? investmentCents,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (effectiveFrom != null) 'effective_from': effectiveFrom,
      if (salaryCents != null) 'salary_cents': salaryCents,
      if (extraIncomeCents != null) 'extra_income_cents': extraIncomeCents,
      if (savingsGoalCents != null) 'savings_goal_cents': savingsGoalCents,
      if (investmentCents != null) 'investment_cents': investmentCents,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanningDefaultsVersionsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<String>? deviceId,
    Value<String>? effectiveFrom,
    Value<int>? salaryCents,
    Value<int>? extraIncomeCents,
    Value<int>? savingsGoalCents,
    Value<int>? investmentCents,
    Value<int>? rowid,
  }) {
    return PlanningDefaultsVersionsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      salaryCents: salaryCents ?? this.salaryCents,
      extraIncomeCents: extraIncomeCents ?? this.extraIncomeCents,
      savingsGoalCents: savingsGoalCents ?? this.savingsGoalCents,
      investmentCents: investmentCents ?? this.investmentCents,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (effectiveFrom.present) {
      map['effective_from'] = Variable<String>(effectiveFrom.value);
    }
    if (salaryCents.present) {
      map['salary_cents'] = Variable<int>(salaryCents.value);
    }
    if (extraIncomeCents.present) {
      map['extra_income_cents'] = Variable<int>(extraIncomeCents.value);
    }
    if (savingsGoalCents.present) {
      map['savings_goal_cents'] = Variable<int>(savingsGoalCents.value);
    }
    if (investmentCents.present) {
      map['investment_cents'] = Variable<int>(investmentCents.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanningDefaultsVersionsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('salaryCents: $salaryCents, ')
          ..write('extraIncomeCents: $extraIncomeCents, ')
          ..write('savingsGoalCents: $savingsGoalCents, ')
          ..write('investmentCents: $investmentCents, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $RecurringTransactionsTable recurringTransactions =
      $RecurringTransactionsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $IncomesTable incomes = $IncomesTable(this);
  late final $InvestmentsTable investments = $InvestmentsTable(this);
  late final $PlanningsTable plannings = $PlanningsTable(this);
  late final $MonthConfigurationsTable monthConfigurations =
      $MonthConfigurationsTable(this);
  late final $SyncMetadataTable syncMetadata = $SyncMetadataTable(this);
  late final $SyncConflictsTable syncConflicts = $SyncConflictsTable(this);
  late final $SyncBaseTable syncBase = $SyncBaseTable(this);
  late final $PlanningDefaultsVersionsTable planningDefaultsVersions =
      $PlanningDefaultsVersionsTable(this);
  late final Index idxTransactionsDue = Index(
    'idx_transactions_due',
    'CREATE INDEX idx_transactions_due ON transactions (due_date)',
  );
  late final Index idxTransactionsCategory = Index(
    'idx_transactions_category',
    'CREATE INDEX idx_transactions_category ON transactions (category_id)',
  );
  late final Index uqTransactionsOccurrence = Index(
    'uq_transactions_occurrence',
    'CREATE UNIQUE INDEX uq_transactions_occurrence ON transactions (recurring_id, occurrence_date)',
  );
  late final Index idxPaymentsTransaction = Index(
    'idx_payments_transaction',
    'CREATE INDEX idx_payments_transaction ON payments (transaction_id)',
  );
  late final Index idxAttachmentsOwner = Index(
    'idx_attachments_owner',
    'CREATE INDEX idx_attachments_owner ON attachments (owner_type, owner_id)',
  );
  late final Index idxIncomesMonth = Index(
    'idx_incomes_month',
    'CREATE INDEX idx_incomes_month ON incomes (year_month)',
  );
  late final Index idxInvestmentsMonth = Index(
    'idx_investments_month',
    'CREATE INDEX idx_investments_month ON investments (year_month)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    recurringTransactions,
    transactions,
    payments,
    attachments,
    incomes,
    investments,
    plannings,
    monthConfigurations,
    syncMetadata,
    syncConflicts,
    syncBase,
    planningDefaultsVersions,
    idxTransactionsDue,
    idxTransactionsCategory,
    uqTransactionsOccurrence,
    idxPaymentsTransaction,
    idxAttachmentsOwner,
    idxIncomesMonth,
    idxInvestmentsMonth,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> version,
  Value<String> deviceId,
  required String name,
  required int color,
  required String icon,
  Value<bool> isDefault,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> version,
  Value<String> deviceId,
  Value<String> name,
  Value<int> color,
  Value<String> icon,
  Value<bool> isDefault,
  Value<int> sortOrder,
  Value<int> rowid,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RecurringTransactionsTable, List<RecurringRow>>
  _recurringTransactionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recurringTransactions,
        aliasName: 'categories__id__recurring_transactions__category_id',
      );

  $$RecurringTransactionsTableProcessedTableManager
  get recurringTransactionsRefs {
    final manager = $$RecurringTransactionsTableTableManager(
      $_db,
      $_db.recurringTransactions,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recurringTransactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<TransactionRow>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'categories__id__transactions__category_id',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> recurringTransactionsRefs(
    Expression<bool> Function($$RecurringTransactionsTableFilterComposer f) f,
  ) {
    final $$RecurringTransactionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringTransactions,
          getReferencedColumn: (t) => t.categoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringTransactionsTableFilterComposer(
                $db: $db,
                $table: $db.recurringTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> recurringTransactionsRefs<T extends Object>(
    Expression<T> Function($$RecurringTransactionsTableAnnotationComposer a) f,
  ) {
    final $$RecurringTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringTransactions,
          getReferencedColumn: (t) => t.categoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (CategoryRow, $$CategoriesTableReferences),
          CategoryRow,
          PrefetchHooks Function({
            bool recurringTransactionsRefs,
            bool transactionsRefs,
          })
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                name: name,
                color: color,
                icon: icon,
                isDefault: isDefault,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                required String name,
                required int color,
                required String icon,
                Value<bool> isDefault = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                name: name,
                color: color,
                icon: icon,
                isDefault: isDefault,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, CategoryRow>(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({recurringTransactionsRefs = false, transactionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (recurringTransactionsRefs) db.recurringTransactions,
                    if (transactionsRefs) db.transactions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (recurringTransactionsRefs)
                        await $_getPrefetchedData<
                          CategoryRow,
                          $CategoriesTable,
                          RecurringRow
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._recurringTransactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).recurringTransactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          CategoryRow,
                          $CategoriesTable,
                          TransactionRow
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (CategoryRow, $$CategoriesTableReferences),
      CategoryRow,
      PrefetchHooks Function({
        bool recurringTransactionsRefs,
        bool transactionsRefs,
      })
    >;
typedef $$RecurringTransactionsTableCreateCompanionBuilder =
    RecurringTransactionsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String> deviceId,
      required String name,
      required int baseAmountCents,
      required String categoryId,
      required ExpenseType expenseType,
      required Frequency frequency,
      Value<int> intervalCount,
      required int dueDay,
      Value<int?> baseMinCents,
      Value<int?> baseMaxCents,
      required String startDate,
      Value<String?> endDate,
      Value<bool> favorite,
      Value<int> rowid,
    });
typedef $$RecurringTransactionsTableUpdateCompanionBuilder =
    RecurringTransactionsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String> deviceId,
      Value<String> name,
      Value<int> baseAmountCents,
      Value<String> categoryId,
      Value<ExpenseType> expenseType,
      Value<Frequency> frequency,
      Value<int> intervalCount,
      Value<int> dueDay,
      Value<int?> baseMinCents,
      Value<int?> baseMaxCents,
      Value<String> startDate,
      Value<String?> endDate,
      Value<bool> favorite,
      Value<int> rowid,
    });

final class $$RecurringTransactionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RecurringTransactionsTable,
          RecurringRow
        > {
  $$RecurringTransactionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) => db.categories
      .createAlias('recurring_transactions__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<TransactionRow>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'recurring_transactions__id__transactions__recurring_id',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.recurringId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RecurringTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseAmountCents => $composableBuilder(
    column: $table.baseAmountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ExpenseType, ExpenseType, String>
  get expenseType => $composableBuilder(
    column: $table.expenseType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Frequency, Frequency, String> get frequency =>
      $composableBuilder(
        column: $table.frequency,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get intervalCount => $composableBuilder(
    column: $table.intervalCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueDay => $composableBuilder(
    column: $table.dueDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseMinCents => $composableBuilder(
    column: $table.baseMinCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseMaxCents => $composableBuilder(
    column: $table.baseMaxCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.recurringId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecurringTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseAmountCents => $composableBuilder(
    column: $table.baseAmountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expenseType => $composableBuilder(
    column: $table.expenseType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalCount => $composableBuilder(
    column: $table.intervalCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueDay => $composableBuilder(
    column: $table.dueDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseMinCents => $composableBuilder(
    column: $table.baseMinCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseMaxCents => $composableBuilder(
    column: $table.baseMaxCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get baseAmountCents => $composableBuilder(
    column: $table.baseAmountCents,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ExpenseType, String> get expenseType =>
      $composableBuilder(
        column: $table.expenseType,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Frequency, String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<int> get intervalCount => $composableBuilder(
    column: $table.intervalCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dueDay =>
      $composableBuilder(column: $table.dueDay, builder: (column) => column);

  GeneratedColumn<int> get baseMinCents => $composableBuilder(
    column: $table.baseMinCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get baseMaxCents => $composableBuilder(
    column: $table.baseMaxCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get favorite =>
      $composableBuilder(column: $table.favorite, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.recurringId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecurringTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringTransactionsTable,
          RecurringRow,
          $$RecurringTransactionsTableFilterComposer,
          $$RecurringTransactionsTableOrderingComposer,
          $$RecurringTransactionsTableAnnotationComposer,
          $$RecurringTransactionsTableCreateCompanionBuilder,
          $$RecurringTransactionsTableUpdateCompanionBuilder,
          (RecurringRow, $$RecurringTransactionsTableReferences),
          RecurringRow,
          PrefetchHooks Function({bool categoryId, bool transactionsRefs})
        > {
  $$RecurringTransactionsTableTableManager(
    _$AppDatabase db,
    $RecurringTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringTransactionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RecurringTransactionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RecurringTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> baseAmountCents = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<ExpenseType> expenseType = const Value.absent(),
                Value<Frequency> frequency = const Value.absent(),
                Value<int> intervalCount = const Value.absent(),
                Value<int> dueDay = const Value.absent(),
                Value<int?> baseMinCents = const Value.absent(),
                Value<int?> baseMaxCents = const Value.absent(),
                Value<String> startDate = const Value.absent(),
                Value<String?> endDate = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringTransactionsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                name: name,
                baseAmountCents: baseAmountCents,
                categoryId: categoryId,
                expenseType: expenseType,
                frequency: frequency,
                intervalCount: intervalCount,
                dueDay: dueDay,
                baseMinCents: baseMinCents,
                baseMaxCents: baseMaxCents,
                startDate: startDate,
                endDate: endDate,
                favorite: favorite,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                required String name,
                required int baseAmountCents,
                required String categoryId,
                required ExpenseType expenseType,
                required Frequency frequency,
                Value<int> intervalCount = const Value.absent(),
                required int dueDay,
                Value<int?> baseMinCents = const Value.absent(),
                Value<int?> baseMaxCents = const Value.absent(),
                required String startDate,
                Value<String?> endDate = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringTransactionsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                name: name,
                baseAmountCents: baseAmountCents,
                categoryId: categoryId,
                expenseType: expenseType,
                frequency: frequency,
                intervalCount: intervalCount,
                dueDay: dueDay,
                baseMinCents: baseMinCents,
                baseMaxCents: baseMaxCents,
                startDate: startDate,
                endDate: endDate,
                favorite: favorite,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecurringTransactionsTable, RecurringRow>(table),
                  $$RecurringTransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({categoryId = false, transactionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionsRefs) db.transactions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.categoryId,
                            referencedTable:
                                $$RecurringTransactionsTableReferences
                                    ._categoryIdTable(db),
                            referencedColumn:
                                $$RecurringTransactionsTableReferences
                                    ._categoryIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          RecurringRow,
                          $RecurringTransactionsTable,
                          TransactionRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$RecurringTransactionsTableReferences
                                  ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecurringTransactionsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recurringId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RecurringTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringTransactionsTable,
      RecurringRow,
      $$RecurringTransactionsTableFilterComposer,
      $$RecurringTransactionsTableOrderingComposer,
      $$RecurringTransactionsTableAnnotationComposer,
      $$RecurringTransactionsTableCreateCompanionBuilder,
      $$RecurringTransactionsTableUpdateCompanionBuilder,
      (RecurringRow, $$RecurringTransactionsTableReferences),
      RecurringRow,
      PrefetchHooks Function({bool categoryId, bool transactionsRefs})
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String> deviceId,
      required String name,
      required int plannedAmountCents,
      required String dueDate,
      required String categoryId,
      required ExpenseType expenseType,
      Value<bool> favorite,
      Value<String> note,
      Value<DateTime?> canceledAt,
      Value<String?> recurringId,
      Value<String?> occurrenceDate,
      Value<bool> overridden,
      Value<int?> plannedMinCents,
      Value<int?> plannedMaxCents,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String> deviceId,
      Value<String> name,
      Value<int> plannedAmountCents,
      Value<String> dueDate,
      Value<String> categoryId,
      Value<ExpenseType> expenseType,
      Value<bool> favorite,
      Value<String> note,
      Value<DateTime?> canceledAt,
      Value<String?> recurringId,
      Value<String?> occurrenceDate,
      Value<bool> overridden,
      Value<int?> plannedMinCents,
      Value<int?> plannedMaxCents,
      Value<int> rowid,
    });

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, TransactionRow> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('transactions__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RecurringTransactionsTable _recurringIdTable(_$AppDatabase db) => db
      .recurringTransactions
      .createAlias('transactions__recurring_id__recurring_transactions__id');

  $$RecurringTransactionsTableProcessedTableManager? get recurringId {
    final $_column = $_itemColumn<String>('recurring_id');
    if ($_column == null) return null;
    final manager = $$RecurringTransactionsTableTableManager(
      $_db,
      $_db.recurringTransactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recurringIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PaymentsTable, List<PaymentRow>>
  _paymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.payments,
    aliasName: 'transactions__id__payments__transaction_id',
  );

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.transactionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedAmountCents => $composableBuilder(
    column: $table.plannedAmountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ExpenseType, ExpenseType, String>
  get expenseType => $composableBuilder(
    column: $table.expenseType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get canceledAt => $composableBuilder(
    column: $table.canceledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occurrenceDate => $composableBuilder(
    column: $table.occurrenceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get overridden => $composableBuilder(
    column: $table.overridden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedMinCents => $composableBuilder(
    column: $table.plannedMinCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedMaxCents => $composableBuilder(
    column: $table.plannedMaxCents,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecurringTransactionsTableFilterComposer get recurringId {
    final $$RecurringTransactionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.recurringId,
          referencedTable: $db.recurringTransactions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringTransactionsTableFilterComposer(
                $db: $db,
                $table: $db.recurringTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<bool> paymentsRefs(
    Expression<bool> Function($$PaymentsTableFilterComposer f) f,
  ) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedAmountCents => $composableBuilder(
    column: $table.plannedAmountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expenseType => $composableBuilder(
    column: $table.expenseType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get canceledAt => $composableBuilder(
    column: $table.canceledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occurrenceDate => $composableBuilder(
    column: $table.occurrenceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get overridden => $composableBuilder(
    column: $table.overridden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedMinCents => $composableBuilder(
    column: $table.plannedMinCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedMaxCents => $composableBuilder(
    column: $table.plannedMaxCents,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecurringTransactionsTableOrderingComposer get recurringId {
    final $$RecurringTransactionsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.recurringId,
          referencedTable: $db.recurringTransactions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringTransactionsTableOrderingComposer(
                $db: $db,
                $table: $db.recurringTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get plannedAmountCents => $composableBuilder(
    column: $table.plannedAmountCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ExpenseType, String> get expenseType =>
      $composableBuilder(
        column: $table.expenseType,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get favorite =>
      $composableBuilder(column: $table.favorite, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get canceledAt => $composableBuilder(
    column: $table.canceledAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get occurrenceDate => $composableBuilder(
    column: $table.occurrenceDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get overridden => $composableBuilder(
    column: $table.overridden,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedMinCents => $composableBuilder(
    column: $table.plannedMinCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedMaxCents => $composableBuilder(
    column: $table.plannedMaxCents,
    builder: (column) => column,
  );

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecurringTransactionsTableAnnotationComposer get recurringId {
    final $$RecurringTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.recurringId,
          referencedTable: $db.recurringTransactions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> paymentsRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          TransactionRow,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (TransactionRow, $$TransactionsTableReferences),
          TransactionRow,
          PrefetchHooks Function({
            bool categoryId,
            bool recurringId,
            bool paymentsRefs,
          })
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> plannedAmountCents = const Value.absent(),
                Value<String> dueDate = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<ExpenseType> expenseType = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<DateTime?> canceledAt = const Value.absent(),
                Value<String?> recurringId = const Value.absent(),
                Value<String?> occurrenceDate = const Value.absent(),
                Value<bool> overridden = const Value.absent(),
                Value<int?> plannedMinCents = const Value.absent(),
                Value<int?> plannedMaxCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                name: name,
                plannedAmountCents: plannedAmountCents,
                dueDate: dueDate,
                categoryId: categoryId,
                expenseType: expenseType,
                favorite: favorite,
                note: note,
                canceledAt: canceledAt,
                recurringId: recurringId,
                occurrenceDate: occurrenceDate,
                overridden: overridden,
                plannedMinCents: plannedMinCents,
                plannedMaxCents: plannedMaxCents,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                required String name,
                required int plannedAmountCents,
                required String dueDate,
                required String categoryId,
                required ExpenseType expenseType,
                Value<bool> favorite = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<DateTime?> canceledAt = const Value.absent(),
                Value<String?> recurringId = const Value.absent(),
                Value<String?> occurrenceDate = const Value.absent(),
                Value<bool> overridden = const Value.absent(),
                Value<int?> plannedMinCents = const Value.absent(),
                Value<int?> plannedMaxCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                name: name,
                plannedAmountCents: plannedAmountCents,
                dueDate: dueDate,
                categoryId: categoryId,
                expenseType: expenseType,
                favorite: favorite,
                note: note,
                canceledAt: canceledAt,
                recurringId: recurringId,
                occurrenceDate: occurrenceDate,
                overridden: overridden,
                plannedMinCents: plannedMinCents,
                plannedMaxCents: plannedMaxCents,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TransactionsTable, TransactionRow>(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoryId = false,
                recurringId = false,
                paymentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (paymentsRefs) db.payments],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.categoryId,
                            referencedTable: $$TransactionsTableReferences
                                ._categoryIdTable(db),
                            referencedColumn: $$TransactionsTableReferences
                                ._categoryIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (recurringId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.recurringId,
                            referencedTable: $$TransactionsTableReferences
                                ._recurringIdTable(db),
                            referencedColumn: $$TransactionsTableReferences
                                ._recurringIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (paymentsRefs)
                        await $_getPrefetchedData<
                          TransactionRow,
                          $TransactionsTable,
                          PaymentRow
                        >(
                          currentTable: table,
                          referencedTable: $$TransactionsTableReferences
                              ._paymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransactionsTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.transactionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      TransactionRow,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (TransactionRow, $$TransactionsTableReferences),
      TransactionRow,
      PrefetchHooks Function({
        bool categoryId,
        bool recurringId,
        bool paymentsRefs,
      })
    >;
typedef $$PaymentsTableCreateCompanionBuilder = PaymentsCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> version,
  Value<String> deviceId,
  required String transactionId,
  required int amountCents,
  required DateTime paidAt,
  Value<String> note,
  Value<int> rowid,
});
typedef $$PaymentsTableUpdateCompanionBuilder = PaymentsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> version,
  Value<String> deviceId,
  Value<String> transactionId,
  Value<int> amountCents,
  Value<DateTime> paidAt,
  Value<String> note,
  Value<int> rowid,
});

final class $$PaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentsTable, PaymentRow> {
  $$PaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias('payments__transaction_id__transactions__id');

  $$TransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<String>('transaction_id')!;

    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get paidAt =>
      $composableBuilder(column: $table.paidAt, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTable,
          PaymentRow,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (PaymentRow, $$PaymentsTableReferences),
          PaymentRow,
          PrefetchHooks Function({bool transactionId})
        > {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<DateTime> paidAt = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                transactionId: transactionId,
                amountCents: amountCents,
                paidAt: paidAt,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                required String transactionId,
                required int amountCents,
                required DateTime paidAt,
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                transactionId: transactionId,
                amountCents: amountCents,
                paidAt: paidAt,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PaymentsTable, PaymentRow>(table),
                  $$PaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transactionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (transactionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.transactionId,
                        referencedTable: $$PaymentsTableReferences
                            ._transactionIdTable(db),
                        referencedColumn: $$PaymentsTableReferences
                            ._transactionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTable,
      PaymentRow,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (PaymentRow, $$PaymentsTableReferences),
      PaymentRow,
      PrefetchHooks Function({bool transactionId})
    >;
typedef $$AttachmentsTableCreateCompanionBuilder =
    AttachmentsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String> deviceId,
      required AttachmentOwner ownerType,
      required String ownerId,
      required String localPath,
      required String originalName,
      required String mime,
      Value<String> hash,
      Value<String?> driveFileId,
      Value<UploadStatus> uploadStatus,
      Value<int> rowid,
    });
typedef $$AttachmentsTableUpdateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String> deviceId,
      Value<AttachmentOwner> ownerType,
      Value<String> ownerId,
      Value<String> localPath,
      Value<String> originalName,
      Value<String> mime,
      Value<String> hash,
      Value<String?> driveFileId,
      Value<UploadStatus> uploadStatus,
      Value<int> rowid,
    });

class $$AttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AttachmentOwner, AttachmentOwner, String>
  get ownerType => $composableBuilder(
    column: $table.ownerType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hash => $composableBuilder(
    column: $table.hash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get driveFileId => $composableBuilder(
    column: $table.driveFileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<UploadStatus, UploadStatus, String>
  get uploadStatus => $composableBuilder(
    column: $table.uploadStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerType => $composableBuilder(
    column: $table.ownerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hash => $composableBuilder(
    column: $table.hash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get driveFileId => $composableBuilder(
    column: $table.driveFileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uploadStatus => $composableBuilder(
    column: $table.uploadStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AttachmentOwner, String> get ownerType =>
      $composableBuilder(column: $table.ownerType, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mime =>
      $composableBuilder(column: $table.mime, builder: (column) => column);

  GeneratedColumn<String> get hash =>
      $composableBuilder(column: $table.hash, builder: (column) => column);

  GeneratedColumn<String> get driveFileId => $composableBuilder(
    column: $table.driveFileId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<UploadStatus, String> get uploadStatus =>
      $composableBuilder(
        column: $table.uploadStatus,
        builder: (column) => column,
      );
}

class $$AttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttachmentsTable,
          AttachmentRow,
          $$AttachmentsTableFilterComposer,
          $$AttachmentsTableOrderingComposer,
          $$AttachmentsTableAnnotationComposer,
          $$AttachmentsTableCreateCompanionBuilder,
          $$AttachmentsTableUpdateCompanionBuilder,
          (
            AttachmentRow,
            BaseReferences<_$AppDatabase, $AttachmentsTable, AttachmentRow>,
          ),
          AttachmentRow,
          PrefetchHooks Function()
        > {
  $$AttachmentsTableTableManager(_$AppDatabase db, $AttachmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<AttachmentOwner> ownerType = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String> originalName = const Value.absent(),
                Value<String> mime = const Value.absent(),
                Value<String> hash = const Value.absent(),
                Value<String?> driveFileId = const Value.absent(),
                Value<UploadStatus> uploadStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                ownerType: ownerType,
                ownerId: ownerId,
                localPath: localPath,
                originalName: originalName,
                mime: mime,
                hash: hash,
                driveFileId: driveFileId,
                uploadStatus: uploadStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                required AttachmentOwner ownerType,
                required String ownerId,
                required String localPath,
                required String originalName,
                required String mime,
                Value<String> hash = const Value.absent(),
                Value<String?> driveFileId = const Value.absent(),
                Value<UploadStatus> uploadStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                ownerType: ownerType,
                ownerId: ownerId,
                localPath: localPath,
                originalName: originalName,
                mime: mime,
                hash: hash,
                driveFileId: driveFileId,
                uploadStatus: uploadStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AttachmentsTable, AttachmentRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AttachmentsTable,
                    AttachmentRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttachmentsTable,
      AttachmentRow,
      $$AttachmentsTableFilterComposer,
      $$AttachmentsTableOrderingComposer,
      $$AttachmentsTableAnnotationComposer,
      $$AttachmentsTableCreateCompanionBuilder,
      $$AttachmentsTableUpdateCompanionBuilder,
      (
        AttachmentRow,
        BaseReferences<_$AppDatabase, $AttachmentsTable, AttachmentRow>,
      ),
      AttachmentRow,
      PrefetchHooks Function()
    >;
typedef $$IncomesTableCreateCompanionBuilder = IncomesCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> version,
  Value<String> deviceId,
  required String yearMonth,
  required IncomeKind kind,
  required int amountCents,
  Value<String> description,
  Value<bool> received,
  Value<int> rowid,
});
typedef $$IncomesTableUpdateCompanionBuilder = IncomesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> version,
  Value<String> deviceId,
  Value<String> yearMonth,
  Value<IncomeKind> kind,
  Value<int> amountCents,
  Value<String> description,
  Value<bool> received,
  Value<int> rowid,
});

class $$IncomesTableFilterComposer
    extends Composer<_$AppDatabase, $IncomesTable> {
  $$IncomesTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get yearMonth => $composableBuilder(
    column: $table.yearMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<IncomeKind, IncomeKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get received => $composableBuilder(
    column: $table.received,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IncomesTableOrderingComposer
    extends Composer<_$AppDatabase, $IncomesTable> {
  $$IncomesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get yearMonth => $composableBuilder(
    column: $table.yearMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get received => $composableBuilder(
    column: $table.received,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IncomesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IncomesTable> {
  $$IncomesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get yearMonth =>
      $composableBuilder(column: $table.yearMonth, builder: (column) => column);

  GeneratedColumnWithTypeConverter<IncomeKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get received =>
      $composableBuilder(column: $table.received, builder: (column) => column);
}

class $$IncomesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IncomesTable,
          IncomeRow,
          $$IncomesTableFilterComposer,
          $$IncomesTableOrderingComposer,
          $$IncomesTableAnnotationComposer,
          $$IncomesTableCreateCompanionBuilder,
          $$IncomesTableUpdateCompanionBuilder,
          (IncomeRow, BaseReferences<_$AppDatabase, $IncomesTable, IncomeRow>),
          IncomeRow,
          PrefetchHooks Function()
        > {
  $$IncomesTableTableManager(_$AppDatabase db, $IncomesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IncomesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IncomesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IncomesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> yearMonth = const Value.absent(),
                Value<IncomeKind> kind = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<bool> received = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IncomesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                yearMonth: yearMonth,
                kind: kind,
                amountCents: amountCents,
                description: description,
                received: received,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                required String yearMonth,
                required IncomeKind kind,
                required int amountCents,
                Value<String> description = const Value.absent(),
                Value<bool> received = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IncomesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                yearMonth: yearMonth,
                kind: kind,
                amountCents: amountCents,
                description: description,
                received: received,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IncomesTable, IncomeRow>(table),
                  BaseReferences<_$AppDatabase, $IncomesTable, IncomeRow>(
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

typedef $$IncomesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IncomesTable,
      IncomeRow,
      $$IncomesTableFilterComposer,
      $$IncomesTableOrderingComposer,
      $$IncomesTableAnnotationComposer,
      $$IncomesTableCreateCompanionBuilder,
      $$IncomesTableUpdateCompanionBuilder,
      (IncomeRow, BaseReferences<_$AppDatabase, $IncomesTable, IncomeRow>),
      IncomeRow,
      PrefetchHooks Function()
    >;
typedef $$InvestmentsTableCreateCompanionBuilder =
    InvestmentsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String> deviceId,
      required String yearMonth,
      Value<int> plannedCents,
      Value<int> realizedCents,
      Value<String> description,
      Value<int> rowid,
    });
typedef $$InvestmentsTableUpdateCompanionBuilder =
    InvestmentsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String> deviceId,
      Value<String> yearMonth,
      Value<int> plannedCents,
      Value<int> realizedCents,
      Value<String> description,
      Value<int> rowid,
    });

class $$InvestmentsTableFilterComposer
    extends Composer<_$AppDatabase, $InvestmentsTable> {
  $$InvestmentsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get yearMonth => $composableBuilder(
    column: $table.yearMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedCents => $composableBuilder(
    column: $table.plannedCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get realizedCents => $composableBuilder(
    column: $table.realizedCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InvestmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvestmentsTable> {
  $$InvestmentsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get yearMonth => $composableBuilder(
    column: $table.yearMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedCents => $composableBuilder(
    column: $table.plannedCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get realizedCents => $composableBuilder(
    column: $table.realizedCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InvestmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvestmentsTable> {
  $$InvestmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get yearMonth =>
      $composableBuilder(column: $table.yearMonth, builder: (column) => column);

  GeneratedColumn<int> get plannedCents => $composableBuilder(
    column: $table.plannedCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get realizedCents => $composableBuilder(
    column: $table.realizedCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );
}

class $$InvestmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvestmentsTable,
          InvestmentRow,
          $$InvestmentsTableFilterComposer,
          $$InvestmentsTableOrderingComposer,
          $$InvestmentsTableAnnotationComposer,
          $$InvestmentsTableCreateCompanionBuilder,
          $$InvestmentsTableUpdateCompanionBuilder,
          (
            InvestmentRow,
            BaseReferences<_$AppDatabase, $InvestmentsTable, InvestmentRow>,
          ),
          InvestmentRow,
          PrefetchHooks Function()
        > {
  $$InvestmentsTableTableManager(_$AppDatabase db, $InvestmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvestmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvestmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvestmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> yearMonth = const Value.absent(),
                Value<int> plannedCents = const Value.absent(),
                Value<int> realizedCents = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvestmentsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                yearMonth: yearMonth,
                plannedCents: plannedCents,
                realizedCents: realizedCents,
                description: description,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                required String yearMonth,
                Value<int> plannedCents = const Value.absent(),
                Value<int> realizedCents = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvestmentsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                yearMonth: yearMonth,
                plannedCents: plannedCents,
                realizedCents: realizedCents,
                description: description,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InvestmentsTable, InvestmentRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $InvestmentsTable,
                    InvestmentRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InvestmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvestmentsTable,
      InvestmentRow,
      $$InvestmentsTableFilterComposer,
      $$InvestmentsTableOrderingComposer,
      $$InvestmentsTableAnnotationComposer,
      $$InvestmentsTableCreateCompanionBuilder,
      $$InvestmentsTableUpdateCompanionBuilder,
      (
        InvestmentRow,
        BaseReferences<_$AppDatabase, $InvestmentsTable, InvestmentRow>,
      ),
      InvestmentRow,
      PrefetchHooks Function()
    >;
typedef $$PlanningsTableCreateCompanionBuilder = PlanningsCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> version,
  Value<String> deviceId,
  Value<int> defaultSalaryCents,
  Value<int> defaultExtraIncomeCents,
  Value<int> defaultSavingsGoalCents,
  Value<int> defaultInvestmentCents,
  Value<int> rowid,
});
typedef $$PlanningsTableUpdateCompanionBuilder = PlanningsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> version,
  Value<String> deviceId,
  Value<int> defaultSalaryCents,
  Value<int> defaultExtraIncomeCents,
  Value<int> defaultSavingsGoalCents,
  Value<int> defaultInvestmentCents,
  Value<int> rowid,
});

class $$PlanningsTableFilterComposer
    extends Composer<_$AppDatabase, $PlanningsTable> {
  $$PlanningsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultSalaryCents => $composableBuilder(
    column: $table.defaultSalaryCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultExtraIncomeCents => $composableBuilder(
    column: $table.defaultExtraIncomeCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultSavingsGoalCents => $composableBuilder(
    column: $table.defaultSavingsGoalCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultInvestmentCents => $composableBuilder(
    column: $table.defaultInvestmentCents,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlanningsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanningsTable> {
  $$PlanningsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultSalaryCents => $composableBuilder(
    column: $table.defaultSalaryCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultExtraIncomeCents => $composableBuilder(
    column: $table.defaultExtraIncomeCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultSavingsGoalCents => $composableBuilder(
    column: $table.defaultSavingsGoalCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultInvestmentCents => $composableBuilder(
    column: $table.defaultInvestmentCents,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlanningsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanningsTable> {
  $$PlanningsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get defaultSalaryCents => $composableBuilder(
    column: $table.defaultSalaryCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultExtraIncomeCents => $composableBuilder(
    column: $table.defaultExtraIncomeCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultSavingsGoalCents => $composableBuilder(
    column: $table.defaultSavingsGoalCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultInvestmentCents => $composableBuilder(
    column: $table.defaultInvestmentCents,
    builder: (column) => column,
  );
}

class $$PlanningsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanningsTable,
          PlanningRow,
          $$PlanningsTableFilterComposer,
          $$PlanningsTableOrderingComposer,
          $$PlanningsTableAnnotationComposer,
          $$PlanningsTableCreateCompanionBuilder,
          $$PlanningsTableUpdateCompanionBuilder,
          (
            PlanningRow,
            BaseReferences<_$AppDatabase, $PlanningsTable, PlanningRow>,
          ),
          PlanningRow,
          PrefetchHooks Function()
        > {
  $$PlanningsTableTableManager(_$AppDatabase db, $PlanningsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanningsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanningsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanningsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> defaultSalaryCents = const Value.absent(),
                Value<int> defaultExtraIncomeCents = const Value.absent(),
                Value<int> defaultSavingsGoalCents = const Value.absent(),
                Value<int> defaultInvestmentCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanningsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                defaultSalaryCents: defaultSalaryCents,
                defaultExtraIncomeCents: defaultExtraIncomeCents,
                defaultSavingsGoalCents: defaultSavingsGoalCents,
                defaultInvestmentCents: defaultInvestmentCents,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> defaultSalaryCents = const Value.absent(),
                Value<int> defaultExtraIncomeCents = const Value.absent(),
                Value<int> defaultSavingsGoalCents = const Value.absent(),
                Value<int> defaultInvestmentCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanningsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                defaultSalaryCents: defaultSalaryCents,
                defaultExtraIncomeCents: defaultExtraIncomeCents,
                defaultSavingsGoalCents: defaultSavingsGoalCents,
                defaultInvestmentCents: defaultInvestmentCents,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlanningsTable, PlanningRow>(table),
                  BaseReferences<_$AppDatabase, $PlanningsTable, PlanningRow>(
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

typedef $$PlanningsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanningsTable,
      PlanningRow,
      $$PlanningsTableFilterComposer,
      $$PlanningsTableOrderingComposer,
      $$PlanningsTableAnnotationComposer,
      $$PlanningsTableCreateCompanionBuilder,
      $$PlanningsTableUpdateCompanionBuilder,
      (
        PlanningRow,
        BaseReferences<_$AppDatabase, $PlanningsTable, PlanningRow>,
      ),
      PlanningRow,
      PrefetchHooks Function()
    >;
typedef $$MonthConfigurationsTableCreateCompanionBuilder =
    MonthConfigurationsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String> deviceId,
      required String yearMonth,
      Value<int?> salaryCents,
      Value<int?> extraIncomeCents,
      Value<int?> savingsGoalCents,
      Value<int?> investmentCents,
      Value<int> rowid,
    });
typedef $$MonthConfigurationsTableUpdateCompanionBuilder =
    MonthConfigurationsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String> deviceId,
      Value<String> yearMonth,
      Value<int?> salaryCents,
      Value<int?> extraIncomeCents,
      Value<int?> savingsGoalCents,
      Value<int?> investmentCents,
      Value<int> rowid,
    });

class $$MonthConfigurationsTableFilterComposer
    extends Composer<_$AppDatabase, $MonthConfigurationsTable> {
  $$MonthConfigurationsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get yearMonth => $composableBuilder(
    column: $table.yearMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get salaryCents => $composableBuilder(
    column: $table.salaryCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get extraIncomeCents => $composableBuilder(
    column: $table.extraIncomeCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get savingsGoalCents => $composableBuilder(
    column: $table.savingsGoalCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get investmentCents => $composableBuilder(
    column: $table.investmentCents,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MonthConfigurationsTableOrderingComposer
    extends Composer<_$AppDatabase, $MonthConfigurationsTable> {
  $$MonthConfigurationsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get yearMonth => $composableBuilder(
    column: $table.yearMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get salaryCents => $composableBuilder(
    column: $table.salaryCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get extraIncomeCents => $composableBuilder(
    column: $table.extraIncomeCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get savingsGoalCents => $composableBuilder(
    column: $table.savingsGoalCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get investmentCents => $composableBuilder(
    column: $table.investmentCents,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MonthConfigurationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MonthConfigurationsTable> {
  $$MonthConfigurationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get yearMonth =>
      $composableBuilder(column: $table.yearMonth, builder: (column) => column);

  GeneratedColumn<int> get salaryCents => $composableBuilder(
    column: $table.salaryCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get extraIncomeCents => $composableBuilder(
    column: $table.extraIncomeCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get savingsGoalCents => $composableBuilder(
    column: $table.savingsGoalCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get investmentCents => $composableBuilder(
    column: $table.investmentCents,
    builder: (column) => column,
  );
}

class $$MonthConfigurationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MonthConfigurationsTable,
          MonthConfigRow,
          $$MonthConfigurationsTableFilterComposer,
          $$MonthConfigurationsTableOrderingComposer,
          $$MonthConfigurationsTableAnnotationComposer,
          $$MonthConfigurationsTableCreateCompanionBuilder,
          $$MonthConfigurationsTableUpdateCompanionBuilder,
          (
            MonthConfigRow,
            BaseReferences<
              _$AppDatabase,
              $MonthConfigurationsTable,
              MonthConfigRow
            >,
          ),
          MonthConfigRow,
          PrefetchHooks Function()
        > {
  $$MonthConfigurationsTableTableManager(
    _$AppDatabase db,
    $MonthConfigurationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MonthConfigurationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MonthConfigurationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MonthConfigurationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> yearMonth = const Value.absent(),
                Value<int?> salaryCents = const Value.absent(),
                Value<int?> extraIncomeCents = const Value.absent(),
                Value<int?> savingsGoalCents = const Value.absent(),
                Value<int?> investmentCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MonthConfigurationsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                yearMonth: yearMonth,
                salaryCents: salaryCents,
                extraIncomeCents: extraIncomeCents,
                savingsGoalCents: savingsGoalCents,
                investmentCents: investmentCents,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                required String yearMonth,
                Value<int?> salaryCents = const Value.absent(),
                Value<int?> extraIncomeCents = const Value.absent(),
                Value<int?> savingsGoalCents = const Value.absent(),
                Value<int?> investmentCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MonthConfigurationsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                yearMonth: yearMonth,
                salaryCents: salaryCents,
                extraIncomeCents: extraIncomeCents,
                savingsGoalCents: savingsGoalCents,
                investmentCents: investmentCents,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MonthConfigurationsTable, MonthConfigRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $MonthConfigurationsTable,
                    MonthConfigRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MonthConfigurationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MonthConfigurationsTable,
      MonthConfigRow,
      $$MonthConfigurationsTableFilterComposer,
      $$MonthConfigurationsTableOrderingComposer,
      $$MonthConfigurationsTableAnnotationComposer,
      $$MonthConfigurationsTableCreateCompanionBuilder,
      $$MonthConfigurationsTableUpdateCompanionBuilder,
      (
        MonthConfigRow,
        BaseReferences<
          _$AppDatabase,
          $MonthConfigurationsTable,
          MonthConfigRow
        >,
      ),
      MonthConfigRow,
      PrefetchHooks Function()
    >;
typedef $$SyncMetadataTableCreateCompanionBuilder =
    SyncMetadataCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String> deviceId,
      Value<DateTime?> lastSyncAt,
      Value<String?> remoteCursor,
      Value<SyncState> state,
      Value<int> rowid,
    });
typedef $$SyncMetadataTableUpdateCompanionBuilder =
    SyncMetadataCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String> deviceId,
      Value<DateTime?> lastSyncAt,
      Value<String?> remoteCursor,
      Value<SyncState> state,
      Value<int> rowid,
    });

class $$SyncMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteCursor => $composableBuilder(
    column: $table.remoteCursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncState, SyncState, String> get state =>
      $composableBuilder(
        column: $table.state,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$SyncMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteCursor => $composableBuilder(
    column: $table.remoteCursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteCursor => $composableBuilder(
    column: $table.remoteCursor,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SyncState, String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);
}

class $$SyncMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetadataTable,
          SyncMetaRow,
          $$SyncMetadataTableFilterComposer,
          $$SyncMetadataTableOrderingComposer,
          $$SyncMetadataTableAnnotationComposer,
          $$SyncMetadataTableCreateCompanionBuilder,
          $$SyncMetadataTableUpdateCompanionBuilder,
          (
            SyncMetaRow,
            BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetaRow>,
          ),
          SyncMetaRow,
          PrefetchHooks Function()
        > {
  $$SyncMetadataTableTableManager(_$AppDatabase db, $SyncMetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<String?> remoteCursor = const Value.absent(),
                Value<SyncState> state = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                lastSyncAt: lastSyncAt,
                remoteCursor: remoteCursor,
                state: state,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<String?> remoteCursor = const Value.absent(),
                Value<SyncState> state = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                lastSyncAt: lastSyncAt,
                remoteCursor: remoteCursor,
                state: state,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncMetadataTable, SyncMetaRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncMetadataTable,
                    SyncMetaRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetadataTable,
      SyncMetaRow,
      $$SyncMetadataTableFilterComposer,
      $$SyncMetadataTableOrderingComposer,
      $$SyncMetadataTableAnnotationComposer,
      $$SyncMetadataTableCreateCompanionBuilder,
      $$SyncMetadataTableUpdateCompanionBuilder,
      (
        SyncMetaRow,
        BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetaRow>,
      ),
      SyncMetaRow,
      PrefetchHooks Function()
    >;
typedef $$SyncConflictsTableCreateCompanionBuilder =
    SyncConflictsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String> deviceId,
      required String entity,
      required String recordId,
      required String localJson,
      required String remoteJson,
      Value<DateTime?> resolvedAt,
      Value<int> rowid,
    });
typedef $$SyncConflictsTableUpdateCompanionBuilder =
    SyncConflictsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String> deviceId,
      Value<String> entity,
      Value<String> recordId,
      Value<String> localJson,
      Value<String> remoteJson,
      Value<DateTime?> resolvedAt,
      Value<int> rowid,
    });

class $$SyncConflictsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localJson => $composableBuilder(
    column: $table.localJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteJson => $composableBuilder(
    column: $table.remoteJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncConflictsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localJson => $composableBuilder(
    column: $table.localJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteJson => $composableBuilder(
    column: $table.remoteJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncConflictsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get localJson =>
      $composableBuilder(column: $table.localJson, builder: (column) => column);

  GeneratedColumn<String> get remoteJson => $composableBuilder(
    column: $table.remoteJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );
}

class $$SyncConflictsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncConflictsTable,
          SyncConflictRow,
          $$SyncConflictsTableFilterComposer,
          $$SyncConflictsTableOrderingComposer,
          $$SyncConflictsTableAnnotationComposer,
          $$SyncConflictsTableCreateCompanionBuilder,
          $$SyncConflictsTableUpdateCompanionBuilder,
          (
            SyncConflictRow,
            BaseReferences<_$AppDatabase, $SyncConflictsTable, SyncConflictRow>,
          ),
          SyncConflictRow,
          PrefetchHooks Function()
        > {
  $$SyncConflictsTableTableManager(_$AppDatabase db, $SyncConflictsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncConflictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncConflictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncConflictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String> localJson = const Value.absent(),
                Value<String> remoteJson = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                entity: entity,
                recordId: recordId,
                localJson: localJson,
                remoteJson: remoteJson,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                required String entity,
                required String recordId,
                required String localJson,
                required String remoteJson,
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                entity: entity,
                recordId: recordId,
                localJson: localJson,
                remoteJson: remoteJson,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncConflictsTable, SyncConflictRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncConflictsTable,
                    SyncConflictRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncConflictsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncConflictsTable,
      SyncConflictRow,
      $$SyncConflictsTableFilterComposer,
      $$SyncConflictsTableOrderingComposer,
      $$SyncConflictsTableAnnotationComposer,
      $$SyncConflictsTableCreateCompanionBuilder,
      $$SyncConflictsTableUpdateCompanionBuilder,
      (
        SyncConflictRow,
        BaseReferences<_$AppDatabase, $SyncConflictsTable, SyncConflictRow>,
      ),
      SyncConflictRow,
      PrefetchHooks Function()
    >;
typedef $$SyncBaseTableCreateCompanionBuilder = SyncBaseCompanion Function({
  required String entity,
  required String recordId,
  required String json,
  Value<int> rowid,
});
typedef $$SyncBaseTableUpdateCompanionBuilder = SyncBaseCompanion Function({
  Value<String> entity,
  Value<String> recordId,
  Value<String> json,
  Value<int> rowid,
});

class $$SyncBaseTableFilterComposer
    extends Composer<_$AppDatabase, $SyncBaseTable> {
  $$SyncBaseTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncBaseTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncBaseTable> {
  $$SyncBaseTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncBaseTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncBaseTable> {
  $$SyncBaseTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);
}

class $$SyncBaseTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncBaseTable,
          SyncBaseRow,
          $$SyncBaseTableFilterComposer,
          $$SyncBaseTableOrderingComposer,
          $$SyncBaseTableAnnotationComposer,
          $$SyncBaseTableCreateCompanionBuilder,
          $$SyncBaseTableUpdateCompanionBuilder,
          (
            SyncBaseRow,
            BaseReferences<_$AppDatabase, $SyncBaseTable, SyncBaseRow>,
          ),
          SyncBaseRow,
          PrefetchHooks Function()
        > {
  $$SyncBaseTableTableManager(_$AppDatabase db, $SyncBaseTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncBaseTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncBaseTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncBaseTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entity = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncBaseCompanion(
                entity: entity,
                recordId: recordId,
                json: json,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entity,
                required String recordId,
                required String json,
                Value<int> rowid = const Value.absent(),
              }) => SyncBaseCompanion.insert(
                entity: entity,
                recordId: recordId,
                json: json,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncBaseTable, SyncBaseRow>(table),
                  BaseReferences<_$AppDatabase, $SyncBaseTable, SyncBaseRow>(
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

typedef $$SyncBaseTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncBaseTable,
      SyncBaseRow,
      $$SyncBaseTableFilterComposer,
      $$SyncBaseTableOrderingComposer,
      $$SyncBaseTableAnnotationComposer,
      $$SyncBaseTableCreateCompanionBuilder,
      $$SyncBaseTableUpdateCompanionBuilder,
      (SyncBaseRow, BaseReferences<_$AppDatabase, $SyncBaseTable, SyncBaseRow>),
      SyncBaseRow,
      PrefetchHooks Function()
    >;
typedef $$PlanningDefaultsVersionsTableCreateCompanionBuilder =
    PlanningDefaultsVersionsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String> deviceId,
      required String effectiveFrom,
      Value<int> salaryCents,
      Value<int> extraIncomeCents,
      Value<int> savingsGoalCents,
      Value<int> investmentCents,
      Value<int> rowid,
    });
typedef $$PlanningDefaultsVersionsTableUpdateCompanionBuilder =
    PlanningDefaultsVersionsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String> deviceId,
      Value<String> effectiveFrom,
      Value<int> salaryCents,
      Value<int> extraIncomeCents,
      Value<int> savingsGoalCents,
      Value<int> investmentCents,
      Value<int> rowid,
    });

class $$PlanningDefaultsVersionsTableFilterComposer
    extends Composer<_$AppDatabase, $PlanningDefaultsVersionsTable> {
  $$PlanningDefaultsVersionsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get salaryCents => $composableBuilder(
    column: $table.salaryCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get extraIncomeCents => $composableBuilder(
    column: $table.extraIncomeCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get savingsGoalCents => $composableBuilder(
    column: $table.savingsGoalCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get investmentCents => $composableBuilder(
    column: $table.investmentCents,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlanningDefaultsVersionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanningDefaultsVersionsTable> {
  $$PlanningDefaultsVersionsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get salaryCents => $composableBuilder(
    column: $table.salaryCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get extraIncomeCents => $composableBuilder(
    column: $table.extraIncomeCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get savingsGoalCents => $composableBuilder(
    column: $table.savingsGoalCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get investmentCents => $composableBuilder(
    column: $table.investmentCents,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlanningDefaultsVersionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanningDefaultsVersionsTable> {
  $$PlanningDefaultsVersionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => column,
  );

  GeneratedColumn<int> get salaryCents => $composableBuilder(
    column: $table.salaryCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get extraIncomeCents => $composableBuilder(
    column: $table.extraIncomeCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get savingsGoalCents => $composableBuilder(
    column: $table.savingsGoalCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get investmentCents => $composableBuilder(
    column: $table.investmentCents,
    builder: (column) => column,
  );
}

class $$PlanningDefaultsVersionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanningDefaultsVersionsTable,
          DefaultsVersionRow,
          $$PlanningDefaultsVersionsTableFilterComposer,
          $$PlanningDefaultsVersionsTableOrderingComposer,
          $$PlanningDefaultsVersionsTableAnnotationComposer,
          $$PlanningDefaultsVersionsTableCreateCompanionBuilder,
          $$PlanningDefaultsVersionsTableUpdateCompanionBuilder,
          (
            DefaultsVersionRow,
            BaseReferences<
              _$AppDatabase,
              $PlanningDefaultsVersionsTable,
              DefaultsVersionRow
            >,
          ),
          DefaultsVersionRow,
          PrefetchHooks Function()
        > {
  $$PlanningDefaultsVersionsTableTableManager(
    _$AppDatabase db,
    $PlanningDefaultsVersionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanningDefaultsVersionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PlanningDefaultsVersionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PlanningDefaultsVersionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> effectiveFrom = const Value.absent(),
                Value<int> salaryCents = const Value.absent(),
                Value<int> extraIncomeCents = const Value.absent(),
                Value<int> savingsGoalCents = const Value.absent(),
                Value<int> investmentCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanningDefaultsVersionsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                effectiveFrom: effectiveFrom,
                salaryCents: salaryCents,
                extraIncomeCents: extraIncomeCents,
                savingsGoalCents: savingsGoalCents,
                investmentCents: investmentCents,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                required String effectiveFrom,
                Value<int> salaryCents = const Value.absent(),
                Value<int> extraIncomeCents = const Value.absent(),
                Value<int> savingsGoalCents = const Value.absent(),
                Value<int> investmentCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanningDefaultsVersionsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                effectiveFrom: effectiveFrom,
                salaryCents: salaryCents,
                extraIncomeCents: extraIncomeCents,
                savingsGoalCents: savingsGoalCents,
                investmentCents: investmentCents,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $PlanningDefaultsVersionsTable,
                    DefaultsVersionRow
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PlanningDefaultsVersionsTable,
                    DefaultsVersionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlanningDefaultsVersionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanningDefaultsVersionsTable,
      DefaultsVersionRow,
      $$PlanningDefaultsVersionsTableFilterComposer,
      $$PlanningDefaultsVersionsTableOrderingComposer,
      $$PlanningDefaultsVersionsTableAnnotationComposer,
      $$PlanningDefaultsVersionsTableCreateCompanionBuilder,
      $$PlanningDefaultsVersionsTableUpdateCompanionBuilder,
      (
        DefaultsVersionRow,
        BaseReferences<
          _$AppDatabase,
          $PlanningDefaultsVersionsTable,
          DefaultsVersionRow
        >,
      ),
      DefaultsVersionRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$RecurringTransactionsTableTableManager get recurringTransactions =>
      $$RecurringTransactionsTableTableManager(_db, _db.recurringTransactions);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
  $$IncomesTableTableManager get incomes =>
      $$IncomesTableTableManager(_db, _db.incomes);
  $$InvestmentsTableTableManager get investments =>
      $$InvestmentsTableTableManager(_db, _db.investments);
  $$PlanningsTableTableManager get plannings =>
      $$PlanningsTableTableManager(_db, _db.plannings);
  $$MonthConfigurationsTableTableManager get monthConfigurations =>
      $$MonthConfigurationsTableTableManager(_db, _db.monthConfigurations);
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db, _db.syncMetadata);
  $$SyncConflictsTableTableManager get syncConflicts =>
      $$SyncConflictsTableTableManager(_db, _db.syncConflicts);
  $$SyncBaseTableTableManager get syncBase =>
      $$SyncBaseTableTableManager(_db, _db.syncBase);
  $$PlanningDefaultsVersionsTableTableManager get planningDefaultsVersions =>
      $$PlanningDefaultsVersionsTableTableManager(
        _db,
        _db.planningDefaultsVersions,
      );
}
