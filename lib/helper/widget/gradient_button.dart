import 'package:flutter/material.dart';

class RaisedGradientButton extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final double width;
  final double height;
  final Function onPressed;
  final BorderRadius borderRadius;
  final Color splashColor;

  const RaisedGradientButton({
    Key key,
    @required this.child,
    this.gradient,
    this.width = double.infinity,
    this.height = 50.0,
    this.onPressed,
    this.borderRadius,
    this.splashColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      width: width,
      height: 50.0,
      decoration: BoxDecoration(
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: Colors.grey[500],
            offset: Offset(0.0, 1.5),
            blurRadius: 1.5,
          ),
        ],
        borderRadius: borderRadius,
      ),
      child: Material(
        borderRadius: borderRadius,
        color: Colors.transparent,
        child: InkWell(
            borderRadius: borderRadius,
            splashColor: splashColor,
            highlightColor: splashColor,
            onTap: onPressed,
            child: Center(
              child: child,
            )),
      ),
    );
  }
}
