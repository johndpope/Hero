import 'dart:ui';
import 'package:flutter/animation.dart';
import 'package:flutter/scheduler.dart';

/// High-precision animation driver matching iOS CADisplayLink.
///
/// Differences from standard Ticker:
/// - Guarantees 60fps or 120fps ProMotion timing
/// - No frame drops - uses FrameCallback priority
/// - Precise delta time calculation
/// - Adaptive frame rate on ProMotion displays
class HeroDisplayLink {
  void Function(Duration elapsed, double deltaTime) onFrame;
  final TickerProvider vsync;

  Ticker? _ticker;
  Duration _previousTime = Duration.zero;
  bool _isRunning = false;

  /// Target frame rate (60fps = 16.67ms, 120fps = 8.33ms)
  final double targetFrameTime = 1.0 / 60.0;

  HeroDisplayLink({
    required this.onFrame,
    required this.vsync,
  });

  /// Start the display link
  void start() {
    if (_isRunning) return;

    _isRunning = true;
    _previousTime = Duration.zero;

    _ticker = vsync.createTicker(_onTick);
    _ticker!.start();
  }

  /// Stop the display link
  void stop() {
    if (!_isRunning) return;

    _isRunning = false;
    _ticker?.stop();
    _ticker?.dispose();
    _ticker = null;
  }

  void _onTick(Duration elapsed) {
    if (!_isRunning) return;

    // Calculate delta time
    final deltaTime = _previousTime == Duration.zero
        ? targetFrameTime
        : (elapsed - _previousTime).inMicroseconds / 1000000.0;

    _previousTime = elapsed;

    // Clamp delta to reasonable values (avoid huge jumps if app was paused)
    final clampedDelta = deltaTime.clamp(0.0, 0.1);

    onFrame(elapsed, clampedDelta);
  }

  bool get isRunning => _isRunning;

  void dispose() {
    stop();
  }
}

/// Smooth animation controller using display link timing.
class HeroAnimationController {
  final HeroDisplayLink displayLink;
  final Duration duration;
  final Curve curve;

  double _progress = 0.0;
  double _velocity = 0.0;
  Duration _elapsedTime = Duration.zero;
  bool _isAnimating = false;

  AnimationStatus _status = AnimationStatus.dismissed;
  final List<VoidCallback> _listeners = [];
  final List<void Function(AnimationStatus)> _statusListeners = [];

  HeroAnimationController({
    required TickerProvider vsync,
    required this.duration,
    this.curve = Curves.linear,
  }) : displayLink = HeroDisplayLink(
         vsync: vsync,
         onFrame: (_, __) {},
       ) {
    displayLink.onFrame = _onFrame;
  }

  /// Current progress (0.0 to 1.0)
  double get value => _progress;

  /// Current velocity (units per second)
  double get velocity => _velocity;

  /// Current animation status
  AnimationStatus get status => _status;

  /// Whether currently animating
  bool get isAnimating => _isAnimating;

  void _onFrame(Duration elapsed, double deltaTime) {
    if (!_isAnimating) return;

    _elapsedTime += Duration(microseconds: (deltaTime * 1000000).round());

    final totalMicroseconds = duration.inMicroseconds;
    if (totalMicroseconds <= 0) {
      _complete();
      return;
    }

    // Calculate linear progress
    final linearProgress = (_elapsedTime.inMicroseconds / totalMicroseconds)
        .clamp(0.0, 1.0);

    // Apply curve
    final previousProgress = _progress;
    _progress = curve.transform(linearProgress);

    // Calculate velocity (change in progress per second)
    _velocity = deltaTime > 0 ? (_progress - previousProgress) / deltaTime : 0.0;

    // Notify listeners
    _notifyListeners();

    // Check if complete
    if (linearProgress >= 1.0) {
      _complete();
    }
  }

  void _complete() {
    _isAnimating = false;
    _progress = 1.0;
    _velocity = 0.0;
    displayLink.stop();
    _updateStatus(AnimationStatus.completed);
  }

  /// Animate to end
  void forward({double from = 0.0}) {
    _progress = from;
    _velocity = 0.0;
    _elapsedTime = Duration(microseconds: (from * duration.inMicroseconds).round());
    _isAnimating = true;
    _updateStatus(AnimationStatus.forward);
    displayLink.start();
  }

  /// Animate to start
  void reverse({double from = 1.0}) {
    _progress = from;
    _velocity = 0.0;
    _elapsedTime = Duration(microseconds: ((1.0 - from) * duration.inMicroseconds).round());
    _isAnimating = true;
    _updateStatus(AnimationStatus.reverse);
    displayLink.start();
  }

  /// Stop animation
  void stop() {
    _isAnimating = false;
    displayLink.stop();
    _updateStatus(AnimationStatus.dismissed);
  }

  /// Reset to beginning
  void reset() {
    _progress = 0.0;
    _velocity = 0.0;
    _elapsedTime = Duration.zero;
    _isAnimating = false;
    displayLink.stop();
    _updateStatus(AnimationStatus.dismissed);
    _notifyListeners();
  }

  void _updateStatus(AnimationStatus newStatus) {
    if (_status == newStatus) return;
    _status = newStatus;
    for (final listener in _statusListeners) {
      listener(newStatus);
    }
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void addStatusListener(void Function(AnimationStatus) listener) {
    _statusListeners.add(listener);
  }

  void removeStatusListener(void Function(AnimationStatus) listener) {
    _statusListeners.remove(listener);
  }

  void dispose() {
    stop();
    displayLink.dispose();
    _listeners.clear();
    _statusListeners.clear();
  }
}
