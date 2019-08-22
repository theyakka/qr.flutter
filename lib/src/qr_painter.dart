/*
 * QR.Flutter
 * Copyright (c) 2019 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:qr/qr.dart';

import 'errors.dart';
import 'paint_cache.dart';
import 'qr_versions.dart';
import 'types.dart';
import 'validator.dart';

// ignore_for_file: deprecated_member_use_from_same_package

const _finderPatternLimit = 7;

// default color for the qr code pixels
const _qrDefaultColor = Color(0xff111111);

/// A [CustomPainter] object that you can use to paint a QR code.
class QrPainter extends CustomPainter {
  /// Create a new QRPainter with passed options (or defaults).
  QrPainter({
    @required String data,
    @required this.version,
    this.errorCorrectionLevel = QrErrorCorrectLevel.L,
    this.color = _qrDefaultColor,
    this.emptyColor,
    this.gapless = false,
    this.imageGap = false,
    this.style = QrStyle.circular,
    this.embeddedImage,
    this.embeddedImageStyle,
  }) : assert(QrVersions.isSupportedVersion(version)) {
    _init(data);
  }

  /// Create a new QrPainter with a pre-validated/created [QrCode] object. This
  /// constructor is useful when you have a custom validation / error handling
  /// flow or for when you need to pre-validate the QR data.
  QrPainter.withQr({
    QrCode qr,
    this.color = _qrDefaultColor,
    this.emptyColor,
    this.gapless = false,
    this.imageGap = false,
    this.style = QrStyle.circular,
    this.embeddedImage,
    this.embeddedImageStyle,
  })  : _qr = qr,
        version = qr.typeNumber,
        errorCorrectionLevel = qr.errorCorrectLevel {
    _calcVersion = version;
    _initPaints();
  }

  /// The QR code version.
  final int version; // the qr code version

  /// The error correction level of the QR code.
  final int errorCorrectionLevel; // the qr code error correction level

  /// The color of the squares.
  final Color color; // the color of the dark squares

  /// The color of the non-squares (background).
  @Deprecated(
      'You should us the background color value of your container widget')
  final Color emptyColor; // the other color
  /// If set to false, the painter will leave a 1px gap between each of the
  /// squares.
  final bool gapless;

  /// The image data to embed (as an overlay) in the QR code. The image will
  /// be added to the center of the QR code.
  final ui.Image embeddedImage;

  /// Styling options for the image overlay.
  final QrEmbeddedImageStyle embeddedImageStyle;

  /// If set to true, an area in the middle of the QR code will be left blank
  /// Default is false.
  final bool imageGap;

  /// Default Qr style is circular
  final QrStyle style;

  /// The base QR code data
  QrCode _qr;

  /// This is the version (after calculating) that we will use if the user has
  /// requested the 'auto' version.
  int _calcVersion;

  /// The size of the 'gap' between the pixels
  final double _gapSize = 0.5;

  /// Cache for all of the [Paint] objects.
  final _paintCache = PaintCache();

  void _init(String data) {
    if (!QrVersions.isSupportedVersion(version)) {
      throw QrUnsupportedVersionException(version);
    }
    // configure and make the QR code data
    final validationResult = QrValidator.validate(
      data: data,
      version: version,
      errorCorrectionLevel: errorCorrectionLevel,
    );
    if (!validationResult.isValid) {
      throw validationResult.error;
    }
    _qr = validationResult.qrCode;
    _calcVersion = _qr.typeNumber;
    _initPaints();
  }

  void _initPaints() {
    // Cache the pixel paint object. For now there is only one but we might
    // expand it to multiple later (e.g.: different colours).
    _paintCache.cache(
        Paint()..style = PaintingStyle.fill, QrCodeElement.codePixel);
    // Cache the finder pattern painters. We'll keep one for each one in case
    // we want to provide customization options later.
    for (final position in FinderPatternPosition.values) {
      _paintCache.cache(Paint()..style = PaintingStyle.stroke,
          QrCodeElement.finderPatternOuter,
          position: position);
      _paintCache.cache(
          Paint()..style = PaintingStyle.fill, QrCodeElement.finderPatternInner,
          position: position);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // if the widget has a zero size side then we cannot continue painting.
    if (size.shortestSide == 0) {
      print("[QR] WARN: width or height is zero. You should set a 'size' value "
          "or nest this painter in a Widget that defines a non-zero size");
      return;
    }
    // DEPRECATED: the `emptyColor` property will be removed soon
    if (emptyColor != null) {
      canvas.drawColor(emptyColor, BlendMode.color);
    }

    final paintMetrics = _PaintMetrics(
      containerSize: size.shortestSide,
      moduleCount: _qr.moduleCount,
      gapSize: (gapless ? 0 : _gapSize),
    );

    // draw the finder pattern elements
    _drawFinderPatternItem(FinderPatternPosition.topLeft, canvas, paintMetrics);
    _drawFinderPatternItem(
        FinderPatternPosition.bottomLeft, canvas, paintMetrics);
    _drawFinderPatternItem(
        FinderPatternPosition.topRight, canvas, paintMetrics);

    // DEBUG: draw the inner content boundary
//    final paint = Paint()..style = ui.PaintingStyle.stroke;
//    paint.strokeWidth = 1;
//    paint.color = const Color(0x55222222);
//    canvas.drawRect(
//        Rect.fromLTWH(paintMetrics.inset, paintMetrics.inset,
//            paintMetrics.innerContentSize, paintMetrics.innerContentSize),
//        paint);

    double left;
    double top;
    final gap = !gapless ? _gapSize : 0;
    final pixelPaint = _paintCache.firstPaint(QrCodeElement.codePixel);
    pixelPaint.color = color;
    for (var x = 0; x < _qr.moduleCount; x++) {
      for (var y = 0; y < _qr.moduleCount; y++) {
        // draw the finder patterns independently
        if (_isFinderPatternPosition(x, y)) continue;

        // Exclude if pixel is in image gap space
        if (imageGap && _isLogoArea(x, y)) continue;

        // paint an 'on' pixel
        if (_qr.isDark(y, x)) {
          left = paintMetrics.inset + (x * (paintMetrics.pixelSize + gap));
          top = paintMetrics.inset + (y * (paintMetrics.pixelSize + gap));
          var pixelHTweak = 0.0;
          var pixelVTweak = 0.0;
          if (gapless && _hasAdjacentHorizontalPixel(x, y, _qr.moduleCount)) {
            pixelHTweak = 0.5;
          }
          if (gapless && _hasAdjacentVerticalPixel(x, y, _qr.moduleCount)) {
            pixelVTweak = 0.5;
          }
          final squareRect = Rect.fromLTWH(
            left,
            top,
            paintMetrics.pixelSize * 0.8 + pixelHTweak,
            paintMetrics.pixelSize * 0.8 + pixelVTweak,
          );
          if (style == QrStyle.circular) {
            final roundedRect =
                RRect.fromRectAndRadius(squareRect, Radius.circular(100));
            canvas.drawRRect(roundedRect, pixelPaint);
          } else if (style == QrStyle.square) {
            canvas.drawRect(squareRect, pixelPaint);
          }
        }
      }
    }

    if (embeddedImage != null) {
      final originalSize = Size(
        embeddedImage.width.toDouble(),
        embeddedImage.height.toDouble(),
      );
      final requestedSize =
          embeddedImageStyle != null ? embeddedImageStyle.size : null;
      final imageSize = _scaledAspectSize(size, originalSize, requestedSize);
      final position = Offset(
        (size.width - imageSize.width) / 2.0,
        (size.height - imageSize.height) / 2.0,
      );
      // draw the image overlay.
      _drawImageOverlay(canvas, position, imageSize, embeddedImageStyle);
    }
  }

  bool _hasAdjacentVerticalPixel(int x, int y, int moduleCount) {
    if (y + 1 >= moduleCount) return false;
    return _qr.isDark(y + 1, x);
  }

  bool _hasAdjacentHorizontalPixel(int x, int y, int moduleCount) {
    if (x + 1 >= moduleCount) return false;
    return _qr.isDark(y, x + 1);
  }

  bool _isLogoArea(int x, int y) {
    //Find center of module count and portion to cut out of QR
    var center = _qr.moduleCount / 2;
    var canvasPortion = _qr.moduleCount * 0.15;

    if (x > center - canvasPortion &&
        x < center + canvasPortion &&
        y > center - canvasPortion &&
        y < center + canvasPortion) return true;
    return false;
  }

  bool _isFinderPatternPosition(int x, int y) {
    final isTopLeft = (y < _finderPatternLimit && x < _finderPatternLimit);
    final isBottomLeft = (y < _finderPatternLimit &&
        (x >= _qr.moduleCount - _finderPatternLimit));
    final isTopRight = (y >= _qr.moduleCount - _finderPatternLimit &&
        (x < _finderPatternLimit));
    return isTopLeft || isBottomLeft || isTopRight;
  }

  void _drawFinderPatternItem(
    FinderPatternPosition position,
    Canvas canvas,
    _PaintMetrics metrics,
  ) {
    final totalGap = (_finderPatternLimit - 1) * metrics.gapSize;
    final radius = ((_finderPatternLimit * metrics.pixelSize) + totalGap) -
        metrics.pixelSize;
    final strokeAdjust = (metrics.pixelSize / 2.0);
    final edgePos =
        (metrics.inset + metrics.innerContentSize) - (radius + strokeAdjust);

    Offset offset;
    if (position == FinderPatternPosition.topLeft) {
      offset =
          Offset(metrics.inset + strokeAdjust, metrics.inset + strokeAdjust);
    } else if (position == FinderPatternPosition.bottomLeft) {
      offset = Offset(metrics.inset + strokeAdjust, edgePos);
    } else {
      offset = Offset(edgePos, metrics.inset + strokeAdjust);
    }

    // configure the paints
    final outerPaint = _paintCache.firstPaint(QrCodeElement.finderPatternOuter,
        position: position);
    outerPaint.strokeWidth = metrics.pixelSize;
    outerPaint.color = color;

    final innerPaint = _paintCache.firstPaint(QrCodeElement.finderPatternInner,
        position: position);
    innerPaint.color = color;

    final strokeRect = Rect.fromLTWH(offset.dx, offset.dy, radius, radius);

    final gapHalf = metrics.pixelSize;
    final gap = gapHalf * 2;
    final innerSize = radius - gap - (2 * strokeAdjust);
    final innerRect = Rect.fromLTWH(offset.dx + gapHalf + strokeAdjust,
        offset.dy + gapHalf + strokeAdjust, innerSize, innerSize);

    // Paint shapes onto canvas
    if (style == QrStyle.circular) {
      final roundedStrokeRect =
          RRect.fromRectAndRadius(strokeRect, Radius.circular(100));
      canvas.drawRRect(roundedStrokeRect, outerPaint);
      final roundedInnerRect =
          RRect.fromRectAndRadius(innerRect, Radius.circular(100));
      canvas.drawRRect(roundedInnerRect, innerPaint);
    } else if (style == QrStyle.square) {
      canvas.drawRect(strokeRect, outerPaint);
      canvas.drawRect(innerRect, innerPaint);
    }
  }

  bool _hasOneNonZeroSide(Size size) => size.longestSide > 0;

  Size _scaledAspectSize(
      Size widgetSize, Size originalSize, Size requestedSize) {
    if (requestedSize != null && !requestedSize.isEmpty) {
      return requestedSize;
    } else if (requestedSize != null && _hasOneNonZeroSide(requestedSize)) {
      final maxSide = requestedSize.longestSide;
      final ratio = maxSide / originalSize.longestSide;
      return Size(ratio * originalSize.width, ratio * originalSize.height);
    } else {
      final maxSide = 0.25 * widgetSize.shortestSide;
      final ratio = maxSide / originalSize.longestSide;
      return Size(ratio * originalSize.width, ratio * originalSize.height);
    }
  }

  void _drawImageOverlay(
      Canvas canvas, Offset position, Size size, QrEmbeddedImageStyle style) {
    final paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high;
    if (style != null) {
      if (style.color != null) {
        paint.colorFilter = ColorFilter.mode(style.color, BlendMode.srcATop);
      }
    }
    final srcSize =
        Size(embeddedImage.width.toDouble(), embeddedImage.height.toDouble());
    final src = Alignment.center.inscribe(srcSize, Offset.zero & srcSize);
    final dst = Alignment.center.inscribe(size, position & size);
    canvas.drawImageRect(embeddedImage, src, dst, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldPainter) {
    if (oldPainter is QrPainter) {
      return color != oldPainter.color ||
          errorCorrectionLevel != oldPainter.errorCorrectionLevel ||
          _calcVersion != oldPainter._calcVersion ||
          _qr != oldPainter._qr ||
          gapless != oldPainter.gapless ||
          embeddedImage != oldPainter.embeddedImage ||
          embeddedImageStyle != oldPainter.embeddedImageStyle;
    }
    return true;
  }

  /// Returns a [ui.Picture] object containing the QR code data.
  ui.Picture toPicture(double size) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    paint(canvas, Size(size, size));
    return recorder.endRecording();
  }

  /// Returns the raw QR code [ui.Image] object.
  Future<ui.Image> toImage(double size,
      {ui.ImageByteFormat format = ui.ImageByteFormat.png}) async {
    return await toPicture(size).toImage(size.toInt(), size.toInt());
  }

  /// Returns the raw QR code image byte data.
  Future<ByteData> toImageData(double size,
      {ui.ImageByteFormat format = ui.ImageByteFormat.png}) async {
    final image = await toImage(size, format: format);
    return image.toByteData(format: format);
  }
}

class _PaintMetrics {
  _PaintMetrics(
      {@required this.containerSize,
      @required this.gapSize,
      @required this.moduleCount}) {
    _calculateMetrics();
  }

  final int moduleCount;
  final double containerSize;
  final double gapSize;

  double _pixelSize;
  double get pixelSize => _pixelSize;

  double _innerContentSize;
  double get innerContentSize => _innerContentSize;

  double _inset;
  double get inset => _inset;

  void _calculateMetrics() {
    final gapTotal = (moduleCount - 1) * gapSize;
    var pixelSize = (containerSize - gapTotal) / moduleCount;
    _pixelSize = (pixelSize * 2).roundToDouble() / 2;
    _innerContentSize = (_pixelSize * moduleCount) + gapTotal;
    _inset = (containerSize - _innerContentSize) / 2;
  }
}
