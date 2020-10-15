import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'light_paint.dart';
import 'light_paint_rect.dart';
import 'target_focus.dart';
import 'target_position.dart';
import 'util.dart';

enum ShapeLightFocus { Circle, RRect }

class AnimatedFocusLight extends StatefulWidget {
  final List<TargetFocus> targets;
  final Function(TargetFocus) focus;
  final Function(TargetFocus) clickTarget;
  final Function removeFocus;
  final Function() finish;
  final double paddingFocus;
  final Color colorShadow;
  final double opacityShadow;

  final Duration duration;
  final Duration pulseDuration;

  const AnimatedFocusLight({
    Key key,
    this.targets,
    this.focus,
    this.finish,
    this.removeFocus,
    this.clickTarget,
    this.paddingFocus = 10,
    this.colorShadow = Colors.black,
    this.opacityShadow = 0.8,
    this.duration = const Duration(milliseconds: 600),
    this.pulseDuration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  AnimatedFocusLightState createState() => AnimatedFocusLightState();
}

class AnimatedFocusLightState extends State<AnimatedFocusLight>
    with TickerProviderStateMixin {
  AnimationController _controller;
  AnimationController _controllerPulse;
  CurvedAnimation _curvedAnimation;
  Animation _tweenPulse;
  Offset _positioned = Offset(0.0, 0.0);
  TargetPosition _targetPosition;

  double _sizeCircle = 100;
  int _currentFocus = 0;
  bool _finishFocus = false;
  bool _initReverse = false;
  double _progressAnimated = 0;
  TargetFocus _targetFocus;

  bool _goNext = true;

  @override
  void initState() {
    _targetFocus = widget?.targets[_currentFocus];
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.ease,
    );

    _controllerPulse = AnimationController(
      vsync: this,
      duration: widget.pulseDuration,
    );

    _tweenPulse = Tween(begin: 1.0, end: 0.99).animate(
      CurvedAnimation(
        parent: _controllerPulse,
        curve: Curves.ease,
      ),
    );

    _controller.addStatusListener(_listener);
    _controllerPulse.addStatusListener(_listenerPulse);

    WidgetsBinding.instance.addPostFrameCallback((_) => _runFocus());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _targetFocus.enableOverlayTab ? next : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          _progressAnimated = _curvedAnimation.value;
          return AnimatedBuilder(
            animation: _controllerPulse,
            builder: (_, child) {
              if (_finishFocus) {
                _progressAnimated = _tweenPulse.value;
              }
              return Stack(
                children: <Widget>[
                  Container(
                    width: double.maxFinite,
                    height: double.maxFinite,
                    child: CustomPaint(
                      painter: _getPainter(_targetFocus),
                    ),
                  ),
                  Positioned(
                    left: (_targetPosition?.offset?.dx ?? 0) - 10,
                    top: (_targetPosition?.offset?.dy ?? 0) - 10,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: _targetFocus.enableTargetTab ? next : null,
                      child: Container(
                        color: Colors.transparent,
                        width: (_targetPosition?.size?.width ?? 0) + 20,
                        height: (_targetPosition?.size?.height ?? 0) + 20,
                      ),
                    ),
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }

  void next() => _tapHandler();

  void previous() => _tapHandler(goNext: false);

  void _tapHandler({bool goNext = true}) {
    setState(() {
      _goNext = goNext;
      _initReverse = true;
    });
    _controllerPulse.reverse(from: _controllerPulse.value);
    widget?.clickTarget(_targetFocus);
  }

  void _nextFocus() {
    if (_currentFocus >= widget.targets.length - 1) {
      this._finish();
      return;
    }
    _currentFocus++;
    _runFocus();
  }

  void _previousFocus() {
    if (_currentFocus <= 0) {
      this._finish();
      return;
    }
    _currentFocus--;
    _runFocus();
  }

  void _runFocus() {
    if (_currentFocus < 0) return;
    _targetFocus = widget.targets[_currentFocus];
    var targetPosition = createTarget(_targetFocus);
    if (targetPosition == null) {
      this._finish();
      return;
    }

    setState(() {
      _finishFocus = false;
      this._targetPosition = targetPosition;

      _positioned = Offset(
        targetPosition.offset.dx + (targetPosition.size.width / 2),
        targetPosition.offset.dy + (targetPosition.size.height / 2),
      );

      if (targetPosition.size.height > targetPosition.size.width) {
        _sizeCircle = targetPosition.size.height * 0.6 + widget.paddingFocus;
      } else {
        _sizeCircle = targetPosition.size.width * 0.6 + widget.paddingFocus;
      }
    });

    _controller.forward();
  }

  void _finish() {
    setState(() {
      _currentFocus = 0;
    });
    widget.finish();
  }

  @override
  void dispose() {
    _controllerPulse.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _listenerPulse(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _controllerPulse.reverse();
    }

    if (status == AnimationStatus.dismissed) {
      if (_initReverse) {
        setState(() {
          _finishFocus = false;
        });
        _controller.reverse();
      } else if (_finishFocus) {
        _controllerPulse.forward();
      }
    }
  }

  void _listener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _finishFocus = true;
      });
      widget?.focus(_targetFocus);

      _controllerPulse.forward();
    }
    if (status == AnimationStatus.dismissed) {
      setState(() {
        _finishFocus = false;
        _initReverse = false;
      });
      if (_goNext) {
        _nextFocus();
      } else {
        _previousFocus();
      }
    }

    if (status == AnimationStatus.reverse) {
      widget?.removeFocus();
    }
  }

  CustomPainter _getPainter(TargetFocus target) {
    if (target?.shape == ShapeLightFocus.RRect) {
      return LightPaintRect(
        colorShadow: target?.color ?? widget.colorShadow,
        progress: _progressAnimated,
        offset: widget.paddingFocus,
        target: _targetPosition ?? TargetPosition(Size.zero, Offset.zero),
        radius: target?.radius ?? 0,
        opacityShadow: widget.opacityShadow,
      );
    } else {
      return LightPaint(
        _progressAnimated,
        _positioned,
        _sizeCircle,
        colorShadow: target?.color ?? widget.colorShadow,
        opacityShadow: widget.opacityShadow,
      );
    }
  }
}
