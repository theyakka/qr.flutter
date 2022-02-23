/*
 * QR.Flutter
 * Copyright (c) 2022 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */

// ignore: avoid_classes_with_only_static_members
/// This class only contains special version codes and helpers. QR codes support
/// version numbers from 1-40 and you should just use the numeric version
/// directly.
class QrVersions {
  /// Automatically determine the QR code version based on input and an
  /// error correction level.
  static const int auto = -1;

  /// The minimum supported version code.
  static const int min = 1;

  /// The maximum supported version code.
  static const int max = 40;
}

/// Checks to see if the supplied version is a valid QR code version
bool isSupportedVersion(int version) =>
    version == QrVersions.auto ||
        (version >= QrVersions.min && version <= QrVersions.max);

