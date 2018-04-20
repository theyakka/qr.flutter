<img src="https://storage.googleapis.com/product-logos/logo_qr_flutter.png" align="center" width="182">

QR.Flutter is a QR code generation and rendering library for Flutter.

# Features
- Built on [QR - Dart](https://github.com/kevmoo/qr.dart)
- Supports QR code versions 1 - 40
- Error correction / redundancy
- Configurable output size, padding, background and foreground colors
- No internet connection required

# Installing

You can install the package by adding the following lines to your `pubspec.yaml`:

```yaml
dependencies:
  qr_flutter: ^1.1.1
```

After adding the dependency to your `pubspec.yaml` you can run: `pub get` or `flutter packages get` if you're using Flutter.

# Getting started

To start, import the dependency in your code:

```dart
import 'package:qr_flutter/qr_flutter.dart';
```

Next, to render a basic QR code you can do as such:

```dart
new QrImage(
  data: "1234567890",
  size: 200.0,
),
```

Depending on your data requirements you may want to tweak the QR code output:

| Property | Type | Description |
|----|----|----|
| `version` | int | A value between 1 and 40. See http://www.qrcode.com/en/about/version.html for details. |
| `errorCorrectionLevel` | int | A value defined on `QrErrorCorrectLevel`. e.g.: `QrErrorCorrectLevel.L`. |
| `size` | double | The (square) size of the image |
| `padding` | EdgeInsets | Padding surrounding the QR code data |
| `backgroundColor` | Color | The background color (default is none) |
| `foregroundColor` | Color | The foreground color (default is black) |

# Demo

See the `example` directory for a basic working example.

# Authors
 * [Luke Freeman](https://github.com/lukef) ([@lukeaf](http://twitter.com/lukeaf))
