import 'package:flutter/widgets.dart';
import '../transition/hero_transition_engine.dart';
import '../types/hero_animation_type.dart';

/// Widget that enables interactive gesture-driven dismiss transitions.
/// Wrap a page's content with this to support pan-to-dismiss.
///
/// Equivalent to iOS Hero's interactive transition handling via
/// UIGestureRecognizer + Hero.shared.update/finish/cancel.
///
/// Example:
/// ```dart
/// HeroInteractiveGesture(
///   child: Scaffold(...),
///   onDismiss: () => Navigator.of(context).pop(),
/// )
/// ```
class HeroInteractiveGesture extends StatefulWidget {
  /// The child widget to make interactively dismissable.
  final Widget child;

  /// Called when the gesture begins a dismiss. Should call Navigator.pop().
  final VoidCallback? onDismiss;

  /// Direction(s) in which the gesture should work.
  final Set<HeroAnimationDirection> directions;

  /// Progress threshold (0-1) above which the transition finishes.
  final double finishThreshold;

  /// Whether to factor velocity into the finish/cancel decision.
  final bool useVelocity;

  /// Velocity threshold (pixels/sec) to finish regardless of progress.
  final double velocityThreshold;

  /// Optional callback with current progress during gesture.
  final void Function(double progress)? onProgressUpdate;

  const HeroInteractiveGesture({
    super.key,
    required this.child,
    this.onDismiss,
    this.directions = const {HeroAnimationDirection.down},
    this.finishThreshold = 0.5,
    this.useVelocity = true,
    this.velocityThreshold = 1000.0,
    this.onProgressUpdate,
  });

  @override
  State<HeroInteractiveGesture> createState() =>
      _HeroInteractiveGestureState();
}

class _HeroInteractiveGestureState extends State<HeroInteractiveGesture> {
  Offset _startPosition = Offset.zero;
  bool _isDismissing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: widget.child,
    );
  }

  void _onPanStart(DragStartDetails details) {
    _startPosition = details.globalPosition;
    _isDismissing = false;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final translation = details.globalPosition - _startPosition;
    final size = MediaQuery.of(context).size;

    double progress = 0;

    if (widget.directions.contains(HeroAnimationDirection.down)) {
      progress = (translation.dy / size.height).clamp(0.0, 1.0);
    } else if (widget.directions.contains(HeroAnimationDirection.up)) {
      progress = (-translation.dy / size.height).clamp(0.0, 1.0);
    } else if (widget.directions.contains(HeroAnimationDirection.right)) {
      progress = (translation.dx / size.width).clamp(0.0, 1.0);
    } else if (widget.directions.contains(HeroAnimationDirection.left)) {
      progress = (-translation.dx / size.width).clamp(0.0, 1.0);
    }

    // Start dismiss on first significant movement
    if (!_isDismissing && progress > 0.01) {
      _isDismissing = true;
      if (widget.onDismiss != null) {
        widget.onDismiss!();
      } else {
        Navigator.of(context).pop();
      }
      // Engine should now be in interactive mode
      HeroTransitionEngine.shared.interactive = true;
    }

    if (_isDismissing) {
      HeroTransitionEngine.shared.update(progress);
      widget.onProgressUpdate?.call(progress);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDismissing) return;

    final velocity = details.velocity.pixelsPerSecond;
    final size = MediaQuery.of(context).size;
    final currentProgress = HeroTransitionEngine.shared.progress;

    bool shouldFinish = currentProgress > widget.finishThreshold;

    // Factor velocity into the decision
    if (widget.useVelocity) {
      double velocityComponent = 0;
      if (widget.directions.contains(HeroAnimationDirection.down)) {
        velocityComponent = velocity.dy;
      } else if (widget.directions.contains(HeroAnimationDirection.up)) {
        velocityComponent = -velocity.dy;
      } else if (widget.directions.contains(HeroAnimationDirection.right)) {
        velocityComponent = velocity.dx;
      } else if (widget.directions.contains(HeroAnimationDirection.left)) {
        velocityComponent = -velocity.dx;
      }

      if (velocityComponent > widget.velocityThreshold) {
        shouldFinish = true;
      } else if (velocityComponent < -widget.velocityThreshold) {
        shouldFinish = false;
      } else {
        // Use projected progress (current + velocity contribution)
        final projectedProgress = currentProgress +
            (velocityComponent / (widget.directions.contains(HeroAnimationDirection.down) ||
                    widget.directions.contains(HeroAnimationDirection.up)
                ? size.height
                : size.width)) *
                0.5;
        shouldFinish = projectedProgress > widget.finishThreshold;
      }
    }

    if (shouldFinish) {
      HeroTransitionEngine.shared.finish();
    } else {
      HeroTransitionEngine.shared.cancel();
    }

    _isDismissing = false;
  }
}
