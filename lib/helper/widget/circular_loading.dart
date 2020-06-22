import 'package:flutter/material.dart';

class CircularLoading extends StatefulWidget {
  final bool enabled;

  const CircularLoading({Key key, this.enabled}) : super(key: key);

  @override
  _CircularLoadingState createState() => _CircularLoadingState();
}

class _CircularLoadingState extends State<CircularLoading>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));

    if (widget.enabled) {
      _controller.forward();
    }

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CircularLoading oldWidget) {
    if (oldWidget.enabled != widget.enabled) {
      if (widget.enabled) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _controller,
      child: Container(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
          height: 58,
          width: 58),
    );
  }
}
