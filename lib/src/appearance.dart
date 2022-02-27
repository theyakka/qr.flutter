import 'package:flutter/widgets.dart';
import 'package:qr_flutter/src/colors.dart';

/// Enumeration representing the finder pattern outer marker frame.
enum QrMarkerShape {
  /// Use square marker frame.
  square,

  /// Use a square (with rounded corners) marker frame.
  roundedRect,

  /// Use circular marker frame.
  circle,
}

/// Enumeration representing the finder pattern inner marker dot.
enum QrMarkerDotShape {
  /// Use square marker dot.
  square,

  /// Use a square (with rounded corners) marker dot.
  roundedRect,

  /// Use circular marker dot.
  circle,
}

/// Enumeration representing the shape of Data modules inside QR.
enum QrDataModuleShape {
  /// Use diamond dots.
  diamond,

  /// Use square dots.
  square,

  /// Use squares with rounded corners
  roundedRect,

  /// Use circular dots.
  circle,
}

/// Defines appearance of the QR code.
class QrAppearance {
  /// Define a new set of appearance attributes.
  const QrAppearance({
    this.gapSize = 0,
    this.markerStyle = const QrMarkerStyle(),
    this.markerDotStyle,
    this.moduleStyle = const QrDataModuleStyle(),
    this.embeddedImageStyle,
  });

  /// The amount of space between the data modules. Defaults to zero (gapless).
  final int gapSize;

  /// The styling options for the marker frame. If no value is defined for the
  /// `markerDotStyle` property, then the dot will inherit from the style
  /// options defined here.
  final QrMarkerStyle markerStyle;

  /// The styling options for the dot (inside part) of the marker frame.
  final QrMarkerDotStyle? markerDotStyle;

  /// The styling options for the individual data modules (squares) of the
  /// QR code.
  final QrDataModuleStyle moduleStyle;

  /// The styling options for the embedded image (if any).
  final QrEmbeddedImageStyle? embeddedImageStyle;
}

/// Styling options for the marker frame.
class QrMarkerStyle {
  /// Create a new set of styling options for QR Eye.
  const QrMarkerStyle({
    this.shape = QrMarkerShape.square,
    this.color = const Color(0xFF000000),
  });

  /// Eye shape.
  final QrMarkerShape? shape;

  /// Color to tint the eye.
  final Color color;

  @override
  int get hashCode => shape.hashCode ^ color.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is QrMarkerStyle) {
      return shape == other.shape && color == other.color;
    }
    return false;
  }
}

/// Styling options for the marker frame.
class QrMarkerDotStyle {
  /// Create a new set of styling options for the marker dot.
  const QrMarkerDotStyle({
    this.shape = QrMarkerDotShape.square,
    this.color = const Color(0xFF000000),
  });

  /// Eye shape.
  final QrMarkerDotShape shape;

  /// Color to tint the eye.
  final Color color;
}

/// Styling options for data module.
class QrDataModuleStyle {
  /// Create a new set of styling options for data modules.
  const QrDataModuleStyle({
    this.shape,
    this.colors,
  });

  /// Eye shape.
  final QrDataModuleShape? shape;

  /// Color to tint the data modules.
  final QrColors? colors;
}

/// Styling options for any embedded image overlay
class QrEmbeddedImageStyle {
  /// Create a new set of styling options.
  const QrEmbeddedImageStyle({
    this.size,
    this.color,
    this.drawOverModules = false,
  });

  /// The size of the image. If one dimension is zero then the other dimension
  /// will be used to scale the zero dimension based on the original image
  /// size.
  final Size? size;

  /// Color to tint the image.
  final Color? color;

  /// Whether any data module "pixels" should be drawn within the image
  /// boundary.
  final bool drawOverModules;

  /// Check to see if the style object has a non-null, non-zero size.
  bool get hasDefinedSize => size != null && size!.longestSide > 0;
}
