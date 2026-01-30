import 'dart:ui';
import 'base_preprocessor.dart';

/// Preprocessor #6: Sort child views by cascade direction
/// and apply incremental delays for staggered animation.
class CascadePreprocessor extends HeroPreprocessor {
  @override
  void process({
    required List<String> fromViewIDs,
    required List<String> toViewIDs,
  }) {
    if (context == null) return;

    _processCascade(fromViewIDs);
    _processCascade(toViewIDs);
  }

  void _processCascade(List<String> ids) {
    // Find IDs that have cascade config
    for (final id in ids) {
      final state = context![id];
      if (state?.cascade == null) continue;

      final cascadeConfig = state!.cascade!;
      final matched = context!.matchedIDs;

      // Collect all sibling IDs that should be cascaded
      // In Flutter, we cascade all IDs in the same route
      final siblingIDs = List<String>.from(ids);
      siblingIDs.remove(id); // Don't cascade the parent itself

      if (siblingIDs.isEmpty) continue;

      // Sort by position according to cascade direction
      final sortableEntries = <_SortableEntry>[];
      for (final siblingID in siblingIDs) {
        final rect = context!.sourceRect(siblingID) ??
            context!.destRect(siblingID);
        if (rect == null) continue;
        sortableEntries.add(_SortableEntry(id: siblingID, center: rect.center));
      }

      sortableEntries.sort((a, b) =>
          cascadeConfig.direction.compare(a.center, b.center));

      // Apply incremental delays
      for (int i = 0; i < sortableEntries.length; i++) {
        final entry = sortableEntries[i];
        if (!cascadeConfig.delayMatchedViews && matched.contains(entry.id)) {
          continue;
        }
        final siblingState = context!.targetStateFor(entry.id);
        final cascadeDelay = Duration(
          microseconds: cascadeConfig.delta.inMicroseconds * i,
        );
        siblingState.delay = siblingState.delay + cascadeDelay;
      }
    }
  }
}

class _SortableEntry {
  final String id;
  final Offset center;
  const _SortableEntry({required this.id, required this.center});
}
