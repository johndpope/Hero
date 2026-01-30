import 'base_preprocessor.dart';
import '../types/hero_conditional_context.dart';
import '../modifiers/hero_modifier.dart';

/// Preprocessor #2: Evaluate conditional modifiers
/// (when, whenMatched, whenPresenting, etc.)
class ConditionalPreprocessor extends HeroPreprocessor {
  final bool isPresenting;

  ConditionalPreprocessor({required this.isPresenting});

  @override
  void process({
    required List<String> fromViewIDs,
    required List<String> toViewIDs,
  }) {
    if (context == null) return;

    void processIDs(List<String> ids, bool isAppearing) {
      for (final id in ids) {
        final state = context![id];
        if (state == null) continue;

        final conditionals = state.conditionalModifiers;
        if (conditionals == null || conditionals.isEmpty) continue;

        final condContext = HeroConditionalContext(
          heroID: id,
          isAppearing: isAppearing,
          isPresenting: isPresenting,
          isMatched: context!.isMatched(id),
        );

        for (final entry in conditionals) {
          if (entry.condition(condContext)) {
            for (final modifier in entry.modifiers) {
              if (modifier is HeroModifier) {
                modifier.apply(state);
              }
            }
          }
        }

        // Clear conditional modifiers after processing
        state.conditionalModifiers = null;
      }
    }

    // Source views are disappearing, destination views are appearing
    processIDs(fromViewIDs, false);
    processIDs(toViewIDs, true);
  }
}
