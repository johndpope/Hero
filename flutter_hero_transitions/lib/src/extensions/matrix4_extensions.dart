import 'package:flutter/rendering.dart';

/// Extensions on Matrix4 for Hero transition calculations.
extension HeroMatrix4Extensions on Matrix4 {
  /// Set the perspective entry (row 3, column 2).
  void setPerspective(double value) {
    setEntry(3, 2, value);
  }

  /// Get a copy of this matrix.
  Matrix4 copy() => clone();

  /// Create a matrix with translation.
  static Matrix4 translationValues(double x, double y, double z) {
    return Matrix4.identity()..translate(x, y, z);
  }

  /// Create a matrix with scale.
  static Matrix4 scaleValues(double x, double y, double z) {
    return Matrix4.identity()..scale(x, y, z);
  }

  /// Linearly interpolate between two matrices.
  static Matrix4 lerp(Matrix4 a, Matrix4 b, double t) {
    final result = Matrix4.zero();
    for (int i = 0; i < 16; i++) {
      result[i] = a[i] + (b[i] - a[i]) * t;
    }
    return result;
  }
}
