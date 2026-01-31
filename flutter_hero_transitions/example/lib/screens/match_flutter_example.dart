import 'package:flutter/material.dart';
import 'package:flutter_hero_transitions/flutter_hero_transitions.dart';
import '../data/image_library.dart';
import '../widgets/example_scaffold.dart';

/// Match Flutter Example (port of SwiftUI Match).
/// ListView of images with matched hero transitions to fullscreen.
class MatchFlutterExampleScreen extends StatelessWidget {
  const MatchFlutterExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      child: ListView.builder(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 60,
          bottom: 40,
        ),
        itemCount: 10,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                HeroPageRoute(
                  builder: (_) => _MatchFlutterDetailScreen(index: index),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  HeroView(
                    id: 'unsplash_${index}_cell',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        ImageLibrary.thumbnail(index),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 80,
                          color: HSVColor.fromAHSV(1, (index * 36.0) % 360, 0.6, 0.8).toColor(),
                          child: Center(child: Text('$index', style: const TextStyle(color: Colors.white, fontSize: 20))),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Unsplash Image $index',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to view fullscreen',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Detail screen showing fullscreen image.
class _MatchFlutterDetailScreen extends StatelessWidget {
  final int index;

  const _MatchFlutterDetailScreen({required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: HeroView(
            id: 'unsplash_${index}_cell',
            child: Image.asset(
              ImageLibrary.image(index),
              fit: BoxFit.contain,
              width: double.infinity,
              errorBuilder: (_, __, ___) => Container(
                width: double.infinity,
                height: 300,
                color: HSVColor.fromAHSV(1, (index * 36.0) % 360, 0.6, 0.8).toColor(),
                child: Center(child: Text('$index', style: const TextStyle(color: Colors.white, fontSize: 60))),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
