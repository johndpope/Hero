import 'package:flutter/widgets.dart';
import '../transition/hero_context.dart';
import '../types/hero_target_state.dart';
import '../modifiers/hero_modifier.dart';
import 'hero_animation_entry.dart';

/// The default animator. Creates animation entries for each view
/// and drives tweens. Supports seek (for interactive) and resume.
///
/// Equivalent to iOS HeroDefaultAnimator<HeroCoreAnimationViewContext>.
class HeroDefaultAnimator {
  final HeroContext context;

  /// Active animation entries keyed by heroID.
  final Map<String, HeroAnimationEntry> entries = {};

  HeroDefaultAnimator({required this.context});

  /// Create animation entries for all views and compute durations.
  /// Returns the total animation duration.
  Duration animate({
    required List<String> fromViewIDs,
    required List<String> toViewIDs,
  }) {
    Duration maxDuration = Duration.zero;

    // Matched views: create a single entry that morphs from source to destination
    final matched = context.matchedIDs;
    for (final id in matched) {
      final sourceRect = context.sourceRect(id);
      var destRect = context.destRect(id);
      if (sourceRect == null || destRect == null) continue;

      // If the destination rect has a zero dimension (e.g., Image widget hasn't
      // loaded yet), compute a reasonable target using the source's aspect ratio
      // centered on the destination's position. This prevents squish artifacts.
      if (destRect.width <= 0 || destRect.height <= 0) {
        // Use the full container width and maintain source aspect ratio
        final containerWidth = context.containerSize.width;
        final aspectRatio = sourceRect.height / sourceRect.width;
        final targetHeight = containerWidth * aspectRatio;
        destRect = Rect.fromCenter(
          center: destRect.center.dy == 0
              ? Offset(containerWidth / 2, context.containerSize.height / 2)
              : destRect.center,
          width: containerWidth,
          height: targetHeight,
        );
      }

      final state = context[id] ?? HeroTargetState();
      final sourceReg = context.sourceView(id);
      final destReg = context.destinationView(id);

      final entry = HeroAnimationEntry(
        heroID: id,
        appearing: true, // matched views morph to destination
        sourceRect: sourceRect,
        targetRect: destRect,
        targetState: state,
        // For matched views, prefer the source widget as the snapshot.
        // The source is already loaded and rendered (like iOS CALayer snapshot).
        // The destination widget may not be ready (e.g., Image not loaded).
        snapshotWidget: _buildSnapshotWidget(sourceReg, destReg, sourceRect),
      );

      entry.animationDuration = state.duration ?? _calculateDuration(sourceRect, destRect);
      entries[id] = entry;
    }

    // Unmatched source views (disappearing)
    for (final id in context.unmatchedSourceIDs) {
      final sourceRect = context.sourceRect(id);
      if (sourceRect == null) continue;
      final state = context[id] ?? HeroTargetState();
      final sourceReg = context.sourceView(id);

      // Target rect: apply position/size from modifiers, or stay in place
      final targetRect = _computeTargetRect(sourceRect, state);

      final entry = HeroAnimationEntry(
        heroID: id,
        appearing: false,
        sourceRect: sourceRect,
        targetRect: targetRect,
        targetState: state,
        snapshotWidget: _buildSnapshotWidget(sourceReg, null, sourceRect),
      );

      entry.animationDuration = state.duration ?? _calculateDuration(sourceRect, targetRect);
      entries[id] = entry;
    }

    // Unmatched destination views (appearing)
    for (final id in context.unmatchedDestIDs) {
      final destRect = context.destRect(id);
      if (destRect == null) continue;
      final state = context[id] ?? HeroTargetState();
      final destReg = context.destinationView(id);

      // Source rect: compute from beginWith modifiers or same as dest
      final sourceRect = _computeSourceRect(destRect, state);

      final entry = HeroAnimationEntry(
        heroID: id,
        appearing: true,
        sourceRect: sourceRect,
        targetRect: destRect,
        targetState: state,
        snapshotWidget: _buildSnapshotWidget(null, destReg, sourceRect),
      );

      entry.animationDuration = state.duration ?? _calculateDuration(sourceRect, destRect);
      entries[id] = entry;
    }

    // Find max duration for durationMatchLongest
    for (final entry in entries.values) {
      if (!entry.targetState.durationMatchLongest) {
        final totalEntryDuration = entry.animationDuration + entry.targetState.delay;
        if (totalEntryDuration > maxDuration) {
          maxDuration = totalEntryDuration;
        }
      }
    }

    // Apply durationMatchLongest
    for (final entry in entries.values) {
      if (entry.targetState.durationMatchLongest) {
        entry.animationDuration = maxDuration;
      }
    }

    // Recalculate max with all entries
    maxDuration = Duration.zero;
    for (final entry in entries.values) {
      final total = entry.animationDuration + entry.targetState.delay;
      if (total > maxDuration) maxDuration = total;
    }

    return maxDuration;
  }

  /// Seek all entries to a progress value (0.0 to 1.0).
  void seekTo(double progress) {
    for (final entry in entries.values) {
      entry.seekTo(progress);
    }
  }

  /// Clean up all entries.
  void clean() {
    entries.clear();
  }

  /// Calculate duration using the EXACT iOS Hero formula.
  ///
  /// From HeroDefaultAnimator.swift:
  ///   let movePoints = (realFromPos.distance(realToPos) + realFromSize.point.distance(realToSize.point))
  ///   let duration = 0.208 + Double(movePoints.clamp(0, 500)) / 3000
  ///
  /// This gives 208ms @ 0pt → 375ms @ 500pt.
  Duration _calculateDuration(Rect from, Rect to) {
    final positionDistance = (from.center - to.center).distance;
    final sizeDistance = (Offset(from.width, from.height) -
            Offset(to.width, to.height))
        .distance;
    final movePoints = positionDistance + sizeDistance;

    // EXACT iOS formula: 0.208 + clamp(movePoints, 0, 500) / 3000
    final seconds = 0.208 + movePoints.clamp(0.0, 500.0) / 3000.0;

    return Duration(milliseconds: (seconds * 1000).round());
  }

  /// Compute target rect from source rect + modifiers (for disappearing views).
  Rect _computeTargetRect(Rect sourceRect, HeroTargetState state) {
    Offset targetCenter = sourceRect.center;
    Size targetSize = sourceRect.size;

    if (state.position != null) {
      targetCenter = state.position!;
    }
    if (state.size != null) {
      targetSize = state.size!;
    }
    if (state.transform != null) {
      // Apply transform offset to position
      final tx = state.transform!.getTranslation();
      targetCenter = targetCenter + Offset(tx.x, tx.y);
    }

    return Rect.fromCenter(
      center: targetCenter,
      width: targetSize.width,
      height: targetSize.height,
    );
  }

  /// Compute source rect for appearing views from beginWith modifiers.
  Rect _computeSourceRect(Rect destRect, HeroTargetState state) {
    if (state.beginState == null || state.beginState!.isEmpty) {
      return destRect;
    }

    // Apply beginWith modifiers to compute the starting state
    final beginTargetState = HeroTargetState();
    for (final modifier in state.beginState!) {
      if (modifier is HeroModifier) {
        modifier.apply(beginTargetState);
      }
    }

    Offset sourceCenter = destRect.center;
    Size sourceSize = destRect.size;

    if (beginTargetState.position != null) {
      sourceCenter = beginTargetState.position!;
    }
    if (beginTargetState.size != null) {
      sourceSize = beginTargetState.size!;
    }
    if (beginTargetState.transform != null) {
      final tx = beginTargetState.transform!.getTranslation();
      sourceCenter = sourceCenter + Offset(tx.x, tx.y);
    }

    return Rect.fromCenter(
      center: sourceCenter,
      width: sourceSize.width,
      height: sourceSize.height,
    );
  }

  /// Build a snapshot widget for the animation overlay.
  ///
  /// For matched views (both sourceReg and destReg non-null), prefer the
  /// source widget since it's already loaded and rendered. The destination
  /// widget (e.g., an Image.asset) may not have resolved its dimensions yet.
  /// This matches iOS Hero behavior where a CALayer snapshot of the source
  /// view is used during the morph.
  Widget _buildSnapshotWidget(
    dynamic sourceReg,
    dynamic destReg,
    Rect rect,
  ) {
    // For matched views, prefer source (already rendered and loaded).
    // For unmatched, use whichever is available.
    final reg = (sourceReg != null && destReg != null)
        ? sourceReg
        : (destReg ?? sourceReg);
    if (reg == null) return const SizedBox.shrink();

    // Access the GlobalKey to get the current widget
    final currentContext = reg.globalKey?.currentContext as BuildContext?;
    if (currentContext == null) return const SizedBox.shrink();

    final widget = currentContext.widget;
    if (widget is KeyedSubtree) {
      return SizedBox(
        width: rect.width,
        height: rect.height,
        child: widget.child,
      );
    }

    return SizedBox(
      width: rect.width,
      height: rect.height,
    );
  }
}
