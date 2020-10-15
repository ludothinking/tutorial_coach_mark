import 'dart:ui';

import 'package:flutter/widgets.dart';

class TargetPosition {
  Size size;
  Offset offset;
  double radius;

  TargetPosition(this.size, this.offset, [this.radius = 0]);

  TargetPosition operator -(TargetPosition other) {
    return TargetPosition(
      size - Offset(other.size.width, other.size.height),
      offset - other.offset,
      radius - other.radius,
    );
  }

  TargetPosition operator +(TargetPosition other) {
    return TargetPosition(
      size + Offset(other.size.width, other.size.height),
      offset + other.offset,
      radius + other.radius,
    );
  }

  TargetPosition operator *(double operand) {
    return TargetPosition(
      size * operand,
      offset * operand,
      radius * operand,
    );
  }
}