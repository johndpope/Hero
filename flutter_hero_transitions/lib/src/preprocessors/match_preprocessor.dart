import 'base_preprocessor.dart';

/// Preprocessor #4: For matched hero IDs, compute the target position
/// and size from the paired view's global rect.
class MatchPreprocessor extends HeroPreprocessor {
  @override
  void process({
    required List<String> fromViewIDs,
    required List<String> toViewIDs,
  }) {
    if (context == null) return;

    final matched = context!.matchedIDs;

    for (final id in matched) {
      final sourceRect = context!.sourceRect(id);
      final destRect = context!.destRect(id);
      if (sourceRect == null || destRect == null) continue;

      // For the source view (disappearing): animate TO the destination's position/size
      final sourceState = context!.targetStateFor(id);
      if (sourceState.position == null) {
        sourceState.position = destRect.center;
      }
      if (sourceState.size == null) {
        sourceState.size = destRect.size;
      }

      // For matched views, clear appearance modifiers (fade, scale, transform,
      // overlay). These modifiers are meant for UNMATCHED views that appear/
      // disappear. Matched views should morph visibly between source and
      // destination — the position/size tween IS the animation. This matches
      // iOS Hero behavior where matched views are always fully visible.
      sourceState.opacity = null;
      sourceState.transform = null;
      sourceState.overlay = null;
    }
  }
}
