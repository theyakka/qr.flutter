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
  qr_flutter: ^4.1.0
```

**Note**: If you're using the Flutter `master` channel, if you encounter build issues, or want to try the latest and greatest then you should use the `master` branch and not a specific release version. To do so, use the following configuration in your `pubspec.yaml`:
 
```yaml
dependencies:
  qr_flutter:
    git:
      url: https://github.com/alexanderkind/qr.flutter
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
QrImageView(
  data: '1234567890',
  version: QrVersions.auto,
  size: 200.0,
),
```

Depending on your data requirements you may want to tweak the QR code output. The following options are available:

| Property                  | Type                 | Description                                                                                                                                                                                         |
|---------------------------|----------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `version`                 | int                  | `QrVersions.auto` or a value between 1 and 40. See http://www.qrcode.com/en/about/version.html for limitations and details.                                                                         |
| `errorCorrectionLevel`    | int                  | A value defined on `QrErrorCorrectLevel`. e.g.: `QrErrorCorrectLevel.L`.                                                                                                                            |
| `size`                    | double               | The (square) size of the image. If not given, will auto size using shortest size constraint.                                                                                                        |
| `padding`                 | EdgeInsets           | Padding surrounding the QR code data.                                                                                                                                                               |
| `backgroundColor`         | Color                | The background color (default is none).                                                                                                                                                             |
| `eyeStyle`                | QrEyeStyle           | Configures the QR code eyes' (corners') shape and color.                                                                                                                                            |
| `dataModuleStyle`         | QrDataModuleStyle    | Configures the shape and the color of the dots.                                                                                                                                                     |
| `gapless`                 | bool                 | Adds an extra pixel in size to prevent gaps (default is true).                                                                                                                                      |
| `errorStateBuilder`       | QrErrorBuilder       | Allows you to show an error state `Widget` in the event there is an error rendering the QR code (e.g.: version is too low, input is too long, etc).                                                 |
| `constrainErrorBounds`    | bool                 | If true, the error `Widget` will be constrained to the square that the QR code was going to be drawn in. If false, the error state `Widget` will grow/shrink to whatever size it needs.             |
| `embeddedImage`           | ImageProvider        | An `ImageProvider` that defines an image to be overlaid in the center of the QR code.                                                                                                               |
| `embeddedImageStyle`      | QrEmbeddedImageStyle | Properties to style the embedded image.                                                                                                                                                             |
| `embeddedImageEmitsError` | bool                 | If true, any failure to load the embedded image will trigger the `errorStateBuilder` or render an empty `Container`. If false, the QR code will be rendered and the embedded image will be ignored. |
| `semanticsLabel`          | String               | `semanticsLabel` will be used by screen readers to describe the content of the QR code.                                                                                                             |
| `borderRadius`            | double               | Setting corner rounding for shape types `QrEyeShape.square`, `QrDataModuleShape.square`, `EmbeddedImageShape.square`. Set in appropriate styles.                                                    |
| `roundedOutsideCorners`   | bool                 | If true, the outer corners of the data are rounded. Set to `QrDataModuleStyle`. Rounded to `borderRadius` by default. Only `QrDataModuleShape.square`.                                              |
| `outsideBorderRadius`     | double               | It is set if the outer rounding `outsideBorderRadius` should differ from the inner one `borderRadius`. No more than `borderRadius`. Only `QrDataModuleShape.square`                                 |
| `gradient`                | Gradient             | Changing the solid color of the code to a gradient, e.g. `LinearGradient`.                                                                                                                          | 
| `safeArea`                | bool                 | If true, data is hidden behind the `embeddedImage`. Set to `QrEmbeddedImageStyle`.                                                                                                                  |
| `safeAreaMultiplier`      | double               | Multiplier `safeArea` size.                                                                                                                                                                         |

# Examples

There is a simple, working, example Flutter app in the `/example` directory. You can use it to play with all
the options. 

Also, the following examples give you a quick overview on how to use the library.

A basic QR code will look something like:

```dart
QrImageView(
  data: 'This is a simple QR code',
  version: QrVersions.auto,
  size: 320,
  gapless: false,
)
```

A QR code with an image (from your application's assets) will look like:

```dart
QrImageView(
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

To show an error state in the event that the QR code can't be validated:

```dart
QrImageView(
  data: 'This QR code will show the error state instead',
  version: 1,
  size: 320,
  gapless: false,
  errorStateBuilder: (cxt, err) {
    return Container(
      child: Center(
        child: Text(
          'Uh oh! Something went wrong...',
          textAlign: TextAlign.center,
        ),
      ),
    );
  },
)
```

A QR code with inside and outside corners rounding and safe area of embedded image:

```dart
QrImageView(
  data: 'London is the capital of Great Britain',
  version: QrVersions.auto,
  size: 320,
  eyeStyle: const QrEyeStyle(
    borderRadius: 10,
  ),
  dataModuleStyle: const QrDataModuleStyle(
    borderRadius: 5,
    roundedOutsideCorners: true,
  ),
  embeddedImage: AssetImage('assets/images/my_embedded_image.png'),
  embeddedImageStyle: QrEmbeddedImageStyle(
    size: Size.square(40),
    color: Colors.white,
    safeArea: true,
    safeAreaMultiplier: 1.1,
    embeddedImageShape: EmbeddedImageShape.square,
    borderRadius: 10,
  ),
)
```

A QR code with gradient:

```dart
QrImageView(
  data: 'Rainbow after the rain',
  version: QrVersions.auto,
  size: 320,
  gradient: LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
      colors: [
      Color(0xffff0000),
      Color(0xffffa500),
      Color(0xffffff00),
      Color(0xff008000),
      Color(0xff0000ff),
      Color(0xff4b0082),
      Color(0xffee82ee),
    ],
  ),
)
```

# Outro
## Credits
Thanks to Kevin Moore for his awesome [QR - Dart](https://github.com/kevmoo/qr.dart) library. It's the core of this library.

For author/contributor information, see the `AUTHORS` file.

## License

QR.Flutter is released under a BSD-3 license. See `LICENSE` for details.
