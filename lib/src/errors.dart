/*
 * QR.Flutter
 * Copyright (c) 2021 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */

import 'package:flutter/rendering.dart' show ImageProvider;

import 'qr_versions.dart';

/// An exception that is thrown when an invalid QR code version / type is
/// requested.
class QrUnsupportedVersionException implements Exception {
  /// Create a new QrUnsupportedVersionException.
  factory QrUnsupportedVersionException(int providedVersion) {
    final message =
        'Invalid version. $providedVersion is not >= ${QrVersions.min} '
        'and <= ${QrVersions.max}';
    return QrUnsupportedVersionException._internal(providedVersion, message);
  }

  QrUnsupportedVersionException._internal(this.providedVersion, this.message);

  /// The version you passed to the QR code operation.
  final int providedVersion;

  /// A message describing the exception state.
  final String message;

  @override
  String toString() => 'QrUnsupportedVersionException: $message';
}

/// An exception that is thrown when something goes wrong with the
/// [ImageProvider] for the embedded image of a QrImage or QrPainter.
class QrEmbeddedImageException implements Exception {
  /// Create a new QrEmbeddedImageException.
  factory QrEmbeddedImageException(String message) {
    return QrEmbeddedImageException._internal(message);
  }
  QrEmbeddedImageException._internal(this.message);

  /// A message describing the exception state.
  final String message;

  @override
  String toString() => 'QrEmbeddedImageException: $message';
}
