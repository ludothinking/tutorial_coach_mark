import 'package:flutter/material.dart';

import 'animated_focus_light.dart';
import 'content_target.dart';
import 'target_focus.dart';
import 'target_position.dart';
import 'util.dart';

class TutorialCoachMarkWidget extends StatefulWidget {
  final List<TargetFocus> targets;
  final Color colorShadow;
  final double opacityShadow;
  final double paddingFocus;
  final AlignmentGeometry alignSkip;
  final String textSkip;
  final TextStyle textStyleSkip;
  final bool hideSkip;
  final bool enableTicker;

  final Duration pulseDuration;
  final Duration focusDuration;
  final double maxPulsePadding;

  final Function(TargetFocus)? clickTarget;
  final Function()? finish;
  final Function()? clickSkip;
  final Function()? onTick;

  const TutorialCoachMarkWidget({
    Key? key,
    required this.targets,
    this.paddingFocus = 10,
    this.alignSkip = Alignment.bottomRight,
    this.textSkip = "SKIP",
    this.colorShadow = Colors.black,
    this.opacityShadow = 0.8,
    this.textStyleSkip = const TextStyle(color: Colors.white),
    this.hideSkip = false,
    this.enableTicker = false,
    this.clickTarget,
    this.finish,
    this.clickSkip,
    this.onTick,
    this.pulseDuration = const Duration(milliseconds: 500),
    this.focusDuration = const Duration(milliseconds: 500),
    this.maxPulsePadding = 8,
  }) : super(key: key);

  @override
  TutorialCoachMarkWidgetState createState() => TutorialCoachMarkWidgetState();
}

class TutorialCoachMarkWidgetState extends State<TutorialCoachMarkWidget> {
  final GlobalKey<AnimatedFocusLightState> _focusLightKey = GlobalKey();
  bool _showContent = false;
  TargetFocus? _currentTarget;

  bool _refocus = false;
  bool _isFadeIn = false;

  Widget? _content;

  @override
  void initState() {
    super.initState();

    _content = _buildContents();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: <Widget>[
          AnimatedFocusLight(
            key: _focusLightKey,
            targets: widget.targets,
            onFinish: widget.finish,
            paddingFocus: widget.paddingFocus,
            colorShadow: widget.colorShadow,
            opacityShadow: widget.opacityShadow,
            onClickTarget: widget.clickTarget,
            enableTicker: widget.enableTicker,
            focusDuration: widget.pulseDuration,
            pulseDuration: widget.focusDuration,
            maxPulsePadding: widget.maxPulsePadding,
            onTick: () {
              setState(() {
                _content = _buildContents();
              });

              widget.onTick?.call();
            },
            onFocus: (target) {
              setState(() {
                _currentTarget = target;
                _showContent = true;

                _refocus = true;
                _isFadeIn = false;
              });
            },
          ),
          IgnorePointer(
            ignoring: true,
            child: TweenAnimationBuilder<double>(
              duration: widget.focusDuration,
              tween: Tween<double>(
                begin: !_refocus
                    ? 1
                    : _isFadeIn
                        ? 0
                        : 1,
                end: !_refocus
                    ? 1
                    : _isFadeIn
                        ? 1
                        : 0,
              ),
              onEnd: () {
                setState(() {
                  if (_refocus && !_isFadeIn) {
                    _isFadeIn = true;

                    _content = _buildContents();
                  } else {
                    _refocus = false;
                  }
                });
              },
              builder: (_, opacity, child) => Opacity(
                opacity: opacity,
                child: child,
              ),
              child: _content,
            ),
          ),
          _buildSkip()
        ],
      ),
    );
  }

  Widget _buildContents() {
    if (_currentTarget == null) {
      return SizedBox.shrink();
    }

    List<Widget> children = [];

    TargetPosition target = createTarget(_currentTarget!);

    var positioned = Offset(
      target.offset.dx + target.size.width / 2,
      target.offset.dy + target.size.height / 2,
    );

    double haloWidth;
    double haloHeight;

    if (_currentTarget!.shape == ShapeLightFocus.Circle) {
      haloWidth = target.size.width > target.size.height
          ? target.size.width
          : target.size.height;
      haloHeight = haloWidth;
    } else {
      haloWidth = target.size.width;
      haloHeight = target.size.height;
    }

    haloWidth = haloWidth * 0.6 + widget.paddingFocus;
    haloHeight = haloHeight * 0.6 + widget.paddingFocus;

    double weight = 0.0;
    double? top;
    double? bottom;
    double? left;

    children = _currentTarget!.contents.map<Widget>((i) {
      switch (i.align) {
        case AlignContent.bottom:
          {
            weight = MediaQuery.of(context).size.width;
            left = 0;
            top = positioned.dy + haloHeight;
            bottom = null;
          }
          break;
        case AlignContent.top:
          {
            weight = MediaQuery.of(context).size.width;
            left = 0;
            top = null;
            bottom = haloHeight +
                (MediaQuery.of(context).size.height - positioned.dy);
          }
          break;
        case AlignContent.left:
          {
            weight = positioned.dx - haloWidth;
            left = 0;
            top = positioned.dy - target.size.height / 2 - haloHeight;
            bottom = null;
          }
          break;
        case AlignContent.right:
          {
            left = positioned.dx + haloWidth;
            top = positioned.dy - target.size.height / 2 - haloHeight;
            bottom = null;
            weight = MediaQuery.of(context).size.width - left!;
          }
          break;
        case AlignContent.custom:
          {
            left = i.customPosition!.left;
            top = i.customPosition!.top;
            bottom = i.customPosition!.bottom;
            weight = MediaQuery.of(context).size.width;
          }
          break;
      }

      return Positioned(
        top: top,
        bottom: bottom,
        left: left,
        child: Container(
          width: weight,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: i.child,
          ),
        ),
      );
    }).toList();

    return Stack(
      children: children,
    );
  }

  Widget _buildSkip() {
    if (widget.hideSkip) {
      return SizedBox.shrink();
    }
    return Align(
      alignment: widget.alignSkip,
      child: SafeArea(
        child: AnimatedOpacity(
          opacity: _showContent ? 1 : 0,
          duration: Duration(milliseconds: 300),
          child: InkWell(
            onTap: widget.clickSkip,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                widget.textSkip,
                style: widget.textStyleSkip,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void next() => _focusLightKey.currentState?.next();

  void previous() => _focusLightKey.currentState?.previous();
}
