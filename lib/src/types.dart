/*
 * QR.Flutter
 * Copyright (c) 2019 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */

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

class QrImageStyle {
  QrImageStyle({
    this.offset = Offset(0, 0),
    this.size = Size(50, 50),
    this.color,
  });
  Offset offset;
  Size size;
  Color color;
}
