/*
 * QR.Flutter
 * Copyright (c) 2021 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */

/// This class only contains special version codes. QR codes support version
/// numbers from 1-40 and you should just use the numeric version directly.
class QrVersions {
  /// Automatically determine the QR code version based on input and an
  /// error correction level.
  static const int auto = -1;

  /// The minimum supported version code.
  static const int min = 1;

  /// The maximum supported version code.
  static const int max = 40;

  /// Checks to see if the supplied version is a valid QR code version
  static bool isSupportedVersion(int version) =>
      version == auto || (version >= min && version <= max);
}
