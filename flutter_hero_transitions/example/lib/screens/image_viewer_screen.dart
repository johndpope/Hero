import 'package:flutter/material.dart';
import 'package:flutter_hero_transitions/flutter_hero_transitions.dart';

/// Standalone fullscreen image viewer with pan-to-dismiss.
/// Used by ImageGallery when a thumbnail is tapped.
class ImageViewerScreen extends StatelessWidget {
  final int imageIndex;
  final String heroId;

  const ImageViewerScreen({
    super.key,
    required this.imageIndex,
    required this.heroId,
  });

  @override
  Widget build(BuildContext context) {
    return HeroInteractiveGesture(
      directions: const {HeroAnimationDirection.down},
      finishThreshold: 0.3,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: HeroView(
            id: heroId,
            child: InteractiveViewer(
              child: Image.asset(
                'assets/foods/unsplash${imageIndex % 10}.jpg',
                fit: BoxFit.contain,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  width: double.infinity,
                  height: 300,
                  color: HSVColor.fromAHSV(1, (imageIndex * 36.0) % 360, 0.6, 0.8).toColor(),
                  child: Center(
                    child: Text(
                      '$imageIndex',
                      style: const TextStyle(color: Colors.white, fontSize: 60),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
