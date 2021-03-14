/*
 * QR.Flutter
 * Copyright (c) 2021 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr/qr.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  testWidgets('QrImage generates correct image', (tester) async {
    final qrImage = MaterialApp(
      home: Center(
        child: RepaintBoundary(
          child: QrImage(
            data: 'This is a test image',
            version: QrVersions.auto,
            gapless: true,
            errorCorrectionLevel: QrErrorCorrectLevel.L,
          ),
        ),
      ),
    );
    await tester.pumpWidget(qrImage);
    await expectLater(
      find.byType(QrImage),
      matchesGoldenFile('./.golden/qr_image_golden.png'),
    );
  });

  testWidgets('QrImage generates correct image with eye style', (tester) async {
    final qrImage = MaterialApp(
      home: Center(
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
      ),
    );
    await tester.pumpWidget(qrImage);
    await expectLater(
      find.byType(QrImage),
      matchesGoldenFile('./.golden/qr_image_eye_styled_golden.png'),
    );
  });

  testWidgets('QrImage generates correct image with data module style',
      (tester) async {
    final qrImage = MaterialApp(
      home: Center(
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
      ),
    );
    await tester.pumpWidget(qrImage);
    await expectLater(
      find.byType(QrImage),
      matchesGoldenFile('./.golden/qr_image_data_module_styled_golden.png'),
    );
  });

  testWidgets('QrImage generates correct image with eye and data module sytle',
      (tester) async {
    final qrImage = MaterialApp(
      home: Center(
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
      ),
    );
    await tester.pumpWidget(qrImage);
    await expectLater(
      find.byType(QrImage),
      matchesGoldenFile('./.golden/qr_image_eye_data_module_styled_golden.png'),
    );
  });

  testWidgets(
      'QrImage does not apply eye and data module color when foreground '
      'color is also specified', (tester) async {
    final qrImage = MaterialApp(
      home: Center(
        child: RepaintBoundary(
          child: QrImage(
            data: 'This is a test image',
            version: QrVersions.auto,
            gapless: true,
            errorCorrectionLevel: QrErrorCorrectLevel.L,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.circle,
              color: Colors.red,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.circle,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(qrImage);
    await expectLater(
      find.byType(QrImage),
      matchesGoldenFile('./.golden/qr_image_foreground_colored_golden.png'),
    );
  });

  testWidgets('QrImage generates correct image with logo', (tester) async {
    await pumpWidgetWithImages(
      tester,
      MaterialApp(
        home: Center(
          child: RepaintBoundary(
            child: QrImage(
              data: 'This is a a qr code with a logo',
              version: QrVersions.auto,
              gapless: true,
              errorCorrectionLevel: QrErrorCorrectLevel.L,
              embeddedImage: FileImage(File('test/.images/logo_yakka.png')),
            ),
          ),
        ),
      ),
      ['test/.images/logo_yakka.png'],
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(QrImage),
      matchesGoldenFile('./.golden/qr_image_logo_golden.png'),
    );
  });
}

/// Pre-cache images to make sure they show up in golden tests.
///
/// See https://github.com/flutter/flutter/issues/36552 for more info.
Future<void> pumpWidgetWithImages(
  WidgetTester tester,
  Widget widget,
  List<String> assetNames,
) async {
  Future<void>? precacheFuture;
  await tester.pumpWidget(
    Builder(builder: (buildContext) {
      precacheFuture = tester.runAsync(() async {
        await Future.wait([
          for (final assetName in assetNames)
            precacheImage(FileImage(File(assetName)), buildContext),
        ]);
      });
      return widget;
    }),
  );
  await precacheFuture;
}

Widget buildTestableWidget(Widget widget) {
  return MediaQuery(data: MediaQueryData(), child: MaterialApp(home: widget));
}
