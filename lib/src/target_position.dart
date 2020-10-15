import 'dart:ui';

import 'package:flutter/widgets.dart';

class TargetPosition {
  Size size;
  Offset offset;

  TargetPosition(this.size, this.offset);

  TargetPosition operator -(TargetPosition other) {
    return TargetPosition(
      size - Offset(other.size.width, other.size.height),
      offset - other.offset,
    );
  }

  TargetPosition operator +(TargetPosition other) {
    return TargetPosition(
      size + Offset(other.size.width, other.size.height),
      offset + other.offset,
    );
  }

  TargetPosition operator *(double operand) {
    return TargetPosition(
      size * operand,
      offset * operand,
    );
  }
}