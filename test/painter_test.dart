import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:qr/qr.dart';
import 'package:qr_flutter/src/qr_versions.dart';
import 'package:qr_flutter/src/qr_painter.dart';

void main() {
//  testWidgets('Painter generates an image', (tester) async {
//    await tester.runAsync(() async {
//      final painter = QrPainter(
//        data: 'This is a test image',
//        color: const Color(0xff222222),
//        emptyColor: const Color(0xffffffff),
//        version: 4,
//        gapless: true,
//        errorCorrectionLevel: QrErrorCorrectLevel.L,
//      );
//      final imageData = await painter.toImageData(300.0);
//      var file = await File('./test_image.png')
//          .writeAsBytes(imageData.buffer.asUint8List());
//      final len = await file.length();
//      expect(len, greaterThan(0));
//    });
//  });

  testWidgets('Painter (on auto) generates an image', (tester) async {
    await tester.runAsync(() async {
      final painter = QrPainter(
        data: 'This is a test image',
        color: const Color(0xff222222),
        emptyColor: const Color(0xffffffff),
        version: QrVersions.auto,
        gapless: true,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );
      final imageData = await painter.toImageData(300.0);
      var file = await File('./test_image.png')
          .writeAsBytes(imageData.buffer.asUint8List());
      final len = await file.length();
      expect(len, greaterThan(0));
    });
  });
}
