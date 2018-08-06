<img src="https://storage.googleapis.com/product-logos/logo_qr_flutter.png" align="center" width="240">
<br/>
QR.Flutter is a Flutter library for simple and fast QR code rendering via a Widget or custom painter.

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
  qr_flutter: ^1.1.2
```

After adding the dependency to your `pubspec.yaml` you can run: `flutter packages get` or update your packages using
your IDE.

# Getting started
To start, import the dependency in your code:

```dart
import 'package:qr_flutter/qr_flutter.dart';
```

Next, to render a basic QR code you can use the following code (or something like it):

```dart
new QrImage(
  data: "1234567890",
  size: 200.0,
),
```

Depending on your data requirements you may want to tweak the QR code output. The following options are available:

| Property | Type | Description |
|----|----|----|
| `version` | int | A value between 1 and 40. See http://www.qrcode.com/en/about/version.html for details. |
| `errorCorrectionLevel` | int | A value defined on `QrErrorCorrectLevel`. e.g.: `QrErrorCorrectLevel.L`. |
| `size` | double | The (square) size of the image. If not given, will auto size using shortest size constraint. |
| `padding` | EdgeInsets | Padding surrounding the QR code data |
| `backgroundColor` | Color | The background color (default is none) |
| `foregroundColor` | Color | The foreground color (default is black) |

# Example
See the `example` directory for a basic working example.

# FAQ
## Has it been tested in production? Can I use it in production?

Yep! It's stable and ready to rock. It's currently in use in quite a few production applications including:
- Sixpoint: [Android](https://play.google.com/store/apps/details?id=com.sixpoint.sixpoint&hl=en_US) & [iOS](https://itunes.apple.com/us/app/sixpoint/id663008674?mt=8) 

# Outro
## Credits
Thanks to Kevin Moore for his awesome [QR - Dart](https://github.com/kevmoo/qr.dart) library. It's the core of this library.

For author/contributor information, see the `AUTHORS` file.

## License

QR.Flutter is released under a modified MIT license. See `LICENSE` for details.