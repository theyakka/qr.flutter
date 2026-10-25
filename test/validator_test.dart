/*
 * QR.Flutter
 * Copyright (c) 2019 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  test('QrValidator picks the smallest version that fits', () {
    final result = QrValidator.validate(
      data: 'This is a test image',
      errorCorrectionLevel: QrErrorCorrectLevel.high,
    );
    expect(result.status, QrValidationStatus.valid);
    expect(result.qrCode!.typeNumber, 3);
    expect(result.qrCode!.errorCorrectLevel, QrErrorCorrectLevel.high);
  });

  test('QrValidator keeps the requested version', () {
    final result = QrValidator.validate(data: 'abc', version: 5);
    expect(result.status, QrValidationStatus.valid);
    expect(result.qrCode!.typeNumber, 5);
  });

  test('QrValidator reports data too long for the requested version', () {
    final result = QrValidator.validate(
      data: 'This QR code will show the error state instead',
      version: 1,
    );
    expect(result.status, QrValidationStatus.contentTooLong);
    expect(result.qrCode, isNull);
    expect(result.error, isNotNull);
  });

  test('QrValidator reports data too long for any version', () {
    final result = QrValidator.validate(data: 'a' * 3000);
    expect(result.status, QrValidationStatus.contentTooLong);
    expect(result.error, isA<InputTooLongException>());
  });
}
