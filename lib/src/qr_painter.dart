/*
 * QR.Flutter
 * Copyright (c) 2022 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'paint_cache.dart';

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
  })  : _qr = qr,
        version = qr.typeNumber,
        errorCorrectionLevel = qr.errorCorrectLevel,
        _isGapless = appearance.gapSize == 0 {
    _calcVersion = version;
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

  bool _needsRepaint = true;

  /// The base QR code data
  QrCode? _qr;

  ColorMatrix? _colorMatrix;

  /// QR Image renderer
  late QrImage _qrImage;

  /// This is the version (after calculating) that we will use if the user has
  /// requested the 'auto' version.
  late final int _calcVersion;

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
    _calcVersion = _qr!.typeNumber;
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
              if (y > 0) {
                print(y % 4);
              }
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
    _needsRepaint = false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // if the widget has a zero size side then we cannot continue painting.
    if (size.shortestSide == 0) {
      print("[QR] WARN: width or height is zero. You should set a 'size' value "
          "or nest this painter in a Widget that defines a non-zero size");
      return;
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

    final paintMetrics = _PaintMetrics(
      containerSize: size.shortestSide,
      moduleCount: _qr!.moduleCount,
      gapSize: appearance.gapSize.toDouble(),
    );

    // draw the finder pattern elements
    _drawFinderPatternItem(FinderPatternPosition.topLeft, canvas, paintMetrics);
    _drawFinderPatternItem(
        FinderPatternPosition.bottomLeft, canvas, paintMetrics);
    _drawFinderPatternItem(
        FinderPatternPosition.topRight, canvas, paintMetrics);

    // DEBUG: draw the inner content boundary
    // final paint = Paint()..style = ui.PaintingStyle.stroke;
    // paint.strokeWidth = 1;
    // paint.color = const Color(0x55222222);
    // canvas.drawRect(
    //     Rect.fromLTWH(paintMetrics.inset, paintMetrics.inset,
    //         paintMetrics.innerContentSize, paintMetrics.innerContentSize),
    //     paint);

    double left;
    double top;
    // tracks where you are in the sequence of colors (if mode == sequence).
    var seqIdx = 0;
    // get the painters for the pixel information
    final pixelPaint = _paintCache.firstPaint(QrCodeElement.codePixel);
    for (var y = 0; y < _qr!.moduleCount; y++) {
      for (var x = 0; x < _qr!.moduleCount; x++) {
        // draw the finder patterns independently
        if (_isFinderPatternPosition(x, y)) continue;
        if (!_qrImage.isDark(y, x)) continue;
        // paint a pixel
        left = paintMetrics.inset +
            (x * (paintMetrics.pixelSize + appearance.gapSize));
        top = paintMetrics.inset +
            (y * (paintMetrics.pixelSize + appearance.gapSize));

        final squareRect = Rect.fromLTWH(
          left,
          top,
          paintMetrics.pixelSize,
          paintMetrics.pixelSize,
        );

        var pixelColor = Color(0xFF000000);
        final colors = appearance.moduleStyle.colors;
        if (colors != null && colors.length > 1) {
          pixelColor = _colorMatrix![x][y]!;
        } else if (colors != null) {
          pixelColor = colors.first!;
        }

        //
        if (imageRect != null &&
            appearance.embeddedImageStyle?.drawOverModules == false &&
            squareRect.overlaps(imageRect)) {
          continue;
        }

        pixelPaint!.color = pixelColor;
        pixelPaint.isAntiAlias = !(_isGapless &&
            appearance.moduleStyle.shape == QrDataModuleShape.square);

        if (appearance.moduleStyle.shape == null ||
            appearance.moduleStyle.shape == QrDataModuleShape.square) {
          canvas.drawRect(squareRect, pixelPaint);
        } else if (appearance.moduleStyle.shape == QrDataModuleShape.diamond) {
          // const diamondRect = null;
        } else {
          Radius radius;
          if (appearance.moduleStyle.shape == QrDataModuleShape.circle) {
            radius = Radius.circular(paintMetrics.pixelSize);
          } else {
            radius = Radius.elliptical(
                paintMetrics.pixelSize * 0.4, paintMetrics.pixelSize * 0.4);
          }
          final roundedRect = RRect.fromRectAndRadius(squareRect, radius);
          canvas.drawRRect(roundedRect, pixelPaint);
        }
      }
    }

    if (embeddedImage != null) {
      // draw the image overlay.
      _drawImageOverlay(canvas, imageRect, appearance.embeddedImageStyle);
    }
  }

  bool _hasAdjacentVerticalPixel(int x, int y, int moduleCount) {
    if (y + 1 >= moduleCount) return false;
    return _qrImage.isDark(y + 1, x);
  }

  bool _hasAdjacentHorizontalPixel(int x, int y, int moduleCount) {
    if (x + 1 >= moduleCount) return false;
    return _qrImage.isDark(y, x + 1);
  }

  bool _isFinderPatternPosition(int x, int y) {
    final isTopLeft = (y < _finderPatternLimit && x < _finderPatternLimit);
    final isBottomLeft = (y < _finderPatternLimit &&
        (x >= _qr!.moduleCount - _finderPatternLimit));
    final isTopRight = (y >= _qr!.moduleCount - _finderPatternLimit &&
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
        position: position)!;
    outerPaint.strokeWidth = metrics.pixelSize;
    outerPaint.color = appearance.markerStyle.color;

    final dotPaint = _paintCache.firstPaint(QrCodeElement.finderPatternDot,
        position: position);
    dotPaint!.color =
        appearance.markerDotStyle?.color ?? appearance.markerStyle.color;

    final outerRect = Rect.fromLTWH(offset.dx, offset.dy, radius, radius);
    final gap = metrics.pixelSize * 2;
    final dotSize = radius - gap - (2 * strokeAdjust);
    final dotRect = Rect.fromLTWH(offset.dx + metrics.pixelSize + strokeAdjust,
        offset.dy + metrics.pixelSize + strokeAdjust, dotSize, dotSize);

    // draw the marker frame. NOTE: if the marker dot style is null (not
    // specified) then we will draw the dot here also. The dot style, in this
    // case, will mirror the style of the marker.
    if (appearance.markerStyle.shape == QrMarkerShape.square) {
      canvas.drawRect(outerRect, outerPaint);
      // no marker dot style, draw the dot to match.
      if (appearance.markerDotStyle == null) {
        canvas.drawRect(dotRect, dotPaint);
      }
    } else {
      Radius rectRadius;
      Radius dotRadius;
      if (appearance.markerStyle.shape == QrMarkerShape.circle) {
        rectRadius = Radius.circular(radius);
        dotRadius = Radius.circular(dotSize);
      } else {
        rectRadius = Radius.elliptical(radius * 0.3, radius * 0.3);
        dotRadius = Radius.elliptical(dotSize * 0.3, dotSize * 0.3);
      }
      canvas.drawRRect(
          RRect.fromRectAndRadius(outerRect, rectRadius), outerPaint);
      // no marker dot style, draw the dot to match.
      if (appearance.markerDotStyle == null) {
        canvas.drawRRect(RRect.fromRectAndRadius(dotRect, dotRadius), dotPaint);
      }
    }

    // if the marker dot style has been defined, we will draw the dot now.

    var dotStyle = appearance.markerDotStyle;
    if (dotStyle != null) {
      if (dotStyle.shape == QrMarkerDotShape.square) {
        canvas.drawRect(dotRect, dotPaint);
      } else {
        Radius dotRadius;
        if (dotStyle.shape == QrMarkerDotShape.circle) {
          dotRadius = Radius.circular(dotSize);
        } else {
          dotRadius = Radius.elliptical(dotSize * 0.3, dotSize * 0.3);
        }
        canvas.drawRRect(RRect.fromRectAndRadius(dotRect, dotRadius), dotPaint);
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
  bool shouldRepaint(CustomPainter oldPainter) {
    return _needsRepaint;
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
  Future<ByteData?> toImageData(double size,
      {ui.ImageByteFormat format = ui.ImageByteFormat.png}) async {
    final image = await toImage(size, format: format);
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
    _pixelSize = (containerSize - gapTotal) / moduleCount;
    _innerContentSize = (_pixelSize * moduleCount) + gapTotal;
    _inset = (containerSize - _innerContentSize) / 2;
  }
}

class ColorMatrix {
  ColorMatrix({required int size})
      : _colors = List.generate(size, (index) => List.filled(size, null));

  final List<List<Color?>> _colors;

  void addAt(int x, int y, Color color) {
    _colors[x][y] = color;
  }

  List<Color?> operator [](int index) => _colors[index];
}
