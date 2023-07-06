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
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  double qrSize = 200;
  double logoSize = 40;
  @override
  Widget build(BuildContext context) {
    const message =
        // ignore: lines_longer_than_80_chars
        'Hey this is a QR code. Change this value in the main_screen.dart file.';

    final qrFutureBuilder = FutureBuilder<ui.Image>(
      future: _loadOverlayImage(),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(width: qrSize, height: qrSize);
        }
        return CustomPaint(
          size: Size.square(qrSize),
          painter: QrPainter(
            data: message,
            gapless: true,
            version: QrVersions.auto,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.squareRounded,
              radius: 15,
              color: Colors.green,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.squareRounded,
              color: Colors.black,
              radius: 3,
            ),
            // size: 320.0,
            embeddedImage: snapshot.data,
            embeddedImageStyle: QrEmbeddedImageStyle(
              size: Size.square(logoSize),
            ),
          ),
        );
      },
    );

    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: SizedBox(
                  width: qrSize,
                  child: qrFutureBuilder,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: qrSize,
                  child: QrImageView(
                    data: message,
                    gapless: true,
                    version: QrVersions.auto,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.squareRounded,
                      radius: 15,
                      color: Colors.green,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.squareRounded,
                      color: Colors.black,
                      radius: 3,
                    ),
                    // size: 320.0,
                    embeddedImage:
                        ExactAssetImage('assets/images/4.0x/logo_yakka.png'),
                    embeddedImageStyle: QrEmbeddedImageStyle(
                      size: Size.square(logoSize),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40)
                  .copyWith(bottom: 40),
              child: const Text(message),
            ),
          ],
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
