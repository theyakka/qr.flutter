/*
 * QR.Flutter
 * Copyright (c) 2022 the QR.Flutter authors.
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

    final qrFutureBuilder = FutureBuilder<ui.Image>(
      future: _loadOverlayImage(),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        final appearance = QrAppearance(
          gapSize: 1,
          moduleStyle: QrDataModuleStyle(
            colors: QrColors.random([
              Color(0xFF999999),
              Color(0xFFFF0066),
              Color(0xFF00FFAE),
              Color(0xFF0000FF),
            ]),
            shape: QrDataModuleShape.circle,
          ),
          markerStyle: QrMarkerStyle(
            color: Color(0xFF666666),
            shape: QrMarkerShape.roundedRect,
          ),
          markerDotStyle: QrMarkerDotStyle(
            color: Color(0xFF888888),
            shape: QrMarkerDotShape.roundedRect,
          ),
        );

        return AspectRatio(
          aspectRatio: 1,
          child: CustomPaint(
            painter: QrPainter(
              data: message,
              version: QrVersions.auto,
              errorCorrectionLevel: QrErrorCorrectLevel.L,
              embeddedImage: snapshot.data,
              embeddedImageStyle: QrEmbeddedImageStyle(
                size: Size.square(60),
              ),
              appearance: appearance,
            ),
          ),
        );
      },
    );

    return Material(
      color: Colors.white,
      child: SafeArea(
        top: true,
        bottom: true,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: qrFutureBuilder,
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
