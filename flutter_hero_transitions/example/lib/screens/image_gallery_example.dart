import 'package:flutter/material.dart';
import 'package:flutter_hero_transitions/flutter_hero_transitions.dart';
import '../data/image_library.dart';
import '../widgets/example_scaffold.dart';
import 'image_viewer_screen.dart';

/// Image Gallery Example — grid with cascade and radial animations.
///
/// iOS parity: ImageGalleryCollectionViewController.swift
///   - 100 items (modulo 11 images)
///   - 3 or 5 column toggle
///   - Radial cascade from tapped cell when navigating to viewer
///   - InverseRadial cascade when returning from viewer
///   - Thumbnails in grid, full-size in viewer
class ImageGalleryScreen extends StatefulWidget {
  final int crossAxisCount;
  const ImageGalleryScreen({super.key, this.crossAxisCount = 3});

  @override
  State<ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  late int _columns;
  final int _imageCount = ImageLibrary.count;

  /// Cascade modifiers for the gallery container, updated dynamically
  /// based on which cell was tapped (iOS HeroViewControllerDelegate parity).
  List<HeroModifier> _cascadeModifiers = [
    HeroModifier.cascade(
      delta: const Duration(milliseconds: 15),
      direction: const CascadeDirection.topToBottom(),
      delayMatchedViews: true,
    ),
  ];

  /// Track which cell was selected (for viewer return cascade).
  int? _selectedIndex;

  /// ScrollController to find cell positions for radial cascade.
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _columns = widget.crossAxisCount;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Get the screen-space center of a cell at the given index.
  Offset? _cellCenter(int index) {
    // Calculate cell position based on grid layout
    final screenWidth = MediaQuery.of(context).size.width;
    final cellSize = (screenWidth - 8) / _columns; // account for padding
    final col = index % _columns;
    final row = index ~/ _columns;
    final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;

    // Grid starts at y = padding.top + 60 (header) + some padding
    final topPadding = MediaQuery.of(context).padding.top + 60 + 48;
    final x = 4 + col * (cellSize + 4) + cellSize / 2;
    final y = topPadding + 4 + row * (cellSize + 4) + cellSize / 2 - scrollOffset;

    return Offset(x, y);
  }

  void _onCellTapped(int index) {
    _selectedIndex = index;

    // Set radial cascade centered on the tapped cell (iOS parity)
    final center = _cellCenter(index);
    if (center != null) {
      setState(() {
        _cascadeModifiers = [
          HeroModifier.cascade(
            delta: const Duration(milliseconds: 15),
            direction: CascadeDirection.radial(center: center),
            delayMatchedViews: true,
          ),
        ];
      });
    }

    Navigator.of(context).push(
      HeroPageRoute(
        builder: (_) => ImageViewerScreen(
          initialIndex: index,
          imageCount: _imageCount,
          onPageChanged: (newIndex) {
            // Track which page the viewer is showing so we can use
            // inverseRadial cascade when returning.
            _selectedIndex = newIndex;
          },
        ),
      ),
    ).then((_) {
      // Restore default cascade for next interaction
      if (mounted) {
        setState(() {
          _cascadeModifiers = [
            HeroModifier.cascade(
              delta: const Duration(milliseconds: 15),
              direction: const CascadeDirection.topToBottom(),
              delayMatchedViews: true,
            ),
          ];
        });
      }
    });
  }

  void _switchLayout() {
    // iOS uses hero.replaceViewController for animated layout switch.
    // We achieve a similar effect by pushing a new route with cascade animation.
    setState(() {
      _cascadeModifiers = [
        HeroModifier.cascade(
          delta: const Duration(milliseconds: 15),
          direction: const CascadeDirection.bottomToTop(),
          delayMatchedViews: true,
        ),
      ];
      _columns = _columns == 3 ? 5 : 3;
    });
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
                Text('$_columns columns',
                    style: Theme.of(context).textTheme.bodyMedium),
                IconButton(
                  icon: const Icon(Icons.grid_view),
                  onPressed: _switchLayout,
                ),
              ],
            ),
          ),
          Expanded(
            child: HeroView(
              id: 'gallery_cascade_container',
              modifiers: _cascadeModifiers,
              child: GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(4),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _columns,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: _imageCount,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _onCellTapped(index),
                    child: HeroView(
                      id: 'image_$index',
                      modifiers: [
                        HeroModifier.fade,
                        HeroModifier.scale(0.8),
                      ],
                      child: Image.asset(
                        ImageLibrary.thumbnail(index),
                        fit: BoxFit.cover,
                        cacheWidth: 200,
                        errorBuilder: (_, __, ___) => Container(
                          color: HSVColor.fromAHSV(
                            1,
                            (index * 36.0) % 360,
                            0.6,
                            0.8,
                          ).toColor(),
                          child: Center(
                            child: Text(
                              '$index',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
