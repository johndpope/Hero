import 'dart:math' as math;
import 'package:flutter/physics.dart';

/// iOS-accurate spring simulation matching CASpringAnimation.
///
/// iOS uses a damped harmonic oscillator with:
/// - Damping ratio (zeta): Controls oscillation (0.825 default for UI)
/// - Stiffness (k): Spring constant (230 default)
/// - Mass (m): 1.0 default
///
/// This produces the smooth, weighty feel of iOS animations.
class HeroSpringSimulation extends Simulation {
  final double mass;
  final double stiffness;
  final double damping;
  final double initialPosition;
  final double targetPosition;
  final double initialVelocity;

  late final double _dampingRatio;
  late final double _omega0;
  late final double _omega1;
  late final double _cosCoeff;
  late final double _sinCoeff;
  late final bool _isOverdamped;
  late final bool _isCriticallyDamped;

  HeroSpringSimulation({
    required this.initialPosition,
    required this.targetPosition,
    this.initialVelocity = 0.0,
    this.mass = 1.0,
    this.stiffness = 230.0,
    double? dampingRatio,
  }) : damping = dampingRatio != null
            ? 2.0 * dampingRatio * math.sqrt(mass * stiffness)
            : 2.0 * 0.825 * math.sqrt(mass * stiffness) {
    _dampingRatio = damping / (2.0 * math.sqrt(mass * stiffness));
    _omega0 = math.sqrt(stiffness / mass);

    if (_dampingRatio < 1.0) {
      // Underdamped - normal springy behavior
      _isOverdamped = false;
      _isCriticallyDamped = false;
      _omega1 = _omega0 * math.sqrt(1.0 - _dampingRatio * _dampingRatio);

      final displacement = initialPosition - targetPosition;
      _cosCoeff = displacement;
      _sinCoeff =
          (initialVelocity + _dampingRatio * _omega0 * displacement) / _omega1;
    } else if (_dampingRatio > 1.0) {
      // Overdamped - slow return without oscillation
      _isOverdamped = true;
      _isCriticallyDamped = false;
      _omega1 = _omega0 * math.sqrt(_dampingRatio * _dampingRatio - 1.0);

      final displacement = initialPosition - targetPosition;
      final alpha = -_dampingRatio * _omega0;
      final beta = alpha * alpha - _omega0 * _omega0;
      final sqrtBeta = math.sqrt(beta.abs());

      _cosCoeff = displacement;
      _sinCoeff = (initialVelocity - alpha * displacement) / sqrtBeta;
    } else {
      // Critically damped - fastest return without overshoot
      _isOverdamped = false;
      _isCriticallyDamped = true;
      _omega1 = 0.0;

      final displacement = initialPosition - targetPosition;
      _cosCoeff = displacement;
      _sinCoeff = initialVelocity + _omega0 * displacement;
    }
  }

  @override
  double x(double time) {
    if (_isCriticallyDamped) {
      final exp = math.exp(-_omega0 * time);
      return targetPosition + (_cosCoeff + _sinCoeff * time) * exp;
    } else if (_isOverdamped) {
      final exp = math.exp(-_dampingRatio * _omega0 * time);
      final cosh = (math.exp(_omega1 * time) + math.exp(-_omega1 * time)) / 2.0;
      final sinh = (math.exp(_omega1 * time) - math.exp(-_omega1 * time)) / 2.0;
      return targetPosition + exp * (_cosCoeff * cosh + _sinCoeff * sinh);
    } else {
      final exp = math.exp(-_dampingRatio * _omega0 * time);
      return targetPosition +
          exp * (_cosCoeff * math.cos(_omega1 * time) + _sinCoeff * math.sin(_omega1 * time));
    }
  }

  @override
  double dx(double time) {
    if (_isCriticallyDamped) {
      final exp = math.exp(-_omega0 * time);
      final term1 = _sinCoeff - _omega0 * (_cosCoeff + _sinCoeff * time);
      return term1 * exp;
    } else if (_isOverdamped) {
      final exp = math.exp(-_dampingRatio * _omega0 * time);
      final cosh = (math.exp(_omega1 * time) + math.exp(-_omega1 * time)) / 2.0;
      final sinh = (math.exp(_omega1 * time) - math.exp(-_omega1 * time)) / 2.0;
      final dCosh = _omega1 * sinh;
      final dSinh = _omega1 * cosh;
      return exp * (_cosCoeff * dCosh + _sinCoeff * dSinh) -
          _dampingRatio * _omega0 * exp * (_cosCoeff * cosh + _sinCoeff * sinh);
    } else {
      final exp = math.exp(-_dampingRatio * _omega0 * time);
      final cos = math.cos(_omega1 * time);
      final sin = math.sin(_omega1 * time);
      return exp *
              ((-_dampingRatio * _omega0 * _cosCoeff - _omega1 * _sinCoeff) * cos +
                  (_omega1 * _cosCoeff - _dampingRatio * _omega0 * _sinCoeff) * sin);
    }
  }

  @override
  bool isDone(double time) {
    // Spring is "done" when position and velocity are near target
    final position = x(time);
    final velocity = dx(time);
    const tolerance = 0.01;
    const velocityTolerance = 0.01;

    return (position - targetPosition).abs() < tolerance &&
        velocity.abs() < velocityTolerance;
  }

  /// Calculate the settling duration (when spring comes to rest).
  /// iOS typically uses 4-5 time constants for damped springs.
  double get settlingDuration {
    if (_dampingRatio >= 1.0) {
      // Overdamped/critically damped settles faster
      return 4.0 / (_dampingRatio * _omega0);
    } else {
      // Underdamped - use envelope decay
      return 5.0 / (_dampingRatio * _omega0);
    }
  }

  @override
  Tolerance get tolerance => const Tolerance(
        distance: 0.01,
        velocity: 0.01,
        time: 0.001,
      );
}
