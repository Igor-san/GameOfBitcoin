
import 'package:drift/drift.dart';

class FoundTable extends Table {
  @override
  String get tableName => 'found';

  @JsonKey('IntKey')
  TextColumn get key => text().named('IntKey')(); //найденный числовой ключ, с названием Key у дрифта какие-то глюки в custom queries

  @override
  Set<Column<Object>> get primaryKey => {key};
}

