import 'package:flutter/material.dart';
import 'content_widget.dart';

/// The main screen of the application. This is the screen you see when the
/// app starts.
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
