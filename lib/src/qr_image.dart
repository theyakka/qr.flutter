/*
 * QR.Flutter
 * Copyright (c) 2019 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qr/qr.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'qr_painter.dart';
import 'qr_versions.dart';

/// A widget that shows a QR code.
class QrImage extends StatelessWidget {
  /// Create a new QR code with the passed options (or using the default
  /// options).
  QrImage({
    @required this.data,
    Key key,
    this.size,
    this.padding = const EdgeInsets.all(10.0),
    this.backgroundColor = const Color(0x00FFFFFF),
    this.foregroundColor = const Color(0xFF000000),
    this.version = QrVersions.auto,
    this.errorCorrectionLevel = QrErrorCorrectLevel.L,
    this.errorStateBuilder,
    this.constrainErrorBounds = true,
    this.gapless = true,
  })  : assert(QrVersions.isSupportedVersion(version)),
        super(key: key);

  /// The QR code string data.
  final String data;

  /// The background color of the final QR code widget.
  final Color backgroundColor;

  /// The foreground color of the final QR code widget.
  final Color foregroundColor;

  /// The QR code version to use.
  final int version;

  /// The QR code error correction level to use.
  final int errorCorrectionLevel;

  /// The external padding between the edge of the widget and the content.
  final EdgeInsets padding;

  /// The intended size of the widget.
  final double size;

  /// The callback that is executed in the event of an error so that you can
  /// interrogate the exception and construct an alternative view to present
  /// to your user.
  final QrErrorBuilder errorStateBuilder;

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

  @override
  Widget build(BuildContext context) {
    final validationResult = QrValidator.validate(data: data);
    return LayoutBuilder(builder: (context, constraints) {
      if (!validationResult.isValid) {
        Widget errorWidget = Container();
        if (errorStateBuilder != null) {
          errorWidget =
              errorStateBuilder(context, validationResult.error) ?? Container();
        }
        final errorWidgetSize = size ??
            (constrainErrorBounds
                ? constraints.biggest.shortestSide
                : constraints.biggest.longestSide);
        return _qrContentWidget(errorWidget, errorWidgetSize);
      }
      final widgetSize = size ?? constraints.biggest.shortestSide;
      final painter = QrPainter.withQr(
        qr: validationResult.qrCode,
        color: foregroundColor,
        gapless: gapless,
      );
      return _qrContentWidget(CustomPaint(painter: painter), widgetSize);
    });
  }

  Widget _qrContentWidget(Widget child, double size) {
    return Container(
      width: size,
      height: size,
      color: backgroundColor,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

typedef QrErrorBuilder = Widget Function(BuildContext context, Exception error);
