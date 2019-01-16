import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr/qr.dart';
import 'package:qr_flutter/src/qr_painter.dart';

void main() {
  testWidgets('Painter generates an image', (WidgetTester tester) async {
    await tester.runAsync(() async {
      final QrPainter painter = QrPainter(
        data: 'This is a test image',
        color: const Color(0xff222222),
        emptyColor: const Color(0xffffffff),
        version: 4,
        gapless: true,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );
      final ByteData imageData = await painter.toImageData(300.0);
      File file = File('./test_image.png');
      file = await file.writeAsBytes(imageData.buffer.asUint8List());
      final int len = await file.length();
      expect(len, greaterThan(0));
    });
  });
}
