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

import 'errors.dart';
import 'qr_versions.dart';

/// The error callback type that will be thrown if there is a code generation
/// issue.
typedef QrError = void Function(Exception error);

/// A [CustomPainter] object that you can use to paint a QR code.
class QrPainter extends CustomPainter {
  /// Create a new QRPainter with passed options (or defaults).
  QrPainter({
    @required String data,
    @required this.version,
    this.errorCorrectionLevel = QrErrorCorrectLevel.L,
    this.color = const Color(0xff000000),
    this.emptyColor,
    this.onError,
    this.gapless = false,
  }) : assert(QrVersions.isSupportedVersion(version)) {
    _init(data);
  }

  /// The QR code version.
  final int version; // the qr code version

  // This is the version (after calculating) that we will use if the user has
  // requested the 'auto' version.
  int _calcVersion;

  /// The error correction level of the QR code.
  final int errorCorrectionLevel; // the qr code error correction level
  /// The color of the squares.
  final Color color; // the color of the dark squares
  /// The color of the non-squares (background).
  final Color emptyColor; // the other color
  /// A callback that is executed when there is an error painting the QR code.
  final QrError onError;

  /// If set to false, the painter will leave a 1px gap between each of the
  /// squares.
  final bool gapless;

  QrCode _qr; // our qr code data
  final Paint _paint = Paint()..style = PaintingStyle.fill;
  bool _hasError = false;

  void _init(String data) {
    if (!QrVersions.isSupportedVersion(version)) {
      _hasError = true;
      this.onError(QrUnsupportedVersionException(version));
      return;
    }
    _paint.color = color;
    // configure and make the QR code data
    try {
      if (version != QrVersions.auto) {
        _calcVersion = version;
        _qr = QrCode(_calcVersion, errorCorrectionLevel);
        _qr.addData(data);
      } else {
        _qr = QrCode.fromData(
          data: data,
          errorCorrectLevel: errorCorrectionLevel,
        );
        _calcVersion = _qr.typeNumber;
      }
      _qr.make();
    } on Exception catch (ex) {
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
      print("[QR] WARN: width or height is zero. You should set a 'size' value "
          "or nest this painter in a Widget that defines a non-zero size");
    }

    if (emptyColor != null) {
      canvas.drawColor(emptyColor, BlendMode.color);
    }

    final squareSize = size.shortestSide / _qr.moduleCount.toDouble();
    final pxAdjustValue = gapless ? 1 : 0;
    for (var x = 0; x < _qr.moduleCount; x++) {
      for (var y = 0; y < _qr.moduleCount; y++) {
        if (_qr.isDark(y, x)) {
          final squareRect = Rect.fromLTWH(x * squareSize, y * squareSize,
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
          _calcVersion != oldDelegate._calcVersion ||
          _qr != oldDelegate._qr;
    }
    return false;
  }

  /// Returns a [ui.Picture] object containing the QR code data.
  ui.Picture toPicture(double size) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    paint(canvas, Size(size, size));
    return recorder.endRecording();
  }

  /// Returns the raw QR code byte data.
  Future<ByteData> toImageData(double size,
      {ui.ImageByteFormat format = ui.ImageByteFormat.png}) async {
    final uiImage = await toPicture(size).toImage(size.toInt(), size.toInt());
    return await uiImage.toByteData(format: format);
  }
}
