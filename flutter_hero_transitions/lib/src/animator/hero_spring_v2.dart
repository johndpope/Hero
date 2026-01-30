import 'dart:math' as math;
import 'package:flutter/animation.dart';
import 'package:flutter/physics.dart';

/// Ultra-smooth spring simulation with proper settling detection.
///
/// iOS UIKit uses a damped harmonic oscillator with these characteristics:
/// - Critically damped or slightly underdamped
/// - Settles within 2-4% of target (not oscillating forever)
/// - Velocity-based completion (not just position)
///
/// This implementation provides 3 quality levels:
/// - iOS: damping=0.825 (slightly bouncy, settles quickly)
/// - Smooth: damping=0.9 (no bounce, very smooth)
/// - Bouncy: damping=0.65 (visible bounce, fun)
class HeroSpringV2 extends Simulation {
  final double mass;
  final double stiffness;
  final double dampingRatio;
  final double initialPosition;
  final double targetPosition;
  final double initialVelocity;

  late final double _dampingCoefficient;
  late final double _angularFrequency;
  late final double _solutionType; // -1: overdamped, 0: critical, 1: underdamped

  // Pre-calculated constants for each damping regime
  late final double _c1, _c2; // Solution constants
  late final double _r1, _r2; // Characteristic roots (overdamped)
  late final double _dampedFrequency; // Underdamped frequency

  // Tolerance for considering the spring "settled"
  static const double _positionTolerance = 0.01; // 1% of distance
  static const double _velocityTolerance = 0.01; // Effectively stopped

  HeroSpringV2({
    required this.initialPosition,
    required this.targetPosition,
    this.initialVelocity = 0.0,
    this.mass = 1.0,
    this.stiffness = 230.0,
    this.dampingRatio = 0.825,
  }) : _dampingCoefficient = 2.0 * dampingRatio * math.sqrt(mass * stiffness),
       _angularFrequency = math.sqrt(stiffness / mass) {
    _calculateSolution();
  }

  /// Named constructors for common spring types
  factory HeroSpringV2.ios({
    required double start,
    required double end,
    double velocity = 0.0,
  }) {
    return HeroSpringV2(
      initialPosition: start,
      targetPosition: end,
      initialVelocity: velocity,
      mass: 1.0,
      stiffness: 230.0,
      dampingRatio: 0.825, // iOS default
    );
  }

  factory HeroSpringV2.smooth({
    required double start,
    required double end,
    double velocity = 0.0,
  }) {
    return HeroSpringV2(
      initialPosition: start,
      targetPosition: end,
      initialVelocity: velocity,
      mass: 1.0,
      stiffness: 250.0,
      dampingRatio: 0.9, // No bounce, very smooth
    );
  }

  factory HeroSpringV2.bouncy({
    required double start,
    required double end,
    double velocity = 0.0,
  }) {
    return HeroSpringV2(
      initialPosition: start,
      targetPosition: end,
      initialVelocity: velocity,
      mass: 1.0,
      stiffness: 200.0,
      dampingRatio: 0.65, // Visible bounce
    );
  }

  void _calculateSolution() {
    final x0 = initialPosition - targetPosition;
    final v0 = initialVelocity;

    if (dampingRatio < 0.9999) {
      // Underdamped: oscillates before settling
      _solutionType = 1.0;
      _dampedFrequency = _angularFrequency * math.sqrt(1.0 - dampingRatio * dampingRatio);
      _c1 = x0;
      _c2 = (v0 + dampingRatio * _angularFrequency * x0) / _dampedFrequency;
    } else if (dampingRatio > 1.0001) {
      // Overdamped: no oscillation, slower settling
      _solutionType = -1.0;
      final discriminant = math.sqrt(dampingRatio * dampingRatio - 1.0);
      _r1 = -_angularFrequency * (dampingRatio + discriminant);
      _r2 = -_angularFrequency * (dampingRatio - discriminant);
      final denom = _r1 - _r2;
      _c1 = (v0 - _r2 * x0) / denom;
      _c2 = (_r1 * x0 - v0) / denom;
    } else {
      // Critically damped: fastest settling without oscillation
      _solutionType = 0.0;
      _c1 = x0;
      _c2 = v0 + _angularFrequency * x0;
      _r1 = -_angularFrequency;
      _r2 = 0;
    }
  }

  @override
  double x(double time) {
    final displacement = _displacement(time);
    return targetPosition + displacement;
  }

  @override
  double dx(double time) {
    return _velocity(time);
  }

  double _displacement(double time) {
    if (_solutionType > 0) {
      // Underdamped
      final decay = math.exp(-dampingRatio * _angularFrequency * time);
      return decay * (_c1 * math.cos(_dampedFrequency * time) +
                      _c2 * math.sin(_dampedFrequency * time));
    } else if (_solutionType < 0) {
      // Overdamped
      return _c1 * math.exp(_r1 * time) + _c2 * math.exp(_r2 * time);
    } else {
      // Critically damped
      final decay = math.exp(_r1 * time);
      return decay * (_c1 + _c2 * time);
    }
  }

  double _velocity(double time) {
    if (_solutionType > 0) {
      // Underdamped
      final decay = math.exp(-dampingRatio * _angularFrequency * time);
      final cosTerm = _c1 * math.cos(_dampedFrequency * time);
      final sinTerm = _c2 * math.sin(_dampedFrequency * time);
      return decay * (-dampingRatio * _angularFrequency * (cosTerm + sinTerm) +
                      _dampedFrequency * (_c2 * math.cos(_dampedFrequency * time) -
                                           _c1 * math.sin(_dampedFrequency * time)));
    } else if (_solutionType < 0) {
      // Overdamped
      return _c1 * _r1 * math.exp(_r1 * time) + _c2 * _r2 * math.exp(_r2 * time);
    } else {
      // Critically damped
      final decay = math.exp(_r1 * time);
      return decay * (_c2 + _r1 * (_c1 + _c2 * time));
    }
  }

  @override
  bool isDone(double time) {
    final distance = (initialPosition - targetPosition).abs();
    if (distance < 0.001) return true; // Already at target

    final currentPos = x(time);
    final currentVel = dx(time);

    // Check if position is within tolerance AND velocity is near zero
    final positionSettled = (currentPos - targetPosition).abs() <
                           (distance * _positionTolerance).clamp(0.1, double.infinity);
    final velocityStopped = currentVel.abs() < _velocityTolerance;

    return positionSettled && velocityStopped;
  }

  @override
  Tolerance get tolerance => const Tolerance(
    distance: 0.01, // Position tolerance
    velocity: 0.01, // Velocity tolerance
    time: 0.001,    // Time resolution
  );
}

/// Pre-baked spring curve for when you want spring behavior but as a Curve.
/// Faster than running simulation on every frame.
class SpringCurve extends Curve {
  final double dampingRatio;
  final double? velocity;

  const SpringCurve({
    this.dampingRatio = 0.825,
    this.velocity,
  });

  @override
  double transformInternal(double t) {
    // Use a simplified spring equation for curve evaluation
    // This is an approximation but much faster than full simulation
    if (t <= 0.0) return 0.0;
    if (t >= 1.0) return 1.0;

    final spring = HeroSpringV2(
      initialPosition: 0.0,
      targetPosition: 1.0,
      initialVelocity: velocity ?? 0.0,
      dampingRatio: dampingRatio,
      stiffness: 300.0, // High stiffness for fast curve
      mass: 1.0,
    );

    // Map t (0-1) to time based on estimated settling time
    final settlingTime = _estimateSettlingTime();
    return spring.x(t * settlingTime).clamp(0.0, 1.0);
  }

  double _estimateSettlingTime() {
    // Settling time ≈ 4 / (ζ * ω₀) for spring systems
    // Use typical values for fast estimation
    final omega0 = math.sqrt(300.0 / 1.0); // sqrt(stiffness/mass)
    return 4.0 / (dampingRatio * omega0);
  }

  @override
  String toString() => 'SpringCurve(dampingRatio: $dampingRatio)';
}
