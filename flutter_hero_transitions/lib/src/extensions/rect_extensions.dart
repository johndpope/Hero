import 'dart:ui';

/// Extensions on Rect for Hero transition calculations.
extension HeroRectExtensions on Rect {
  /// Get the center point of the rect.
  Offset get centerPoint => center;

  /// Calculate the distance between centers of two rects.
  double distanceTo(Rect other) {
    return (center - other.center).distance;
  }

  /// Linearly interpolate between two rects.
  static Rect lerp(Rect a, Rect b, double t) {
    return Rect.fromLTWH(
      a.left + (b.left - a.left) * t,
      a.top + (b.top - a.top) * t,
      a.width + (b.width - a.width) * t,
      a.height + (b.height - a.height) * t,
    );
  }

  /// Create a rect centered at a position with given size.
  static Rect fromCenter(Offset center, Size size) {
    return Rect.fromCenter(
      center: center,
      width: size.width,
      height: size.height,
    );
  }

  /// Inset the rect by a given value on all sides.
  Rect insetBy(double value) {
    return Rect.fromLTRB(
      left + value,
      top + value,
      right - value,
      bottom - value,
    );
  }
}
