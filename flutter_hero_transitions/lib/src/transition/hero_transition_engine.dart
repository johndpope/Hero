import 'package:flutter/widgets.dart';
import '../types/hero_transition_state.dart';
import '../types/hero_animation_type.dart';
import '../types/hero_view_ordering_strategy.dart';
import '../modifiers/hero_modifier.dart';
import '../preprocessors/base_preprocessor.dart';
import '../preprocessors/ignore_subview_modifiers_preprocessor.dart';
import '../preprocessors/conditional_preprocessor.dart';
import '../preprocessors/default_animation_preprocessor.dart';
import '../preprocessors/match_preprocessor.dart';
import '../preprocessors/source_preprocessor.dart';
import '../preprocessors/cascade_preprocessor.dart';
import '../animator/hero_default_animator.dart';
import '../animator/hero_animation_entry.dart';
import '../animator/hero_progress_runner.dart';
import 'hero_context.dart';
import 'hero_registry.dart';

/// Callback for transition progress updates.
typedef HeroProgressCallback = void Function(double progress);

/// Callback for transition state changes.
typedef HeroTransitionStateCallback = void Function(HeroTransitionState state);

/// The main transition engine. Singleton that orchestrates all Hero transitions.
///
/// Equivalent to iOS HeroTransition.
class HeroTransitionEngine extends ChangeNotifier {
  HeroTransitionEngine._();
  static final HeroTransitionEngine shared = HeroTransitionEngine._();

  // --- Configuration ---

  /// Default animation type for all transitions.
  HeroAnimationType defaultAnimation = const HeroAnimationType.auto();

  /// Background color of the transition container.
  Color containerColor = const Color(0x00000000);

  /// Whether user interaction is enabled during transition.
  bool isUserInteractionEnabled = false;

  /// View ordering strategy.
  HeroViewOrderingStrategy viewOrderingStrategy = HeroViewOrderingStrategy.auto;

  // --- State ---

  /// Current transition state.
  HeroTransitionState _state = HeroTransitionState.possible;
  HeroTransitionState get state => _state;

  /// Whether the current transition is a presentation (push) or dismissal (pop).
  bool isPresenting = true;

  /// Current progress (0.0 to 1.0).
  double _progress = 0.0;
  double get progress => _progress;

  /// Whether the current transition is interactive (gesture-driven).
  bool interactive = false;
  bool get isInteractive => interactive;

  /// Whether the current interactive mode was forced by the debug hook.
  bool debugForceInteractive = false;

  /// Hook that can force interactive mode. Set by [HeroDebugWrapper].
  /// When this returns true, the engine forces interactive mode on all
  /// transitions, allowing the debug overlay to control progress.
  bool Function()? forceInteractiveHook;

  /// Whether a transition is currently active.
  bool get isTransitioning => _state != HeroTransitionState.possible;

  /// Total computed animation duration.
  Duration totalDuration = const Duration(milliseconds: 375);

  // --- Internal ---

  /// The active transition context.
  HeroContext? context;

  /// The default animator.
  HeroDefaultAnimator? _animator;

  /// Active animation entries (notified to overlay for rendering).
  final ValueNotifier<List<HeroAnimationEntry>> activeAnimations =
      ValueNotifier([]);

  /// Route references.
  Route<dynamic>? _fromRoute;
  Route<dynamic>? _toRoute;

  /// Public getters for route references (used by HeroPageRoute to determine
  /// whether to hide itself during transitions).
  Route<dynamic>? get fromRoute => _fromRoute;
  Route<dynamic>? get toRoute => _toRoute;

  /// Animation controller for non-interactive transitions.
  AnimationController? _animationController;

  /// The TickerProvider (set by the overlay widget).
  TickerProvider? _tickerProvider;

  /// Progress runner for finishing/canceling interactive transitions.
  HeroProgressRunner? _progressRunner;

  /// Callbacks.
  HeroProgressCallback? onProgressUpdate;
  HeroTransitionStateCallback? onStateChange;

  // --- Public API ---

  /// Set the ticker provider (called by HeroOverlay widget).
  void setTickerProvider(TickerProvider provider) {
    _tickerProvider = provider;
  }

  /// Notify that a transition is about to happen.
  /// Called by HeroTransitionObserver when a route push/pop occurs.
  void notifyTransition({
    required Route<dynamic>? fromRoute,
    required Route<dynamic>? toRoute,
    required bool isPresenting,
    HeroAnimationType? animationType,
    bool interactive = false,
  }) {
    if (_state != HeroTransitionState.possible) return;

    _setState(HeroTransitionState.notified);
    this.isPresenting = isPresenting;
    _fromRoute = fromRoute;
    _toRoute = toRoute;
    this.interactive = interactive;
    _progress = isPresenting ? 0.0 : 1.0;

    // Schedule the start for after the next frame, when the destination
    // route's widgets have had a chance to build and register their HeroViews.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _start(animationType: animationType);
    });
  }

  /// Interactive transition: update progress (0.0 to 1.0).
  void update(double percentageComplete) {
    if (_state != HeroTransitionState.animating) return;
    _progress = percentageComplete.clamp(0.0, 1.0);
    _animator?.seekTo(_progress);
    _notifyAnimations();
    onProgressUpdate?.call(_progress);
  }

  /// Finish the transition (animate to end).
  void finish({bool animate = true}) {
    if (_state != HeroTransitionState.animating) return;

    if (!animate) {
      _complete(finished: true);
      return;
    }

    _animateToEnd(reverse: false);
  }

  /// Cancel the transition (animate back to start).
  void cancel({bool animate = true}) {
    if (_state != HeroTransitionState.animating) return;

    if (!animate) {
      _complete(finished: false);
      return;
    }

    _animateToEnd(reverse: true);
  }

  /// Apply modifiers dynamically during an interactive transition.
  void applyModifiers(List<HeroModifier> modifiers, String heroID) {
    if (context == null) return;
    final state = context![heroID];
    if (state == null) return;
    for (final mod in modifiers) {
      mod.apply(state);
    }
    // Rebuild the entry's tweens
    final entry = _animator?.entries[heroID];
    if (entry != null) {
      // Re-seek to current progress to reflect new modifiers
      entry.seekTo(_progress);
      _notifyAnimations();
    }
  }

  // --- Internal Methods ---

  void _setState(HeroTransitionState newState) {
    _state = newState;
    onStateChange?.call(newState);
    notifyListeners();
  }

  void _start({HeroAnimationType? animationType}) {
    if (_state != HeroTransitionState.notified) return;
    _setState(HeroTransitionState.starting);

    // 1. Collect all registered HeroViews from source and destination routes
    final fromViews = HeroRegistry.instance.viewsForRoute(_fromRoute);
    final toViews = HeroRegistry.instance.viewsForRoute(_toRoute);

    // Get screen size
    final screenSize = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

    // 2. Build context
    context = HeroContext(
      containerSize: screenSize,
      fromViews: fromViews,
      toViews: toViews,
    );

    // 3. Apply modifiers from registrations to target states
    for (final view in fromViews) {
      if (view.modifiers != null && view.modifiers!.isNotEmpty) {
        context!.applyModifiers(view.id, view.modifiers!);
      }
    }
    for (final view in toViews) {
      if (view.modifiers != null && view.modifiers!.isNotEmpty) {
        context!.applyModifiers(view.id, view.modifiers!);
      }
    }

    // 4. Run preprocessors in order
    final resolvedType = animationType ?? defaultAnimation;
    final preprocessors = <HeroPreprocessor>[
      IgnoreSubviewModifiersPreprocessor(),
      ConditionalPreprocessor(isPresenting: isPresenting),
      DefaultAnimationPreprocessor(
        animationType: resolvedType,
        isPresenting: isPresenting,
      ),
      MatchPreprocessor(),
      SourcePreprocessor(),
      CascadePreprocessor(),
    ];

    final fromIDs = fromViews.map((v) => v.id).toList();
    final toIDs = toViews.map((v) => v.id).toList();

    for (final preprocessor in preprocessors) {
      preprocessor.context = context;
      preprocessor.process(fromViewIDs: fromIDs, toViewIDs: toIDs);
    }

    // 5. Start animation
    _animate(fromIDs: fromIDs, toIDs: toIDs);
  }

  void _animate({required List<String> fromIDs, required List<String> toIDs}) {
    _setState(HeroTransitionState.animating);

    // Create animator
    _animator = HeroDefaultAnimator(context: context!);

    // Compute entries and durations
    totalDuration = _animator!.animate(
      fromViewIDs: fromIDs,
      toViewIDs: toIDs,
    );

    // Set entries list (structural change — triggers widget rebuild)
    _updateEntriesList();

    // Force interactive mode when debug hook is set (e.g. HeroDebugPlugin)
    if (forceInteractiveHook?.call() == true) {
      interactive = true;
      debugForceInteractive = true;
      // Notify listeners so the debug overlay can detect the transition
      // (the earlier _setState notification fired before entries were ready)
      notifyListeners();
    }

    if (!interactive) {
      // Non-interactive: drive animation with AnimationController
      _startAnimationController();
    }
    // If interactive, wait for update() calls
  }

  void _startAnimationController() {
    if (_tickerProvider == null) {
      // Fallback: seek to final state and complete after next frame
      _progress = 1.0;
      _animator?.seekTo(1.0);
      _notifyAnimations();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _complete(finished: true);
      });
      return;
    }

    _animationController = AnimationController(
      vsync: _tickerProvider!,
      duration: totalDuration,
    );

    _animationController!.addListener(() {
      _progress = _animationController!.value;
      _animator?.seekTo(_progress);
      _notifyAnimations();
      onProgressUpdate?.call(_progress);
    });

    _animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Delay completion by one frame so the overlay renders the final
        // position (progress=1.0) before being cleared. Without this, the
        // value listener and status listener both fire in the same tick —
        // the status listener clears the overlay before the final frame is
        // painted, causing the animation to appear to "zoom past" the target.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _complete(finished: true);
        });
      } else if (status == AnimationStatus.dismissed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _complete(finished: false);
        });
      }
    });

    _animationController!.forward(from: 0.0);
  }

  void _animateToEnd({required bool reverse}) {
    if (_tickerProvider == null) {
      _complete(finished: !reverse);
      return;
    }

    // Create a progress runner to animate from current progress to 0 or 1
    _progressRunner?.dispose();
    _progressRunner = HeroProgressRunner(tickerProvider: _tickerProvider!);

    _progressRunner!.onProgressUpdate = (progress) {
      _progress = progress;
      _animator?.seekTo(progress);
      _notifyAnimations();
      onProgressUpdate?.call(progress);
    };

    _progressRunner!.onComplete = (finished) {
      _complete(finished: finished);
    };

    final remaining = reverse ? _progress : (1.0 - _progress);
    final remainingDuration = Duration(
      microseconds: (totalDuration.inMicroseconds * remaining).round(),
    );

    _progressRunner!.start(
      fromProgress: _progress,
      toProgress: reverse ? 0.0 : 1.0,
      duration: remainingDuration.inMilliseconds > 50
          ? remainingDuration
          : const Duration(milliseconds: 50),
    );
  }

  void _complete({required bool finished}) {
    // Guard: completion is deferred by one frame via addPostFrameCallback,
    // so it may fire after the engine has already been reset by another
    // transition or an interactive cancel.
    if (_state != HeroTransitionState.animating &&
        _state != HeroTransitionState.completing) {
      return;
    }
    _setState(HeroTransitionState.completing);

    // Clean up
    _animationController?.dispose();
    _animationController = null;
    _progressRunner?.dispose();
    _progressRunner = null;
    _animator?.clean();
    _animator = null;

    // Clear overlay
    activeAnimations.value = [];

    // Reset state
    context = null;
    _fromRoute = null;
    _toRoute = null;
    interactive = false;
    debugForceInteractive = false;
    _progress = 0.0;

    _setState(HeroTransitionState.possible);
  }

  void _notifyAnimations() {
    if (_animator == null) return;
    // Notify listeners without creating a new List every frame.
    // The overlay's render objects listen directly and call markNeedsPaint().
    // Only create a new list on first call (structural change).
    // Subsequent calls just notify to trigger repaint.
    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    activeAnimations.notifyListeners();
  }

  /// Update the entries list (called when entries are first created).
  void _updateEntriesList() {
    if (_animator == null) return;
    activeAnimations.value = List.unmodifiable(_animator!.entries.values);
  }

  /// Dispose the engine (for testing).
  @override
  void dispose() {
    _animationController?.dispose();
    _progressRunner?.dispose();
    super.dispose();
  }
}
