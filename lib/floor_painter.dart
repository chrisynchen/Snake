import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:snake/pair.dart';

enum Shape { CIRCLE, SQUARE, TRIANGLE, HEART }

enum Direction { LEFT, RIGHT, UP, DOWN }

class FloorPainter extends CustomPainter {
  int _cellSize;
  Paint _paint;
  MaterialColor _snakeColor;
  MaterialColor _eatColor;

  List<List<int>> _cells;

  Pair<int, int> _eatPoint;

  Shape shape = Shape.CIRCLE;

  Direction direction = Direction.RIGHT;

  FloorPainter(this._snakeColor, this._eatColor, this._cells, this._cellSize,
      this._eatPoint,
      {this.shape, this.direction}) {
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
          if (shape == Shape.SQUARE) {
            _drawRect(canvas, _paint, i, j);
          } else if (shape == Shape.TRIANGLE) {
            _drawTriangle(canvas, _paint, direction, i, j);
          } else if (shape == Shape.HEART) {
            _drawHeart(canvas, _paint, direction, i, j);
          } else {
            _drawCircle(canvas, _paint, i, j);
          }
        } else {
          _paint.color = Colors.white;
          _drawRect(canvas, _paint, i, j);
        }
      }
    }
  }

  void _drawEatPoint(Canvas canvas) {
    _paint.color = Colors.white;
    _drawRect(canvas, _paint, _eatPoint.left, _eatPoint.right);

    _paint.color = _eatColor;

    if (shape == Shape.SQUARE) {
      _drawRect(canvas, _paint, _eatPoint.left, _eatPoint.right);
    } else if (shape == Shape.TRIANGLE) {
      _drawTriangle(
          canvas, _paint, Direction.UP, _eatPoint.left, _eatPoint.right);
    } else if (shape == Shape.HEART) {
      _drawHeart(
          canvas, _paint, Direction.DOWN, _eatPoint.left, _eatPoint.right);
    } else {
      _drawCircle(canvas, _paint, _eatPoint.left, _eatPoint.right);
    }
  }

  void _drawCircle(Canvas canvas, Paint paint, int i, int j) {
    final _radius = _cellSize / 2;
    canvas.drawCircle(
        Offset(i * _cellSize.toDouble() + _radius,
            j * _cellSize.toDouble() + _radius),
        _radius,
        paint);
  }

  void _drawRect(Canvas canvas, Paint paint, int i, int j) {
    Rect rect = Rect.fromLTRB(
        i * _cellSize.toDouble(),
        j * _cellSize.toDouble(),
        (i + 1) * _cellSize.toDouble(),
        (j + 1) * _cellSize.toDouble());
    canvas.drawRect(rect, _paint);
  }

  void _drawTriangle(
      Canvas canvas, Paint paint, Direction direction, int i, int j) {
    var path = Path();
    if (direction == Direction.UP) {
      path.moveTo(i * _cellSize.toDouble(), (j + 1) * _cellSize.toDouble());
      path.lineTo(
          (i + 1) * _cellSize.toDouble(), (j + 1) * _cellSize.toDouble());
      path.lineTo((i + 0.5) * _cellSize.toDouble(), j * _cellSize.toDouble());
    } else if (direction == Direction.RIGHT) {
      path.moveTo(i * _cellSize.toDouble(), (j + 1) * _cellSize.toDouble());
      path.lineTo(i * _cellSize.toDouble(), j * _cellSize.toDouble());
      path.lineTo(
          (i + 1) * _cellSize.toDouble(), (j + 0.5) * _cellSize.toDouble());
    } else if (direction == Direction.DOWN) {
      path.moveTo(i * _cellSize.toDouble(), j * _cellSize.toDouble());
      path.lineTo((i + 1) * _cellSize.toDouble(), j * _cellSize.toDouble());
      path.lineTo(
          (i + 0.5) * _cellSize.toDouble(), (j + 1) * _cellSize.toDouble());
    } else if (direction == Direction.LEFT) {
      path.moveTo((i + 1) * _cellSize.toDouble(), j * _cellSize.toDouble());
      path.lineTo(
          (i + 1) * _cellSize.toDouble(), (j + 1) * _cellSize.toDouble());
      path.lineTo(i * _cellSize.toDouble(), (j + 0.5) * _cellSize.toDouble());
    }
    path.close();
    canvas.drawPath(path, _paint);
  }

  void _drawHeart(
      Canvas canvas, Paint paint, Direction direction, int i, int j) {
    Path path = Path();
    if (direction == Direction.UP) {
      path.moveTo(
          (i + 0.5) * _cellSize.toDouble(), (j + 0.65) * _cellSize.toDouble());
      path.cubicTo(
          (i + 0.2) * _cellSize.toDouble(),
          (j + 0.9) * _cellSize.toDouble(),
          (i - 0.25) * _cellSize.toDouble(),
          (j + 0.4) * _cellSize.toDouble(),
          (i + 0.5) * _cellSize.toDouble(),
          j * _cellSize.toDouble());
      path.moveTo(
          (i + 0.5) * _cellSize.toDouble(), (j + 0.65) * _cellSize.toDouble());
      path.cubicTo(
          (i + 0.8) * _cellSize.toDouble(),
          (j + 0.9) * _cellSize.toDouble(),
          (i + 1.25) * _cellSize.toDouble(),
          (j + 0.4) * _cellSize.toDouble(),
          (i + 0.5) * _cellSize.toDouble(),
          j * _cellSize.toDouble());
    } else if (direction == Direction.RIGHT) {
      path.moveTo(
          (i + 0.35) * _cellSize.toDouble(), (j + 0.5) * _cellSize.toDouble());
      path.cubicTo(
          (i + 0.1) * _cellSize.toDouble(),
          (j + 0.2) * _cellSize.toDouble(),
          (i + 0.6) * _cellSize.toDouble(),
          (j - 0.25) * _cellSize.toDouble(),
          (i + 1) * _cellSize.toDouble(),
          (j + 0.5) * _cellSize.toDouble());
      path.moveTo(
          (i + 0.35) * _cellSize.toDouble(), (j + 0.5) * _cellSize.toDouble());
      path.cubicTo(
          (i + 0.1) * _cellSize.toDouble(),
          (j + 0.8) * _cellSize.toDouble(),
          (i + 0.6) * _cellSize.toDouble(),
          (j + 1.25) * _cellSize.toDouble(),
          (i + 1) * _cellSize.toDouble(),
          (j + 0.5) * _cellSize.toDouble());
    } else if (direction == Direction.DOWN) {
      path.moveTo(
          (i + 0.5) * _cellSize.toDouble(), (j + 0.35) * _cellSize.toDouble());
      path.cubicTo(
          (i + 0.2) * _cellSize.toDouble(),
          (j + 0.1) * _cellSize.toDouble(),
          (i - 0.25) * _cellSize.toDouble(),
          (j + 0.6) * _cellSize.toDouble(),
          (i + 0.5) * _cellSize.toDouble(),
          (j + 1) * _cellSize.toDouble());
      path.moveTo(
          (i + 0.5) * _cellSize.toDouble(), (j + 0.35) * _cellSize.toDouble());
      path.cubicTo(
          (i + 0.8) * _cellSize.toDouble(),
          (j + 0.1) * _cellSize.toDouble(),
          (i + 1.25) * _cellSize.toDouble(),
          (j + 0.6) * _cellSize.toDouble(),
          (i + 0.5) * _cellSize.toDouble(),
          (j + 1) * _cellSize.toDouble());
    } else if (direction == Direction.LEFT) {
      path.moveTo(
          (i + 0.65) * _cellSize.toDouble(), (j + 0.5) * _cellSize.toDouble());
      path.cubicTo(
          (i + 0.9) * _cellSize.toDouble(),
          (j + 0.2) * _cellSize.toDouble(),
          (i + 0.4) * _cellSize.toDouble(),
          (j - 0.25) * _cellSize.toDouble(),
          i * _cellSize.toDouble(),
          (j + 0.5) * _cellSize.toDouble());
      path.moveTo(
          (i + 0.65) * _cellSize.toDouble(), (j + 0.5) * _cellSize.toDouble());
      path.cubicTo(
          (i + 0.9) * _cellSize.toDouble(),
          (j + 0.8) * _cellSize.toDouble(),
          (i + 0.4) * _cellSize.toDouble(),
          (j + 1.25) * _cellSize.toDouble(),
          i * _cellSize.toDouble(),
          (j + 0.5) * _cellSize.toDouble());
    }
    path.close();
    canvas.drawPath(path, _paint);
  }
}
