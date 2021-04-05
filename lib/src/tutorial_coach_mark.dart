import 'package:flutter/material.dart';

import 'target_focus.dart';
import 'tutorial_coach_mark_widget.dart';

class TutorialCoachMark {
  final BuildContext? context;
  final OverlayState? overlay;

  final List<TargetFocus> targets;
  final Function(TargetFocus)? onClickTarget;
  final Function()? onFinish;
  final double paddingFocus;
  final Function()? onClickSkip;
  final AlignmentGeometry alignSkip;
  final String textSkip;
  final TextStyle textStyleSkip;
  final bool hideSkip;
  final Color colorShadow;
  final double opacityShadow;
  final GlobalKey<TutorialCoachMarkWidgetState> _widgetKey = GlobalKey();

  final bool enableTicker;
  final Function()? onTick;

  final Duration pulseDuration;
  final Duration focusDuration;
  final double maxPulsePadding;

  OverlayEntry? _overlayEntry;

  TutorialCoachMark({
    this.context,
    this.overlay,
    required this.targets,
    this.colorShadow = Colors.black,
    this.onClickTarget,
    this.onFinish,
    this.paddingFocus = 10,
    this.onClickSkip,
    this.alignSkip = Alignment.bottomRight,
    this.textSkip = "SKIP",
    this.textStyleSkip = const TextStyle(color: Colors.white),
    this.hideSkip = false,
    this.opacityShadow = 0.8,
    this.enableTicker = false,
    this.onTick,
    this.pulseDuration = const Duration(milliseconds: 500),
    this.focusDuration = const Duration(milliseconds: 500),
    this.maxPulsePadding = 8,
  })  : assert(context != null || overlay != null,
            "Either [context] or [overlay] must not be null");

  OverlayEntry _buildOverlay() {
    return OverlayEntry(builder: (context) {
      return TutorialCoachMarkWidget(
        key: _widgetKey,
        targets: targets,
        clickTarget: onClickTarget,
        paddingFocus: paddingFocus,
        clickSkip: skip,
        alignSkip: alignSkip,
        textSkip: textSkip,
        textStyleSkip: textStyleSkip,
        hideSkip: hideSkip,
        colorShadow: colorShadow,
        opacityShadow: opacityShadow,
        finish: finish,
        enableTicker: enableTicker,
        onTick: onTick,
        focusDuration: pulseDuration,
        pulseDuration: focusDuration,
        maxPulsePadding: maxPulsePadding,
      );
    });
  }

  void show() {
    if (_overlayEntry == null) {
      _overlayEntry = _buildOverlay();
      _getOverlay().insert(_overlayEntry!);
    }
  }

  void finish() {
    if (onFinish != null) onFinish!();
    _removeOverlay();
  }

  void skip() {
    if (onClickSkip != null) onClickSkip!();
    _removeOverlay();
  }

  void next() => _widgetKey.currentState?.next();

  void previous() => _widgetKey.currentState?.previous();

  OverlayState _getOverlay() {
    if (overlay != null) {
      return overlay!;
    } else {
      return Overlay.of(context!)!;
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
