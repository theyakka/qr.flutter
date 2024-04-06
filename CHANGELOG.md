# 4.1.0
- Bump `qr` dependency (from `^3.0.0` to `^3.0.1`).

# 4.0.1 
- Bump `qr` dependency (from `^2.0.0` to `^3.0.0`).
- **BREAKING**: Rename `QrImage` to `QrImageView`

# 4.0.0
- Migrate to null safety

# 3.2.0
- Fix issue where finder patterns don't render correctly with the painter
- Small fixes + optimizations

# 3.1.0
- Fix issue with `emptyColor` rendering.
- Fix a bug related to placeholder image loading.
- Bump to Flutter 1.7+. Flutter API changes have necessitated a bump. Sorry.

# 3.0.1
- Added an example.

# 3.0.0
- Use `QrVersions.auto` and let the library pick the appropriate version for you.
- Add an image that will be overlaid in the centre of the widget. You can specify the image size but not position.
- `QrImage.onError` has been removed. It was horribly broken so we decided to not deprecate it and just remove it totally.
- `QrImage.errorStateBuilder` introduced to allow you to display an in-line `Widget` when an error (such as data too long) occurs. By default the error state `Widget` will be constrained to the `QRImage` bounds (aka a Square) but you can use the `constrainErrorBounds` property to prevent that.
- A bunch of bug fixes you can look at in the source code.

# 2.1.0
- The `gapless` option is now `true` by default.
- Allow assigning `Key` values to `QrImage` widgets.
- Update `qr.dart` dependency.
- `qr.dart` is now exported so you don't need a second `import`.

# 2.0.0
- Flutter 1.2.1 compatibility

# 2.0.0-dev.1
- Fixes issue caused by breaking change in Flutter (https://github.com/flutter/flutter/issues/26655).

# 1.1.6
- Adds analyzer configuration
- Fixes linting issues
- Migrate to Dart 2.x friendly syntax
- Tidy some initialization logic / code
- Bump copyright

# 1.1.5
- Add image data export functions (see `test/painter_tests.dart` for an example)

# 1.1.4
- Add gapless toggle

# 1.1.3
- Lower min sdk version to cater to some older versions of Flutter

# 1.1.2
- The QrImage widget will now autosize if no size has been defined (thanks @romkor!)
- Requires Dart 2 (as so does Flutter)
- Dart 2 pubspec compatability changes

# 1.1.1
- Fixes and issue where the QR image won't get repainted even though the data has changed

# 1.1.0
- Update to 1.0 release of the dart qr library

# 1.0.0
- Initial release
