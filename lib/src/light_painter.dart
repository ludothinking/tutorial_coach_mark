import 'package:flutter/material.dart';

import 'target_position.dart';

class LightPainter extends CustomPainter {
  final TargetPosition target;
  final Color colorShadow;
  final double opacityShadow;
  final double padding;
  final double radius;

  late Paint _paintFocus;

  LightPainter({
    required this.target,
    this.colorShadow = Colors.black,
    this.opacityShadow = 0.8,
    this.padding = 10,
    this.radius = 10,
  }) : assert(opacityShadow >= 0 && opacityShadow <= 1) {
    _paintFocus = Paint()
      ..color = Colors.transparent
      ..blendMode = BlendMode.clear;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawColor(colorShadow.withOpacity(opacityShadow), BlendMode.dstATop);
    double x = target.offset.dx - padding / 2;
    double y = target.offset.dy - padding / 2;

    double w = target.size.width + padding;
    double h = target.size.height + padding;

    RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      Radius.circular(radius),
    );

    canvas.drawRRect(rrect, _paintFocus);
    canvas.restore();
  }

  @override
  bool shouldRepaint(LightPainter oldDelegate) {
    return true;
  }
}
