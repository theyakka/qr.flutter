/*
 * QR.Flutter
 * Copyright (c) 2019 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';

/// Represents a specific element / part of a QR code. This is used to isolate
/// the different parts so that we can style and modify specific parts
/// independently.
enum QrCodeElement {
  /// The 'stroke' / outer square of the QR code finder pattern element.
  finderPatternOuter,

  /// The inner square of the QR code finder pattern element.
  finderPatternInner,

  /// The individual pixels of the QR code
  codePixel,
}

/// Enumeration representing the three finder pattern (square 'eye') locations.
enum FinderPatternPosition {
  /// The top left position.
  topLeft,

  /// The top right position.
  topRight,

  /// The bottom left position.
  bottomLeft,
}

class ImageRef {
  ImageRef(String filename);
  ImageRef.withBytes(Uint8List bytes) : _bytes = bytes;
  Uint8List _bytes;
  Uint8List get rawBytes => _bytes;
  Future<Uint8List> get bytes async {
    if (bytes == null) {
      return _resolve();
    }
    return _bytes;
  }

  Future<Uint8List> _resolve() async {
    _bytes = await File('').readAsBytes();
    return _bytes;
  }
}

class QrImageStyle {
  Offset offset;
  Size size;
  Color color;
}
