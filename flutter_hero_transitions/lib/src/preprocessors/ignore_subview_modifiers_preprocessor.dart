import 'base_preprocessor.dart';

/// Preprocessor #1: Remove modifiers from subviews when parent
/// has the ignoreSubviewModifiers modifier set.
class IgnoreSubviewModifiersPreprocessor extends HeroPreprocessor {
  @override
  void process({
    required List<String> fromViewIDs,
    required List<String> toViewIDs,
  }) {
    if (context == null) return;

    void processIDs(List<String> ids) {
      for (final id in ids) {
        final state = context![id];
        if (state?.ignoreSubviewModifiers != null) {
          // In a widget tree, we don't have direct parent-child relationships
          // between HeroViews the same way iOS does. This preprocessor
          // is kept for API compatibility but the behavior is handled
          // differently in Flutter - the HeroView.isEnabledForSubviews
          // property prevents child registration instead.
        }
      }
    }

    processIDs(fromViewIDs);
    processIDs(toViewIDs);
  }
}
