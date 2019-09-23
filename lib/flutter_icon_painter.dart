import 'dart:math' as math;

import 'package:flutter/material.dart';

class FlutterIconPainter extends CustomPainter {
  final Paint _paintLight = Paint()
    ..strokeWidth = 10.0
    ..isAntiAlias = true
    ..style = PaintingStyle.fill
    ..color = Color(0xff7bcdf4);

  final Paint _paint = Paint()
    ..strokeWidth = 10.0
    ..isAntiAlias = true
    ..style = PaintingStyle.fill
    ..color = Color(0xff135C9C);

  final int _iconSize;

  FlutterIconPainter(this._iconSize);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(0, size.height / 2);
    canvas.rotate(-math.pi / 4);

    final dx = size.width / 4;
    final dy = size.height / 4;
    final _radius = _iconSize / 4;
    canvas.drawCircle(
        Offset(
            dx + 0.00625 * _iconSize + _radius, dy + 0.5 * _iconSize + _radius),
        _radius,
        _paint);

    canvas.drawRRect(
        RRect.fromLTRBAndCorners(dx, dy, dx + _iconSize.toDouble() / 2,
            dy + _iconSize.toDouble() * 0.75,
            topLeft: Radius.circular(_iconSize / 5)),
        _paint);

    canvas.drawRRect(
        RRect.fromLTRBAndCorners(dx, dy, dx + _iconSize.toDouble() * 0.75,
            dy + _iconSize.toDouble() / 2,
            topLeft: Radius.circular(_iconSize / 5)),
        _paintLight);
    canvas.drawCircle(
        Offset(
            dx + 0.5 * _iconSize + _radius, dy + 0.00625 * _iconSize + _radius),
        _radius,
        _paintLight);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
