import 'dart:ui';

import 'package:flutter/animation.dart';

/// Custom Tween that moves along a quadratic Bezier arc path
/// instead of a straight line. Equivalent to iOS Hero's arc modifier
/// using CAKeyframeAnimation.
class ArcTween extends Tween<Offset> {
  final double intensity;

  ArcTween({
    required Offset begin,
    required Offset end,
    this.intensity = 1.0,
  }) : super(begin: begin, end: end);

  @override
  Offset lerp(double t) {
    final from = begin!;
    final to = end!;

    // Only apply arc if there's significant movement in both axes
    if ((from.dx - to.dx).abs() < 1 || (from.dy - to.dy).abs() < 1) {
      return Offset.lerp(from, to, t)!;
    }

    // Control point for the quadratic Bezier curve
    final maxControl = from.dy > to.dy
        ? Offset(to.dx, from.dy)
        : Offset(from.dx, to.dy);
    final midpoint = (to - from) / 2 + from;
    final control = midpoint + (maxControl - midpoint) * intensity;

    // Quadratic Bezier: B(t) = (1-t)^2 * P0 + 2(1-t)t * P1 + t^2 * P2
    final oneMinusT = 1 - t;
    return Offset(
      oneMinusT * oneMinusT * from.dx +
          2 * oneMinusT * t * control.dx +
          t * t * to.dx,
      oneMinusT * oneMinusT * from.dy +
          2 * oneMinusT * t * control.dy +
          t * t * to.dy,
    );
  }
}
