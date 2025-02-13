/*
dart run build_runner build ->generates all the required code once.
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
 */

import 'package:drift/drift.dart';
import 'tables/tables.dart';


// assuming that your file is called filename.dart. This will give an error at
// first, but it's needed for drift to know about the generated code
part 'database.g.dart';

// this annotation tells drift to prepare a database class that uses both of the
// tables we just defined. We'll see how to use that database class in a moment.
@DriftDatabase(tables: [AddressTable],
  queries: {
    'addressCount': 'SELECT COUNT(Address) FROM [address];',
    'getFirstAddress': 'SELECT Address FROM [address] LIMIT 1;'
  },
)
class SharedDatabase extends _$SharedDatabase {
  SharedDatabase(QueryExecutor e): super(e);

  @override
  int get schemaVersion => 1;
}

