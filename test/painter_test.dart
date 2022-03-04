/*
 * QR.Flutter
 * Copyright (c) 2022 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  testWidgets("QrPainter is working", (tester) async {
    final key = const Key("mainWidget");
    final painter = MaterialApp(
      home: RepaintBoundary(
        child: AspectRatio(
          aspectRatio: 1,
          child: SizedBox(
            width: 300,
            height: 300,
            child: CustomPaint(
              key: key,
              painter: QrPainter(
                data: 'The painter is this thing',
                version: QrVersions.auto,
                errorCorrectionLevel: QrErrorCorrectLevel.L,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(painter);
    await expectLater(
      find.byKey(key),
      matchesGoldenFile('./.golden/qr_painter_golden.png'),
    );
  });

  testWidgets('QrPainter generates correct image', (tester) async {
    final painter = QrPainter(
      data: 'The painter is this thing',
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );
    ByteData? imageData;
    await tester.runAsync(() async {
      imageData = await painter.toImageData(600.0);
    });
    final imageBytes = imageData!.buffer.asUint8List();
    final widget = Center(
      child: RepaintBoundary(
        child: SizedBox(
          width: 600,
          height: 600,
          child: Image.memory(imageBytes),
        ),
      ),
    );
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary),
      matchesGoldenFile('./.golden/qr_painter_golden_2.png'),
    );
  });
}
