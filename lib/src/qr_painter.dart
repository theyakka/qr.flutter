/*
 * QR.Flutter
 * Copyright (c) 2019 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr/qr.dart';

import 'errors.dart';
import 'paint_cache.dart';
import 'qr_versions.dart';
import 'types.dart';
import 'validator.dart';

// ignore_for_file: deprecated_member_use_from_same_package

const int _finderPatternLimit = 7;

// default colors for the qr code pixels
const Color _qrDefaultColor = Color(0xff000000);
const Color _qrDefaultEmptyColor = Color(0x00ffffff);

/// A [CustomPainter] object that you can use to paint a QR code.
class QrPainter extends CustomPainter {
  /// Create a new QRPainter with passed options (or defaults).
  QrPainter({
    required String data,
    required this.version,
    this.errorCorrectionLevel = QrErrorCorrectLevel.L,
    @Deprecated('use colors in eyeStyle and dataModuleStyle instead')
    this.color = _qrDefaultColor,
    @Deprecated(
      'You should use the background color value of your container widget',
    )
    this.emptyColor = _qrDefaultEmptyColor,
    this.gapless = false,
    this.embeddedImage,
    this.embeddedImageStyle = const QrEmbeddedImageStyle(),
    this.eyeStyle = const QrEyeStyle(),
    this.dataModuleStyle = const QrDataModuleStyle(),
    this.gradient,
  }) : assert(
        QrVersions.isSupportedVersion(version),
        'QR code version $version is not supported',
        ) {
    _init(data);
  }

  /// Create a new QrPainter with a pre-validated/created [QrCode] object. This
  /// constructor is useful when you have a custom validation / error handling
  /// flow or for when you need to pre-validate the QR data.
  QrPainter.withQr({
    required QrCode qr,
    @Deprecated('use colors in eyeStyle and dataModuleStyle instead')
    this.color = _qrDefaultColor,
    @Deprecated(
      'You should use the background color value of your container widget',
    )
    this.emptyColor = _qrDefaultEmptyColor,
    this.gapless = false,
    this.embeddedImage,
    this.embeddedImageStyle = const QrEmbeddedImageStyle(),
    this.eyeStyle = const QrEyeStyle(),
    this.dataModuleStyle = const QrDataModuleStyle(),
    this.gradient,
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
  @Deprecated('use colors in eyeStyle and dataModuleStyle instead')
  final Color color;

  /// The gradient for all (dataModuleShape, eyeShape, embeddedImageShape)
  final Gradient? gradient;

  /// The color of the non-squares (background).
  @Deprecated(
      'You should use the background color value of your container widget')
  final Color emptyColor; // the other color
  /// If set to false, the painter will leave a 1px gap between each of the
  /// squares.
  final bool gapless;

  /// The image data to embed (as an overlay) in the QR code. The image will
  /// be added to the center of the QR code.
  final ui.Image? embeddedImage;

  /// Styling options for the image overlay.
  final QrEmbeddedImageStyle embeddedImageStyle;

  /// Styling option for QR Eye ball and frame.
  final QrEyeStyle eyeStyle;

  /// Styling option for QR data module.
  final QrDataModuleStyle dataModuleStyle;

  /// The base QR code data
  QrCode? _qr;

  /// QR Image renderer
  late QrImage _qrImage;

  /// This is the version (after calculating) that we will use if the user has
  /// requested the 'auto' version.
  late final int _calcVersion;

  /// The size of the 'gap' between the pixels
  final double _gapSize = 0.25;

  /// Cache for all of the [Paint] objects.
  final PaintCache _paintCache = PaintCache();

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
      throw validationResult.error!;
    }
    _qr = validationResult.qrCode;
    _calcVersion = _qr!.typeNumber;
    _initPaints();
  }

  void _initPaints() {
    // Initialize `QrImage` for rendering
    _qrImage = QrImage(_qr!);
    // Cache the pixel paint object. For now there is only one but we might
    // expand it to multiple later (e.g.: different colours).
    _paintCache.cache(
      Paint()..style = PaintingStyle.fill,
      QrCodeElement.codePixel,
    );
    // Cache the empty pixel paint object. Empty color is deprecated and will go
    // away.
    _paintCache.cache(
      Paint()..style = PaintingStyle.fill,
      QrCodeElement.codePixelEmpty,
    );
    // Cache the finder pattern painters. We'll keep one for each one in case
    // we want to provide customization options later.
    for (final position in FinderPatternPosition.values) {
      _paintCache.cache(
        Paint()..style = PaintingStyle.stroke,
        QrCodeElement.finderPatternOuter,
        position: position,
      );
      _paintCache.cache(
        Paint()..style = PaintingStyle.stroke,
        QrCodeElement.finderPatternInner,
        position: position,
      );
      _paintCache.cache(
        Paint()..style = PaintingStyle.fill,
        QrCodeElement.finderPatternDot,
        position: position,
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // if the widget has a zero size side then we cannot continue painting.
    if (size.shortestSide == 0) {
      debugPrint(
          "[QR] WARN: width or height is zero. You should set a 'size' value "
          'or nest this painter in a Widget that defines a non-zero size');
      return;
    }

    final paintMetrics = _PaintMetrics(
      containerSize: size.shortestSide,
      moduleCount: _qr!.moduleCount,
      gapSize: gapless ? 0 : _gapSize,
    );

    // draw the finder pattern elements
    _drawFinderPatternItem(
      FinderPatternPosition.topLeft,
      canvas,
      paintMetrics,
    );
    _drawFinderPatternItem(
      FinderPatternPosition.bottomLeft,
      canvas,
      paintMetrics,
    );
    _drawFinderPatternItem(
      FinderPatternPosition.topRight,
      canvas,
      paintMetrics,
    );

    // DEBUG: draw the inner content boundary
//    final paint = Paint()..style = ui.PaintingStyle.stroke;
//    paint.strokeWidth = 1;
//    paint.color = const Color(0x55222222);
//    canvas.drawRect(
//        Rect.fromLTWH(paintMetrics.inset, paintMetrics.inset,
//            paintMetrics.innerContentSize, paintMetrics.innerContentSize),
//        paint);

    Size? embeddedImageSize;
    Offset? embeddedImagePosition;
    Offset? safeAreaPosition;
    Rect? safeAreaRect;
    if (embeddedImage != null) {
      final originalSize = Size(
        embeddedImage!.width.toDouble(),
        embeddedImage!.height.toDouble(),
      );
      final requestedSize = embeddedImageStyle.size;
      embeddedImageSize = _scaledAspectSize(size, originalSize, requestedSize);
      embeddedImagePosition = Offset(
        (size.width - embeddedImageSize.width) / 2.0,
        (size.height - embeddedImageSize.height) / 2.0,
      );
      if(embeddedImageStyle.safeArea) {
        final safeAreaMultiplier = embeddedImageStyle.safeAreaMultiplier;
        safeAreaPosition = Offset(
          (size.width - embeddedImageSize.width * safeAreaMultiplier) / 2.0,
          (size.height - embeddedImageSize.height * safeAreaMultiplier) / 2.0,
        );
        safeAreaRect = Rect.fromLTWH(
          safeAreaPosition.dx,
          safeAreaPosition.dy,
          embeddedImageSize.width * safeAreaMultiplier,
          embeddedImageSize.height * safeAreaMultiplier,
        );
      }

      if(embeddedImageStyle.embeddedImageShape != EmbeddedImageShape.none) {
        final color = _priorityColor(embeddedImageStyle.shapeColor);

        final squareRect = Rect.fromLTWH(
          embeddedImagePosition.dx,
          embeddedImagePosition.dy,
          embeddedImageSize.width,
          embeddedImageSize.height,
        );

        final paint = Paint()..color = color;

        switch(embeddedImageStyle.embeddedImageShape) {
          case EmbeddedImageShape.square:
            if(embeddedImageStyle.borderRadius > 0) {
              final roundedRect = RRect.fromRectAndRadius(
                squareRect,
                Radius.circular(embeddedImageStyle.borderRadius),
              );
              canvas.drawRRect(roundedRect, paint);
            } else {
              canvas.drawRect(squareRect, paint);
            }
            break;
          case EmbeddedImageShape.circle:
            final roundedRect = RRect.fromRectAndRadius(squareRect,
                Radius.circular(squareRect.width / 2));
            canvas.drawRRect(roundedRect, paint);
            break;
          default:
            break;
        }
      }
    }

    final gap = !gapless ? _gapSize : 0;
    // get the painters for the pixel information
    final pixelPaint = _paintCache.firstPaint(QrCodeElement.codePixel);
    pixelPaint!.color = _priorityColor(dataModuleStyle.color);

    final emptyPixelPaint = _paintCache
        .firstPaint(QrCodeElement.codePixelEmpty);
    emptyPixelPaint!.color = _qrDefaultEmptyColor;

    final borderRadius = Radius
        .circular(dataModuleStyle.borderRadius);
    final outsideBorderRadius = Radius
        .circular(dataModuleStyle.outsideBorderRadius);
    final isRoundedOutsideCorners = dataModuleStyle.roundedOutsideCorners;

    for (var x = 0; x < _qr!.moduleCount; x++) {
      for (var y = 0; y < _qr!.moduleCount; y++) {
        // draw the finder patterns independently
        if (_isFinderPatternPosition(x, y)) {
          continue;
        }
        final isDark = _qrImage.isDark(y, x);
        final paint = isDark ? pixelPaint : emptyPixelPaint;
        if (!isDark && !isRoundedOutsideCorners) {
          continue;
        }
        // paint a pixel
        final squareRect = _createDataModuleRect(paintMetrics, x, y, gap);
        // check safeArea
        if(embeddedImageStyle.safeArea
            && safeAreaRect?.overlaps(squareRect) == true) continue;
        switch(dataModuleStyle.dataModuleShape) {
          case QrDataModuleShape.square:
            if(dataModuleStyle.borderRadius > 0) {

              // If pixel isDark == true and outside safe area
              // than can't be rounded
              final isDarkLeft = _isDarkOnSide(x - 1, y,
                  safeAreaRect, paintMetrics, gap);
              final isDarkTop = _isDarkOnSide(x, y - 1,
                  safeAreaRect, paintMetrics, gap);
              final isDarkRight =  _isDarkOnSide(x + 1, y,
                  safeAreaRect, paintMetrics, gap);
              final isDarkBottom =  _isDarkOnSide(x, y + 1,
                  safeAreaRect, paintMetrics, gap);

              if(!isDark && isRoundedOutsideCorners) {
                final isDarkTopLeft =  _isDarkOnSide(x - 1, y - 1,
                    safeAreaRect, paintMetrics, gap);;
                final isDarkTopRight =  _isDarkOnSide(x + 1, y - 1,
                    safeAreaRect, paintMetrics, gap);;
                final isDarkBottomLeft =  _isDarkOnSide(x - 1, y + 1,
                    safeAreaRect, paintMetrics, gap);;
                final isDarkBottomRight =  _isDarkOnSide(x + 1, y + 1,
                    safeAreaRect, paintMetrics, gap);;

                final roundedRect = RRect.fromRectAndCorners(
                  squareRect,
                  topLeft: isDarkTop && isDarkLeft && isDarkTopLeft
                      ? outsideBorderRadius
                      : Radius.zero,
                  topRight: isDarkTop && isDarkRight && isDarkTopRight
                      ? outsideBorderRadius
                      : Radius.zero,
                  bottomLeft: isDarkBottom && isDarkLeft && isDarkBottomLeft
                      ? outsideBorderRadius
                      : Radius.zero,
                  bottomRight: isDarkBottom && isDarkRight && isDarkBottomRight
                      ? outsideBorderRadius
                      : Radius.zero,
                );
                canvas.drawPath(
                  Path.combine(
                    PathOperation.difference,
                    Path()..addRect(squareRect),
                    Path()..addRRect(roundedRect)..close(),
                  ),
                  pixelPaint,
                );
              } else {
                final roundedRect = RRect.fromRectAndCorners(
                  squareRect,
                  topLeft: isDarkTop || isDarkLeft
                      ? Radius.zero
                      : borderRadius,
                  topRight: isDarkTop || isDarkRight
                      ? Radius.zero
                      : borderRadius,
                  bottomLeft: isDarkBottom || isDarkLeft
                      ? Radius.zero
                      : borderRadius,
                  bottomRight: isDarkBottom || isDarkRight
                      ? Radius.zero
                      : borderRadius,
                );
                canvas.drawRRect(roundedRect, paint);
              }
            } else {
              canvas.drawRect(squareRect, paint);
            }
            break;
          default:
            final roundedRect = RRect.fromRectAndRadius(squareRect,
                Radius.circular(squareRect.width / 2));
            canvas.drawRRect(roundedRect, paint);
            break;
        }
      }
    }

    // set gradient for all
    if(gradient != null) {
      final paintGradient = Paint();
      paintGradient.shader = gradient!
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      paintGradient.blendMode = BlendMode.values[12];
      canvas.drawRect(
        Rect.fromLTWH(
          paintMetrics.inset,
          paintMetrics.inset,
          paintMetrics.innerContentSize,
          paintMetrics.innerContentSize,
        ),
        paintGradient,
      );
    }

    // draw the image overlay.
    if (embeddedImage != null) {
      _drawImageOverlay(
        canvas,
        embeddedImagePosition!,
        embeddedImageSize!,
        embeddedImageStyle,
      );
    }
  }

  bool _isDarkOnSide(int x, int y, Rect? safeAreaRect,
      _PaintMetrics paintMetrics, num gap,) {
    final maxIndexPixel = _qrImage.moduleCount - 1;

    final xIsContains = x >= 0 && x <= maxIndexPixel;
    final yIsContains = y >= 0 && y <= maxIndexPixel;

    return xIsContains && yIsContains
        ? _qrImage.isDark(y, x)
        && !(safeAreaRect?.overlaps(
            _createDataModuleRect(paintMetrics, x, y, gap))
            ?? false)
        : false;
  }

  Rect _createDataModuleRect(_PaintMetrics paintMetrics, int x, int y, num gap) {
    final left = paintMetrics.inset + (x * (paintMetrics.pixelSize + gap));
    final top = paintMetrics.inset + (y * (paintMetrics.pixelSize + gap));
    var pixelHTweak = 0.0;
    var pixelVTweak = 0.0;
    if (gapless && _hasAdjacentHorizontalPixel(x, y, _qr!.moduleCount)) {
      pixelHTweak = 0.5;
    }
    if (gapless && _hasAdjacentVerticalPixel(x, y, _qr!.moduleCount)) {
      pixelVTweak = 0.5;
    }
    return Rect.fromLTWH(
      left,
      top,
      paintMetrics.pixelSize + pixelHTweak,
      paintMetrics.pixelSize + pixelVTweak,
    );
  }

  bool _hasAdjacentVerticalPixel(int x, int y, int moduleCount) {
    if (y + 1 >= moduleCount) {
      return false;
    }
    return _qrImage.isDark(y + 1, x);
  }

  bool _hasAdjacentHorizontalPixel(int x, int y, int moduleCount) {
    if (x + 1 >= moduleCount) {
      return false;
    }
    return _qrImage.isDark(y, x + 1);
  }

  bool _isFinderPatternPosition(int x, int y) {
    final isTopLeft = y < _finderPatternLimit && x < _finderPatternLimit;
    final isBottomLeft = y < _finderPatternLimit &&
        (x >= _qr!.moduleCount - _finderPatternLimit);
    final isTopRight = y >= _qr!.moduleCount - _finderPatternLimit &&
        (x < _finderPatternLimit);
    return isTopLeft || isBottomLeft || isTopRight;
  }

  void _drawFinderPatternItem(
    FinderPatternPosition position,
    Canvas canvas,
    _PaintMetrics metrics,
  ) {
    final totalGap = (_finderPatternLimit - 1) * metrics.gapSize;
    final radius =
        ((_finderPatternLimit * metrics.pixelSize) + totalGap) -
            metrics.pixelSize;
    final strokeAdjust = metrics.pixelSize / 2.0;
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
    final outerPaint = _paintCache.firstPaint(
      QrCodeElement.finderPatternOuter,
      position: position,
    )!;
    final color = _priorityColor(eyeStyle.color);
    outerPaint.strokeWidth = metrics.pixelSize;
    outerPaint.color = color;

    final innerPaint = _paintCache
        .firstPaint(QrCodeElement.finderPatternInner, position: position)!;
    innerPaint.strokeWidth = metrics.pixelSize;
    innerPaint.color = emptyColor;

    final dotPaint = _paintCache.firstPaint(
      QrCodeElement.finderPatternDot,
      position: position,
    );
    dotPaint!.color = color;

    final outerRect =
        Rect.fromLTWH(offset.dx, offset.dy, radius, radius);

    final innerRadius = radius - (2 * metrics.pixelSize);
    final innerRect = Rect.fromLTWH(
      offset.dx + metrics.pixelSize,
      offset.dy + metrics.pixelSize,
      innerRadius,
      innerRadius,
    );

    final gap = metrics.pixelSize * 2;
    final dotSize = radius - gap - (2 * strokeAdjust);
    final dotRect = Rect.fromLTWH(
      offset.dx + metrics.pixelSize + strokeAdjust,
      offset.dy + metrics.pixelSize + strokeAdjust,
      dotSize,
      dotSize,
    );

    switch(eyeStyle.eyeShape) {
      case QrEyeShape.square:
        if(eyeStyle.borderRadius > 0) {
          final roundedOuterStrokeRect = RRect.fromRectAndRadius(
              outerRect, Radius.circular(eyeStyle.borderRadius));
          canvas.drawRRect(roundedOuterStrokeRect, outerPaint);
          canvas.drawRect(innerRect, innerPaint);
          final roundedDotStrokeRect = RRect.fromRectAndRadius(
              dotRect, Radius.circular(eyeStyle.borderRadius / 2));
          canvas.drawRRect(roundedDotStrokeRect, dotPaint);
        } else {
          canvas.drawRect(outerRect, outerPaint);
          canvas.drawRect(innerRect, innerPaint);
          canvas.drawRect(dotRect, dotPaint);
        }
        break;
      default:
        final roundedOuterStrokeRect =
        RRect.fromRectAndRadius(outerRect, Radius.circular(radius));
        canvas.drawRRect(roundedOuterStrokeRect, outerPaint);

        final roundedInnerStrokeRect =
        RRect.fromRectAndRadius(outerRect, Radius.circular(innerRadius));
        canvas.drawRRect(roundedInnerStrokeRect, innerPaint);

        final roundedDotStrokeRect =
        RRect.fromRectAndRadius(dotRect, Radius.circular(dotSize));
        canvas.drawRRect(roundedDotStrokeRect, dotPaint);
        break;
    }
  }

  bool _hasOneNonZeroSide(Size size) => size.longestSide > 0;

  Size _scaledAspectSize(
    Size widgetSize,
    Size originalSize,
    Size? requestedSize,
  ) {
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
    Canvas canvas,
    Offset position,
    Size size,
    QrEmbeddedImageStyle? style,
  ) {
    final paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high;
    if (style != null) {
      if (style.color != null) {
        paint.colorFilter = ColorFilter.mode(style.color!, BlendMode.srcATop);
      }
    }
    final srcSize = Size(
      embeddedImage!.width.toDouble(),
      embeddedImage!.height.toDouble(),
    );
    final src = Alignment.center.inscribe(srcSize, Offset.zero & srcSize);
    final dst = Alignment.center.inscribe(size, position & size);
    canvas.drawImageRect(embeddedImage!, src, dst, paint);
  }

  /// if [gradient] != null, then only black [_qrDefaultColor],
  /// needed for gradient
  /// else [color] or [QrPainter.color]
  Color _priorityColor(Color? color) =>
      gradient != null ? _qrDefaultColor : color ?? this.color;

  @override
  bool shouldRepaint(CustomPainter oldPainter) {
    if (oldPainter is QrPainter) {
      return errorCorrectionLevel != oldPainter.errorCorrectionLevel ||
          _calcVersion != oldPainter._calcVersion ||
          _qr != oldPainter._qr ||
          gapless != oldPainter.gapless ||
          embeddedImage != oldPainter.embeddedImage ||
          embeddedImageStyle != oldPainter.embeddedImageStyle ||
          eyeStyle != oldPainter.eyeStyle ||
          dataModuleStyle != oldPainter.dataModuleStyle;
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
  Future<ui.Image> toImage(double size) {
    return toPicture(size).toImage(size.toInt(), size.toInt());
  }

  /// Returns the raw QR code image byte data.
  Future<ByteData?> toImageData(
    double size, {
    ui.ImageByteFormat format = ui.ImageByteFormat.png,
  }) async {
    final image = await toImage(size);
    return image.toByteData(format: format);
  }
}

class _PaintMetrics {
  _PaintMetrics({
    required this.containerSize,
    required this.gapSize,
    required this.moduleCount,
  }) {
    _calculateMetrics();
  }

  final int moduleCount;
  final double containerSize;
  final double gapSize;

  late final double _pixelSize;
  double get pixelSize => _pixelSize;

  late final double _innerContentSize;
  double get innerContentSize => _innerContentSize;

  late final double _inset;
  double get inset => _inset;

  void _calculateMetrics() {
    final gapTotal = (moduleCount - 1) * gapSize;
    final pixelSize = (containerSize - gapTotal) / moduleCount;
    _pixelSize = (pixelSize * 2).roundToDouble() / 2;
    _innerContentSize = (_pixelSize * moduleCount) + gapTotal;
    _inset = (containerSize - _innerContentSize) / 2;
  }
}
