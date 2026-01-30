import 'package:flutter/scheduler.dart';

/// Drives progress from current value to 0 or 1 using a Ticker.
/// Equivalent to iOS HeroProgressRunner using CADisplayLink.
class HeroProgressRunner {
  final TickerProvider tickerProvider;
  Ticker? _ticker;
  Duration _elapsed = Duration.zero;

  double _fromProgress = 0.0;
  double _toProgress = 1.0;
  Duration _duration = const Duration(milliseconds: 350);

  bool get isRunning => _ticker?.isActive ?? false;

  /// Called on each frame with the interpolated progress value.
  void Function(double progress)? onProgressUpdate;

  /// Called when the animation completes. `finished` is true if it ran to
  /// the end, false if it ran back to the start.
  void Function(bool finished)? onComplete;

  HeroProgressRunner({required this.tickerProvider});

  /// Start animating from current progress to the target.
  void start({
    required double fromProgress,
    required double toProgress,
    required Duration duration,
  }) {
    stop();
    _fromProgress = fromProgress;
    _toProgress = toProgress;
    _duration = duration;
    _elapsed = Duration.zero;

    _ticker = tickerProvider.createTicker(_onTick);
    _ticker!.start();
  }

  void _onTick(Duration elapsed) {
    _elapsed = elapsed;

    if (_duration.inMicroseconds <= 0) {
      onProgressUpdate?.call(_toProgress);
      onComplete?.call(_toProgress >= 0.5);
      stop();
      return;
    }

    final fraction =
        (_elapsed.inMicroseconds / _duration.inMicroseconds).clamp(0.0, 1.0);
    final progress =
        _fromProgress + (_toProgress - _fromProgress) * fraction;

    onProgressUpdate?.call(progress);

    if (fraction >= 1.0) {
      onComplete?.call(_toProgress >= 0.5);
      stop();
    }
  }

  /// Stop the animation.
  void stop() {
    _ticker?.stop();
    _ticker?.dispose();
    _ticker = null;
  }

  /// Dispose resources.
  void dispose() {
    stop();
  }
}
