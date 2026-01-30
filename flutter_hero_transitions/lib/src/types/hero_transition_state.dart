/// Transition state machine states.
/// Mirrors iOS HeroTransitionState exactly.
enum HeroTransitionState {
  /// Hero is able to start a new transition.
  possible,

  /// UIKit (Flutter Navigator) has notified Hero of a pending transition.
  notified,

  /// Hero's start() method has been called. Preparing views and preprocessors.
  starting,

  /// Hero's animate() method has been called. Animation in progress.
  animating,

  /// Hero's complete() method has been called. Cleaning up.
  completing,
}
