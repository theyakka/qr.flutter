/*
 * QR.Flutter
 * Copyright (c) 2019 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:qr/qr.dart';

import 'qr_painter.dart';

class QrImage extends StatelessWidget {
  QrImage({
    @required String data,
    Key key,
    this.size,
    this.padding = const EdgeInsets.all(10.0),
    this.backgroundColor,
    Color foregroundColor = const Color(0xFF000000),
    int version = 4,
    int errorCorrectionLevel = QrErrorCorrectLevel.L,
    this.onError,
    this.gapless = true,
  }) : _painter = QrPainter(
            data: data,
            color: foregroundColor,
            version: version,
            errorCorrectionLevel: errorCorrectionLevel,
            gapless: gapless,
            onError: onError
  ), super(key: key);

  final QrPainter _painter;
  final Color backgroundColor;
  final EdgeInsets padding;
  final double size;
  final QrError onError;
  final bool gapless;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double widgetSize = size ?? constraints.biggest.shortestSide;
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
