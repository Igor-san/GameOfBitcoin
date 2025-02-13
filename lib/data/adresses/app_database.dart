import 'dart:developer';
import 'package:game_of_bitcoin/common/common.dart';
import 'package:game_of_bitcoin/data/data.dart';

import 'package:game_of_bitcoin/main.dart' show logger;

class AppDatabase {
  static bool isOpened = false;
  static String lastError = '';
  static SharedDatabase? _database;
  static late Repository repo;
  static String currentPath = ''; //текущий путь к базе

  AppDatabase._() {
    _reset(); //сбросим возможно старые состояния
  }

  static _reset()  {
    isOpened = false;
    currentPath = '';
    _database = null;
  }

  static _isDatabaseCorrect() async {
    var either = await repo.isDatabaseCorrect();
    if (either.isLeft()){
      throw either;
    } else if (either.asRight() == false){
      throw Exception("Это не допустимая база данных");
    }
   }

  static Future<AppDatabase> open(String dbFilePath) async {
    try {

      var component = AppDatabase._();
      lastError = '';

      if (_database == null) {
        List<String> dbFilePathList = [dbFilePath];
        _database = constructDb(dbFilePathList);
        repo = Repository(database: _database!);
        //!!! нужно проверить та ли это база, например есть ли таблица Address
        await _isDatabaseCorrect(); //дальше не пройдет если база не та
        if (dbFilePath.isEmpty) { //первый запуск до копирования демки или андроид с вебом
          //simolus3: There's no general solution for this since some executors don't operate on a file (e.g. web or VmDatabase.memory()).
          dbFilePath = dbFilePathList[0]; //через одно место но только так смог получить новый путь
        }
        currentPath = dbFilePath;
        isOpened = true;
      } else {
        if (currentPath != dbFilePath) {
          await _database!.close();
        //Databases currently can't be re-opened. https://github.com/simolus3/drift/discussions/2513
          _reset(); //!!сбросим
          List<String> dbFilePathList = [dbFilePath];

          _database = constructDb(dbFilePathList);
          repo = Repository(database: _database!);
          //!!! нужно проверить та ли это база, например есть ли таблица Address
          await _isDatabaseCorrect(); //дальше не пройдет если база не та

          currentPath = dbFilePath;
          isOpened = true;

        }
      }

      return component;
    } catch(ex){
      lastError = ex.toString();
      logger.e("AppDatabase open error: ${ex}", error: ex);
      return AppDatabase._(); //with isOpened = false
    }
  }

}