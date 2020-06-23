import 'package:flutter/material.dart';

import 'widget/gradient_button.dart';

const double _padding = 24;
final _controlBackgroundColor = Colors.white.withAlpha(150);

Widget buildCheckBox(
    String title, bool initialValue, Function(bool) onChanged) {
  return Material(
    elevation: 4,
    color: _controlBackgroundColor,
    borderRadius: BorderRadius.circular(_padding),
    child: InkWell(
      borderRadius: BorderRadius.circular(_padding),
      onTap: () {
        onChanged(!initialValue);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularCheckBox(
              value: initialValue,
              onChanged: onChanged,
            ),
            Container(
              width: 12,
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            )
          ],
        ),
      ),
    ),
  );
}

class Label extends StatelessWidget {
  final String text;

  const Label({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
    );
  }
}

class CircularCheckBox extends StatelessWidget {
  final bool value;
  final Function(bool) onChanged;

  const CircularCheckBox({Key key, this.value, this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        height: _padding,
        width: _padding,
        decoration: BoxDecoration(
          color: value ? Color(0xFFF39F86) : null,
          shape: BoxShape.circle,
          border: value ? null : Border.all(color: Colors.black45, width: 1),
        ),
        child: value
            ? Icon(
                Icons.check,
                size: 18,
                color: Colors.white,
              )
            : Container(),
      ),
    );
  }
}

class HomeTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final FocusNode focusNode;

  const HomeTextField({Key key, this.controller, this.hintText, this.focusNode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      color: Colors.white,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: _padding, vertical: 6),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.left,
          decoration: InputDecoration(
              disabledBorder: InputBorder.none,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              )),
        ),
      ),
    );
  }
}

class HomeButton extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;
  final Function onPressed;
  final List<Color> gradientColors;

  const HomeButton(
      {Key key,
      this.width,
      this.height,
      this.onPressed,
      this.child,
      this.gradientColors = const <Color>[
        Color(0xFFF9D976),
        Color(0xFFF39F86),
      ]})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedGradientButton(
        height: height,
        width: width,
        splashColor: Color(0xFFF9D976).withOpacity(0.5),
        child: child,
        gradient: LinearGradient(
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(50),
        onPressed: onPressed);
  }
}
