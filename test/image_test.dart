import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr/qr.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  testWidgets('QrImage generates correct image', (tester) async {
    final qrImage = Center(
      child: RepaintBoundary(
        child: QrImage(
          data: 'This is a test image',
          version: QrVersions.auto,
          gapless: true,
          errorCorrectionLevel: QrErrorCorrectLevel.L,
        ),
      ),
    );
    await tester.pumpWidget(qrImage);
    await expectLater(
      find.byType(RepaintBoundary),
      matchesGoldenFile('./.golden/qr_image_golden.png'),
    );
  });

  testWidgets('QrImage generates correct image with logo', (tester) async {
    final qrImage = Center(
      child: RepaintBoundary(
        child: QrImage(
          data: 'This is a test image',
          version: QrVersions.auto,
          gapless: true,
          errorCorrectionLevel: QrErrorCorrectLevel.L,
          embeddedImage: AssetImage('assets/images/logo_yakka.png'),
        ),
      ),
    );
    await tester.pumpWidget(qrImage);
    await expectLater(
      find.byType(RepaintBoundary),
      matchesGoldenFile('./.golden/qr_image_logo_golden.png'),
    );
  });
}
