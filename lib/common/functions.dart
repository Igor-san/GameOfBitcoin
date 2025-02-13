import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'extensions.dart';

Random _rnd = Random();

typedef FutureCallback = Future<void> Function();

bool get isDesktop =>(!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS));


Uri getBlockchainUri(String address) {
  //https://www.blockchain.com/explorer/addresses/btc/1sdsfsfsfs
  return Uri.parse('https://www.blockchain.com/explorer/addresses/btc/$address');

}

const _keyChars = '1234567890';

///Случайный ключ заданной длины или случайной длины
String getRandomKey([int length=0]) {
  if (length == 0){
    length = _rnd.nextInt(77)+1; //макс биткоин ключ 115792089237316195423570985008687907852837564279074904382605163141518161494336. но на 1 уменьшим длину
  }
  return String.fromCharCodes(Iterable.generate(
      length, (_) => _keyChars.codeUnitAt(_rnd.nextInt(_keyChars.length)))
  );
}


Future<String> getLoggerDir() async {
  var logDir = "logs";
  String path = '';
  if (Platform.isAndroid) {
    Directory dir = await getApplicationDocumentsDirectory();
    path = p.join(dir.path, logDir);
  } else {
    path = p.join(Directory.current.path, logDir);
  }
  return path;

}

void showScaffoldMessage({required BuildContext context, required String message,
  required bool isError,
  int successDuration =2,
  int errorDuration = 3,
}) {

  var duration = Duration(seconds: successDuration);
  Color backColor = Theme.of(context).extension<MyColors>()?.successColor?? Colors.greenAccent ;
  if (isError) {
    backColor = Theme.of(context).extension<MyColors>()?.errorColor?? Theme.of(context).colorScheme.error;
    duration = Duration(seconds: errorDuration);
  }

  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: backColor,
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18.0,
          ),
        ),
      ),
    );

}
