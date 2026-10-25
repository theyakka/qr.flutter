/*
 * QR.Flutter
 * Copyright (c) 2019 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */

// qr_flutter has its own QrValidationResult (see src/validator.dart).
export 'package:qr/qr.dart' hide QrValidationResult;

export 'src/errors.dart';
export 'src/qr_image_view.dart';
export 'src/qr_painter.dart';
export 'src/qr_versions.dart';
export 'src/types.dart';
export 'src/validator.dart';
