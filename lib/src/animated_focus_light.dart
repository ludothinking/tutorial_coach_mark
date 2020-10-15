import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
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

  final Function(TargetFocus) onFocus;
  final Function(TargetFocus) onClickTarget;
  final Function() onRemoveFocus;
  final Function() onFinish;

  final Duration focusDuration;
  final Duration pulseDuration;

  const AnimatedFocusLight({
    Key key,
    this.targets,
    this.paddingFocus = 10,
    this.colorShadow = Colors.black,
    this.opacityShadow = 0.8,
    this.onFocus,
    this.onFinish,
    this.onRemoveFocus,
    this.onClickTarget,
    this.focusDuration = const Duration(milliseconds: 2000),
    this.pulseDuration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  AnimatedFocusLightState createState() => AnimatedFocusLightState();
}

class AnimatedFocusLightState extends State<AnimatedFocusLight>
    with TickerProviderStateMixin {
  TargetPosition _currentTarget;
  TargetPosition _oldTarget;

  int _currentFocus = 0;
  TargetFocus _targetFocus;

  double _pulseBegin = 1;
  double _pulseEnd = 0;
  double _pulseOffset;

  @override
  void initState() {
    _targetFocus = widget?.targets[_currentFocus];

    _runFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _targetFocus.enableOverlayTab ? next : null,
      child: TweenAnimationBuilder(
        curve: Curves.ease,
        duration: widget.focusDuration,
        tween: Tween<TargetPosition>(begin: _oldTarget, end: _currentTarget),
        builder: (_, position, __) {
          return Stack(
            children: <Widget>[
              LayoutBuilder(
                builder: (_, c) => TweenAnimationBuilder(
                  duration: widget.pulseDuration,
                  curve: Curves.ease,
                  tween: Tween<double>(begin: _pulseBegin, end: _pulseEnd),
                  onEnd: () {
                    setState(() {
                      _pulseBegin = 1 - _pulseBegin;
                      _pulseEnd = 1 - _pulseEnd;

                      _pulseOffset = 16;
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
                            (_pulseOffset ?? min(c.maxHeight, c.maxWidth)) *
                                percent,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: (_currentTarget?.offset?.dx ?? 0) - 10,
                top: (_currentTarget?.offset?.dy ?? 0) - 10,
                child: InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: _targetFocus.enableTargetTab ? next : null,
                  child: Container(
                    color: Colors.transparent,
                    width: (_currentTarget?.size?.width ?? 0) + 20,
                    height: (_currentTarget?.size?.height ?? 0) + 20,
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  void next() {
    widget.onClickTarget?.call(_targetFocus);

    _nextFocus();
  }

  void previous() {
    //not implemented yet!
  }

  void _nextFocus() {
    if (_currentFocus >= widget.targets.length - 1) {
      this._finish();
      return;
    }

    _currentFocus++;

    _runFocus();

    widget?.onFocus(_targetFocus);
  }

  void _runFocus() {
    if (_currentFocus < 0) {
      return;
    }

    _targetFocus = widget.targets[_currentFocus];

    var targetPosition = createTarget(_targetFocus);

    setState(() {
      _oldTarget = _currentTarget ?? targetPosition;
      _currentTarget = targetPosition;

      if (_targetFocus.shape == ShapeLightFocus.Circle) {
        var hypotenuse = sqrt(pow(targetPosition.size.width, 2) +
            pow(targetPosition.size.height, 2));

        targetPosition.radius = hypotenuse;

        var oldSize = targetPosition.size;
        targetPosition.size = Size(hypotenuse, hypotenuse);

        var diff = (oldSize - targetPosition.size) as Offset;
        targetPosition.offset += diff / 2;
      }
    });
  }

  void _finish() {
    setState(() {
      _currentFocus = 0;
    });

    widget.onFinish();
  }
}
