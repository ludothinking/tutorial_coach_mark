import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'light_painter.dart';
import 'target_focus.dart';
import 'target_position.dart';
import 'util.dart';

enum ShapeLightFocus { Circle, RRect }

class AnimatedFocusLight extends StatefulWidget {
  final List<TargetFocus> targets;
  final double paddingFocus;
  final Color colorShadow;
  final double opacityShadow;

  final double maxPulsePadding;

  final bool enableTicker;

  final Function(TargetFocus)? onFocus;
  final Function(TargetFocus)? onClickTarget;
  final Function()? onFinish;
  final Function()? onTick;

  final Duration focusDuration;
  final Duration pulseDuration;

  const AnimatedFocusLight({
    Key? key,
    required this.targets,
    this.paddingFocus = 10,
    this.colorShadow = Colors.black,
    this.opacityShadow = 0.8,
    this.maxPulsePadding = 8,
    this.enableTicker = false,
    this.onFocus,
    this.onFinish,
    this.onClickTarget,
    this.onTick,
    this.focusDuration = const Duration(milliseconds: 500),
    this.pulseDuration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  AnimatedFocusLightState createState() => AnimatedFocusLightState();
}

class AnimatedFocusLightState extends State<AnimatedFocusLight> {
  TargetPosition? _currentTarget;
  TargetPosition? _oldTarget;

  int _currentFocus = 0;
  TargetFocus? _targetFocus;

  double _pulseBegin = 1;
  double _pulseEnd = 0;
  double? _pulsePadding;

  Ticker? _ticker;

  @override
  void initState() {
    super.initState();

    _targetFocus = widget.targets[_currentFocus];

    if (widget.enableTicker) {
      _ticker = Ticker(_tick);
      _ticker!.start();
    }

    _runFocus();
  }

  @override
  void dispose() {
    super.dispose();

    _ticker?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _targetFocus!.enableOverlayTab ? next : null,
      child: TweenAnimationBuilder<TargetPosition>(
        curve: Curves.ease,
        duration: widget.focusDuration,
        tween: Tween<TargetPosition>(begin: _oldTarget, end: _currentTarget),
        builder: (_, position, __) {
          return Stack(
            children: <Widget>[
              LayoutBuilder(
                builder: (_, c) => TweenAnimationBuilder<double>(
                  duration: widget.pulseDuration,
                  curve: Curves.ease,
                  tween: Tween<double>(begin: _pulseBegin, end: _pulseEnd),
                  onEnd: () {
                    setState(() {
                      _pulseBegin = 1 - _pulseBegin;
                      _pulseEnd = 1 - _pulseEnd;

                      _pulsePadding = widget.maxPulsePadding;
                    });
                  },
                  builder: (_, percent, __) => Container(
                    width: double.maxFinite,
                    height: double.maxFinite,
                    child: CustomPaint(
                      painter: LightPainter(
                        colorShadow: _targetFocus?.color ?? widget.colorShadow,
                        radius: position.radius,
                        target: position,
                        opacityShadow: widget.opacityShadow,
                        padding: widget.paddingFocus +
                            (_pulsePadding ?? min(c.maxHeight, c.maxWidth)) *
                                percent,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: (_currentTarget?.offset.dx ?? 0) - 10,
                top: (_currentTarget?.offset.dy ?? 0) - 10,
                child: InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: _targetFocus!.enableTargetTab ? next : null,
                  child: Container(
                    color: Colors.transparent,
                    width: (_currentTarget?.size.width ?? 0) + 20,
                    height: (_currentTarget?.size.height ?? 0) + 20,
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  void _tick(Duration _) {
    if (_targetFocus == null || _currentTarget == null) {
      return;
    }

    setState(() {
      _currentTarget = createTarget(_targetFocus!);
    });

    widget.onTick?.call();
  }

  void _runFocus() {
    if (_currentFocus < 0) {
      return;
    }

    _targetFocus = widget.targets[_currentFocus];

    setState(() {
      var temp = _currentTarget;
      _currentTarget = createTarget(_targetFocus!);

      if (_oldTarget == null) {
        _oldTarget = temp ?? _currentTarget;
      }
    });

    WidgetsBinding.instance!.addPostFrameCallback(
      (_) => widget.onFocus?.call(_targetFocus!),
    );
  }

  void _nextFocus() {
    if (_currentFocus >= widget.targets.length - 1) {
      this._finish();
      return;
    }

    _currentFocus++;

    _runFocus();
  }

  void _finish() {
    setState(() {
      _currentFocus = 0;
    });

    widget.onFinish!();
  }

  void next() {
    widget.onClickTarget?.call(_targetFocus!);

    _nextFocus();
  }

  void previous() {
    //not implemented yet!
  }
}
