import 'dart:ui';
import 'dart:math' as math;

/// Extensions on Offset for Hero transition calculations.
extension HeroOffsetExtensions on Offset {
  /// Translate by x, y amounts.
  Offset translate(double dx, double dy) => Offset(this.dx + dx, this.dy + dy);

  /// Multiply each component independently.
  Offset multiplyComponents(Offset other) =>
      Offset(dx * other.dx, dy * other.dy);

  /// Clamp both components to a range.
  Offset clampComponents(double minVal, double maxVal) =>
      Offset(dx.clamp(minVal, maxVal), dy.clamp(minVal, maxVal));

  /// Point-wise minimum.
  Offset min(Offset other) =>
      Offset(math.min(dx, other.dx), math.min(dy, other.dy));

  /// Point-wise maximum.
  Offset max(Offset other) =>
      Offset(math.max(dx, other.dx), math.max(dy, other.dy));
}
