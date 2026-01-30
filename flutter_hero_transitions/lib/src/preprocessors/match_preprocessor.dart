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
    }
  }
}
