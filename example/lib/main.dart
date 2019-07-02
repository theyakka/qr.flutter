import 'package:flutter/material.dart';

import 'screens/main.screen.dart';

void main() => runApp(App());

/// The example application entry point
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR.Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
