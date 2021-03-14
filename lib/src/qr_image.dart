/*
 * QR.Flutter
 * Copyright (c) 2019 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qr/qr.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'qr_painter.dart';
import 'qr_versions.dart';
import 'types.dart';
import 'validator.dart';

/// A widget that shows a QR code.
class QrImage extends StatefulWidget {
  /// Create a new QR code using the [String] data and the passed options (or
  /// using the default options).
  QrImage({
    required String data,
    Key? key,
    this.size,
    this.padding = const EdgeInsets.all(10.0),
    this.backgroundColor = Colors.transparent,
    this.foregroundColor,
    this.version = QrVersions.auto,
    this.errorCorrectionLevel = QrErrorCorrectLevel.L,
    this.errorStateBuilder,
    this.constrainErrorBounds = true,
    this.gapless = true,
    this.embeddedImage,
    this.embeddedImageStyle,
    this.semanticsLabel = 'qr code',
    this.eyeStyle = const QrEyeStyle(
      eyeShape: QrEyeShape.square,
      color: Colors.black,
    ),
    this.dataModuleStyle = const QrDataModuleStyle(
      dataModuleShape: QrDataModuleShape.square,
      color: Colors.black,
    ),
    this.embeddedImageEmitsError = false, this.blendEmbeddedImage=false,
  })  : assert(QrVersions.isSupportedVersion(version)),
        _data = data,
        _qrCode = null,
        super(key: key);

  /// Create a new QR code using the [QrCode] data and the passed options (or
  /// using the default options).
  QrImage.withQr({
    required QrCode qr,
    Key? key,
    this.size,
    this.padding = const EdgeInsets.all(10.0),
    this.backgroundColor = Colors.transparent,
    this.foregroundColor,
    this.version = QrVersions.auto,
    this.errorCorrectionLevel = QrErrorCorrectLevel.L,
    this.errorStateBuilder,
    this.constrainErrorBounds = true,
    this.gapless = true,
    this.embeddedImage,
    this.embeddedImageStyle,
    this.semanticsLabel = 'qr code',
    this.eyeStyle = const QrEyeStyle(
      eyeShape: QrEyeShape.square,
      color: Colors.black,
    ),
    this.dataModuleStyle = const QrDataModuleStyle(
      dataModuleShape: QrDataModuleShape.square,
      color: Colors.black,
    ),
    this.embeddedImageEmitsError = false, this.blendEmbeddedImage=false,
  })  : assert(QrVersions.isSupportedVersion(version)),
        _data = null,
        _qrCode = qr,
        super(key: key);

  // The data passed to the widget
  final String? _data;
  // The QR code data passed to the widget
  final QrCode? _qrCode;

  /// The background color of the final QR code widget.
  final Color backgroundColor;

  /// The foreground color of the final QR code widget.
  @Deprecated('use colors in eyeStyle and dataModuleStyle instead')
  final Color? foregroundColor;

  /// The QR code version to use.
  final int version;

  /// The QR code error correction level to use.
  final int errorCorrectionLevel;

  /// Embedded image will be blended into the qr code
  ///
  /// In layman terms, qr code will not be drawn behind embedded image so it
  /// looks like the image is part of the qr code.
  final bool blendEmbeddedImage;

  /// The external padding between the edge of the widget and the content.
  final EdgeInsets padding;

  /// The intended size of the widget.
  final double? size;

  /// The callback that is executed in the event of an error so that you can
  /// interrogate the exception and construct an alternative view to present
  /// to your user.
  final QrErrorBuilder? errorStateBuilder;

  /// If `true` then the error widget will be constrained to the boundary of the
  /// QR widget if it had been valid. If `false` the error widget will grow to
  /// the size it needs. If the error widget is allowed to grow, your layout may
  /// jump around (depending on specifics).
  ///
  /// NOTE: Setting a [size] value will override this setting and both the
  /// content widget and error widget will adhere to the size value.
  final bool constrainErrorBounds;

  /// If set to false, each of the squares in the QR code will have a small
  /// gap. Default is true.
  final bool gapless;

  /// The image data to embed (as an overlay) in the QR code. The image will
  /// be added to the center of the QR code.
  final ImageProvider? embeddedImage;

  /// Styling options for the image overlay.
  final QrEmbeddedImageStyle? embeddedImageStyle;

  /// If set to true and there is an error loading the embedded image, the
  /// [errorStateBuilder] callback will be called (if it is defined). If false,
  /// the widget will ignore the embedded image and just display the QR code.
  /// The default is false.
  final bool embeddedImageEmitsError;

  /// [semanticsLabel] will be used by screen readers to describe the content of
  /// the qr code.
  /// Default is 'qr code'.
  final String semanticsLabel;

  /// Styling option for QR Eye ball and frame.
  final QrEyeStyle eyeStyle;

  /// Styling option for QR data module.
  final QrDataModuleStyle dataModuleStyle;

  @override
  _QrImageState createState() => _QrImageState();
}

class _QrImageState extends State<QrImage> {
  /// The QR code string data.
  QrCode? _qr;

  /// The current validation status.
  late QrValidationResult _validationResult;

  @override
  Widget build(BuildContext context) {
    if (widget._data != null) {
      _validationResult = QrValidator.validate(
        data: widget._data!,
        version: widget.version,
        errorCorrectionLevel: widget.errorCorrectionLevel,
      );
      if (_validationResult.isValid) {
        _qr = _validationResult.qrCode;
      } else {
        _qr = null;
      }
    } else if (widget._qrCode != null) {
      _qr = widget._qrCode;
      _validationResult =
          QrValidationResult(status: QrValidationStatus.valid, qrCode: _qr);
    }
    return LayoutBuilder(builder: (context, constraints) {
      // validation failed, show an error state widget if builder is present.
      if (!_validationResult.isValid) {
        return _errorWidget(context, constraints, _validationResult.error);
      }
      // no error, build the regular widget
      final widgetSize = widget.size ?? constraints.biggest.shortestSide;
      if (widget.embeddedImage != null) {
        // if requesting to embed an image then we need to load via a
        // FutureBuilder because the image provider will be async.
        return FutureBuilder<ui.Image>(
          future: _loadQrImage(context, widget.embeddedImageStyle),
          builder: (ctx, snapshot) {
            if (snapshot.error != null) {
              print("snapshot error: ${snapshot.error}");
              if (widget.embeddedImageEmitsError) {
                return _errorWidget(context, constraints, snapshot.error);
              } else {
                return _qrWidget(context, null, widgetSize);
              }
            }
            if (snapshot.hasData) {
              print('loaded image');
              final loadedImage = snapshot.data;
              return _qrWidget(context, loadedImage, widgetSize);
            } else {
              return Container();
            }
          },
        );
      } else {
        return _qrWidget(context, null, widgetSize);
      }
    });
  }

  Widget _qrWidget(BuildContext context, ui.Image? image, double edgeLength) {
    final painter = QrPainter.withQr(
      qr: _qr!,
      color: widget.foregroundColor,
      gapless: widget.gapless,
      embeddedImageStyle: widget.embeddedImageStyle,
      embeddedImage: image,
      blendEmbeddedImage: widget.blendEmbeddedImage,
      eyeStyle: widget.eyeStyle,
      dataModuleStyle: widget.dataModuleStyle,
    );
    return _QrContentView(
      edgeLength: edgeLength,
      backgroundColor: widget.backgroundColor,
      padding: widget.padding,
      semanticsLabel: widget.semanticsLabel,
      child: CustomPaint(painter: painter),
    );
  }

  Widget _errorWidget(
      BuildContext context, BoxConstraints constraints, Object? error) {
    final errorWidget = widget.errorStateBuilder == null
        ? Container()
        : widget.errorStateBuilder!(context, error);
    final errorSideLength = (widget.constrainErrorBounds
        ? widget.size ?? constraints.biggest.shortestSide
        : constraints.biggest.longestSide);
    return _QrContentView(
      edgeLength: errorSideLength,
      backgroundColor: widget.backgroundColor,
      padding: widget.padding,
      child: errorWidget,
      semanticsLabel: widget.semanticsLabel,
    );
  }

  late ImageStreamListener streamListener;
  Future<ui.Image> _loadQrImage(
      BuildContext buildContext, QrEmbeddedImageStyle? style) async {
    if (style != null) {}

    final mq = MediaQuery.of(buildContext);
    final completer = Completer<ui.Image>();
    final stream = widget.embeddedImage!.resolve(ImageConfiguration(
      devicePixelRatio: mq.devicePixelRatio,
    ));

    streamListener = ImageStreamListener((info, err) {
      stream.removeListener(streamListener);
      completer.complete(info.image);
    }, onError: (dynamic err, _) {
      stream.removeListener(streamListener);
      completer.completeError(err);
    });
    stream.addListener(streamListener);
    return completer.future;
  }
}

/// A function type to be called when any form of error occurs while
/// painting a [QrImage].
typedef QrErrorBuilder = Widget Function(BuildContext context, Object? error);

class _QrContentView extends StatelessWidget {
  _QrContentView({
    required this.edgeLength,
    required this.child,
    this.backgroundColor,
    this.padding,
    this.semanticsLabel,
  });

  /// The length of both edges (because it has to be a square).
  final double edgeLength;

  /// The background color of the containing widget.
  final Color? backgroundColor;

  /// The padding that surrounds the child widget.
  final EdgeInsets? padding;

  /// The child widget.
  final Widget child;

  /// [semanticsLabel] will be used by screen readers to describe the content of
  /// the qr code.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      child: Container(
        width: edgeLength,
        height: edgeLength,
        color: backgroundColor,
        child: Padding(
          padding: padding!,
          child: child,
        ),
      ),
    );
  }
}
