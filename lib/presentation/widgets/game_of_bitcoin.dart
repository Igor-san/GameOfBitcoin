import 'package:flutter/material.dart';
import 'widgets.dart';

class GameOfBitcoin extends StatefulWidget {
  const GameOfBitcoin({
    this.controlsHeight = 70, //без учета статусной строки которая всегда видна
    this.statusHeight = 22, //статусная строка которая всегда видна
    this.hideControls = false, //в мобильной версии скрывать подробности
    super.key,
  });

  final double controlsHeight;
  final double statusHeight;
  final hideControls;

  @override
  State<GameOfBitcoin> createState() => _GameOfBitcoinState();
}

class _GameOfBitcoinState extends State<GameOfBitcoin> {
  GameController? gameController;

  late Color cellsColor = Theme.of(context).colorScheme.error; //Живая ячейка
  late Color gridColor = Theme.of(context).colorScheme.onPrimary;
  late Color backgroundColor = Theme.of(context).colorScheme.secondary;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {

      if (context.size is Size) {
        double cellSizeX = context.size!.width / 16;
        double cellSizeY = (context.size!.height -
                (!widget.hideControls ? widget.controlsHeight+widget.statusHeight : widget.statusHeight)) /
            16;

        setState(() {
          gameController = GameController(
            cellSizeX: cellSizeX,
            cellSizeY: cellSizeY,
            gridSize: Size(
              context.size!.width,
              context.size!.height -
                  (!widget.hideControls ? widget.controlsHeight+widget.statusHeight : widget.statusHeight),
            ),
            controlsSize: Size(
              context.size!.width,
              widget.controlsHeight+widget.statusHeight,
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    gameController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (context, constraints) {
        _onConstraintChange(constraints);

        return Row(
          children: [
            Expanded(
              child: gameController != null
                  ? Column(
                      children: [
                        GameControls(
                          controller: gameController!,
                          controlsHeight: widget.controlsHeight,
                          statusHeight: widget.statusHeight,
                          isMobile: widget.hideControls,
                        ),
                        Expanded(
                          child: GameGrid(
                            controller: gameController!,
                            cellsColor: cellsColor,
                            gridColor: gridColor,
                            backgroundColor: backgroundColor,
                          ),
                        ),
                      ],
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  void _onConstraintChange(BoxConstraints constraints) {
    double cellSizeX = constraints.maxWidth / 16;
    double cellSizeY = (constraints.maxHeight -
            (!widget.hideControls ? widget.controlsHeight+widget.statusHeight : widget.statusHeight)) /
        16;

    gameController?.update(
      cellSizeX: cellSizeX,
      cellSizeY: cellSizeY,
      gridSize: Size(
        constraints.maxWidth,
        constraints.maxHeight -
            (!widget.hideControls ? widget.controlsHeight+widget.statusHeight : widget.statusHeight),
      ),
      controlsSize: Size(
        constraints.maxWidth,
        widget.controlsHeight+widget.statusHeight,
      ),
    );
  }

}
