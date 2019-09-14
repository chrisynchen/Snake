import 'package:flutter/material.dart';
import 'package:snake/pair.dart';

enum Shape { Circle, Square, Triangle }

enum Direction { LEFT, RIGHT, UP, DOWN }

class FloorPainter extends CustomPainter {
  int _cellSize;
  Paint _paint;
  MaterialColor _snakeColor;
  MaterialColor _eatColor;

  List<List<int>> _cells;

  Pair<int, int> _eatPoint;

  Shape shape = Shape.Circle;

  FloorPainter(this._snakeColor, this._eatColor, this._cells, this._cellSize,
      this._eatPoint,
      {this.shape}) {
    _paint = Paint()
      ..strokeWidth = 10.0
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawCells(canvas);
    _drawEatPoint(canvas);
  }

  @override
  bool shouldRepaint(FloorPainter oldDelegate) {
    return true;
  }

  void _drawCells(Canvas canvas) {
    for (var i = 0; i < _cells.length; i++) {
      for (var j = 0; j < _cells[0].length; j++) {
        if (_cells[i][j] == 1) {
          _paint.color = _snakeColor;
          if (shape == Shape.Square) {
            Rect rect = Rect.fromLTRB(
                i * _cellSize.toDouble(),
                j * _cellSize.toDouble(),
                (i + 1) * _cellSize.toDouble(),
                (j + 1) * _cellSize.toDouble());
            canvas.drawRect(rect, _paint);
          } else if (shape == Shape.Triangle) {
            var path = Path();
            path.moveTo(
                i * _cellSize.toDouble(), (j + 1) * _cellSize.toDouble());
            path.lineTo(
                (i + 1) * _cellSize.toDouble(), (j + 1) * _cellSize.toDouble());
            path.lineTo(
                (i + 0.5) * _cellSize.toDouble(), j * _cellSize.toDouble());
            path.close();
            canvas.drawPath(path, _paint);
          } else {
            final _radius = _cellSize / 2;
            canvas.drawCircle(
                Offset(i * _cellSize.toDouble() + _radius,
                    j * _cellSize.toDouble() + _radius),
                _radius,
                _paint);
          }
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
    _paint.color = _eatColor;

    final _radius = _cellSize / 2;
    if (shape == Shape.Square) {
      Rect rect = Rect.fromLTRB(
          _eatPoint.left * _cellSize.toDouble(),
          _eatPoint.right * _cellSize.toDouble(),
          (_eatPoint.left + 1) * _cellSize.toDouble(),
          (_eatPoint.right + 1) * _cellSize.toDouble());
      canvas.drawRect(rect, _paint);
    } else if (shape == Shape.Triangle) {
      var path = Path();
      path.moveTo(_eatPoint.left * _cellSize.toDouble(),
          (_eatPoint.right + 1) * _cellSize.toDouble());
      path.lineTo((_eatPoint.left + 1) * _cellSize.toDouble(),
          (_eatPoint.right + 1) * _cellSize.toDouble());
      path.lineTo((_eatPoint.left + 0.5) * _cellSize.toDouble(),
          _eatPoint.right * _cellSize.toDouble());
      path.close();
      canvas.drawPath(path, _paint);
    } else {
      canvas.drawCircle(
          Offset(_eatPoint.left * _cellSize.toDouble() + _radius,
              _eatPoint.right * _cellSize.toDouble() + _radius),
          _radius,
          _paint);
    }
  }
}
