import 'package:flutter/material.dart';

/// Using [ShadowDegree] with values [ShadowDegree.dark] or [ShadowDegree.light]
/// to get a darker version of the used color.
/// [duration] in milliseconds
///
class AnimatedButton extends StatefulWidget {
  final GestureTapCallback onPressed;
  final Widget child;
  final bool enabled;
  final Color color;
  final double height;
  final double width;
  final ShadowDegree shadowDegree;
  final int duration;
  final BoxShape shape;
  final void Function(bool) onToggle;
  final bool tapToggleEnabled;
  final bool initiallyToggled;

  const AnimatedButton({super.key, required this.onToggle, required this.onPressed, required this.child, this.enabled = true, this.color = Colors.blue, this.height = 64, this.shadowDegree = ShadowDegree.light, this.width = 200, this.duration = 70, this.shape = BoxShape.rectangle, this.tapToggleEnabled = true, this.initiallyToggled = false}) : assert(child != null);

  @override
  AnimatedButtonState createState() => AnimatedButtonState();
}

class AnimatedButtonState extends State<AnimatedButton> {
  static const Curve _curve = Curves.easeIn;
  static const double _shadowHeight = 4;
  double _position = 4;
  bool toggled = false;

  @override
  void initState() {
    super.initState();
    // Initialize the state based on the initiallyToggled parameter only once
    toggled = widget.initiallyToggled;
    _position = widget.initiallyToggled ? 0 : 4;

    setState(() {
      toggled;
      _position;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double height = widget.height - _shadowHeight;

    return GestureDetector(
      onTap: widget.enabled ? _pressed : null,
      onTapCancel: widget.enabled ? _unPressed : null,
      child: SizedBox(
        width: 100,
        height: height + _shadowHeight,
        child: Stack(
          children: <Widget>[
            Positioned(
              bottom: 0,
              child: Container(
                height: height,
                width: 100,
                decoration: BoxDecoration(
                    color: widget.enabled ? darken(widget.color, widget.shadowDegree) : darken(Colors.grey, widget.shadowDegree),
                    borderRadius: widget.shape != BoxShape.circle
                        ? const BorderRadius.all(
                            Radius.circular(16),
                          )
                        : null,
                    shape: widget.shape),
              ),
            ),
            AnimatedPositioned(
              curve: _curve,
              duration: Duration(milliseconds: widget.duration),
              bottom: _position,
              child: Container(
                height: height,
                width: 100,
                decoration: BoxDecoration(
                    color: widget.enabled ? const Color(0xFFF9F6EE) : Colors.grey,
                    borderRadius: widget.shape != BoxShape.circle
                        ? const BorderRadius.all(
                            Radius.circular(16),
                          )
                        : null,
                    shape: widget.shape),
                child: Center(
                  child: widget.child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pressed() {
    if (toggled == false) {
      toggleButton();
    } else if (widget.tapToggleEnabled) {
      untoggleButton();
      widget.onToggle.call(toggled);
    }
  }

  void toggleButton() {
    setState(() {
      _position = 0;
      toggled = true;
    });
    widget.onToggle.call(toggled);
  }

  void untoggleButton() {
    setState(() {
      _position = 4;
      toggled = false;
    });
  }

  void _unPressed() {
    setState(() {
      _position = 4;
    });
    widget.onPressed;
  }
}

Color darken(Color color, ShadowDegree degree) {
  double amount = degree == ShadowDegree.dark ? 0.3 : 0.12;
  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

enum ShadowDegree { light, dark }
