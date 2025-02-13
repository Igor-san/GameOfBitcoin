
import 'package:dartz/dartz.dart';
import 'dart:async';
import 'package:drift/drift.dart';

import 'package:game_of_bitcoin/main.dart' show logger;
import 'package:game_of_bitcoin/common/common.dart';

import 'found_database.dart';

class FoundRepository {
  final FoundSharedDatabase database;

  FoundRepository({
    required this.database,
  });

  ///Shrink и переиндексация
  Future<void> _vacuumAndReindex() async {
    await database.customStatement('VACUUM');
    await database.customStatement('REINDEX');
  }

  Future<int> getTableSize(String name) async {

    try {
      var count = countAll();
      var q;
      switch (name) {
        case 'found':
          q = database.selectOnly(database.foundTable);
        default:
          return -1;
      }

      var res = await (q..addColumns([count]))
          .map((row) => row.read(count))
          .getSingle();

      if (res == null) {
        return -1;
      }
      return res;
    } catch (ex) {
      logger.e("getTableSize($name)", error: ex);
      return -1;
    }
  }

  Future<Map<String, int>> getTablesInfo() async {

    Map<String, int> result = {};
    try {
      int r = await getTableSize('found');
      result['found'] = r;

      return result;
    } catch (ex) {
      logger.e("getTablesInfo()", error: ex);
      return result;
    }
  }

///Проверить существование адреса
  Future<Either<Failure,bool>> isKeyExists(String key) async {
    try {

      var query = database.select(database.foundTable)
        ..where((x) => x.key.equals(key));

      var item = await query.getSingleOrNull();

      if (item == null) {
        return Right(false);
      }

      return Right(true);
    } catch (ex) {
      logger.e("isKeyExists", error: ex);
      return Left(DbFailure("isKeyExists($key) Exception ${ex.toString()}"));
    }
  }

  Future<Either<Failure, int>> addKey({required String key}) async {
    try {
        var entry = FoundTableCompanion(key: Value(key));
        int id = await database.into(database.foundTable).insert(entry);

      return Right(id);
    } catch (ex) {
      logger.e("addKey", error: ex);
      return Left(DbFailure("addKey($key) Exception ${ex.toString()}"));
    }
  }

  Future<Either<Failure, List<String>>> getAllFounded() async {
    try {
      List<FoundTableData> allItems =
      await database.select(database.foundTable).get();
      return Right(_mapListFoundTableDataToListString(allItems));
    } catch (ex) {
      logger.e("getAllFounded", error: ex);
      return Left(DbFailure("getAllFounded Exception ${ex.toString()}"));
    }
  }


  Future<Either<Failure, bool>> clearDatabase() async {
    try {
      //если есть внешние ключи - нужно их вначале отключить //https://github.com/simolus3/drift/issues/265
      await database.transaction(() async {
        for (final table in database.allTables) {
          await database.delete(table).go();
        }
      });
      await _vacuumAndReindex();

      return const Right(true);
    } catch (ex) {
      logger.e("clearDatabase", error: ex);
      return Left(DbFailure("clearDatabase() Exception ${ex.toString()}"));
    }
  }
}

List<String> _mapListFoundTableDataToListString(List<FoundTableData> allItems) {
  return allItems.map((item)=>item.key).toList();
}
