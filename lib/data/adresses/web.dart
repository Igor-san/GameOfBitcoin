
import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:flutter/services.dart';

import "package:game_of_bitcoin/data/data.dart";
import 'package:game_of_bitcoin/common/constants.dart';

DatabaseConnection _connectOnWeb() {
  return DatabaseConnection.delayed(Future(() async {
    final result = await WasmDatabase.open(
      databaseName: 'addresses_db', // prefer to only use valid identifiers here
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.dart.js'),
      initializeDatabase: () async {
        final data = await rootBundle.load("assets/${Constants.DEMO_DB_NAME}");
        return data.buffer.asUint8List();
      },
    );
    if (result.missingFeatures.isNotEmpty) {
      // Depending how central local persistence is to your app, you may want
      // to show a warning to the user if only unrealiable implemetentations
      // are available.
      print('Using ${result.chosenImplementation} due to missing browser '
          'features: ${result.missingFeatures}');
    }

    return result.resolvedExecutor;
  }));
}


SharedDatabase constructDb(List<String> path) {
  return SharedDatabase(_connectOnWeb());
}
