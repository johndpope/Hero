import '../preprocessors/base_preprocessor.dart';
import '../transition/hero_context.dart';
import '../transition/hero_transition_engine.dart';

/// Abstract interface for Hero animators.
abstract class HeroAnimatorInterface {
  HeroContext? context;

  /// Check if this animator can handle a specific view.
  bool canAnimate(String heroID, bool appearing);

  /// Animate the given views. Returns the computed duration.
  Duration animate({
    required List<String> fromViewIDs,
    required List<String> toViewIDs,
  });

  /// Seek to a specific time.
  void seekTo(Duration timePassed);

  /// Resume animation after interactive gesture.
  Duration resume({required Duration timePassed, required bool reverse});

  /// Clean up resources.
  void clean();
}

/// Base class for Hero plugins. Combines preprocessor and animator capabilities.
///
/// Equivalent to iOS HeroPlugin which conforms to both
/// HeroPreprocessor and HeroAnimator.
abstract class HeroPlugin extends HeroPreprocessor implements HeroAnimatorInterface {
  HeroTransitionEngine? engine;

  /// If true, seekTo is called on every frame even during non-interactive transitions.
  bool get requirePerFrameCallback => false;

  @override
  void process({
    required List<String> fromViewIDs,
    required List<String> toViewIDs,
  }) {}

  @override
  bool canAnimate(String heroID, bool appearing) => false;

  @override
  Duration animate({
    required List<String> fromViewIDs,
    required List<String> toViewIDs,
  }) => Duration.zero;

  @override
  void seekTo(Duration timePassed) {}

  @override
  Duration resume({required Duration timePassed, required bool reverse}) =>
      Duration.zero;

  @override
  void clean() {}

  // --- Static Plugin Management ---

  static final List<HeroPlugin Function()> _enabledPlugins = [];

  /// Enable a plugin type.
  static void enable(HeroPlugin Function() factory) {
    _enabledPlugins.add(factory);
  }

  /// Disable a plugin type.
  static void disable<T extends HeroPlugin>() {
    _enabledPlugins.removeWhere((f) => f() is T);
  }

  /// Get all enabled plugin instances.
  static List<HeroPlugin> get enabledPlugins =>
      _enabledPlugins.map((f) => f()).toList();
}
