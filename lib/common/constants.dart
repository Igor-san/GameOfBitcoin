
import 'dart:ui' show Size;

class Constants {
  static const String APP_NAME = 'Game of Bitcoin';
  static const LOG_PREFIX = "game_of_bitcoin"; //game_of_bitcoin-2024-12-25.log  in logger.dart
  static const LOG_SUFFIX = "log"; //without .

  static const DATABASE_PATH_KEY = "DATABASE_PATH_KEY";

  static const Size NORMAL_SIZE = Size(1024,860);
  static const Size MOBILE_SIZE = Size(500,700);

  static const String IS_DARK_THEME_NAME = 'isDarkTheme';

  static const String DEMO_DB_NAME = 'demo_db.sqlite'; //база с адресами/хэшами
  static const String FOUND_DB_NAME = 'found_db.sqlite'; //база для найденных ключей
}
