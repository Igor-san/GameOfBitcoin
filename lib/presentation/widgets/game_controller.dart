import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:game_of_bitcoin/common/common.dart';
import 'package:game_of_bitcoin/locator_service.dart';
import 'package:game_of_bitcoin/bloc/bloc.dart';

class GameController {
  Random rng = Random();

  GameController({
    required this.cellSizeX,
    required this.cellSizeY,
    required this.gridSize,
    required this.controlsSize,
  }) {
    rowsCount = 16;
    columnsCount = 16;
    randomCells();
    backBuffer = emptyCells();
  }

  double cellSizeX;
  double cellSizeY;
  Size gridSize;
  Size controlsSize;

  late List<List<int>> cells;
  late List<List<int>> backBuffer;

  late int columnsCount;
  late int rowsCount;

  FutureCallback? whenCompute; //вызывается после очередной установки ячеек
  FutureCallback? onCellsRepaint; //для перерисовки ячеек GameGrid
  FutureCallback?
      onControlRepaint; //для перерисовки панели управления и информации
  bool isWorking = false; //флаг работы

  void update({
    double? cellSizeX,
    double? cellSizeY,
    Size? gridSize,
    Size? controlsSize,
  }) {
    bool needStart = false;

    if (isWorking) {
      interruptTimer(true);
      needStart = true;
    }

    if (cellSizeX != null) {
      this.cellSizeX = cellSizeX;
    }
    if (cellSizeY != null) {
      this.cellSizeY = cellSizeY;
    }
    if (gridSize != null) {
      this.gridSize = gridSize;
    }
    if (controlsSize != null) {
      this.controlsSize = controlsSize;
    }
    if (needStart) {
      startTimer(true);
    }
  }

  startSafeTimer() async {
    await whenCompute
        ?.call(); //тут мы начальную комбинацию должны проверить, так как в doWhile ее уже не будет
    callListeners();
    //так как вызвали whenCompute то вдруг там и остановили
    if (!isWorking) {
      return;
    }

    Future.doWhile(() async {
      computeCells();
      await whenCompute?.call();
      callListeners();
      return isWorking;
    });
  }

  void startTimer(bool manual) async {
    bool isEmpty = cells.expand((i) => i).every((x) => x == 0);
    if (isEmpty) {
      callListeners();
      isWorking = false;
      return;
    }

    if (isWorking) {
      interruptTimer(manual);
      await Future.delayed(Duration(milliseconds: 100));
    }

    isWorking = true;
    if (manual) {
      //если вручную - известим контрол, если автоматом значит пусть идет все как есть
      sl<ControllerBloc>().add(ControllerEvent(gameState: GameState.Playing));
    }

    startSafeTimer();
    callListeners();
  }

  void clear() {
    interruptTimer(true);
    cells = emptyCells();
    callListeners();
  }

  void interruptTimer(bool manual) {
    //нужно предотвратить мигание кнопок на панели в момент Стоп-Старт
    isWorking = false;
    if (manual) {
      //так как автоматом начнем буквально сразу чтобы кнопки не мигали, а если сами нажалм - тогда проэмиттим
      emitStopped();
    }
    callListeners();
  }

  ///Установим состояние Stopped
  void emitStopped() {
    sl<ControllerBloc>().add(ControllerEvent(gameState: GameState.Stopped));
  }

  @override
  void dispose() {
    isWorking = false;
  }

  void computeCells() {
    //А это сама Игра в Жизнь https://github.com/GangemiLorenzo/Game-Of-Life
    cells.asMap().entries.forEach((r) {
      r.value.asMap().entries.forEach((c) {
        int n = 0;
        int i = r.key;
        int j = c.key;
        backBuffer[i][j] = 0;

        if (i - 1 > 0) {
          if (j - 1 > 0) {
            n += cells[i - 1][j - 1];
          }
          n += cells[i - 1][j];
          if (j + 1 < cells[i].length) {
            n += cells[i - 1][j + 1];
          }
        }
        if (i + 1 < cells.length) {
          if (j - 1 > 0) {
            n += cells[i + 1][j - 1];
          }
          n += cells[i + 1][j];
          if (j + 1 < cells[i].length) {
            n += cells[i + 1][j + 1];
          }
        }

        if (j - 1 > 0) {
          n += cells[i][j - 1];
        }
        if (j + 1 < cells[i].length) {
          n += cells[i][j + 1];
        }

        if (cells[i][j] == 1 && (n == 2 || n == 3)) {
          backBuffer[i][j] = cells[i][j];
        } else if (cells[i][j] == 1) {
          backBuffer[i][j] = 0;
        }
        if (cells[i][j] == 0 && n == 3) {
          backBuffer[i][j] = 1 - cells[i][j];
        }
      });
    });

    final supp = cells;
    cells = backBuffer;
    backBuffer = supp;
  }

  List<List<int>> emptyCells() => List<List<int>>.generate(
        rowsCount,
        (_) => [
          ...List<int>.filled(columnsCount, 0),
        ],
      );

  void randomCells() {
    cells = List<List<int>>.generate(
      rowsCount,
      (_) => List<int>.generate(columnsCount, (_) => rng.nextInt(2)),
    );
    callListeners();
  }

  Future callListeners() async {
    onCellsRepaint?.call();
    onControlRepaint?.call();
  }
}
