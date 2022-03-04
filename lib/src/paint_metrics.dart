import 'package:flutter/cupertino.dart';

import '../qr_flutter.dart';

/// Storage class for pre-calculated values that are re-used across different
/// paint sub-processes.
class PaintMetrics {
  /// Create a new storage class for the various data points we want to re-use
  /// when painting.
  PaintMetrics({
    required this.containerSize,
    required this.gapSize,
    required this.moduleCount,
    this.inset = 0,
  }) {
    _calculateMetrics();
  }

  /// The size of the QR code in data "pixels".
  final int moduleCount;

  /// The size of the container we're going to be painting to.
  final Size containerSize;

  /// The size of the gap to draw between the data pixels.
  final double gapSize;

  /// The amount that the code contents should be inset from the edges.
  final double inset;

  late final double _pixelSize;
  double get pixelSize => _pixelSize;

  late final double _innerContentSize;
  double get innerContentSize => _innerContentSize;

  late final Offset _origin;
  Offset get origin => _origin;

  Offset finderPositionOffset(
    FinderPatternPosition position,
    double markerSize,
    double adjust,
  ) {
    final leftOffset = _origin.dx + adjust;
    final topOffset = _origin.dy + adjust;
    if (position == FinderPatternPosition.topLeft) {
      return Offset(leftOffset, topOffset);
    } else if (position == FinderPatternPosition.bottomLeft) {
      return Offset(leftOffset, containerSize.height - topOffset - markerSize);
    } else {
      return Offset(containerSize.width - leftOffset - markerSize, topOffset);
    }
  }

  void _calculateMetrics() {
    final gapTotal = (moduleCount - 1) * gapSize;
    _pixelSize =
        (containerSize.shortestSide - (2 * inset) - gapTotal) / moduleCount;
    _innerContentSize = (_pixelSize * moduleCount) + gapTotal;
    _origin = Offset(
      (containerSize.width - _innerContentSize) / 2,
      (containerSize.height - _innerContentSize) / 2,
    );
  }
}
