/*
 * QR.Flutter
 * Copyright (c) 2019 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart' show decodeImageFromList;
import 'package:flutter_test/flutter_test.dart';
import 'package:qr/qr.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  setUp(() async {
    final tempDir = Directory('./.temp');
    final exists = await tempDir.exists();
    if (!exists) {
      await tempDir.create(recursive: true);
    }
  });

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
    final logoUri = Uri.parse('./test/.images/logo_yakka.png');
    final imageData = File.fromUri(logoUri).readAsBytesSync();
    ui.Image image;
    await tester.runAsync(() async {
      image = await decodeImageFromList(imageData);
    });
    final qrImage = Center(
      child: RepaintBoundary(
        child: QrImage(
          data: 'This is a test image',
          version: QrVersions.auto,
          gapless: true,
          errorCorrectionLevel: QrErrorCorrectLevel.L,
          image: image,
        ),
      ),
    );
    await tester.pumpWidget(qrImage);
    await expectLater(
      find.byType(RepaintBoundary),
      matchesGoldenFile('./.golden/qr_image_logo_golden.png'),
    );
  });

  testWidgets('QrPainter generates correct image', (tester) async {
    final painter = QrPainter(
      data: 'The painter is this thing',
      version: QrVersions.auto,
      gapless: true,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
      color: const Color(0xFF000000),
    );
    final widget = FutureBuilder(
      future: painter.toImageData(600.0),
      builder: (ctx, snapshot) {
        final ByteData imageData = snapshot.data;
        final imageBytes = imageData.buffer.asUint8List();
        return Center(
          child: RepaintBoundary(
            child: Container(
              width: 600,
              height: 600,
              child: Image.memory(imageBytes),
            ),
          ),
        );
      },
    );
    await tester.pumpWidget(widget);
    await tester.pump();
    expect(
      find.byType(Image),
      matchesGoldenFile('./.golden/qr_painter_golden.png'),
    );
  });
}
