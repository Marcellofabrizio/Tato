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

  const AnimatedButton(
      {super.key,
      required this.onPressed,
      required this.child,
      this.enabled = true,
      this.color = Colors.blue,
      this.height = 64,
      this.shadowDegree = ShadowDegree.light,
      this.width = 200,
      this.duration = 70,
      this.shape = BoxShape.rectangle})
      : assert(child != null);

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  static const Curve _curve = Curves.easeIn;
  static const double _shadowHeight = 4;
  double _position = 4;
  bool _toggled = false;

  @override
  Widget build(BuildContext context) {
    final double _height = widget.height - _shadowHeight;

    return GestureDetector(
      // width here is required for centering the button in parent
      // onTapDown: widget.enabled ? _pressed : null,
      // onTapUp: widget.enabled ? _unPressedOnTapUp : null,
      onTap: widget.enabled ? _pressed : null,
      onTapCancel: widget.enabled ? _unPressed : null,
      child: SizedBox(
        width: widget.width,
        height: _height + _shadowHeight,
        child: Stack(
          children: <Widget>[
            // background shadow serves as drop shadow
            // width is necessary for bottom shadow
            Positioned(
              bottom: 0,
              child: Container(
                height: _height,
                width: widget.width,
                decoration: BoxDecoration(
                    color: widget.enabled
                        ? darken(widget.color, widget.shadowDegree)
                        : darken(Colors.grey, widget.shadowDegree),
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
                height: _height,
                width: widget.width,
                decoration: BoxDecoration(
                    color: widget.enabled ? widget.color : Colors.grey,
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

  void _toggle(_) {
    setState(() {
      _toggled = !_toggled;
    });

    if (_toggled) {
      _pressed;
    } else {
      _unPressed;
    }
  }

  void _pressed() {
    if (_toggled == false) {
      setState(() {
        _position = 0;
        _toggled = true;
      });
    } else {
      setState(() {
        _position = 4;
        _toggled = false;
      });
      widget.onPressed();
    }
  }

  void _unPressedOnTapUp(_) => _unPressed();

  void _unPressed() {
    setState(() {
      _position = 4;
    });
    widget.onPressed();
  }
}

Color darken(Color color, ShadowDegree degree) {
  double amount = degree == ShadowDegree.dark ? 0.3 : 0.12;
  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

enum ShadowDegree { light, dark }
