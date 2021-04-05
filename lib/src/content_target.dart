import 'package:flutter/widgets.dart';

import 'custom_target_position.dart';

enum AlignContent { top, bottom, left, right, custom }

class ContentTarget {
  ContentTarget({
    this.align = AlignContent.bottom,
    required this.child,
    this.customPosition,
  }) : assert(!(align == AlignContent.custom && customPosition == null));

  final AlignContent align;
  final CustomTargetPosition? customPosition;
  final Widget child;

  @override
  String toString() {
    return 'ContentTarget{align: $align, child: $child}';
  }
}
