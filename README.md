<img src="https://storage.googleapis.com/product-logos/logo_qr_flutter.png" align="center" width="200">

QR.Flutter is a Flutter library for simple and fast QR code rendering via a Widget or custom painter.

# Need help?

Please do not submit an issue for a "How do i ..?" or "What is the deal with ..?" type question. They will pretty much be closed instantly. If you have questions, please ask them on the Discussions board or on Stack Overflow. They will get answered there.

Using issues creates a large amount of noise and results in real issues getting fixed slower.

# Features
- Null safety
- Built on [QR - Dart](https://github.com/kevmoo/qr.dart)
- Automatic QR code version/type detection or manual entry 
- Supports QR code versions 1 - 40
- Error correction / redundancy
- Configurable output size, padding, background and foreground colors
- Supports image overlays
- Export to image data to save to file or use in memory
- No internet connection required

# Installing

**Version compatibility**: 4.0.0+ supports null safety and requires a version of Flutter that is compatible.
If you're using an incompatible version of flutter, please use a 3.x version of this library.

You should add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  qr_flutter: ^4.0.0
```

**Note**: If you're using the Flutter `master` channel, if you encounter build issues, or want to try the latest and greatest then you should use the `master` branch and not a specific release version. To do so, use the following configuration in your `pubspec.yaml`:
 
```yaml
dependencies:
  qr_flutter:
    git:
      url: git://github.com/lukef/qr.flutter.git
```

Keep in mind the `master` branch could be unstable.

After adding the dependency to your `pubspec.yaml` you can run: `flutter packages get` or update your packages using
your IDE.

# Getting started
To start, import the dependency in your code:

```dart
import 'package:qr_flutter/qr_flutter.dart';
```

Next, to render a basic QR code you can use the following code (or something like it):

```dart
QrImage(
  data: "1234567890",
  version: QrVersions.auto,
  size: 200.0,
),
```

Depending on your data requirements you may want to tweak the QR code output. The following options are available:

| Property | Type | Description |
|----|----|----|
| `version` | int | `QrVersions.auto` or a value between 1 and 40. See http://www.qrcode.com/en/about/version.html for limitations and details. |
| `errorCorrectionLevel` | int | A value defined on `QrErrorCorrectLevel`. e.g.: `QrErrorCorrectLevel.L`. |
| `size` | double | The (square) size of the image. If not given, will auto size using shortest size constraint. |
| `padding` | EdgeInsets | Padding surrounding the QR code data. |
| `backgroundColor` | Color | The background color (default is none). |
| `foregroundColor` | Color | The foreground color (default is black). |
| `gapless` | bool | Adds an extra pixel in size to prevent gaps (default is true). |
| `errorStateBuilder` | QrErrorBuilder | Allows you to show an error state `Widget` in the event there is an error rendering the QR code (e.g.: version is too low, input is too long, etc). |
| `constrainErrorBounds` | bool | If true, the error `Widget` will be constrained to the square that the QR code was going to be drawn in. If false, the error state `Widget` will grow/shrink to whatever size it needs. |
| `embeddedImage` | ImageProvider | An `ImageProvider` that defines an image to be overlaid in the center of the QR code. |
| `embeddedImageStyle` | QrEmbeddedImageStyle | Properties to style the embedded image. |
| `embeddedImageEmitsError` | bool | If true, any failure to load the embedded image will trigger the `errorStateBuilder` or render an empty `Container`. If false, the QR code will be rendered and the embedded image will be ignored. |
|`semanticsLabel`|String|`semanticsLabel` will be used by screen readers to describe the content of the QR code.|
|`roundedImage`| bool | If true, image shows as a circular image with stock in the QR code.|
|`borderColor`| Color | The rounded image stock color in the QR code.|

# Examples

There is a simple, working, example Flutter app in the `/example` directory. You can use it to play with all
the options. 

Also, the following examples give you a quick overview on how to use the library.

A basic QR code will look something like:

```dart
QrImage(
  data: 'This is a simple QR code',
  version: QrVersions.auto,
  size: 320,
  gapless: false,
)
```

A QR code with an image (from your application's assets) will look like:

```dart
QrImage(
  data: 'This QR code has an embedded image as well',
  version: QrVersions.auto,
  size: 320,
  gapless: false,
  embeddedImage: AssetImage('assets/images/my_embedded_image.png'),
  embeddedImageStyle: QrEmbeddedImageStyle(
    size: Size(80, 80),
  ),
)
```

A QR code with an rounded image (from your application's assets) will look like:

```dart
QrImage(
  data: 'This QR code has an embedded image as well',
  version: QrVersions.auto,
  size: 320,
  gapless: false,
  embeddedImage: AssetImage('assets/images/my_embedded_image.png'),
  embeddedImageStyle: QrEmbeddedImageStyle(
    size: Size(80, 80),
  ),
  roundedImage: true,
  borderColor: Colors.green,
)
```

To show an error state in the event that the QR code can't be validated:

```dart
QrImage(
  data: 'This QR code will show the error state instead',
  version: 1,
  size: 320,
  gapless: false,
  errorStateBuilder: (cxt, err) {
    return Container(
      child: Center(
        child: Text(
          "Uh oh! Something went wrong...",
          textAlign: TextAlign.center,
        ),
      ),
    );
  },
)
```


# FAQ
## Has it been tested in production? Can I use it in production?

Yep! It's stable and ready to rock. It's currently in use in quite a few production applications including:
- Sixpoint: [Android](https://play.google.com/store/apps/details?id=com.sixpoint.sixpoint&hl=en_US) & [iOS](https://itunes.apple.com/us/app/sixpoint/id663008674?mt=8) 

# Outro
## Credits
Thanks to Kevin Moore for his awesome [QR - Dart](https://github.com/kevmoo/qr.dart) library. It's the core of this library.

For author/contributor information, see the `AUTHORS` file.

## License

QR.Flutter is released under a BSD-3 license. See `LICENSE` for details.
