import 'base_preprocessor.dart';

/// Preprocessor #5: Handle the `.source(heroID:)` modifier.
/// Copies the source view's rect as the initial state for the target view.
class SourcePreprocessor extends HeroPreprocessor {
  @override
  void process({
    required List<String> fromViewIDs,
    required List<String> toViewIDs,
  }) {
    if (context == null) return;

    void processIDs(List<String> ids) {
      for (final id in ids) {
        final state = context![id];
        if (state == null || state.source == null) continue;

        final sourceID = state.source!;

        // Try to find the source view's rect
        final sourceRect = context!.sourceRect(sourceID) ??
            context!.destRect(sourceID);
        if (sourceRect == null) continue;

        // Apply the source view's position and size as beginWith state
        state.beginState ??= [];
        // The view should start at the source's position
        state.position ??= sourceRect.center;
        state.size ??= sourceRect.size;
      }
    }

    processIDs(fromViewIDs);
    processIDs(toViewIDs);
  }
}
