
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:game_of_bitcoin/locator_service.dart';

import 'package:game_of_bitcoin/common/common.dart';
import 'package:game_of_bitcoin/data/data.dart';
import 'package:game_of_bitcoin/domain/domain.dart';
import 'package:game_of_bitcoin/main.dart' show logger;
import 'package:game_of_bitcoin/presentation/presentation.dart';
import 'package:game_of_bitcoin/bloc/bloc.dart';

const double _textFontSize = 12.0;

class GameControls extends StatefulWidget {
  final double controlsHeight;
  final double statusHeight; //высота статусной строки которая видна всегда
  final bool isMobile;

  const GameControls({
    super.key,
    required this.controller,
    required this.controlsHeight,
    required this.statusHeight,
    required this.isMobile,
  });

  final GameController controller;

  @override
  State<GameControls> createState() => _GameControlsState();
}

class _GameControlsState extends State<GameControls> {

  String privateKeyInt = '';
  String compressedP2PKH = '';
  String uncompressedP2PKH = '';
  String lastStatus = '';
  bool isKeyFound = false; //ключ найден - нужно сбрасывать не забывать
  int keysFounded = 0;

  final List<String> stateHistory = []; //детектор
  bool autoStartAfterEnd =
      true; //начинать со случаной комбинации после окончания текущего прохода. Может в настройки как в питоновской?
  int totalGames = 0; //общее число полных игр
  int currentStep =
      0; //это шаг в текущей игре - вызывается на событии whenCompute
  int maxOfStep = 0; //максимальное число шагов в игре
  String cacheInfo = '';
  double maxSpeed = 0;
  Stopwatch speedometer = Stopwatch(); //просто для измерения скорости генерации

  late FoundRepository foundRepo; //repo for founded keys

  @override
  void initState() {

  foundRepo = sl<FoundRepository>();

    widget.controller.whenCompute =
        _checkCells; //обработка нового состояния ячеек
    widget.controller.onControlRepaint =
        _onControlRepaint; //перерисовка панели управления и информации

    super.initState();
  }

  String _getStepInfo() {
    if (currentStep % 10 == 0) {
      //every 10 steps
      cacheInfo =
          "Ход $currentStep (max $maxOfStep), игр $totalGames, max ${maxSpeed.toStringAsFixed(2)} ходов в сек.";
    }

    String foundedMsg ="";
    if (keysFounded>0){
      foundedMsg =", ключей ${keysFounded}";
    }
    return "${cacheInfo}$foundedMsg";
  }


  Future _onControlRepaint() async {
    if (mounted) {
      setState(() {

      });
    }
  }

  @override
  Widget build(BuildContext context) {

       return  BlocListener<ControllerBloc, ControllerState>(
          listener: (context, state) {

            if (state.gameState == GameState.Start) {
              _startGame(true);
            } else if (state.gameState == GameState.Stop) {
              _stopGame(true);
            } else if (state.gameState == GameState.GetKey) {
              _getKey(); //если постоянно вызывать то будет вызван только первый раз!
            } else if (state.gameState == GameState.Random) {
              _randomCells(); //если постоянно вызывать то будет вызван только первый раз!
            } else if (state.gameState == GameState.Clear) {
              _clear(); //если постоянно вызывать то будет вызван только первый раз!
            }
            //--
          },

          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(1.0),
                child: SizedBox(
                  height: widget.statusHeight,
                  child: Row(
                      children: [
                        Expanded(
                          child: Text(_getStepInfo(),
                              style: TextStyle(fontSize: _textFontSize)),
                        ),
                      ]
                  ),
                ),
              ),
              widget.isMobile
                  ? Container()
                  : Padding(
                padding: const EdgeInsets.only(top: 0.0, bottom: 0.0),
                child: SizedBox(
                  height: widget.controlsHeight,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(

                          child: Row(
                            children: [
                              Expanded(
                                child: Tooltip(

                                    message: "Приватный десятичный ключ",
                                    child: SelectableText(privateKeyInt,
                                        style:
                                        TextStyle(fontSize: _textFontSize))),
                              ),
                              Expanded(
                                child: Tooltip(
                                    message: "сжатый 2PKH",
                                    child: SelectableText(compressedP2PKH,
                                        style:
                                        TextStyle(fontSize: _textFontSize))),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          child: Row(
                            spacing: 4.0,
                            children: [
                              Expanded(
                                child: Tooltip(
                                  message: "Текущий статус",
                                  child: SizedBox(
                                    child: SelectableText(lastStatus,
                                        style:
                                        TextStyle(fontSize: _textFontSize)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

  }

  void _setKeyInfo(BitcoinKey? key, [bool found = false]) {

    if (key != null) {
      isKeyFound = found;
      privateKeyInt = key.bigIntKey.toString();
      compressedP2PKH = key.p2PKHcompressed;
      uncompressedP2PKH = key.p2PKHuncompressed;

    } else {
      isKeyFound = found;
      privateKeyInt = '';
      compressedP2PKH = '';
      uncompressedP2PKH = '';

    }
    setState(() {});

  }

  void _getKey() async {
    //Это вызывается по кнопке Get Key - тут не исследуем возможность останова, просто извлекаем BitcoinKey
    try {

      bool found = false;
      var cells = widget.controller.cells; //наши ячейки
      List<int> bits = cells.expand((i) => i).toList();
      bool isEmpty = bits.every((x) => x == 0);
      if (isEmpty) {
        lastStatus = "Все ячейки мертвы, ключ не будет корректным.";
        _setKeyInfo(null);
      } else {
        BitcoinKey key = BitcoinKey.fromBits(bits);

        if (AppDatabase.isOpened) {
          found = await _checkKey(key, true); //manual = true - просто проверяем наличие в базе
        }

        _setKeyInfo(
            key, found); //тут setState и отобразится последнее lastStatus
      }

      if (widget.isMobile) {
        //если мобильно то покажем BottomSheet, иначе в обычной верхней панели
        _showModalBottomSheet(found);
      }

    } catch (ex) {
      logger.e('_getKey error: $ex');
      _setKeyInfo(null); //очистим вывод
    } finally{
      widget.controller.emitStopped(); //чтобы не подвисло GameState.GetKey
    }
  }

  Future _checkCells() async {
    // проверяем условие остановки
    //1) Осталось пустое поле
    //2) Следующая комбинация равна предыдущей
    //3) самое сложное - повторяемый паттерн
    try {
      //чтобы не подвисало если ранний return или базы нет
      await Future.delayed(Duration(
          microseconds:
          1));

      currentStep++; //увеличиваем шаг в игре
      var cells = widget.controller.cells; //наши ячейки

      List<int> bits = cells.expand((i) => i).toList();

      bool isEmpty = bits.every((x) => x == 0);
      if (isEmpty) {
        //1) идет игра и все ячейки обнулились, остановим
        log("Игра закончилась, все ячейки мертвы.");
        lastStatus = "Игра закончилась, все ячейки мертвы";
        _stopGame(false);

        return;
      }

      if (_detectLoop()) {
        //2,3) алгоритм обнаружения зацикливания
        //logger.d("Обнаружено зацикливание. Игра остановлена. Длина истории ${stateHistory.length}");
        lastStatus = "Обнаружено зацикливание. Игра остановлена.";

        _stopGame(false);

        return;
      }

      BitcoinKey key = BitcoinKey.fromBits(bits);

      bool found = false;
      if (AppDatabase.isOpened) {
        found = await _checkKey(key, false);
      }

      if (found) keysFounded++;

      _setKeyInfo(key, found); //тут setState и отобразится последнее lastStatus

    } catch (ex) {
      logger.e('_checkCells error: $ex');
      _setKeyInfo(null); //очистим вывод
    } finally{

    }
  }

  bool _detectLoop() {

    String currentState =
        widget.controller.cells.map((row) => row.join()).join();

    // Проверяем, есть ли текущее состояние в истории
    int index = stateHistory.indexOf(currentState);
    if (index != -1) {
      // Если состояние найдено, проверяем, повторяется ли последовательность
      int historyLength = stateHistory.length;
      int cycleLength = historyLength - index;

      // Проверяем, совпадают ли предыдущие состояния с текущей последовательностью
      for (int i = 0; i < cycleLength; i++) {
        if (stateHistory[historyLength - cycleLength + i] !=
            stateHistory[index + i]) {
          return false; // Нет зацикливания
        }
      }
      return true; // Обнаружено зацикливание
    }

    stateHistory.add(currentState);

    return false;
  }

  Future<bool> _checkKey(BitcoinKey key, bool manual) async {

    bool found = await _checkAddress(key.ripemd160compressed,
        key, manual); //если тут найден то следующее все равно проверится!
    if (!found) {
      //если не найден ripemd160compressed ищем ripemd160uncompressed
      found = await _checkAddress(key.ripemd160uncompressed, key, manual);
    }

    return found;
  }

  //manual - вручную по кнопке GetKey - тогда игнорируем что уже есть в базе и возвращаем если есть
  Future<bool> _checkAddress(String address, BitcoinKey key, bool manual) async {

    var either = await AppDatabase.repo.isAddressExists(address);

    bool isExists = false;
    if (either.isLeft()) {
      lastStatus = either.asLeft().message;
    } else {
      isExists = either.asRight();

      if (isExists) {
        lastStatus = "$address найден!";

        if (manual) {
          _showSuccess(lastStatus); //но не забудем известить
          return true; //по кнопке GetKey - просто вернем сообщение, не добавляя в базу и не делая пропуск в случае повтора alreadyInBase
        }
        //нужно известить и  остановить если играем
        var eitherInBase = await foundRepo.isKeyExists(key.bigIntKey.toString());

        bool alreadyInBase = false;

        if (eitherInBase.isLeft()) {
          logger.e("_checkAddress isKeyExists error : ${eitherInBase.asLeft().message}"); //упс, просто будем считать что новый
        } else {
          alreadyInBase = eitherInBase.asRight();
        }

        if (alreadyInBase){
          lastStatus = "$address найден, но ключ уже есть в базе! Продолжаем.";
          return false; //продолжим игру
        }

        _pauseGame(); //остановим без очистки поля

        var either = await foundRepo.addKey(key: key.bigIntKey.toString()); //бинго в базу

        String errorSave ='';

        if (either.isLeft()) {
          errorSave = either.asLeft().message;
          logger.e("addKey error : $errorSave");
          lastStatus = "$lastStatus, но сохранить ключ в базу не удалось!";
        }

        _showSuccess(lastStatus);
      } else {
        lastStatus = "$address не найден";
      }
    }

    return isExists;
  }

  void _showSuccess(String message) {
    if (mounted) {
      showScaffoldMessage(
        context: context,
        message: message,
        isError: false,
        successDuration: 5,
      );
    }

  }

  ///Остановить игру и почистить массивы, Если manual - значит не начинать автоматом если задано
  void _stopGame(bool manual) async {

    speedometer
        .stop();
    if (speedometer.elapsedMilliseconds > 0) {

      double speed = (currentStep / speedometer.elapsedMilliseconds) * 1000;
      if (speed > maxSpeed) maxSpeed = speed;
    }
    speedometer.reset();

    widget.controller.interruptTimer(manual); //нужно предотвратить мигание кнопок на панели в момент Стоп-Старт
    stateHistory.clear();
    if (currentStep > maxOfStep) maxOfStep = currentStep;
    currentStep = 0;

    if (!manual && autoStartAfterEnd) {
      widget.controller.randomCells();
      await Future.delayed(Duration(
          microseconds:
              1));
      _startGame(manual);
    }

  }

  ///Приостановить игру без сброса счетчиков
  _pauseGame() {
    speedometer.stop();
    widget.controller.interruptTimer(true); //true - так как нужно известить контрол
  }

  ///начать игру, manual - по кнопке а не автоматом после окончания предыдущей
  _startGame(bool manual) {
    speedometer.start();

    totalGames++;
    widget.controller.startTimer(manual);
  }

  void _randomCells() {
    widget.controller.randomCells();
    widget.controller.emitStopped(); //чтобы не подвисло GameState.Random
    _setKeyInfo(null);
  }

  void _clear() {
    widget.controller.clear(); //emitStopped inside
    _setKeyInfo(null);
  }

  void _showModalBottomSheet(bool found, ) {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.all(8),
          height: MediaQuery.of(context).size.height * 0.40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0.0),
              topRight: Radius.circular(0.0),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Material( //чтобы tileColor срабатывал, иначе его Container перекрывает
                  type: MaterialType.transparency,
                  child: ListTile(
                    selectedTileColor: Colors.redAccent,
                    selectedColor: Colors.white,
                    selected: found,
                    title: found ? Text("Ключ есть в базе!", style: TextStyle(color: Colors.white,),) : Text('Нет в базе'),
                    trailing: Icon(Icons.close),
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                ListTile(
                  dense: true,
                  title: const Text('Private Key Integer'),
                  subtitle: SelectableText('$privateKeyInt'),
                ),
                ListTile(
                  dense: true,
                  title: const Text('Compressed P2PKH'),
                  subtitle: SelectableText('$compressedP2PKH'),
                ),
                ListTile(
                  dense: true,
                  title: const Text('Uncompressed P2PKH'),
                  subtitle: SelectableText('$uncompressedP2PKH'),
                ),
              ],
            ),
          ),
        );
      },
    );

  }

}
