/// Strategy for ordering views in the transition overlay.
enum HeroViewOrderingStrategy {
  /// Automatically determine ordering based on transition direction.
  auto,

  /// Source view is rendered on top of destination view.
  sourceViewOnTop,

  /// Destination view is rendered on top of source view.
  destinationViewOnTop,
}
