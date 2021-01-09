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
  final _fire = Fire();
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
  Widget build(BuildContext context) {
    return _AnimatedFire(animation: _animation, fire: _fire);
  }
}

class _AnimatedFire extends AnimatedWidget {
  _AnimatedFire(
      {Key? key, required Animation<num> animation, required Fire fire})
      : _fire = fire,
        super(key: key, listenable: animation);

  final Fire _fire;

  Widget build(BuildContext context) {
    return Container(
      child: CustomPaint(
        painter: _FirePainter(_fire),
      ),
      constraints: BoxConstraints(
        minWidth: double.infinity,
        minHeight: double.infinity,
      ),
    );
  }
}

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
