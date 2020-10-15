import 'dart:math';

import 'package:flutter/widgets.dart';

import 'animated_focus_light.dart';
import 'target_focus.dart';
import 'target_position.dart';

TargetPosition createTarget(TargetFocus focus) {
  TargetPosition target;

  if (focus.keyTarget != null) {
    var key = focus.keyTarget;

    try {
      final RenderBox renderBoxRed = key.currentContext.findRenderObject();
      final size = renderBoxRed.size;
      final offset = renderBoxRed.localToGlobal(Offset.zero);

      target = TargetPosition(size, offset);
    } catch (e) {
      throw ("It was not possible to fetch information from the given key ${focus.keyTarget}");
    }
  } else {
    target = focus.targetPosition ?? TargetPosition(Size.zero, Offset.zero);
  }

  if (focus.shape == ShapeLightFocus.Circle) {
    var sideA = pow(target.size.width, 2);
    var sideB = pow(target.size.height, 2);
    var hypotenuse = sqrt(sideA + sideB);

    target.radius = hypotenuse;

    var oldSize = target.size;
    target.size = Size(hypotenuse, hypotenuse);

    var diff = (oldSize - target.size) as Offset;
    target.offset += diff / 2;
  }

  return target;
}
