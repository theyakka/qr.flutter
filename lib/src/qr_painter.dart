/*
 * QR.Flutter
 * Copyright (c) 2018 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */
import 'package:flutter/widgets.dart';
import 'package:qr/qr.dart';

typedef void QrError(dynamic error);

class QrPainter extends CustomPainter {
  QrPainter(String data, this.color, this.version, this.errorCorrectionLevel,
      {this.onError, this.gapless})
      : this._qr = new QrCode(version, errorCorrectionLevel) {
    _p.color = this.color;
    // configure and make the QR code data
    try {
      _qr.addData(data);
      _qr.make();
    } catch (ex) {
      if (this.onError != null) {
        _hasError = true;
        this.onError(ex);
      }
    }
  }

  final QrCode _qr; // our qr code data
  final _p = new Paint()..style = PaintingStyle.fill;
  bool _hasError = false;

  // properties
  final int version; // the qr code version
  final int errorCorrectionLevel; // the qr code error correction level
  final Color color; // the color of the dark squares
  final QrError onError;
  final bool gapless;

  @override
  void paint(Canvas canvas, Size size) {
    if (_hasError) return;
    if (size.shortestSide == 0) {
      print(
          "[QR] WARN: width or height is zero. You should set a 'size' value or nest this painter in a Widget that defines a non-zero size");
    }
    final squareSize = size.shortestSide / _qr.moduleCount;

    final extra = gapless ? 1 : 0;

    for (int x = 0; x < _qr.moduleCount; x++) {
      for (int y = 0; y < _qr.moduleCount; y++) {
        if (_qr.isDark(y, x)) {
          final squareRect = new Rect.fromLTWH(x * squareSize, y * squareSize,
              squareSize + extra, squareSize + extra);
          canvas.drawRect(squareRect, _p);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is QrPainter) {
      return this.color != oldDelegate.color ||
          this.errorCorrectionLevel != oldDelegate.errorCorrectionLevel ||
          this.version != oldDelegate.version ||
          this._qr != oldDelegate._qr;
    }
    return false;
  }
}
