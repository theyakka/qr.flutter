/*
 * QR.Flutter
 * Copyright (c) 2022 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../qr_flutter.dart';
import 'color_matrix.dart';
import 'paint_cache.dart';
import 'paint_metrics.dart';

const _finderPatternLimit = 7;

/// A [CustomPainter] object that you can use to paint a QR code.
class QrPainter extends CustomPainter {
  /// Create a new QRPainter with passed options (or defaults).
  QrPainter({
    required String data,
    required this.version,
    this.errorCorrectionLevel = QrErrorCorrectLevel.M,
    this.appearance = const QrAppearance(),
    this.embeddedImage,
    this.inset = 0,
  })  : _isGapless = appearance.gapSize == 0,
        assert(isSupportedVersion(version)) {
    _init(data);
  }

  /// Create a new QrPainter with a pre-validated/created [QrCode] object. This
  /// constructor is useful when you have a custom validation / error handling
  /// flow or for when you need to pre-validate the QR data.
  QrPainter.withQr({
    required QrCode qr,
    this.appearance = const QrAppearance(),
    this.embeddedImage,
    this.inset = 0,
  })  : _qr = qr,
        version = qr.typeNumber,
        errorCorrectionLevel = qr.errorCorrectLevel,
        _isGapless = appearance.gapSize == 0 {
    _initColors();
    _initPaints();
  }

  /// The QR code version.
  final int version; // the qr code version

  /// The error correction level of the QR code.
  final int errorCorrectionLevel; // the qr code error correction level

  /// Configuration options for modifying how the QR code looks.
  final QrAppearance appearance;

  /// The image data to embed (as an overlay) in the QR code. The image will
  /// be added to the center of the QR code.
  final ui.Image? embeddedImage;

  /// The amount that the code contents should be inset from the edges.
  final double inset;

  /// The base QR code data
  QrCode? _qr;

  ColorMatrix? _colorMatrix;

  /// QR Image renderer
  late QrImage _qrImage;

  /// Cache for all of the [Paint] objects.
  final _paintCache = PaintCache();

  /// Do we need to render gaps between the modules.
  final bool _isGapless;

  void _init(String data) {
    if (!isSupportedVersion(version)) {
      throw QrUnsupportedVersionException(version);
    }
    // configure and make the QR code data
    final validationResult = validateData(
      data: data,
      version: version,
      errorCorrectionLevel: errorCorrectionLevel,
    );
    if (!validationResult.isValid) {
      throw validationResult.error!;
    }
    _qr = validationResult.qrCode;
    _initColors();
    _initPaints();
  }

  void _initColors() {
    final moduleCount = _qr?.moduleCount;
    final colors = appearance.moduleStyle.colors;
    if (moduleCount != null && colors != null && colors.length > 0) {
      final matrix = ColorMatrix(size: moduleCount);
      for (var y = 0; y < moduleCount; y++) {
        for (var x = 0; x < moduleCount; x++) {
          if (colors.mode != null && colors.mode == ColorMode.sequence) {
            final Axis? direction = colors.options[optionKeyDirection];
            if (direction == Axis.horizontal) {
              matrix.addAt(y, x, colors[y % 4]);
              continue;
            }
            matrix.addAt(x, y, colors[y % 4]);
          } else {
            matrix.addAt(x, y, colors.random()!);
          }
        }
      }
      _colorMatrix = matrix;
    }
  }

  void _initPaints() {
    // Initialize `QrImage` for rendering
    _qrImage = QrImage(_qr!);
    // Cache the pixel paint object. For now there is only one but we might
    // expand it to multiple later (e.g.: different colours).
    _paintCache.cache(
        Paint()..style = PaintingStyle.fill, QrCodeElement.codePixel);
    // Cache the empty pixel paint object. Empty color is deprecated and will go
    // away.
    _paintCache.cache(
        Paint()..style = PaintingStyle.fill, QrCodeElement.codePixelEmpty);
    // Cache the finder pattern painters. We'll keep one for each one in case
    // we want to provide customization options later.
    for (final position in FinderPatternPosition.values) {
      _paintCache.cache(Paint()..style = PaintingStyle.stroke,
          QrCodeElement.finderPatternOuter,
          position: position);
      _paintCache.cache(Paint()..style = PaintingStyle.stroke,
          QrCodeElement.finderPatternInner,
          position: position);
      _paintCache.cache(
          Paint()..style = PaintingStyle.fill, QrCodeElement.finderPatternDot,
          position: position);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paintWithOverrides(canvas, size, null, null);
  }

  void _paintWithOverrides(
      Canvas canvas, Size size, Color? background, double? customInset) {
    if (background != null) {
      final bgPaint = Paint();
      bgPaint.color = background;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    }

    // if the widget has a zero size side then we cannot continue painting.
    if (kDebugMode) {
      if (size.shortestSide == 0) {
        print(
            "[QR] WARN: width or height is zero. You should set a 'size' value "
            "or nest this painter in a Widget that defines a non-zero size");
        return;
      }
    }

    // calculate the image rect so we can draw it and check for overlaps (if
    // necessary.
    Rect? imageRect;
    final image = embeddedImage;
    if (image != null) {
      final ogImageSize = Size(image.width.toDouble(), image.height.toDouble());
      final imageSize = _scaledAspectSize(
          size, ogImageSize, appearance.embeddedImageStyle?.size);
      imageRect = Rect.fromLTWH(
        (size.width - imageSize.width) / 2.0,
        (size.height - imageSize.height) / 2.0,
        imageSize.width,
        imageSize.height,
      );
    }

    // do some pre-calculation / caching of units that we're going to reuse.
    final paintMetrics = PaintMetrics(
      containerSize: size,
      moduleCount: _qr!.moduleCount,
      gapSize: appearance.gapSize.toDouble(),
      inset: customInset ?? inset,
    );

    // draw the finder pattern elements.
    _drawFinderPatternItem(FinderPatternPosition.topLeft, canvas, paintMetrics);
    _drawFinderPatternItem(
        FinderPatternPosition.bottomLeft, canvas, paintMetrics);
    _drawFinderPatternItem(
        FinderPatternPosition.topRight, canvas, paintMetrics);

    // draw the data modules.
    // tracks where you are in the sequence of colors (if mode == sequence).
    // get the painters for the pixel information.
    final pixelPaint = _paintCache.firstPaint(QrCodeElement.codePixel);
    // the qr code is an x by y (square) grid.
    for (var y = 0; y < _qr!.moduleCount; y++) {
      for (var x = 0; x < _qr!.moduleCount; x++) {
        // we draw the finder patterns independently, so skip this area.
        if (_isFinderPatternPosition(x, y)) continue;
        // if the pixel is a light pixel then we don't draw anything. skip.
        if (!_qrImage.isDark(y, x)) continue;
        // calculate the pixel rect + offsets.
        final left = paintMetrics.origin.dx +
            (x * (paintMetrics.pixelSize + appearance.gapSize));
        final top = paintMetrics.origin.dy +
            (y * (paintMetrics.pixelSize + appearance.gapSize));
        final pixelBoundaryRect = Rect.fromLTWH(
            left, top, paintMetrics.pixelSize, paintMetrics.pixelSize);
        // check to see if the pixel boundary encroaches on the image. if so,
        // we should avoid painting it if the `drawOverModules` flag is `false`.
        if (imageRect != null &&
            appearance.embeddedImageStyle?.drawOverModules == false &&
            pixelBoundaryRect.overlaps(imageRect)) {
          continue;
        }
        // determine what color the pixel should be and set up the paint colour.
        var pixelColor = const Color(0xFF000000);
        final colors = appearance.moduleStyle.colors;
        if (colors != null && colors.length > 1) {
          pixelColor = _colorMatrix![x][y]!;
        } else if (colors != null) {
          pixelColor = colors.first!;
        }
        pixelPaint!.color = pixelColor;
        // if we're drawing gapless + square shaped then we should turn off
        // antialiasing because it will render some antialias artifacts that
        // make it look like there is a gap.
        pixelPaint.isAntiAlias = !(_isGapless &&
            (appearance.moduleStyle.shape == null ||
                appearance.moduleStyle.shape == QrDataModuleShape.square));
        // determine what path we need to render based on the module shape.
        if (appearance.moduleStyle.shape == null ||
            appearance.moduleStyle.shape == QrDataModuleShape.square) {
          // square shape is simple.
          canvas.drawRect(pixelBoundaryRect, pixelPaint);
        } else if (appearance.moduleStyle.shape == QrDataModuleShape.diamond) {
          // create a diamond path and draw it.
          final diamondPath = Path();
          final midDelta = paintMetrics.pixelSize / 2;
          diamondPath.addPolygon([
            Offset(left, top + midDelta), // left
            Offset(left + midDelta, top), // top
            Offset(left + paintMetrics.pixelSize, top + midDelta), // right
            Offset(left + midDelta, top + paintMetrics.pixelSize), // bottom
          ], true);
          canvas.drawPath(diamondPath, pixelPaint);
        } else {
          // we can tread circular and rounded rect the same because they just
          // have a different radius.
          Radius radius;
          if (appearance.moduleStyle.shape == QrDataModuleShape.circle) {
            radius = Radius.circular(paintMetrics.pixelSize);
          } else {
            radius = Radius.elliptical(
                paintMetrics.pixelSize * 0.4, paintMetrics.pixelSize * 0.4);
          }
          canvas.drawRRect(
              RRect.fromRectAndRadius(pixelBoundaryRect, radius), pixelPaint);
        }
      }
    }
    // draw the embedded image
    if (embeddedImage != null) {
      // draw the image overlay.
      _drawImageOverlay(canvas, imageRect, appearance.embeddedImageStyle);
    }
  }

  /// Determines if the x / y position is in an area of the grid where one of
  /// the primary finder patterns will be drawn. Larger qr codes will have
  /// "embedded" finder patterns. This method does not include detection for
  /// those.
  bool _isFinderPatternPosition(int x, int y) {
    final isTopLeft = (y < _finderPatternLimit && x < _finderPatternLimit);
    final isBottomLeft = (y < _finderPatternLimit &&
        (x >= _qr!.moduleCount - _finderPatternLimit));
    final isTopRight = (y >= _qr!.moduleCount - _finderPatternLimit &&
        (x < _finderPatternLimit));
    return isTopLeft || isBottomLeft || isTopRight;
  }

  /// Draws an "eyeball" finder pattern on to the canvas.
  void _drawFinderPatternItem(
    FinderPatternPosition position,
    Canvas canvas,
    PaintMetrics metrics,
  ) {
    final totalGap = (_finderPatternLimit - 1) * metrics.gapSize;
    final radius = ((_finderPatternLimit * metrics.pixelSize) + totalGap) -
        metrics.pixelSize;
    final strokeAdjust = (metrics.pixelSize / 2.0);
    // configure the paints
    final outerPaint = _paintCache.firstPaint(QrCodeElement.finderPatternOuter,
        position: position)!;
    outerPaint.strokeWidth = metrics.pixelSize;
    outerPaint.color = appearance.markerStyle.color;
    final dotPaint = _paintCache.firstPaint(QrCodeElement.finderPatternDot,
        position: position);
    dotPaint!.color =
        appearance.markerDotStyle?.color ?? appearance.markerStyle.color;

    final gap = metrics.pixelSize +
        (max(1, appearance.markerStyle.gap) * metrics.pixelSize);
    final markerFrameSize = radius - gap;
    final markerFrameOffset = (radius - markerFrameSize) / 2;
    final markerOffset =
        metrics.finderPositionOffset(position, radius, strokeAdjust);
    final outerRect =
        Rect.fromLTWH(markerOffset.dx, markerOffset.dy, radius, radius);
    final markerFrameRect = Rect.fromLTWH(markerOffset.dx + markerFrameOffset,
        markerOffset.dy + markerFrameOffset, markerFrameSize, markerFrameSize);

    // draw the marker frame. NOTE: if the marker dot style is null (not
    // specified) then we will draw the dot here also. The dot style, in this
    // case, will mirror the style of the marker.
    if (appearance.markerStyle.shape == QrMarkerShape.square) {
      canvas.drawRect(outerRect, outerPaint);
      // no marker dot style, draw the dot to match.
      if (appearance.markerDotStyle == null) {
        canvas.drawRect(markerFrameRect, dotPaint);
      }
    } else {
      Radius rectRadius;
      Radius dotRadius;
      if (appearance.markerStyle.shape == QrMarkerShape.circle) {
        rectRadius = Radius.circular(radius);
        dotRadius = Radius.circular(markerFrameSize);
      } else {
        rectRadius = Radius.elliptical(radius * 0.3, radius * 0.3);
        dotRadius =
            Radius.elliptical(markerFrameSize * 0.3, markerFrameSize * 0.3);
      }
      canvas.drawRRect(
          RRect.fromRectAndRadius(outerRect, rectRadius), outerPaint);
      // no marker dot style, draw the dot to match.
      if (appearance.markerDotStyle == null) {
        canvas.drawRRect(
            RRect.fromRectAndRadius(markerFrameRect, dotRadius), dotPaint);
      }
    }

    // if the marker dot style has been defined, we will draw the dot now.
    var dotStyle = appearance.markerDotStyle;
    if (dotStyle != null) {
      if (dotStyle.shape == QrMarkerDotShape.square) {
        canvas.drawRect(markerFrameRect, dotPaint);
      } else {
        Radius dotRadius;
        if (dotStyle.shape == QrMarkerDotShape.circle) {
          dotRadius = Radius.circular(markerFrameSize);
        } else {
          dotRadius =
              Radius.elliptical(markerFrameSize * 0.3, markerFrameSize * 0.3);
        }
        canvas.drawRRect(
            RRect.fromRectAndRadius(markerFrameRect, dotRadius), dotPaint);
      }
    }
  }

  bool _hasOneNonZeroSide(Size size) => size.longestSide > 0;

  Size _scaledAspectSize(
      Size widgetSize, Size originalSize, Size? requestedSize) {
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
      Canvas canvas, Rect? drawRect, QrEmbeddedImageStyle? style) {
    if (drawRect == null) {
      return;
    }
    final paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high;
    if (style != null) {
      if (style.color != null) {
        paint.colorFilter = ColorFilter.mode(style.color!, BlendMode.srcATop);
      }
    }
    final srcSize =
        Size(embeddedImage!.width.toDouble(), embeddedImage!.height.toDouble());
    final src = Alignment.center.inscribe(srcSize, Offset.zero & srcSize);
    final dst = Alignment.center.inscribe(
        drawRect.size, Offset(drawRect.left, drawRect.top) & drawRect.size);
    canvas.drawImageRect(embeddedImage!, src, dst, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is QrPainter) {
      return oldDelegate.appearance != appearance ||
          oldDelegate.version != version ||
          oldDelegate.errorCorrectionLevel != errorCorrectionLevel ||
          oldDelegate.embeddedImage != embeddedImage;
    }
    return true;
  }

  /// Returns a [ui.Picture] object containing the QR code data.
  Future<ui.Picture> toPicture({
    required double size,
    Color? background,
    double? inset,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    _paintWithOverrides(canvas, Size(size, size), background, inset);
    return recorder.endRecording();
  }

  /// Returns the raw QR code [ui.Image] object.
  Future<ui.Image> toImage(
    double size, {
    ui.ImageByteFormat format = ui.ImageByteFormat.png,
    Color? background,
    double? inset,
  }) async {
    final picture =
        await toPicture(size: size, background: background, inset: inset);
    return picture.toImage(size.toInt(), size.toInt());
  }

  /// Returns the raw QR code image byte data.
  Future<ByteData?> toImageData(
    double size, {
    ui.ImageByteFormat format = ui.ImageByteFormat.png,
    Color? background,
    double? inset,
  }) async {
    final image = await toImage(size,
        format: format, background: background, inset: inset);
    return image.toByteData(format: format);
  }
}
