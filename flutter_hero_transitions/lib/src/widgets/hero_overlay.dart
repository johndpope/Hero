import 'package:flutter/material.dart';
import '../transition/hero_transition_engine.dart';
import '../animator/hero_animation_entry.dart';

/// Full-screen overlay that renders animated proxy widgets during transitions.
/// Place this in your app's widget tree above the Navigator.
///
/// Example:
/// ```dart
/// MaterialApp(
///   builder: (context, child) {
///     return Stack(
///       children: [
///         child!,
///         const HeroOverlay(),
///       ],
///     );
///   },
/// )
/// ```
class HeroOverlay extends StatefulWidget {
  const HeroOverlay({super.key});

  @override
  State<HeroOverlay> createState() => _HeroOverlayState();
}

class _HeroOverlayState extends State<HeroOverlay>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    HeroTransitionEngine.shared.setTickerProvider(this);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<HeroAnimationEntry>>(
      valueListenable: HeroTransitionEngine.shared.activeAnimations,
      builder: (context, entries, _) {
        if (entries.isEmpty) return const SizedBox.shrink();

        return IgnorePointer(
          ignoring: !HeroTransitionEngine.shared.isUserInteractionEnabled,
          child: Stack(
            children: [
              // Optional background color
              if ((HeroTransitionEngine.shared.containerColor.a * 255).round() > 0)
                Positioned.fill(
                  child: ColoredBox(
                    color: HeroTransitionEngine.shared.containerColor,
                  ),
                ),
              // Animated proxy widgets
              ...entries.map(_buildAnimatedProxy),
            ],
          ),
        );
      },
    );
  }

  /// Build a snapshot widget rendered at its native size and stretched to fill
  /// the current animated rect. This mimics iOS CALayer bitmap snapshot
  /// behavior — content is rendered once at its original size, then the
  /// layer is stretched to fill the morphing frame (like a rasterized bitmap).
  /// The cross-fade between source and destination masks any intermediate
  /// distortion, just as iOS cross-fades two CALayer snapshots.
  Widget _buildScaledSnapshot(Widget snapshot, Size nativeSize, double w, double h) {
    return SizedBox(
      width: w,
      height: h,
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox(
          width: nativeSize.width,
          height: nativeSize.height,
          child: snapshot,
        ),
      ),
    );
  }

  Widget _buildAnimatedProxy(HeroAnimationEntry entry) {
    final w = entry.currentRect.width.clamp(0.0, double.infinity);
    final h = entry.currentRect.height.clamp(0.0, double.infinity);
    final borderRadius = BorderRadius.circular(entry.currentCornerRadius);

    // Build the content widget — either a single snapshot or a cross-fade
    // between source and destination snapshots (for matched views).
    Widget contentWidget;
    if (entry.destSnapshotWidget != null && entry.destSnapshotSize != null) {
      // Cross-fade: source fades out, destination fades in.
      //
      // SOURCE snapshot: rendered at its native size and bitmap-scaled via
      // FittedBox.fill to fill the animated rect (like an iOS CALayer bitmap
      // snapshot). Any aspect-ratio distortion is masked by the cross-fade
      // since the source is fading out.
      //
      // DESTINATION snapshot: rendered directly at the animated rect size.
      // Widgets like Stack(fit: StackFit.expand) + Image(fit: BoxFit.cover)
      // naturally adapt to any size, so no FittedBox is needed. This avoids
      // the distortion caused by rendering at native size then stretching.
      final t = entry.crossFadeProgress;
      contentWidget = Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Destination snapshot (behind, fading in) — renders at animated size
          if (t > 0.0)
            Opacity(
              opacity: t.clamp(0.0, 1.0),
              child: SizedBox(
                width: w,
                height: h,
                child: entry.destSnapshotWidget!,
              ),
            ),
          // Source snapshot (on top, fading out) — bitmap-scaled from native size
          if (t < 1.0)
            Opacity(
              opacity: (1.0 - t).clamp(0.0, 1.0),
              child: _buildScaledSnapshot(
                entry.snapshotWidget, entry.sourceSnapshotSize, w, h,
              ),
            ),
        ],
      );
    } else {
      // Single snapshot (unmatched views) — bitmap-scale to fill animated rect
      contentWidget = _buildScaledSnapshot(
        entry.snapshotWidget, entry.sourceSnapshotSize, w, h,
      );
    }

    return Positioned(
      left: entry.currentRect.left,
      top: entry.currentRect.top,
      width: w,
      height: h,
      child: Transform(
        transform: entry.currentTransform,
        alignment: Alignment.center,
        child: Opacity(
          opacity: entry.currentOpacity.clamp(0.0, 1.0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Main content
              SizedBox(
                width: w,
                height: h,
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: entry.currentBackgroundColor,
                      borderRadius: borderRadius,
                      boxShadow: entry.currentBoxShadow != null
                          ? [entry.currentBoxShadow!]
                          : null,
                    ),
                    child: contentWidget,
                  ),
                ),
              ),
              // Overlay
              if (entry.overlayOpacity != null &&
                  entry.overlayOpacity! > 0 &&
                  entry.overlayColor != null)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: borderRadius,
                    child: ColoredBox(
                      color: entry.overlayColor!
                          .withValues(alpha: entry.overlayOpacity!.clamp(0.0, 1.0)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
