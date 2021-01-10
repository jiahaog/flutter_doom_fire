import 'dart:math';
import 'dart:ui';

import 'palette.dart';

get _fireColor => palette.length - 1;
const _noFireColor = 0;

/// Algorithm for the fire.
class Fire {
  List<List<int>> _firePixels = [];
  static final _random = Random(1234);

  int? width;
  int? height;

  final Set<_Coordinate> _temporarySources = <_Coordinate>{};
  final Set<_Coordinate> _permanentSources = <_Coordinate>{};

  /// Direction and strength of the wind.
  ///
  /// Positive values indicates the left to right direction.
  int wind = 0;

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
            if (y == height - 1) _fireColor else _noFireColor
        ]
    ];

    _permanentSources.clear();
    for (var x = 0; x < width; x += 1) {
      _permanentSources.add(_Coordinate(x, height - 1));
    }
  }

  /// Propagates the fire.
  void doFire() {
    for (var y = 1; y < height!; y += 1) {
      for (var x = 0; x < width!; x += 1) {
        _spreadFire(_Coordinate(x, y));
      }
    }
  }

  /// Adds a temporary source of fire.
  ///
  /// Can be cleared with [clearAddedSources].
  void addSource({required int x, required int y}) {
    _temporarySources.add(_Coordinate(x, y));
    _temporarySources.add(_Coordinate(x + 1, y));
    _temporarySources.add(_Coordinate(x, y + 1));
    _temporarySources.add(_Coordinate(x - 1, y));
    _temporarySources.add(_Coordinate(x, y - 1));
  }

  /// Clears all fire sources from [addSource].
  void clearAddedSources() => _temporarySources.clear();

  void _spreadFire(_Coordinate from) {
    final fromFire =
        _temporarySources.contains(from) || _permanentSources.contains(from)
            ? palette.length - 1
            : _firePixels[from.y][from.x];

    final x = max(0, min(width! - 1, from.x + _windOffset));
    _firePixels[from.y - 1][x] = max(0, fromFire - _smaller);
  }

  int get _windOffset {
    // Plus one because [nextInt] is exclusive.
    final offset = _random.nextInt(wind.abs() + 1);
    return (wind > 0 ? 1 : -1) * offset;
  }

  int get _smaller => _random.nextInt(4);

  /// Returns the color for a specific coordinate.
  ///
  /// [x] and [y] should fall within the bounds set by [setSize].
  Color colorAt({required int x, required int y}) => palette[_firePixels[y][x]];
}

class _Coordinate {
  final int x;
  final int y;

  _Coordinate(this.x, this.y);

  @override
  bool operator ==(Object other) {
    return other is _Coordinate && other.x == x && other.y == y;
  }

  // Common hash function.
  @override
  int get hashCode => x * 31 + y;

  @override
  String toString() => 'Coordinate(x=$x, y=$y)';
}
