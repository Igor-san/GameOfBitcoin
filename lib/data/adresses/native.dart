// native.dart
import 'dart:developer' show log;
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqlite3/sqlite3.dart';

import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'package:game_of_bitcoin/common/constants.dart';
import "package:game_of_bitcoin/data/data.dart";

SharedDatabase constructDb(List<String> dbPath) {
  assert(dbPath.length == 1, "Путь к файлу необходимо передавать в списке");

  final db = _openConnection(dbPath);

  return SharedDatabase(db);
}

///приходится передавать в списке чтобы по ссылке изменить при необходимости путь
LazyDatabase _openConnection(List<String> dbPath) {
  return LazyDatabase(() async {
    // Only copy if the database doesn't exist https://stackoverflow.com/questions/51384175/sqlite-in-flutter-how-database-assets-work
    // Construct a file path to copy database to https://drift.simonbinder.eu/examples/existing_databases/#extracting-the-database
    if (dbPath[0].isEmpty) {
      //или первый запуск под десктопом, или мы в вебе или андроиде

      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      log("Directory documentsDirectory = $documentsDirectory");
      dbPath[0] = p.join(documentsDirectory.path, Constants.DEMO_DB_NAME);

      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        dbPath[0] = p.join(
            Directory.current.path,
            Constants
                .DEMO_DB_NAME); //На десктопе пусть рядом с экзешником будет
      }

      if (FileSystemEntity.typeSync(dbPath[0]) ==
          FileSystemEntityType.notFound) {
        // Load database from asset and copy
        //ByteData data = await rootBundle.load(p.join('assets', Constants.DEMO_DB_NAME)); //так в Виндос не копирует у меня
        ByteData data = await rootBundle.load(
            "assets/${Constants.DEMO_DB_NAME}"); //так копирует

        List<int> bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        // Save copied asset to documents
        await File(dbPath[0]).writeAsBytes(bytes);
      }
    }

    final file = File(dbPath[0]);

    bool exists = await file.exists();
    if (!exists) {
      throw Exception(
          "file not exists!"); //если нет то чтобы не создавалась пустая
    }

    // Also work around limitations on old Android versions
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    // Make sqlite3 pick a more suitable location for temporary files - the
    // one from the system may be inaccessible due to sandboxing.
    final cachebase = (await getTemporaryDirectory()).path;
    // We can't access /tmp on Android, which sqlite3 would try by default.
    // Explicitly tell it about the correct temporary directory.
    sqlite3.tempDirectory = cachebase;
//So until its not accessed, its not created, i see, thank you! i just did simple query and it popped up.
    return NativeDatabase.createInBackground(file, enableMigrations: false);
  });
}
