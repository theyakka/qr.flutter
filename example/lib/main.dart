import 'package:flutter/material.dart';

import 'screens/main.screen.dart';

void main() => runApp(new App());

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'QR code demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MainScreen(),
    );
  }
}
