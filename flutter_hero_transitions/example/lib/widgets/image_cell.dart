import 'package:flutter/material.dart';

/// Grid cell widget for displaying an image thumbnail.
/// Used by ImageGallery and MatchInCollection examples.
class ImageCell extends StatelessWidget {
  final int index;
  final String? assetName;
  final Color? color;
  final VoidCallback? onTap;
  final double cornerRadius;

  const ImageCell({
    super.key,
    required this.index,
    this.assetName,
    this.color,
    this.onTap,
    this.cornerRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cornerRadius),
        child: assetName != null
            ? Image.asset(
                assetName!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: color ??
          HSVColor.fromAHSV(1, (index * 36.0) % 360, 0.7, 0.8).toColor(),
      child: Center(
        child: Text(
          '$index',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
