import 'package:flutter/widgets.dart';

import 'target_focus.dart';
import 'target_position.dart';

TargetPosition createTarget(TargetFocus target) {
  if (target.keyTarget != null) {
    var key = target.keyTarget;

    try {
      final RenderBox renderBoxRed = key.currentContext.findRenderObject();
      final size = renderBoxRed.size;
      final offset = renderBoxRed.localToGlobal(Offset.zero);

      return TargetPosition(size, offset);
    } catch (e) {
      throw ("It was not possible to fetch information from the given key ${target.keyTarget}");
    }
  } else {
    return target.targetPosition;
  }
}
