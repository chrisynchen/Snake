import 'package:flutter/material.dart';
import 'package:snake/pair.dart';

class FloorPainter extends CustomPainter {
  int _cellSize;
  Paint _paint;
  double _radius;
  MaterialColor _color;

  List<List<int>> cells;

  Pair<int, int> _eatPoint;

  FloorPainter(
      this._radius, this._color, this.cells, this._cellSize, this._eatPoint) {
    _paint = Paint()
      ..strokeWidth = 10.0
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    print("paint");
    _drawCells(canvas);
    _drawEatPoint(canvas);
  }

  @override
  bool shouldRepaint(FloorPainter oldDelegate) {
    return true;
  }

  void _drawCells(Canvas canvas) {
    for (var i = 0; i < cells.length; i++) {
      for (var j = 0; j < cells[0].length; j++) {
        if (cells[i][j] == 1) {
          _paint.color = _color;
          canvas.drawCircle(
              Offset(i * _cellSize.toDouble() + _radius,
                  j * _cellSize.toDouble() + _radius),
              _radius,
              _paint);
        } else {
          _paint.color = Colors.white;
          Rect rect = Rect.fromLTRB(
              i * _cellSize.toDouble(),
              j * _cellSize.toDouble(),
              (i + 1) * _cellSize.toDouble(),
              (j + 1) * _cellSize.toDouble());
          canvas.drawRect(rect, _paint);
        }
      }
    }
  }

  void _drawEatPoint(Canvas canvas) {
    _paint.color = Colors.red;
    canvas.drawCircle(
        Offset(_eatPoint.left * _cellSize.toDouble() + _radius,
            _eatPoint.right * _cellSize.toDouble() + _radius),
        _radius,
        _paint);
  }
}