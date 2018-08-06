import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:qr/qr.dart';

import 'qr_painter.dart';

class QrImage extends StatelessWidget {
  QrImage({
    @required String data,
    this.size,
    this.padding = const EdgeInsets.all(10.0),
    this.backgroundColor,
    Color foregroundColor = const Color(0xFF000000),
    int version = 4,
    int errorCorrectionLevel = QrErrorCorrectLevel.L,
    this.onError,
  }) : _painter = new QrPainter(data, foregroundColor, version, errorCorrectionLevel, onError: onError);

  final QrPainter _painter;
  final Color backgroundColor;
  final EdgeInsets padding;
  final double size;
  final QrError onError;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double widgetSize = size ?? constraints.biggest.shortestSide;
        return new Container(
          width: widgetSize,
          height: widgetSize,
          color: backgroundColor,
          child: new Padding(
            padding: this.padding,
            child: new CustomPaint(
              painter: _painter,
            ),
          ),
        );
      },
    );
  }
}
