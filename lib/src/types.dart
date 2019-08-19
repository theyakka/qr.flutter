/*
 * QR.Flutter
 * Copyright (c) 2019 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */

import 'dart:ui';

import 'package:flutter/widgets.dart';

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

/// Styling options for any embedded image overlay
class QrEmbeddedImageStyle {
  /// Create a new set of styling options.
  QrEmbeddedImageStyle({
    this.size,
    this.color,
  });

  /// The size of the image. If one dimension is zero then the other dimension
  /// will be used to scale the zero dimension based on the original image
  /// size.
  Size size;

  /// Color to tint the image.
  Color color;

  /// Check to see if the style object has a non-null, non-zero size.
  bool get hasDefinedSize => size != null && size.longestSide > 0;

  @override
  int get hashCode => size.hashCode ^ color.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is QrEmbeddedImageStyle) {
      return size == other.size && color == other.color;
    }
    return false;
  }
}
