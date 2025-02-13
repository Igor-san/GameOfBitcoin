import 'package:drift/drift.dart';
//Address название, но там RipeMd160!
class AddressTable extends Table {
  @override
  String get tableName => 'address';

  @JsonKey('Address')
  TextColumn get address => text().named('Address')();

  @override
  Set<Column<Object>> get primaryKey => {address};
}
