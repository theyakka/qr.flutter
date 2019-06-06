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
