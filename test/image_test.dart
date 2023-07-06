/*
 * QR.Flutter
 * Copyright (c) 2019 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  testWidgets('QrImageView generates correct image', (
    tester,
  ) async {
    final qrImage = MaterialApp(
      home: Center(
        child: RepaintBoundary(
          child: QrImageView(
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
      find.byType(QrImageView),
      matchesGoldenFile('./.golden/qr_image_golden.png'),
    );
  });

  testWidgets(
    'QrImageView generates correct image with eye style',
    (tester) async {
      final qrImage = MaterialApp(
        home: Center(
          child: RepaintBoundary(
            child: QrImageView(
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
        find.byType(QrImageView),
        matchesGoldenFile('./.golden/qr_image_eye_styled_golden.png'),
      );
    },
  );

  testWidgets(
    'QrImageView generates correct image with data module style',
    (tester) async {
      final qrImage = MaterialApp(
        home: Center(
          child: RepaintBoundary(
            child: QrImageView(
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
        find.byType(QrImageView),
        matchesGoldenFile('./.golden/qr_image_data_module_styled_golden.png'),
      );
    },
  );

  testWidgets(
    'QrImageView generates correct image with eye and data module sytle',
    (tester) async {
      final qrImage = MaterialApp(
        home: Center(
          child: RepaintBoundary(
            child: QrImageView(
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
        find.byType(QrImageView),
        matchesGoldenFile(
          './.golden/qr_image_eye_data_module_styled_golden.png',
        ),
      );
    },
  );

  testWidgets(
    'QrImageView does not apply eye and data module color when foreground '
    'color is also specified',
    (tester) async {
      final qrImage = MaterialApp(
        home: Center(
          child: RepaintBoundary(
            child: QrImageView(
              data: 'This is a test image',
              version: QrVersions.auto,
              gapless: true,
              // ignore: deprecated_member_use_from_same_package
              foregroundColor: Colors.red,
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
        find.byType(QrImageView),
        matchesGoldenFile('./.golden/qr_image_foreground_colored_golden.png'),
      );
    },
  );

  testWidgets(
    'QrImageView generates correct image with logo',
    (tester) async {
      await pumpWidgetWithImages(
        tester,
        MaterialApp(
          home: Center(
            child: RepaintBoundary(
              child: QrImageView(
                data: 'This is a a qr code with a logo',
                version: QrVersions.auto,
                gapless: true,
                errorCorrectionLevel: QrErrorCorrectLevel.L,
                embeddedImage: FileImage(File('test/.images/logo_yakka.png')),
              ),
            ),
          ),
        ),
        <String>['test/.images/logo_yakka.png'],
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(QrImageView),
        matchesGoldenFile('./.golden/qr_image_logo_golden.png'),
      );
    },
  );

  testWidgets(
    'QrImageView rounded generates correct image',
    (tester) async {
      final qrImage = MaterialApp(
        home: Center(
          child: RepaintBoundary(
            child: QrImageView(
              data: 'This is a a qr code with a logo',
              gapless: true,
              version: QrVersions.auto,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.squareRounded,
                radius: 15,
                color: Colors.green,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.squareRounded,
                color: Colors.black,
                radius: 3,
              ),
            ),
          ),
        ),
      );
      await tester.pumpWidget(qrImage);
      await expectLater(
        find.byType(QrImageView),
        matchesGoldenFile(
          './.golden/qr_image_rounded_golden.png',
        ),
      );
    },
  );

  testWidgets(
    'QrImageView rounded generates correct image with logo',
    (tester) async {
      await pumpWidgetWithImages(
        tester,
        MaterialApp(
          home: Center(
            child: RepaintBoundary(
              child: QrImageView(
                data: 'This is a a qr code with a logo',
                gapless: true,
                version: QrVersions.auto,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.squareRounded,
                  radius: 15,
                  color: Colors.green,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.squareRounded,
                  color: Colors.black,
                  radius: 3,
                ),
                size: 320.0,
                embeddedImage: FileImage(File('test/.images/logo_yakka.png')),
                embeddedImageStyle: const QrEmbeddedImageStyle(
                  size: Size.square(60),
                ),
              ),
            ),
          ),
        ),
        <String>['test/.images/logo_yakka.png'],
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(QrImageView),
        matchesGoldenFile('./.golden/qr_image_rounded_logo_golden.png'),
      );
    },
  );

  testWidgets(
    'QrImageView rounded generates correct image with logo & border color',
    (tester) async {
      await pumpWidgetWithImages(
        tester,
        MaterialApp(
          home: Center(
            child: RepaintBoundary(
              child: QrImageView(
                data: 'This is a a qr code with a logo',
                gapless: true,
                version: QrVersions.auto,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.squareRounded,
                  radius: 15,
                  color: Colors.green,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.squareRounded,
                  color: Colors.black,
                  radius: 3,
                ),
                size: 320.0,
                embeddedImage: FileImage(File('test/.images/logo_yakka.png')),
                embeddedImageStyle: const QrEmbeddedImageStyle(
                  size: Size.square(60),
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ),
        <String>['test/.images/logo_yakka.png'],
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(QrImageView),
        matchesGoldenFile(
          './.golden/qr_image_rounded_logo_border_color_golden.png',
        ),
      );
    },
  );
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
    Builder(
      builder: (buildContext) {
        precacheFuture = tester.runAsync(() async {
          await Future.wait(<Future<void>>[
            for (final String assetName in assetNames)
              precacheImage(FileImage(File(assetName)), buildContext),
          ]);
        });
        return widget;
      },
    ),
  );
  await precacheFuture;
}

Widget buildTestableWidget(Widget widget) {
  return MediaQuery(
    data: const MediaQueryData(),
    child: MaterialApp(home: widget),
  );
}
