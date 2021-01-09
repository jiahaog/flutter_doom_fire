import 'dart:math';
import 'dart:ui';

import 'palette.dart';

/// Algorithm for the fire.
class Fire {
  List<List<int>> _firePixels = [];
  static final _random = Random(1234);

  int? width;
  int? height;

  /// Updates the dimensions of the fire.
  void setSize({required int width, required int height}) {
    // Don't clear the state if the width and height remains unchanged. This
    // will allow the fire to continue propagating.
    if (width == this.width && height == this.height) {
      return;
    }

    this.width = width;
    this.height = height;

    _firePixels = [
      for (var y = 0; y < height; y += 1)
        [
          for (var x = 0; x < width; x += 1)
            if (y == height - 1) palette.length - 1 else 0
        ]
    ];
  }

  /// Propagates the fire.
  void doFire() {
    for (var y = 1; y < height!; y += 1) {
      for (var x = 0; x < width!; x += 1) {
        _spreadFire(x, y);
      }
    }
  }

  void _spreadFire(int fromX, int fromY) {
    final x = max(0, min(width! - 1, fromX - _random.nextInt(2)));
    _firePixels[fromY - 1][x] = max(0, _firePixels[fromY][fromX] - _smaller);
  }

  int get _smaller => _random.nextInt(4);

  /// Returns the color for a specific coordinate.
  ///
  /// [x] and [y] should fall within the bounds set by [setSize].
  Color colorAt({required int x, required int y}) => palette[_firePixels[y][x]];
}
