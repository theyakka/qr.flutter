/*
 * QR.Flutter
 * Copyright (c) 2019 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:qr/qr.dart';

import 'qr_painter.dart';
import 'qr_versions.dart';

/// A widget that shows a QR code.
class QrImage extends StatelessWidget {
  /// Create a new QR code with the passed options (or using the default
  /// options).
  QrImage({
    @required String data,
    Key key,
    this.size,
    this.padding = const EdgeInsets.all(10.0),
    this.backgroundColor = const Color(0x00FFFFFF),
    Color foregroundColor = const Color(0xFF000000),
    int version = QrVersions.auto,
    int errorCorrectionLevel = QrErrorCorrectLevel.L,
    this.onError,
    this.gapless = true,
  })  : assert(QrVersions.isSupportedVersion(version)),
        _painter = QrPainter(
            data: data,
            color: foregroundColor,
            version: version,
            errorCorrectionLevel: errorCorrectionLevel,
            gapless: gapless,
            onError: onError),
        super(key: key);

  final QrPainter _painter;

  /// The background color of the final QR code widget.
  final Color backgroundColor;

  /// The external padding between the edge of the widget and the content.
  final EdgeInsets padding;

  /// The intended size of the widget.
  final double size;

  /// The callback that is executed in the event of an error.
  final QrError onError;

  /// If set to false, each of the squares in the QR code will have a small
  /// gap. Default is true.
  final bool gapless;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final widgetSize = size ?? constraints.biggest.shortestSide;
        return Container(
          width: widgetSize,
          height: widgetSize,
          color: backgroundColor,
          child: Padding(
            padding: padding,
            child: CustomPaint(
              painter: _painter,
            ),
          ),
        );
      },
    );
  }
}
