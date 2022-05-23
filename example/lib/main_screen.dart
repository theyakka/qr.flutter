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
import 'package:url_launcher/url_launcher.dart';

import 'save_file.dart' if (dart.library.html) 'save_file_web.dart';

/// This is the screen that you'll see when the app starts
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _tapCount = 0;
  Timer? _tapTimer;
  final String _defaultInstructions = "Use your camera to scan the QR code for a simple message.";
  String _instructions = "Use your camera to scan the QR code for a simple message.";
  late QrPainter _painter;

  @override
  Widget build(BuildContext context) {
    const codeMessage =
        // ignore: lines_longer_than_80_chars
        'How much wood would a woodchuck chuck if a woodchuck could chuck wood?';

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
              const Color(0xFF0E664B),
              const Color(0xFF008253),
              const Color(0xFF2AB689),
              const Color(0xFF7BD4AB),
            ]),
            shape: QrDataModuleShape.circle,
          ),
          markerStyle: const QrMarkerStyle(
            color: Color(0xFF0E664B),
            shape: QrMarkerShape.roundedRect,
            gap: 2,
          ),
          markerDotStyle: const QrMarkerDotStyle(
            color: Color(0xFF339C7A),
            shape: QrMarkerDotShape.roundedRect,
          ),
          embeddedImageStyle: const QrEmbeddedImageStyle(
            size: Size.square(72),
            drawOverModules: false,
          ),
        );

        _painter = QrPainter(
          data: codeMessage,
          version: QrVersions.auto,
          errorCorrectionLevel: QrErrorCorrectLevel.M,
          embeddedImage: snapshot.data,
          appearance: appearance,
        );

        return GestureDetector(
          onTap: onCodeTapped,
          child: AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(painter: _painter),
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
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 240,
                    maxWidth: 480,
                    minHeight: 240,
                    maxHeight: 480,
                  ),
                  child: qrFutureBuilder,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 20, right: 20, bottom: 100),
                child: Text(_instructions, textAlign: TextAlign.center),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(bottom: 40),
              //   child: Row(
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       TextButton(
              //           onPressed: onImageButtonPressed,
              //           child: const Text("Save as image"))
              //     ],
              //   ),
              // )
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

  void onImageButtonPressed() async {
    final imageData = await _painter.toImageData(
      400,
      background: const Color(0xFFFFFFFF),
      inset: 20,
    );
    final bytes = imageData?.buffer.asUint8List();
    if (bytes != null) {
      saveData(bytes, "image_file.png");
    }
  }

  void onCodeTapped() {
    _tapTimer?.cancel();
    _tapTimer = Timer(const Duration(seconds: 3), () {
      _tapCount = 0;
      setState(() {
        _instructions = _defaultInstructions;
      });
    });
    _tapCount++;
    if (_tapCount == 5) {
      setState(() {
        _instructions = "Keep tapping ...";
      });
    }
    if (_tapCount == 10) {
      setState(() {
        _instructions = _defaultInstructions;
      });
      _tapTimer?.cancel();
      _tapCount = 0;
      launchUrl(Uri.parse("https://www.youtube.com/watch?v=dQw4w9WgXcQ"));
    }
  }
}
