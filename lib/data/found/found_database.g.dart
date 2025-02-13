// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'found_database.dart';

// ignore_for_file: type=lint
class $FoundTableTable extends FoundTable
    with TableInfo<$FoundTableTable, FoundTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoundTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'IntKey', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'found';
  @override
  VerificationContext validateIntegrity(Insertable<FoundTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('IntKey')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['IntKey']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  FoundTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoundTableData(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}IntKey'])!,
    );
  }

  @override
  $FoundTableTable createAlias(String alias) {
    return $FoundTableTable(attachedDatabase, alias);
  }
}

class FoundTableData extends DataClass implements Insertable<FoundTableData> {
  final String key;
  const FoundTableData({required this.key});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['IntKey'] = Variable<String>(key);
    return map;
  }

  FoundTableCompanion toCompanion(bool nullToAbsent) {
    return FoundTableCompanion(
      key: Value(key),
    );
  }

  factory FoundTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoundTableData(
      key: serializer.fromJson<String>(json['IntKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'IntKey': serializer.toJson<String>(key),
    };
  }

  FoundTableData copyWith({String? key}) => FoundTableData(
        key: key ?? this.key,
      );
  FoundTableData copyWithCompanion(FoundTableCompanion data) {
    return FoundTableData(
      key: data.key.present ? data.key.value : this.key,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoundTableData(')
          ..write('key: $key')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => key.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoundTableData && other.key == this.key);
}

class FoundTableCompanion extends UpdateCompanion<FoundTableData> {
  final Value<String> key;
  final Value<int> rowid;
  const FoundTableCompanion({
    this.key = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoundTableCompanion.insert({
    required String key,
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<FoundTableData> custom({
    Expression<String>? key,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'IntKey': key,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoundTableCompanion copyWith({Value<String>? key, Value<int>? rowid}) {
    return FoundTableCompanion(
      key: key ?? this.key,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['IntKey'] = Variable<String>(key.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoundTableCompanion(')
          ..write('key: $key, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$FoundSharedDatabase extends GeneratedDatabase {
  _$FoundSharedDatabase(QueryExecutor e) : super(e);
  $FoundSharedDatabaseManager get managers => $FoundSharedDatabaseManager(this);
  late final $FoundTableTable foundTable = $FoundTableTable(this);
  Selectable<int> keyCount() {
    return customSelect('SELECT COUNT(IntKey) AS _c0 FROM found',
        variables: [],
        readsFrom: {
          foundTable,
        }).map((QueryRow row) => row.read<int>('_c0'));
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [foundTable];
}

typedef $$FoundTableTableCreateCompanionBuilder = FoundTableCompanion Function({
  required String key,
  Value<int> rowid,
});
typedef $$FoundTableTableUpdateCompanionBuilder = FoundTableCompanion Function({
  Value<String> key,
  Value<int> rowid,
});

class $$FoundTableTableFilterComposer
    extends Composer<_$FoundSharedDatabase, $FoundTableTable> {
  $$FoundTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));
}

class $$FoundTableTableOrderingComposer
    extends Composer<_$FoundSharedDatabase, $FoundTableTable> {
  $$FoundTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));
}

class $$FoundTableTableAnnotationComposer
    extends Composer<_$FoundSharedDatabase, $FoundTableTable> {
  $$FoundTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);
}

class $$FoundTableTableTableManager extends RootTableManager<
    _$FoundSharedDatabase,
    $FoundTableTable,
    FoundTableData,
    $$FoundTableTableFilterComposer,
    $$FoundTableTableOrderingComposer,
    $$FoundTableTableAnnotationComposer,
    $$FoundTableTableCreateCompanionBuilder,
    $$FoundTableTableUpdateCompanionBuilder,
    (
      FoundTableData,
      BaseReferences<_$FoundSharedDatabase, $FoundTableTable, FoundTableData>
    ),
    FoundTableData,
    PrefetchHooks Function()> {
  $$FoundTableTableTableManager(
      _$FoundSharedDatabase db, $FoundTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoundTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoundTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoundTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FoundTableCompanion(
            key: key,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            Value<int> rowid = const Value.absent(),
          }) =>
              FoundTableCompanion.insert(
            key: key,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FoundTableTableProcessedTableManager = ProcessedTableManager<
    _$FoundSharedDatabase,
    $FoundTableTable,
    FoundTableData,
    $$FoundTableTableFilterComposer,
    $$FoundTableTableOrderingComposer,
    $$FoundTableTableAnnotationComposer,
    $$FoundTableTableCreateCompanionBuilder,
    $$FoundTableTableUpdateCompanionBuilder,
    (
      FoundTableData,
      BaseReferences<_$FoundSharedDatabase, $FoundTableTable, FoundTableData>
    ),
    FoundTableData,
    PrefetchHooks Function()>;

class $FoundSharedDatabaseManager {
  final _$FoundSharedDatabase _db;
  $FoundSharedDatabaseManager(this._db);
  $$FoundTableTableTableManager get foundTable =>
      $$FoundTableTableTableManager(_db, _db.foundTable);
}
