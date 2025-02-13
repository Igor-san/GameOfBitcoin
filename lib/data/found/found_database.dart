/*
dart run build_runner build --delete-conflicting-outputs
 */

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/tables.dart';


// assuming that your file is called filename.dart. This will give an error at
// first, but it's needed for drift to know about the generated code
part 'found_database.g.dart';

// this annotation tells drift to prepare a database class that uses both of the
// tables we just defined. We'll see how to use that database class in a moment.
//'keyCount': 'SELECT COUNT(Key) FROM found;' Got Instance of 'InvalidStatement', expected insert, select, update or delete
//что-то Key название столбца ему не нравится
@DriftDatabase(tables: [FoundTable],
  queries: {
    'keyCount': 'SELECT COUNT(IntKey) FROM found;'
  },
)
class FoundSharedDatabase extends _$FoundSharedDatabase {
  FoundSharedDatabase(QueryExecutor e): super(e);

  @override
  int get schemaVersion => 1;
}
