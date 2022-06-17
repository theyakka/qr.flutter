import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Used to store / access the directional configuration for color lists that
/// support directions.
const String optionKeyDirection = "direction";

int colorHash(Color color) {
  return color.red ^ color.green ^ color.blue ^ color.alpha;
}

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
  Color? get first => colors.isNotEmpty ? colors.first : null;

  /// Get the last color in the list.
  Color? get last => colors.isNotEmpty ? colors.last : null;

  /// Checks that the color list has a single element and returns that element.
  Color? get single => colors.single;

  /// Checks to see if the color list is not empty.
  bool get isNotEmpty => colors.isNotEmpty;

  /// Returns the length of the color list.
  int get length => colors.length;

  /// Returns a color from the color list at random.
  Color? random() {
    if (colors.isEmpty) {
      return null;
    }
    final randInt = Random().nextInt(colors.length);
    return colors[randInt];
  }

  /// Returns the color from the color list at the provided index.
  Color operator [](int index) => colors[index];

  @override
  bool operator ==(Object other) {
    if (other is QrColors) {
      return other.hashCode == hashCode &&
          mapEquals<String, dynamic>(options, other.options);
    }
    return false;
  }

  @override
  int get hashCode {
    var colorsHash= -1;
    for (var c in colors) {
      colorsHash ^= colorHash(c);
    }
    return mode.hashCode ^ colorsHash;
  }
}

/// How a set of colors will be applied to the QR code when it is painted.
enum ColorMode {
  /// The colors will be applied as a sequence (c1, c2 .. cN). The order of the
  /// color in the sequence will be determined by it's position in the list.
  sequence,

  /// The colors in the list will be applied at random.
  random,
}
