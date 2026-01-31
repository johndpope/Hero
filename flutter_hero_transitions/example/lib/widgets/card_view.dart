import 'package:flutter/material.dart';
import 'dart:ui';
import '../data/image_library.dart';

/// App Store-style card widget with image, blur overlay, title, and subtitle.
/// Used by AppStoreCardExample.
class CardView extends StatelessWidget {
  final int imageIndex;
  final String? title;
  final String? subtitle;

  const CardView({
    super.key,
    required this.imageIndex,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 300,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.asset(
              ImageLibrary.image(imageIndex),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                color: HSVColor.fromAHSV(1, (imageIndex * 36.0) % 360, 0.7, 0.8).toColor(),
                child: Center(
                  child: Text(
                    'Image $imageIndex',
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
            ),
            // Gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
            // Blur overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.black.withOpacity(0.2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title ?? 'Card Title $imageIndex',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle ?? 'Subtitle for card $imageIndex',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
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

/// Wrapper that adds shadow, rounded corners, and touch feedback.
/// Equivalent to iOS RoundedCardWrapperView.
class RoundedCardWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const RoundedCardWrapper({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  State<RoundedCardWrapper> createState() => _RoundedCardWrapperState();
}

class _RoundedCardWrapperState extends State<RoundedCardWrapper> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
