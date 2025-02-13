import 'package:dartz/dartz.dart';
import 'dart:async';
import 'package:drift/drift.dart';

import 'package:game_of_bitcoin/main.dart' show logger;
import 'package:game_of_bitcoin/data/data.dart';
import 'package:game_of_bitcoin/common/common.dart';

class Repository {
  final SharedDatabase database;

  Repository({
    required this.database,
  });

  Future<int> getTableSize(String name) async {

    try {
      var count = countAll();
      var q;
      switch (name) {
        case 'address':
          q = database.selectOnly(database.addressTable);
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
      logger.e("getTableSize($name) Exception", error: ex);
      return -1;
    }
  }

  Future<Map<String, int>> getTablesInfo() async {

    Map<String, int> result = {};
    try {
      int r = await getTableSize('address');
      result['address'] = r;

      return result;
    } catch (ex) {
      logger.e("getTablesInfo() Exception", error: ex);
      return result;
    }
  }

  ///та ли это база, т.е. sqlite с таблицей address
  Future<Either<Failure, bool>> isDatabaseCorrect() async {
    try {
      await database.getFirstAddress().get(); //если нет таблицы Address то вылетит
      return Right(true); //все равно правильная база

    } on DbFailure catch (ex) {
    logger.e("isDatabaseCorrect() DbFailure", error: ex);
    return Left(DbFailure("isDatabaseCorrect DbFailure ${ex.message}"));
    } catch (ex) {
      logger.e("isDatabaseCorrect() Exception", error: ex);
      return Left(DbFailure("isDatabaseCorrect() Exception ${ex}"));
    }
  }

///Проверить существование адреса
  Future<Either<Failure,bool>> isAddressExists(String address) async {
    try {

      var query = database.select(database.addressTable)
        ..where((x) => x.address.equals(address));

      var item = await query.getSingleOrNull();

      if (item == null) {
        return Right(false);
      }

      return Right(true);
    } catch (ex) {
      logger.e("isAddressExists($address) Exception", error: ex);
      return Left(DbFailure("isAddressExists($address) Exception ${ex.toString()}"));
    }
  }

  @override
  Future<Either<Failure, int>> addAddress(String address) async {
    try {
        var entry = AddressTableCompanion(address: Value(address));
        int id = await database.into(database.addressTable).insert(entry);

      return Right(id);
    } catch (ex) {
      logger.e("ddAddress($address) Exception", error: ex);
      return Left(DbFailure("addAddress($address) Exception ${ex.toString()}"));
    }
  }
}