import 'package:flutter/material.dart';
import 'package:flutter_hero_transitions/flutter_hero_transitions.dart';
import '../widgets/example_scaffold.dart';

/// Image Gallery Example - grid with cascade and radial animations.
class ImageGalleryScreen extends StatefulWidget {
  final int crossAxisCount;
  const ImageGalleryScreen({super.key, this.crossAxisCount = 3});

  @override
  State<ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  late int _columns;
  final int _imageCount = 30;

  @override
  void initState() {
    super.initState();
    _columns = widget.crossAxisCount;
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('$_columns columns'),
                IconButton(
                  icon: const Icon(Icons.grid_view),
                  onPressed: () {
                    setState(() {
                      _columns = _columns == 3 ? 5 : 3;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(4),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _columns,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: _imageCount,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      HeroPageRoute(
                        builder: (_) => _ImageViewerScreen(
                          initialIndex: index,
                          imageCount: _imageCount,
                        ),
                      ),
                    );
                  },
                  child: HeroView(
                    id: 'gallery_image_$index',
                    modifiers: [
                      HeroModifier.fade,
                      HeroModifier.scale(0.8),
                    ],
                    child: Image.asset(
                      'assets/foods/unsplash${index % 10}.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: HSVColor.fromAHSV(1, (index * 12.0) % 360, 0.6, 0.8).toColor(),
                        child: Center(
                          child: Text(
                            '$index',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageViewerScreen extends StatelessWidget {
  final int initialIndex;
  final int imageCount;

  const _ImageViewerScreen({
    required this.initialIndex,
    required this.imageCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: imageCount,
            itemBuilder: (context, index) {
              return Center(
                child: HeroView(
                  id: 'gallery_image_$index',
                  child: InteractiveViewer(
                    child: Image.asset(
                      'assets/foods/unsplash${index % 10}.jpg',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        width: double.infinity,
                        height: 300,
                        color: HSVColor.fromAHSV(1, (index * 12.0) % 360, 0.6, 0.8).toColor(),
                        child: Center(child: Text('$index', style: const TextStyle(color: Colors.white, fontSize: 40))),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
