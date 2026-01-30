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
    return Positioned(
      left: entry.currentRect.left,
      top: entry.currentRect.top,
      width: entry.currentRect.width.clamp(0.0, double.infinity),
      height: entry.currentRect.height.clamp(0.0, double.infinity),
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
                width: entry.currentRect.width.clamp(0.0, double.infinity),
                height: entry.currentRect.height.clamp(0.0, double.infinity),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(entry.currentCornerRadius),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: entry.currentBackgroundColor,
                      borderRadius:
                          BorderRadius.circular(entry.currentCornerRadius),
                      boxShadow: entry.currentBoxShadow != null
                          ? [entry.currentBoxShadow!]
                          : null,
                    ),
                    child: entry.snapshotWidget,
                  ),
                ),
              ),
              // Overlay
              if (entry.overlayOpacity != null &&
                  entry.overlayOpacity! > 0 &&
                  entry.overlayColor != null)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(entry.currentCornerRadius),
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
