import 'dart:ui';

/// Stores a two dimensional array of [Color] values to optimize the (re)rendering
/// of the data modules when using random or sequenced colors.
class ColorMatrix {
  /// Creates a `size` x `size` matrix of [Color] values.
  ColorMatrix({required int size})
      : _colors = List.generate(size, (index) => List.filled(size, null));

  final List<List<Color?>> _colors;

  /// Adds a [Color] value at the x and y position.
  void addAt(int x, int y, Color color) {
    _colors[x][y] = color;
  }

  /// Retrieve the [Color] value at the given index.
  List<Color?> operator [](int index) => _colors[index];
}
