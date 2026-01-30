import '../transition/hero_context.dart';

/// Base interface for all preprocessors.
/// Preprocessors modify view target states before animation begins.
abstract class HeroPreprocessor {
  HeroContext? context;

  /// Process views before animation.
  void process({
    required List<String> fromViewIDs,
    required List<String> toViewIDs,
  });
}
