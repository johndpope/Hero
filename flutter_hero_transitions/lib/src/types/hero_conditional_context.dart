/// Context information available to conditional modifiers.
/// Equivalent to iOS HeroConditionalContext.
class HeroConditionalContext {
  /// The hero ID of the view being evaluated.
  final String heroID;

  /// Whether this view is appearing (destination) or disappearing (source).
  final bool isAppearing;

  /// Whether the overall transition is a presentation (push) or dismissal (pop).
  final bool isPresenting;

  /// Whether this view has a matching view in the other route.
  final bool isMatched;

  const HeroConditionalContext({
    required this.heroID,
    required this.isAppearing,
    required this.isPresenting,
    required this.isMatched,
  });
}
