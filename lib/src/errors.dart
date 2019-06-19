import 'package:qr_flutter/src/qr_versions.dart';

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
