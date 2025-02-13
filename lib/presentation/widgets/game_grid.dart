import 'package:flutter/material.dart';
import 'game_controller.dart';

class GameGrid extends StatefulWidget {
  const GameGrid({
    required this.controller,
    required this.cellsColor,
    required this.gridColor,
    required this.backgroundColor,
    super.key,
  });

  final GameController controller;
  final Color cellsColor;
  final Color gridColor;
  final Color backgroundColor;

  @override
  State<GameGrid> createState() => _GameGridState();
}

class _GameGridState extends State<GameGrid> with TickerProviderStateMixin {
  @override
  void initState() {

    widget.controller.onCellsRepaint = _onCellsRepaint;
    super.initState();
  }

  Future _onCellsRepaint() async {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (details) =>
          _onTap(details.localPosition, widget.controller.gridSize),
      onPanUpdate: (details) =>
          _onTapUpdate(details.localPosition, widget.controller.gridSize),
      child: CustomPaint(
        painter: GameGridPainter(
          r: widget.controller.rowsCount,
          c: widget.controller.columnsCount,
          cells: widget.controller.cells,
          cellsColor: widget.cellsColor,
          gridColor: widget.gridColor,
          backgroundColor: widget.backgroundColor,
        ),
        child: const SizedBox(
          height: double.infinity,
          width: double.infinity,
        ),
      ),
    );
  }

  void _onTap(Offset tap, Size size) {
    try {
      final c = tap.dx ~/ widget.controller.cellSizeX;
      final r = tap.dy ~/ widget.controller.cellSizeY;

      int inverse = widget.controller.cells[r][c]==1? 0 : 1; //Но при перемещении этого бы не хотелось, только при одиночных кликах
      setState(() {
        widget.controller.cells[r][c] = inverse;
      });
    } catch (_) {}
  }

  void _onTapUpdate(Offset tap, Size size) {
    try {
//при перемещениях не инвертируем ячейки а все ставим в 1
      final c = tap.dx ~/ widget.controller.cellSizeX;
      final r = tap.dy ~/ widget.controller.cellSizeY;
      setState(() {
        widget.controller.cells[r][c] = 1;
      });
    } catch (_) {}
  }

}

class GameGridPainter extends CustomPainter {
  GameGridPainter({
    required this.r,
    required this.c,
    required this.cells,
    required this.cellsColor,
    required this.gridColor,
    required this.backgroundColor,
    Key? key,
  }) : super();

  final int r;
  final int c;
  final List<List<int>> cells;
  final Color cellsColor;
  final Color gridColor;
  final Color backgroundColor;

  //final _textPainter = TextPainter(textDirection: TextDirection.ltr);

  @override
  void paint(Canvas canvas, Size size) {
    final lh = size.height / r;
    final lw = size.width / c;

    _drawBackground(size, canvas);
    _drawGrid(size, lh, lw, canvas);
    _drawSquares(lh, lw, r, c, canvas);
  }
/* если захочется номера ячеек отобразить
  void _drawLetter(Canvas canvas, String letter, Offset offset, double width) {
    _textPainter.text = TextSpan(text: letter);
    _textPainter.layout(
      minWidth: 0,
      maxWidth: width,
    );
    _textPainter.paint(canvas,offset); // Offset(0, -_textPainter.height));
  }
*/
  void _drawBackground(Size size, Canvas canvas) {
    final height = size.height;
    final width = size.width;
    final paint = Paint()..color = backgroundColor;

    canvas.drawRect(Rect.fromLTRB(0, 0, width, height), paint);
  }

  void _drawGrid(Size size, double lh, double lw, Canvas canvas) {
    final height = size.height;
    final width = size.width;
    const stroke = 1;
    final paint = Paint()
      ..color = gridColor
      ..strokeCap = StrokeCap.round;

    for (double h = 0; h < height + stroke; h += lh) {
      Path linePath = Path();
      linePath.addRect(Rect.fromLTRB(
          0, h.toDouble() - stroke / 2, width, h.toDouble() + stroke / 2));
      canvas.drawPath(linePath, paint);
    }

    for (double w = 0; w < width + stroke; w += lw) {
      Path linePath = Path();
      linePath.addRect(Rect.fromLTRB(
          w.toDouble() - stroke / 2, 0, w.toDouble() + stroke / 2, height));
      canvas.drawPath(linePath, paint);
    }
  }

  void _drawSquares(
      double lh,
      double lw,
      int r,
      int c,
      Canvas canvas,
      ) {
    const padding = 1;
    final paint = Paint()
      ..color = cellsColor
      ..strokeCap = StrokeCap.round;

    final secondPaint = Paint()
      ..color = cellsColor.withValues(alpha: 0.2)
      ..strokeCap = StrokeCap.round;

    Path linePath = Path();
    Path secondPath = Path();

    for (int y = 0; y < r; y++) {
      for (int x = 0; x < c; x++) {
        final offset = Offset(x * lw + lw / 2, y * lh + lh / 2);
        //_drawLetter(canvas, getIndexFromRowColumn(y,x).toString(), offset, lw);
        if (cells[y][x] == 1) {
          secondPath.addRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(
                  center: offset.translate(1, 1),
                  width: lw - padding,
                  height: lh - padding,
                ),
                Radius.circular(padding.toDouble())),
          );
          linePath.addRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(
                  center: offset,
                  width: lw - padding,
                  height: lh - padding,
                ),
                Radius.circular(padding.toDouble())),
          );
        }
      }
    }

    canvas.drawPath(secondPath, secondPaint);
    canvas.drawPath(linePath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
