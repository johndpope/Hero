/// Snapshot strategy for capturing views during transition.
enum HeroSnapshotType {
  /// Optimize snapshot based on view type.
  optimized,

  /// Standard snapshot capture.
  normal,

  /// Render layer-based snapshot.
  layerRender,

  /// Don't create a snapshot; animate the actual widget.
  noSnapshot,
}
