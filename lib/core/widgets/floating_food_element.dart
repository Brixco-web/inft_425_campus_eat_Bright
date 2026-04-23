import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A single animated food/graphic icon that drifts across its parent [Stack],
/// fading in and out with a gentle rotation. Each instance randomises its own
/// trajectory so repeats still look organic.
class FloatingFoodElement extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final Duration duration;

  const FloatingFoodElement({
    super.key,
    required this.icon,
    this.color = Colors.white,
    this.size = 24.0,
    this.duration = const Duration(seconds: 10),
  });

  @override
  State<FloatingFoodElement> createState() => _FloatingFoodElementState();
}

class _FloatingFoodElementState extends State<FloatingFoodElement>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Random start / end values for the drift path
  late final double _startX;
  late final double _startY;
  late final double _endX;
  late final double _endY;
  late final double _rotationStart;
  late final double _rotationEnd;

  @override
  void initState() {
    super.initState();
    final rng = math.Random();

    _startX = rng.nextDouble();
    _startY = rng.nextDouble();
    _endX = rng.nextDouble();
    _endY = rng.nextDouble();
    _rotationStart = rng.nextDouble() * math.pi * 2;
    _rotationEnd =
        _rotationStart + (rng.nextBool() ? 1 : -1) * math.pi;

    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use Align + FractionalTranslation instead of Positioned so we
    // don't require being a *direct* child of a Stack.
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = _controller.value;

        // Lerp position
        final double x = _startX + (_endX - _startX) * t;
        final double y = _startY + (_endY - _startY) * t;

        // Lerp rotation
        final double rotation =
            _rotationStart + (_rotationEnd - _rotationStart) * t;

        // Sinusoidal opacity so the element gently fades in / out
        final double opacity = (math.sin(t * math.pi) * 0.35).clamp(0.0, 0.4);

        return Align(
          alignment: FractionalOffset(x, y),
          child: Transform.rotate(
            angle: rotation,
            child: Opacity(
              opacity: opacity,
              child: child,
            ),
          ),
        );
      },
      child: Icon(widget.icon, size: widget.size, color: widget.color),
    );
  }
}
