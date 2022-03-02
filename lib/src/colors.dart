import 'dart:math';

import 'package:flutter/widgets.dart';

const String optionKeyDirection = "direction";

/// Color configuration for the data module portion of the QR code.
class QrColors {
  /// Use a single color.
  QrColors.single(Color color)
      : colors = [color],
        mode = null,
        options = <String, dynamic>{};

  /// Apply the colors in the order c1, c2 .. cN and then repeat the order.
  QrColors.sequence(this.colors, {Axis direction = Axis.vertical})
      : mode = ColorMode.sequence,
        options = <String, dynamic>{optionKeyDirection: direction};

  /// Apply the colors at random.
  QrColors.random(this.colors)
      : mode = ColorMode.random,
        options = <String, dynamic>{};

  /// The colors in the color list.
  final List<Color> colors;

  /// Mode determines how the colors will be applied when the modules are
  /// painted.
  final ColorMode? mode;

  /// Additional options passed to the color list so that the painter knows
  /// how to properly draw it.
  final Map<String, dynamic> options;

  /// Get the first color in the list.
  Color? get first => colors.length > 0 ? colors.first : null;

  /// Get the last color in the list.
  Color? get last => colors.length > 0 ? colors.last : null;

  Color? get single => colors.single;

  bool get hasColors => colors.isNotEmpty;

  int get length => colors.length;

  Color? random() {
    if (colors.length == 0) {
      return null;
    }
    final randInt = Random().nextInt(colors.length);
    return colors[randInt];
  }

  Color operator [](int index) => colors[index];
}

/// How a set of colors will be applied to the QR code when it is painted.
enum ColorMode {
  /// The colors will be applied as a sequence (c1, c2 .. cN). The order of the
  /// color in the sequence will be determined by it's position in the list.
  sequence,

  /// The colors in the list will be applied at random.
  random,
}
