import 'package:flutter/material.dart';
import 'image_gallery_example.dart';

/// TV Image Gallery - adapted for larger screens (tablet/desktop).
/// Uses 5 columns instead of 3.
class TvImageGalleryScreen extends StatelessWidget {
  const TvImageGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageGalleryScreen(crossAxisCount: 5);
  }
}
