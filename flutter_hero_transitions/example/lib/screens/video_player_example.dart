import 'package:flutter/material.dart';
import 'package:flutter_hero_transitions/flutter_hero_transitions.dart';
import '../widgets/example_scaffold.dart';

/// Video Player Example - interactive dismiss with video placeholder.
/// Uses a placeholder since video_player needs actual video assets.
class VideoPlayerExampleScreen extends StatelessWidget {
  const VideoPlayerExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  HeroPageRoute(
                    animationType: const HeroAnimationType.none(),
                    builder: (_) => const _VideoFullscreenScreen(),
                  ),
                );
              },
              child: HeroView(
                id: 'videoPlayer',
                modifiers: [HeroModifier.useNoSnapshot],
                child: Container(
                  width: 320,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/bigbuckbunny.jpg',
                          fit: BoxFit.cover,
                          width: 320,
                          height: 180,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[900],
                            child: const Center(
                              child: Icon(Icons.movie, color: Colors.white54, size: 50),
                            ),
                          ),
                        ),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Tap to play fullscreen', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class _VideoFullscreenScreen extends StatelessWidget {
  const _VideoFullscreenScreen();

  @override
  Widget build(BuildContext context) {
    return HeroInteractiveGesture(
      directions: const {HeroAnimationDirection.down},
      finishThreshold: 0.3,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: HeroView(
            id: 'videoPlayer',
            modifiers: [HeroModifier.useNoSnapshot],
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/bigbuckbunny.jpg',
                    fit: BoxFit.contain,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: Icon(Icons.movie, color: Colors.white54, size: 80),
                      ),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 50),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    right: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close, color: Colors.white, size: 30),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
