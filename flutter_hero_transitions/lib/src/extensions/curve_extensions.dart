import 'package:flutter/animation.dart';

/// iOS-accurate cubic-bezier curves matching Core Animation.
///
/// These curves match the exact control points used by iOS UIKit/Core Animation,
/// providing the signature iOS animation feel.
class HeroCurves {
  HeroCurves._();

  /// iOS default ease-in-out curve.
  /// Core Animation: cubic-bezier(0.42, 0, 0.58, 1)
  /// This is the default for most iOS transitions.
  static const Curve iosEaseInOut = Cubic(0.42, 0.0, 0.58, 1.0);

  /// iOS ease-out curve.
  /// Core Animation: cubic-bezier(0, 0, 0.58, 1)
  /// Used when elements decelerate to a stop.
  static const Curve iosEaseOut = Cubic(0.0, 0.0, 0.58, 1.0);

  /// iOS ease-in curve.
  /// Core Animation: cubic-bezier(0.42, 0, 1, 1)
  /// Used when elements accelerate from rest.
  static const Curve iosEaseIn = Cubic(0.42, 0.0, 1.0, 1.0);

  /// iOS linear curve (no easing).
  static const Curve iosLinear = Curves.linear;

  /// Material Design curves (kept for compatibility).
  static const Curve standard = Cubic(0.4, 0.0, 0.2, 1.0);
  static const Curve deceleration = Cubic(0.0, 0.0, 0.2, 1.0);
  static const Curve acceleration = Cubic(0.4, 0.0, 1.0, 1.0);
  static const Curve sharp = Cubic(0.4, 0.0, 0.6, 1.0);
  static const Curve easeOutBack = Cubic(0.175, 0.885, 0.32, 1.275);

  /// Look up a curve by name string.
  static Curve? fromName(String name) {
    switch (name.toLowerCase()) {
      case 'linear':
      case 'ioslinear':
        return iosLinear;
      case 'easein':
      case 'ease_in':
      case 'ioseasein':
        return iosEaseIn;
      case 'easeout':
      case 'ease_out':
      case 'ioseaseout':
        return iosEaseOut;
      case 'easeinout':
      case 'ease_in_out':
      case 'ioseaseinout':
        return iosEaseInOut;
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
