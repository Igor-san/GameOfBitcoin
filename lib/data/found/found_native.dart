// native.dart

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:path_provider/path_provider.dart';

import 'package:game_of_bitcoin/common/constants.dart';

import 'found_database.dart';

FoundSharedDatabase constructFoundDb() {
  final db = LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    var path = p.join(dbFolder.path, Constants.FOUND_DB_NAME);
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      path = p.join(Directory.current.path, Constants.FOUND_DB_NAME); //На десктопе пусть рядом с экзешником будет
    }

    final file = File(path);

    // Also work around limitations on old Android versions
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;
    // Если enableMigrations = false  тогда не заполняется таблицами созданная пустая база!
    return NativeDatabase.createInBackground(file, enableMigrations: true);
  });
  return FoundSharedDatabase(db);
}