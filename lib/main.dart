import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'src/fire.dart';

void main() => runApp(_DoomFire());

class _DoomFire extends StatefulWidget {
  @override
  _DoomFireState createState() => _DoomFireState();
}

class _DoomFireState extends State<_DoomFire>
    with SingleTickerProviderStateMixin {
  late Animation<num> _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: Duration(seconds: 1), vsync: this)
          ..repeat();
    // Tween values don't matter.
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _AnimatedFire(animation: _animation);
}

class _AnimatedFire extends AnimatedWidget {
  _AnimatedFire({Key? key, required Animation<num> animation})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) => _FireContainer();
}

class _FireContainer extends StatefulWidget {
  @override
  _FireContainerState createState() => _FireContainerState();
}

class _FireContainerState extends State<_FireContainer> {
  final _fire = Fire();

  /// Local position of the drag (if any).
  Offset? _dragStart;

  void _onHorizontalDragStart(DragStartDetails details) =>
      _dragStart = details.localPosition;

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final offsetFromDragStart = details.localPosition - _dragStart!;
    final normalizedOffset = offsetFromDragStart.dx * _dragOffsetToWindScale;
    setState(() => _fire.wind = normalizedOffset.round());
  }

  void _onHorizontalDragEnd(DragEndDetails _) => _dragStart = null;

  void _onTapDown(TapDownDetails details) {
    final x = (details.localPosition.dx / _pixelSize).round();
    final y = (details.localPosition.dy / _pixelSize).round();

    setState(() => _fire.addSource(x: x, y: y));
  }

  void _onDoubleTap() => setState(() => _fire.clearAddedSources());

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        onHorizontalDragStart: _onHorizontalDragStart,
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        onTapDown: _onTapDown,
        onDoubleTap: _onDoubleTap,
        child: CustomPaint(
          painter: _FirePainter(_fire),
        ),
      ),
      constraints: BoxConstraints(
        minWidth: double.infinity,
        minHeight: double.infinity,
      ),
    );
  }
}

const _dragOffsetToWindScale = 1 / 100;
const _pixelSize = 5.0;

class _FirePainter extends CustomPainter {
  _FirePainter(this._fire);

  final Fire _fire;

  @override
  void paint(Canvas canvas, Size size) {
    final height = (size.height / _pixelSize).round();
    final width = (size.width / _pixelSize).round();

    _fire
      ..setSize(width: width, height: height)
      ..doFire();

    for (var x = 0; x < width; x += 1) {
      for (var y = 0; y < height; y += 1) {
        canvas.drawRect(
          Rect.fromPoints(
            Offset(x * _pixelSize, y * _pixelSize),
            Offset((x + 1) * _pixelSize, (y + 1) * _pixelSize),
          ),
          Paint()..color = _fire.colorAt(x: x, y: y),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_FirePainter oldDelegate) => true;
}
