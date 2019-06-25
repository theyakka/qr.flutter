import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr/qr.dart';
import 'package:qr_flutter/src/qr_painter.dart';

void main() {
  testWidgets('Painter generates an image', (WidgetTester tester) async {
    const int version = 4;
    const int errorCorrectionLevel = QrErrorCorrectLevel.L;
    const String data = 'This is a test image';

    final QrCode qr = QrCode(version, errorCorrectionLevel)
      ..addData(data)
      ..make();

    await tester.runAsync(() async {
      final QrPainter painter = QrPainter(
        qr: qr,
        emptyColor: const Color(0xffffffff),
        gapless: true,
      );
      final ByteData imageData = await painter.toImageData(300.0);
      File file = File('./test_image.png');
      file = await file.writeAsBytes(imageData.buffer.asUint8List());
      final int len = await file.length();
      expect(len, greaterThan(0));
    });
  });
}
