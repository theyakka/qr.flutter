import 'dart:typed_data' show ByteData, Uint8List;
import 'dart:ui' as ui show Codec, Image;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qr/qr.dart';

class QrImageProvider extends ImageProvider<QrImageProvider> {
  const QrImageProvider(this.data,
      {this.width = 1024,
      this.errorImage,
      this.gapless = true,
      this.scale = 1.0,
      this.version = 4,
      this.errorCorrectionLevel = QrErrorCorrectLevel.L,
      this.emptyColor = Colors.transparent})
      : assert(data != null),
        assert(scale != null);

  final String data;
  final int width;
  final Uint8List errorImage;

  final bool gapless;
  final double scale;
  final int version;
  final int errorCorrectionLevel;
  final Color emptyColor;

  @override
  ImageStreamCompleter load(QrImageProvider key) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key),
      scale: key.scale,
    );
  }

  @override
  Future<QrImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<QrImageProvider>(this);
  }

  Future<ui.Codec> _loadAsync(QrImageProvider key) async {
    assert(key == this);

    final QrCode qr = QrCode(version, errorCorrectionLevel);

    final Paint _paint = Paint()..style = PaintingStyle.fill;

    final PictureRecorder recorder = PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    if (emptyColor != null) {
      canvas.drawColor(emptyColor, BlendMode.color);
    }

    try {
      qr.addData(data);
      qr.make();
    } catch (e) {
      debugPrint('[QrImageProvider] error $e');

      if (errorImage != null) {
        return PaintingBinding.instance.instantiateImageCodec(errorImage);
      }

      return Future<ui.Codec>.error(
          ArgumentError('An error was thrown but no errorImage was provided.'));
    }

    final double squareSize = width / qr.moduleCount.toDouble();
    final int pxAdjustValue = gapless ? 1 : 0;

    for (int x = 0; x < qr.moduleCount; x++) {
      for (int y = 0; y < qr.moduleCount; y++) {
        if (qr.isDark(y, x)) {
          final Rect squareRect = Rect.fromLTWH(x * squareSize, y * squareSize,
              squareSize + pxAdjustValue, squareSize + pxAdjustValue);
          canvas.drawRect(squareRect, _paint);
        }
      }
    }

    final Picture picture = recorder.endRecording();

    final ui.Image image = await picture.toImage(width, width);
    final ByteData byteData =
        await image.toByteData(format: ImageByteFormat.png);
    final Uint8List bytes = byteData.buffer.asUint8List();

    return PaintingBinding.instance.instantiateImageCodec(bytes);
  }
}
