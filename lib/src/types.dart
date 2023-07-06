/*
 * QR.Flutter
 * Copyright (c) 2019 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */

import 'package:flutter/widgets.dart';

/// Represents a specific element / part of a QR code. This is used to isolate
/// the different parts so that we can style and modify specific parts
/// independently.
enum QrCodeElement {
  /// The 'stroke' / outer square of the QR code finder pattern element.
  finderPatternOuter,

  /// The inner/in-between square of the QR code finder pattern element.
  finderPatternInner,

  /// The "dot" square of the QR code finder pattern element.
  finderPatternDot,

  /// The individual pixels of the QR code
  codePixel,

  /// The "empty" pixels of the QR code
  codePixelEmpty,
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

/// Enumeration representing the finder pattern eye's shape.
enum QrEyeShape {
  /// Use square eye frame.
  square,

  /// Use square rounded eye frame.
  squareRounded,

  /// Use circular eye frame.
  circle,
}

/// Enumeration representing the shape of Data modules inside QR.
enum QrDataModuleShape {
  /// Use square dots.
  square,

  /// Use square rounded eye frame.
  squareRounded,

  /// Use circular dots.
  circle,
}

/// Styling options for finder pattern eye.
@immutable
class QrEyeStyle {
  /// Create a new set of styling options for QR Eye.
  const QrEyeStyle({this.eyeShape, this.color, this.radius = 0});

  /// Eye shape.
  final QrEyeShape? eyeShape;

  /// Color to tint the eye.
  final Color? color;

  /// radius
  final double radius;

  @override
  int get hashCode => eyeShape.hashCode ^ color.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is QrEyeStyle) {
      return eyeShape == other.eyeShape && color == other.color;
    }
    return false;
  }
}

/// Styling options for data module.
@immutable
class QrDataModuleStyle {
  /// Create a new set of styling options for data modules.
  const QrDataModuleStyle({
    this.dataModuleShape,
    this.color,
    this.radius = 0,
  });

  /// Eye shape.
  final QrDataModuleShape? dataModuleShape;

  /// Color to tint the data modules.
  final Color? color;

  /// radius
  final double radius;

  @override
  int get hashCode => dataModuleShape.hashCode ^ color.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is QrDataModuleStyle) {
      return dataModuleShape == other.dataModuleShape && color == other.color;
    }
    return false;
  }
}

/// Styling options for any embedded image overlay
@immutable
class QrEmbeddedImageStyle {
  /// Create a new set of styling options.
  const QrEmbeddedImageStyle({
    this.size,
    this.color,
  });

  /// The size of the image. If one dimension is zero then the other dimension
  /// will be used to scale the zero dimension based on the original image
  /// size.
  final Size? size;

  /// Color to tint the image.
  final Color? color;

  /// Check to see if the style object has a non-null, non-zero size.
  bool get hasDefinedSize => size != null && size!.longestSide > 0;

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
