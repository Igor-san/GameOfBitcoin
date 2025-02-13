import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;

import 'package:game_of_bitcoin/common/common.dart';


Future<Logger> createLogger() async {

  var now = DateTime.now();
  var formatter = DateFormat('yyyy-MM-dd');
  String formattedDate = formatter.format(now);
  String path = '';

  if (!kIsWeb){
    path = await getLoggerDir(); // куда пишу логи
    if (!await Directory(path).exists()){
      await Directory(path).create(recursive: false);
    }
  }

  return Logger(
      filter: MyLogFilter(),
      printer: kDebugMode ? PrettyPrinter(
        dateTimeFormat:DateTimeFormat.onlyTimeAndSinceStart,
        printEmojis: false,
        //  colors: false, noBoxingByDefault: true, printEmojis: false // убирает лишние знаки значков в виде кода
      )
          : PrettyPrinter(
          dateTimeFormat:DateTimeFormat.onlyTimeAndSinceStart,
          colors: false, noBoxingByDefault: true, printEmojis: false),

      output: MultiOutput([
        Logger.defaultOutput(),
        if (!kIsWeb && path.isNotEmpty)
        FileOutput(
            file: File(
              p.join(path,
                  "${Constants.LOG_PREFIX}-${formattedDate}.${Constants.LOG_SUFFIX}"),
            )
        ),
      ])
  );
}

class MyLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
   //фильтр один на все принтеры!
    if (kDebugMode) return true; //в дебаге вывожу все, в релизе только ошибки
    return (event.level == Level.error || event.level == Level.fatal);
  }
}
