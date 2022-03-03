/// Storage class for pre-calculated values that are re-used across different
/// paint sub-processes.
class PaintMetrics {
  /// Create a new storage class for the various data points we want to re-use
  /// when painting.
  PaintMetrics({
    required this.containerSize,
    required this.gapSize,
    required this.moduleCount,
  }) {
    _calculateMetrics();
  }

  /// The size of the QR code in data "pixels".
  final int moduleCount;

  /// The size of the container we're going to be painting to.
  final double containerSize;

  /// The size of the gap to draw between the data pixels.
  final double gapSize;

  late final double _pixelSize;
  double get pixelSize => _pixelSize;

  late final double _innerContentSize;
  double get innerContentSize => _innerContentSize;

  late final double _inset;
  double get inset => _inset;

  void _calculateMetrics() {
    final gapTotal = (moduleCount - 1) * gapSize;
    _pixelSize = (containerSize - gapTotal) / moduleCount;
    _innerContentSize = (_pixelSize * moduleCount) + gapTotal;
    _inset = (containerSize - _innerContentSize) / 2;
  }
}
