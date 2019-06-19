import 'package:flutter/material.dart';
import 'content_widget.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ContentWidget(),
      resizeToAvoidBottomPadding: true,
    );
  }
}
