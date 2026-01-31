import 'package:flutter/material.dart';
import 'package:flutter_hero_transitions/flutter_hero_transitions.dart';
import '../data/image_library.dart';

/// Full-screen image viewer with horizontal paging and pan-to-dismiss.
///
/// iOS parity: ImageViewController.swift
///   - Horizontal PageView with ALL images (scrolls to selected on load)
///   - Pan-to-dismiss gesture (vertical only, when not zoomed)
///   - Dynamic position modifier during pan (iOS Hero.shared.apply)
///   - Threshold: progress + velocity > 0.3
///   - Hero modifiers: position(center), scale(0.6), fade
class ImageViewerScreen extends StatefulWidget {
  final int initialIndex;
  final int imageCount;
  final ValueChanged<int>? onPageChanged;

  const ImageViewerScreen({
    super.key,
    required this.initialIndex,
    required this.imageCount,
    this.onPageChanged,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late final PageController _pageController;
  late int _currentPage;
  bool _isDismissing = false;
  Offset _panStart = Offset.zero;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    _panStart = details.globalPosition;
    _isDismissing = false;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final translation = details.globalPosition - _panStart;
    final size = MediaQuery.of(context).size;
    // iOS: progress = translation.y / 2 / bounds.height
    final progress = (translation.dy / 2 / size.height).clamp(0.0, 1.0);

    if (!_isDismissing && progress > 0.01) {
      _isDismissing = true;
      Navigator.of(context).pop();
      HeroTransitionEngine.shared.interactive = true;
    }

    if (_isDismissing) {
      HeroTransitionEngine.shared.update(progress);

      // iOS parity: apply position modifier to track finger.
      // Hero.shared.apply(modifiers: [.position(currentPos)], to: cell.imageView)
      final currentPos = Offset(
        translation.dx + size.width / 2,
        translation.dy + size.height / 2,
      );
      HeroTransitionEngine.shared.applyModifiers(
        [HeroModifier.position(currentPos)],
        'image_$_currentPage',
      );
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDismissing) return;

    final size = MediaQuery.of(context).size;
    final currentProgress = HeroTransitionEngine.shared.progress;
    final velocityY = details.velocity.pixelsPerSecond.dy;

    // iOS: if progress + velocity.y / bounds.height > 0.3
    if (currentProgress + velocityY / size.height > 0.3) {
      HeroTransitionEngine.shared.finish();
    } else {
      HeroTransitionEngine.shared.cancel();
    }

    _isDismissing = false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragStart: _onPanStart,
        onVerticalDragUpdate: _onPanUpdate,
        onVerticalDragEnd: _onPanEnd,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.imageCount,
              onPageChanged: (index) {
                _currentPage = index;
                widget.onPageChanged?.call(index);
              },
              itemBuilder: (context, index) {
                return Center(
                  child: HeroView(
                    id: 'image_$index',
                    modifiers: [
                      // iOS: .position(center.x, height + width/2), .scale(0.6), .fade
                      HeroModifier.position(Offset(
                        size.width / 2,
                        size.height + size.width / 2,
                      )),
                      HeroModifier.scale(0.6),
                      HeroModifier.fade,
                    ],
                    child: Image.asset(
                      ImageLibrary.image(index),
                      fit: BoxFit.contain,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        width: double.infinity,
                        height: 300,
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
                              fontSize: 60,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // Close button
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
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
