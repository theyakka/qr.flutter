/*
 * QR.Flutter
 * Copyright (c) 2019 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:qr/qr.dart';

import 'qr_painter.dart';

typedef ErrorBuilder = Widget Function(BuildContext context, dynamic error);

class QrImage extends StatelessWidget {
  QrImage({
    @required this.data,
    this.errorBuilder,
    Key key,
    this.size,
    this.padding = const EdgeInsets.all(10.0),
    this.backgroundColor,
    this.version = 4,
    this.errorCorrectionLevel = QrErrorCorrectLevel.L,
    this.gapless = true,
  }) : super(key: key);

  final String data;
  final ErrorBuilder errorBuilder;
  final Color backgroundColor;
  final EdgeInsets padding;
  final double size;
  final bool gapless;
  final int version;
  final int errorCorrectionLevel;

  @override
  Widget build(BuildContext context) {
    final QrCode qr = QrCode(version, errorCorrectionLevel);

    bool hasError = false;
    dynamic error;

    try {
      qr.addData(data);
      qr.make();
      hasError = false;
    } catch (e) {
      hasError = true;
      error = e;
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double widgetSize = size ?? constraints.biggest.shortestSide;
        return Container(
          width: widgetSize,
          height: widgetSize,
          color: backgroundColor,
          child: Padding(
            padding: padding,
            child: hasError
                ? errorBuilder(context, error)
                : CustomPaint(
                    painter: QrPainter(
                      qr: qr,
                      gapless: gapless,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
