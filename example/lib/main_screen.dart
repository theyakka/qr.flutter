/*
 * QR.Flutter
 * Copyright (c) 2019 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// This is the screen that you'll see when the app starts
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final message =
        // ignore: lines_longer_than_80_chars
        'Hey this is a QR code. Change this value in the main_screen.dart file.';

    /*final qrFutureBuilder = FutureBuilder<ui.Image>(
      future: _loadOverlayImage(),
      builder: (ctx, snapshot) {
        final size = 280.0;
        if (!snapshot.hasData) {
          return Container(width: size, height: size);
        }
        return CustomPaint(
          size: Size.square(size),
          painter: QrPainter(
            data: message,
            version: QrVersions.auto,
            gapless: true,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              //color: Color(0xff128760),
              borderRadius: 10,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              //color: Color(0xff1a5441),
              borderRadius: 5,
            ),
            // size: 320.0,
            embeddedImage: snapshot.data,
            embeddedImageStyle: QrEmbeddedImageStyle(
              size: Size.square(50),
              safeArea: true,
              safeAreaMultiplier: 1.1,
            ),
          ),
        );
      },
    );*/

    return Material(
      color: Colors.white,
      child: SafeArea(
        top: true,
        bottom: true,
        child: Container(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Container(
                    width: 280,
                    child: QrImageView(
                      data: message,
                      version: QrVersions.auto,
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [Color(0xff289f70), Color(0xff134b38)],
                      ),
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xff128760),
                        borderRadius: 10,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Color(0xff1a5441),
                        borderRadius: 5,
                      ),
                      embeddedImage: AssetImage('assets/images/4.0x/logo_yakka_transparent.png'),
                      embeddedImageStyle: QrEmbeddedImageStyle(
                        size: Size.square(40),
                        color: Colors.white,
                        safeArea: true,
                        safeAreaMultiplier: 1.1,
                        embeddedImageShape: EmbeddedImageShape.square,
                        shapeColor: Color(0xff128760),
                        borderRadius: 10,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40)
                    .copyWith(bottom: 40),
                child: Text(message),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<ui.Image> _loadOverlayImage() async {
    final completer = Completer<ui.Image>();
    final byteData = await rootBundle.load('assets/images/4.0x/logo_yakka.png');
    ui.decodeImageFromList(byteData.buffer.asUint8List(), completer.complete);
    return completer.future;
  }
}
