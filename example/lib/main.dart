import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/main.screen.dart';

void main() => runApp(App());

/// The example application entry point
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: const Color(0xff8d42f5),
    ));

    final themeData = ThemeData.light().copyWith(
      primaryColor: const Color(0xff8d42f5),
      accentColor: const Color(0xff8d42f5),
      buttonTheme: ButtonThemeData(
        highlightColor: const Color(0x118d42f5),
        splashColor: const Color(0x338d42f5),
        textTheme: ButtonTextTheme.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: const Color(0xff8d42f5)),
        ),
      ),
    );
    return MaterialApp(
      title: 'QR.Flutter',
      theme: themeData,
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
