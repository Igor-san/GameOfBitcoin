// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AddressTableTable extends AddressTable
    with TableInfo<$AddressTableTable, AddressTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AddressTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'Address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [address];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'address';
  @override
  VerificationContext validateIntegrity(Insertable<AddressTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('Address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['Address']!, _addressMeta));
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {address};
  @override
  AddressTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AddressTableData(
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}Address'])!,
    );
  }

  @override
  $AddressTableTable createAlias(String alias) {
    return $AddressTableTable(attachedDatabase, alias);
  }
}

class AddressTableData extends DataClass
    implements Insertable<AddressTableData> {
  final String address;
  const AddressTableData({required this.address});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['Address'] = Variable<String>(address);
    return map;
  }

  AddressTableCompanion toCompanion(bool nullToAbsent) {
    return AddressTableCompanion(
      address: Value(address),
    );
  }

  factory AddressTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AddressTableData(
      address: serializer.fromJson<String>(json['Address']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'Address': serializer.toJson<String>(address),
    };
  }

  AddressTableData copyWith({String? address}) => AddressTableData(
        address: address ?? this.address,
      );
  AddressTableData copyWithCompanion(AddressTableCompanion data) {
    return AddressTableData(
      address: data.address.present ? data.address.value : this.address,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AddressTableData(')
          ..write('address: $address')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => address.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AddressTableData && other.address == this.address);
}

class AddressTableCompanion extends UpdateCompanion<AddressTableData> {
  final Value<String> address;
  final Value<int> rowid;
  const AddressTableCompanion({
    this.address = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AddressTableCompanion.insert({
    required String address,
    this.rowid = const Value.absent(),
  }) : address = Value(address);
  static Insertable<AddressTableData> custom({
    Expression<String>? address,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (address != null) 'Address': address,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AddressTableCompanion copyWith({Value<String>? address, Value<int>? rowid}) {
    return AddressTableCompanion(
      address: address ?? this.address,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (address.present) {
      map['Address'] = Variable<String>(address.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AddressTableCompanion(')
          ..write('address: $address, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$SharedDatabase extends GeneratedDatabase {
  _$SharedDatabase(QueryExecutor e) : super(e);
  $SharedDatabaseManager get managers => $SharedDatabaseManager(this);
  late final $AddressTableTable addressTable = $AddressTableTable(this);
  Selectable<int> addressCount() {
    return customSelect('SELECT COUNT(Address) AS _c0 FROM address',
        variables: [],
        readsFrom: {
          addressTable,
        }).map((QueryRow row) => row.read<int>('_c0'));
  }

  Selectable<AddressTableData> getFirstAddress() {
    return customSelect('SELECT Address FROM address LIMIT 1',
        variables: [],
        readsFrom: {
          addressTable,
        }).asyncMap(addressTable.mapFromRow);
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [addressTable];
}

typedef $$AddressTableTableCreateCompanionBuilder = AddressTableCompanion
    Function({
  required String address,
  Value<int> rowid,
});
typedef $$AddressTableTableUpdateCompanionBuilder = AddressTableCompanion
    Function({
  Value<String> address,
  Value<int> rowid,
});

class $$AddressTableTableFilterComposer
    extends Composer<_$SharedDatabase, $AddressTableTable> {
  $$AddressTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));
}

class $$AddressTableTableOrderingComposer
    extends Composer<_$SharedDatabase, $AddressTableTable> {
  $$AddressTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));
}

class $$AddressTableTableAnnotationComposer
    extends Composer<_$SharedDatabase, $AddressTableTable> {
  $$AddressTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);
}

class $$AddressTableTableTableManager extends RootTableManager<
    _$SharedDatabase,
    $AddressTableTable,
    AddressTableData,
    $$AddressTableTableFilterComposer,
    $$AddressTableTableOrderingComposer,
    $$AddressTableTableAnnotationComposer,
    $$AddressTableTableCreateCompanionBuilder,
    $$AddressTableTableUpdateCompanionBuilder,
    (
      AddressTableData,
      BaseReferences<_$SharedDatabase, $AddressTableTable, AddressTableData>
    ),
    AddressTableData,
    PrefetchHooks Function()> {
  $$AddressTableTableTableManager(_$SharedDatabase db, $AddressTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AddressTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AddressTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AddressTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> address = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AddressTableCompanion(
            address: address,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String address,
            Value<int> rowid = const Value.absent(),
          }) =>
              AddressTableCompanion.insert(
            address: address,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AddressTableTableProcessedTableManager = ProcessedTableManager<
    _$SharedDatabase,
    $AddressTableTable,
    AddressTableData,
    $$AddressTableTableFilterComposer,
    $$AddressTableTableOrderingComposer,
    $$AddressTableTableAnnotationComposer,
    $$AddressTableTableCreateCompanionBuilder,
    $$AddressTableTableUpdateCompanionBuilder,
    (
      AddressTableData,
      BaseReferences<_$SharedDatabase, $AddressTableTable, AddressTableData>
    ),
    AddressTableData,
    PrefetchHooks Function()>;

class $SharedDatabaseManager {
  final _$SharedDatabase _db;
  $SharedDatabaseManager(this._db);
  $$AddressTableTableTableManager get addressTable =>
      $$AddressTableTableTableManager(_db, _db.addressTable);
}
