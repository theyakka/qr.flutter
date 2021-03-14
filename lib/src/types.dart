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

  /// Use circular eye frame.
  circle,

  /// Use custom frame
  custom
}

/// Enumeration representing the shape of Data modules inside QR.
enum QrDataModuleShape {
  /// Use square dots.
  square,

  /// Use circular dots.
  circle,
}

/// A holder for customizing the eye of a QRCode
class QrEyeShapeStyle {
  /// Set the border radius of the eye to give a shape
  final BorderRadius eyeShape;

  /// Set the border radius of the eyeball to give it a custom shape
  final BorderRadius eyeballShape;

  /// if to use a dashed eye
  ///
  /// This field is ignored for the eyeball
  final bool dashedBorder;

  /// Create A new Shape style
  const QrEyeShapeStyle(
      {this.dashedBorder = false,
      this.eyeShape = BorderRadius.zero,
      this.eyeballShape = BorderRadius.zero});

  /// Sets the style to none
  static const none = QrEyeShapeStyle(
      eyeShape: BorderRadius.zero, eyeballShape: BorderRadius.zero);
}

/// Customize the shape of the finders on a QRCode
class QrEyeShapeStyles {
  /// Customize the bottom left eye
  final QrEyeShapeStyle bottomLeft;

  /// Customize the top right eye
  final QrEyeShapeStyle topRight;

  /// Customize the top left eye
  final QrEyeShapeStyle topLeft;

  /// Sets the style to none
  static const none = QrEyeShapeStyles.all(QrEyeShapeStyle.none);

  const QrEyeShapeStyles._(this.bottomLeft, this.topLeft, this.topRight)
      : assert(bottomLeft != null && topRight != null && topLeft != null);

  const QrEyeShapeStyles.only({
    QrEyeShapeStyle bottomLeft = QrEyeShapeStyle.none,
    QrEyeShapeStyle topRight = QrEyeShapeStyle.none,
    QrEyeShapeStyle topLeft = QrEyeShapeStyle.none,
  }) : this._(bottomLeft, topLeft, topRight);

  /// Call this to create a uniform style
  const QrEyeShapeStyles.all(QrEyeShapeStyle style)
      : this._(style, style, style);
}

/// Styling options for finder pattern eye.
class QrEyeStyle {
  /// Create a new set of styling options for QR Eye.
  const QrEyeStyle({
    this.eyeShape,
    this.color,
    this.shape = QrEyeShapeStyles.none,
  });

  /// Eye shape.
  final QrEyeShape? eyeShape;

  /// Color to tint the eye.
  final Color? color;

  /// The custom shape of the eye
  final QrEyeShapeStyles shape;

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
class QrDataModuleStyle {
  /// Create a new set of styling options for data modules.
  const QrDataModuleStyle({
    this.dataModuleShape,
    this.color,
  });

  /// Eye shape.
  final QrDataModuleShape? dataModuleShape;

  /// Color to tint the data modules.
  final Color? color;

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
class QrEmbeddedImageStyle {
  /// Create a new set of styling options.
  QrEmbeddedImageStyle({
    this.size,
    this.color,
  });

  /// The size of the image. If one dimension is zero then the other dimension
  /// will be used to scale the zero dimension based on the original image
  /// size.
  Size? size;

  /// Color to tint the image.
  Color? color;

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
