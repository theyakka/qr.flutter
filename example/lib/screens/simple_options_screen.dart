import 'package:flutter/material.dart';

class SimpleOptionsScreen extends StatefulWidget {
  /// Create an instance of the options screen.
  SimpleOptionsScreen({Key key}) : super(key: key);
  @override
  SimpleOptionsScreenState createState() => SimpleOptionsScreenState();
}

class SimpleOptionsScreenState extends State<SimpleOptionsScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 220),
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        print('dismissed');
      }
    });
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _animationController.forward();
    return FadeTransition(
      opacity: _animation,
      child: _contentWidget(),
    );
  }

  Widget _contentWidget() {
    return Container(color: const Color(0xff8d42f5));
  }

  void toggle({VoidCallback callback}) {
    if (_animationController.status == AnimationStatus.completed) {
      _animationController.reverse().whenComplete(callback);
    } else {
      _animationController.forward().whenComplete(callback);
    }
  }
}
