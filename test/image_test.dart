/*
 * QR.Flutter
 * Copyright (c) 2019 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */

import 'dart:io';

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

  testWidgets('QrImage generates correct image with eye style', (tester) async {
    final qrImage = Center(
      child: RepaintBoundary(
        child: QrImage(
          data: 'This is a test image',
          version: QrVersions.auto,
          gapless: true,
          errorCorrectionLevel: QrErrorCorrectLevel.L,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.circle,
            color: Colors.green,
          ),
        ),
      ),
    );
    await tester.pumpWidget(qrImage);
    await expectLater(
      find.byType(RepaintBoundary),
      matchesGoldenFile('./.golden/qr_image_eye_styled_golden.png'),
    );
  });

  testWidgets('QrImage generates correct image with data module style',
      (tester) async {
    final qrImage = Center(
      child: RepaintBoundary(
        child: QrImage(
          data: 'This is a test image',
          version: QrVersions.auto,
          gapless: true,
          errorCorrectionLevel: QrErrorCorrectLevel.L,
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.circle,
            color: Colors.blue,
          ),
        ),
      ),
    );
    await tester.pumpWidget(qrImage);
    await expectLater(
      find.byType(RepaintBoundary),
      matchesGoldenFile('./.golden/qr_image_data_module_styled_golden.png'),
    );
  });

  testWidgets('QrImage generates correct image with eye and data module sytle',
      (tester) async {
    final qrImage = Center(
      child: RepaintBoundary(
        child: QrImage(
          data: 'This is a test image',
          version: QrVersions.auto,
          gapless: true,
          errorCorrectionLevel: QrErrorCorrectLevel.L,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.circle,
            color: Colors.green,
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.circle,
            color: Colors.blue,
          ),
        ),
      ),
    );
    await tester.pumpWidget(qrImage);
    await expectLater(
      find.byType(RepaintBoundary),
      matchesGoldenFile('./.golden/qr_image_eye_data_module_styled_golden.png'),
    );
  });

  testWidgets('QrImage generates correct image with logo', (tester) async {
    final key = GlobalKey();
    final qrImage = Center(
      key: key,
      child: RepaintBoundary(
        child: QrImage(
          data: 'This is a a qr code with a logo',
          version: QrVersions.auto,
          gapless: true,
          errorCorrectionLevel: QrErrorCorrectLevel.L,
          embeddedImage: FileImage(File('test/.images/logo_yakka.png')),
        ),
      ),
    );

    await tester.pumpWidget(buildTestableWidget(qrImage));
    await tester.pump(Duration(seconds: 15));

    await expectLater(
      find.byKey(key),
      matchesGoldenFile('./.golden/qr_image_logo_golden.png'),
    );
  });
}

Widget buildTestableWidget(Widget widget) {
  return MediaQuery(data: MediaQueryData(), child: MaterialApp(home: widget));
}
