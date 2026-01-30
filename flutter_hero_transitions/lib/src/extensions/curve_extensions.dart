import 'package:flutter/animation.dart';

/// Named curves matching iOS Hero's timing function constants.
/// Includes Material Design timing functions.
class HeroCurves {
  HeroCurves._();

  /// Standard Material Design curve.
  static const Curve standard = Cubic(0.4, 0.0, 0.2, 1.0);

  /// Material Design deceleration curve.
  static const Curve deceleration = Cubic(0.0, 0.0, 0.2, 1.0);

  /// Material Design acceleration curve.
  static const Curve acceleration = Cubic(0.4, 0.0, 1.0, 1.0);

  /// Material Design sharp curve.
  static const Curve sharp = Cubic(0.4, 0.0, 0.6, 1.0);

  /// Ease out with overshoot (back).
  static const Curve easeOutBack = Cubic(0.175, 0.885, 0.32, 1.275);

  /// Look up a curve by name string.
  static Curve? fromName(String name) {
    switch (name.toLowerCase()) {
      case 'linear':
        return Curves.linear;
      case 'easein':
      case 'ease_in':
        return Curves.easeIn;
      case 'easeout':
      case 'ease_out':
        return Curves.easeOut;
      case 'easeinout':
      case 'ease_in_out':
        return Curves.easeInOut;
      case 'standard':
        return standard;
      case 'deceleration':
        return deceleration;
      case 'acceleration':
        return acceleration;
      case 'sharp':
        return sharp;
      case 'easeoutback':
      case 'ease_out_back':
        return easeOutBack;
      default:
        return null;
    }
  }
}
