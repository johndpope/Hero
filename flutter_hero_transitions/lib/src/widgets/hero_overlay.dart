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

  Widget _buildAnimatedProxy(HeroAnimationEntry entry) {
    final w = entry.currentRect.width.clamp(0.0, double.infinity);
    final h = entry.currentRect.height.clamp(0.0, double.infinity);
    final borderRadius = BorderRadius.circular(entry.currentCornerRadius);

    // Build the content widget — either a single snapshot or a cross-fade
    // between source and destination snapshots (for matched views).
    Widget contentWidget;
    if (entry.destSnapshotWidget != null) {
      // Cross-fade: source fades out, destination fades in.
      // Both are rendered at the current interpolated size so they
      // fill the morphing frame correctly.
      final t = entry.crossFadeProgress;
      contentWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          // Destination snapshot (behind, fading in)
          if (t > 0.0)
            Opacity(
              opacity: t.clamp(0.0, 1.0),
              child: SizedBox(width: w, height: h, child: entry.destSnapshotWidget),
            ),
          // Source snapshot (on top, fading out)
          if (t < 1.0)
            Opacity(
              opacity: (1.0 - t).clamp(0.0, 1.0),
              child: SizedBox(width: w, height: h, child: entry.snapshotWidget),
            ),
        ],
      );
    } else {
      contentWidget = entry.snapshotWidget;
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
