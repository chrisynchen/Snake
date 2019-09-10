import 'package:flutter/material.dart';

class CirclePainter extends CustomPainter {
  final double _radius;
  Paint _paint;

  CirclePainter(this._radius, MaterialColor color) {
    _paint = Paint()
      ..color = color
      ..strokeWidth = 10.0
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(0.0, 0.0), _radius, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
