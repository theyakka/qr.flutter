/*
 * QR.Flutter
 * Copyright (c) 2019 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:qr/qr.dart';

typedef QrError = void Function(dynamic error);

class QrPainter extends CustomPainter {
  QrPainter({
    @required String data,
    @required this.version,
    this.errorCorrectionLevel = QrErrorCorrectLevel.L,
    this.color = const Color(0xff000000),
    this.emptyColor,
    this.onError,
    this.gapless = false,
  }) : _qr = QrCode(version, errorCorrectionLevel) {
    _init(data);
  }

  final int version; // the qr code version
  final int errorCorrectionLevel; // the qr code error correction level
  final Color color; // the color of the dark squares
  final Color emptyColor; // the other color
  final QrError onError;
  final bool gapless;

  final QrCode _qr; // our qr code data
  final Paint _paint = Paint()..style = PaintingStyle.fill;
  bool _hasError = false;

  void _init(String data) {
    _paint.color = color;
    // configure and make the QR code data
    try {
      _qr.addData(data);
      _qr.make();
    } catch (ex) {
      if (onError != null) {
        _hasError = true;
        this.onError(ex);
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_hasError) {
      return;
    }
    if (size.shortestSide == 0) {
      print(
          "[QR] WARN: width or height is zero. You should set a 'size' value or nest this painter in a Widget that defines a non-zero size");
    }

    if (emptyColor != null) {
      canvas.drawColor(emptyColor, BlendMode.color);
    }

    final double squareSize = size.shortestSide / _qr.moduleCount.toDouble();
    final int pxAdjustValue = gapless ? 1 : 0;
    for (int x = 0; x < _qr.moduleCount; x++) {
      for (int y = 0; y < _qr.moduleCount; y++) {
        if (_qr.isDark(y, x)) {
          final Rect squareRect = Rect.fromLTWH(x * squareSize, y * squareSize,
              squareSize + pxAdjustValue, squareSize + pxAdjustValue);
          canvas.drawRect(squareRect, _paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is QrPainter) {
      return color != oldDelegate.color ||
          errorCorrectionLevel != oldDelegate.errorCorrectionLevel ||
          version != oldDelegate.version ||
          _qr != oldDelegate._qr;
    }
    return false;
  }

  ui.Picture toPicture(double size) {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    paint(canvas, Size(size, size));
    return recorder.endRecording();
  }

  Future<ByteData> toImageData(double size,
      {ui.ImageByteFormat format = ui.ImageByteFormat.png}) async {
    final ui.Image uiImage = await
        toPicture(size).toImage(size.toInt(), size.toInt());
    return await uiImage.toByteData(format: format);
  }
}
