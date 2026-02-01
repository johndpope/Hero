import 'package:flutter/widgets.dart';
import '../types/hero_target_state.dart';
import '../extensions/curve_extensions.dart';
import 'arc_tween.dart';
import 'hero_spring_simulation.dart';

/// Represents one animating element in the transition overlay.
/// Holds tweens, current computed values, and seek logic.
class HeroAnimationEntry {
  /// The hero ID this entry animates.
  final String heroID;

  /// Whether this view is appearing (destination) or disappearing (source).
  final bool appearing;

  /// The starting rect (global coordinates).
  final Rect sourceRect;

  /// The target rect (global coordinates).
  final Rect targetRect;

  /// Target state with all modifiers applied.
  final HeroTargetState targetState;

  /// The widget to render during animation (source snapshot for matched views).
  final Widget snapshotWidget;

  /// For matched views: the destination widget to cross-fade into.
  /// When non-null, the overlay cross-fades from snapshotWidget to this.
  final Widget? destSnapshotWidget;

  /// The native size the source snapshot was captured at.
  /// Used to render the snapshot at its original size and scale to fit.
  final Size sourceSnapshotSize;

  /// The native size the destination snapshot was captured at.
  /// Used to render the snapshot at its original size and scale to fit.
  final Size? destSnapshotSize;

  /// Current cross-fade progress (0.0 = source, 1.0 = destination).
  /// Only meaningful when destSnapshotWidget is non-null.
  double crossFadeProgress = 0.0;

  /// Computed animation duration for this entry.
  Duration animationDuration;

  // --- Tweens ---
  late Tween<double> _leftTween;
  late Tween<double> _topTween;
  late Tween<double> _widthTween;
  late Tween<double> _heightTween;
  late Tween<double> _opacityTween;
  late Tween<double> _cornerRadiusTween;
  Tween<Offset>? _positionTween; // May be ArcTween
  Tween<Matrix4>? _transformTween;
  ColorTween? _backgroundColorTween;
  Tween<double>? _shadowOpacityTween;
  Tween<double>? _shadowRadiusTween;
  Tween<Offset>? _shadowOffsetTween;
  ColorTween? _shadowColorTween;
  Tween<double>? _overlayOpacityTween;

  // --- Current computed values ---
  Rect currentRect;
  double currentOpacity = 1.0;
  double currentCornerRadius = 0.0;
  Matrix4 currentTransform = Matrix4.identity();
  Color? currentBackgroundColor;
  double currentShadowOpacity = 0.0;
  double currentShadowRadius = 0.0;
  Offset currentShadowOffset = Offset.zero;
  Color currentShadowColor = const Color(0xFF000000);
  double? overlayOpacity;
  Color? overlayColor;

  HeroAnimationEntry({
    required this.heroID,
    required this.appearing,
    required this.sourceRect,
    required this.targetRect,
    required this.targetState,
    required this.snapshotWidget,
    this.destSnapshotWidget,
    required this.sourceSnapshotSize,
    this.destSnapshotSize,
    this.animationDuration = const Duration(milliseconds: 350),
  }) : currentRect = sourceRect {
    _buildTweens();
  }

  void _buildTweens() {
    final sRect = sourceRect;
    final tRect = targetRect;

    // Position tweens
    if (targetState.arcIntensity != null && targetState.arcIntensity! > 0) {
      _positionTween = ArcTween(
        begin: sRect.center,
        end: tRect.center,
        intensity: targetState.arcIntensity!,
      );
    }

    _leftTween = Tween(begin: sRect.left, end: tRect.left);
    _topTween = Tween(begin: sRect.top, end: tRect.top);
    _widthTween = Tween(begin: sRect.width, end: tRect.width);
    _heightTween = Tween(begin: sRect.height, end: tRect.height);

    // Opacity
    final sourceOpacity = appearing ? (targetState.opacity ?? 1.0) : 1.0;
    final destOpacity = appearing ? 1.0 : (targetState.opacity ?? 1.0);
    _opacityTween = Tween(begin: sourceOpacity, end: destOpacity);

    // Corner radius
    final sourceRadius = appearing ? (targetState.cornerRadius ?? 0.0) : 0.0;
    final destRadius = appearing ? 0.0 : (targetState.cornerRadius ?? 0.0);
    _cornerRadiusTween = Tween(begin: sourceRadius, end: destRadius);

    // Transform
    if (targetState.transform != null) {
      final sourceTransform = appearing ? targetState.transform! : Matrix4.identity();
      final destTransform = appearing ? Matrix4.identity() : targetState.transform!;
      _transformTween = Matrix4Tween(begin: sourceTransform, end: destTransform);
    }

    // Background color
    if (targetState.backgroundColor != null) {
      final sourceColor = appearing ? targetState.backgroundColor : null;
      final destColor = appearing ? null : targetState.backgroundColor;
      _backgroundColorTween = ColorTween(begin: sourceColor, end: destColor);
    }

    // Shadow
    if (targetState.shadowOpacity != null) {
      _shadowOpacityTween = Tween(
        begin: appearing ? 0.0 : (targetState.shadowOpacity ?? 0.0),
        end: appearing ? (targetState.shadowOpacity ?? 0.0) : 0.0,
      );
    }
    if (targetState.shadowRadius != null) {
      _shadowRadiusTween = Tween(
        begin: 0.0,
        end: targetState.shadowRadius!,
      );
    }
    if (targetState.shadowOffset != null) {
      _shadowOffsetTween = Tween(
        begin: Offset.zero,
        end: targetState.shadowOffset!,
      );
    }
    if (targetState.shadowColor != null) {
      _shadowColorTween = ColorTween(
        begin: const Color(0xFF000000),
        end: targetState.shadowColor!,
      );
    }

    // Overlay
    if (targetState.overlay != null) {
      overlayColor = targetState.overlay!.color;
      _overlayOpacityTween = Tween(
        begin: appearing ? targetState.overlay!.opacity : 0.0,
        end: appearing ? 0.0 : targetState.overlay!.opacity,
      );
    }
  }

  /// Seek to a specific progress value (0.0 to 1.0).
  void seekTo(double progress) {
    // Use Material Standard curve (0.4, 0, 0.2, 1) — the ACTUAL default
    // used by iOS Hero library (NOT iOS system easeInOut).
    final curve = targetState.curve ?? HeroCurves.standard;

    // Total duration including delay
    final totalDurationUs = animationDuration.inMicroseconds +
        targetState.delay.inMicroseconds;
    final delayFraction = totalDurationUs > 0
        ? targetState.delay.inMicroseconds / totalDurationUs
        : 0.0;

    // Adjust progress for delay
    double adjustedProgress;
    if (progress < delayFraction) {
      adjustedProgress = 0.0;
    } else {
      adjustedProgress =
          ((progress - delayFraction) / (1.0 - delayFraction)).clamp(0.0, 1.0);
    }

    // Apply spring physics if spring is set
    double curvedT;
    if (targetState.spring != null) {
      // Use real spring simulation like iOS CASpringAnimation
      curvedT = _evaluateSpring(adjustedProgress);
    } else {
      curvedT = curve.transform(adjustedProgress);
    }

    _applyProgress(curvedT);
  }

  /// Evaluate spring physics at a given normalized time.
  /// Returns the output position (0.0 to 1.0) matching CASpringAnimation behavior.
  double _evaluateSpring(double normalizedTime) {
    if (normalizedTime <= 0.0) return 0.0;
    if (normalizedTime >= 1.0) return 1.0;

    final spring = targetState.spring!;
    final sim = HeroSpringSimulation(
      initialPosition: 0.0,
      targetPosition: 1.0,
      mass: spring.mass,
      stiffness: spring.stiffness,
      dampingRatio: spring.dampingRatio,
    );

    // Map normalizedTime to actual spring time
    final springDuration = sim.settlingDuration;
    final time = normalizedTime * springDuration;
    return sim.x(time).clamp(0.0, 1.5); // Allow slight overshoot for bounce
  }

  void _applyProgress(double t) {
    // Position - use arc tween if available
    if (_positionTween != null) {
      final pos = _positionTween!.transform(t);
      final w = _widthTween.transform(t);
      final h = _heightTween.transform(t);
      currentRect = Rect.fromCenter(center: pos, width: w, height: h);
    } else {
      currentRect = Rect.fromLTWH(
        _leftTween.transform(t),
        _topTween.transform(t),
        _widthTween.transform(t),
        _heightTween.transform(t),
      );
    }

    currentOpacity = _opacityTween.transform(t).clamp(0.0, 1.0);
    currentCornerRadius = _cornerRadiusTween.transform(t);

    if (_transformTween != null) {
      currentTransform = _transformTween!.transform(t);
    }
    if (_backgroundColorTween != null) {
      currentBackgroundColor = _backgroundColorTween!.transform(t);
    }
    if (_shadowOpacityTween != null) {
      currentShadowOpacity = _shadowOpacityTween!.transform(t);
    }
    if (_shadowRadiusTween != null) {
      currentShadowRadius = _shadowRadiusTween!.transform(t);
    }
    if (_shadowOffsetTween != null) {
      currentShadowOffset = _shadowOffsetTween!.transform(t);
    }
    if (_shadowColorTween != null) {
      currentShadowColor = _shadowColorTween!.transform(t) ?? const Color(0xFF000000);
    }
    if (_overlayOpacityTween != null) {
      overlayOpacity = _overlayOpacityTween!.transform(t);
    }

    // Cross-fade progress for matched views (source → destination).
    // Uses the raw animation progress t so cross-fade is smooth and linear.
    if (destSnapshotWidget != null) {
      crossFadeProgress = t.clamp(0.0, 1.0);
    }
  }

  /// Get the current BoxShadow (null if no shadow).
  BoxShadow? get currentBoxShadow {
    if (currentShadowOpacity <= 0) return null;
    return BoxShadow(
      color: currentShadowColor.withValues(alpha: currentShadowOpacity),
      blurRadius: currentShadowRadius,
      offset: currentShadowOffset,
    );
  }
}
