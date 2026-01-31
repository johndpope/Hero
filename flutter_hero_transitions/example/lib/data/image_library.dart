/// Image asset paths for the example app.
///
/// Matches the iOS ImageLibrary class: 11 unique Unsplash images
/// that cycle via modulo for any number of items.
class ImageLibrary {
  ImageLibrary._();

  /// Number of unique unsplash images (0–10, matching iOS modulo 11).
  static const int count = 100;

  /// File extension for a given index (0-9 are .png, 10 is .jpg).
  static String _ext(int index) => index == 10 ? 'jpg' : 'png';

  /// Full-size unsplash image for the image viewer.
  static String image(int index) {
    final i = index % 11;
    return 'assets/foods/unsplash$i.${_ext(i)}';
  }

  /// Thumbnail unsplash image for the gallery grid.
  static String thumbnail(int index) {
    final i = index % 11;
    return 'assets/foods/unsplash${i}_thumb.${_ext(i)}';
  }

  /// Cell-size unsplash image (small grid cells).
  static String cell(int index) {
    final i = index % 11;
    return 'assets/foods/unsplash${i}_cell.${_ext(i)}';
  }

  /// Hero logo.
  static const String heroLogo = 'assets/hero_logo.png';

  /// City guide images.
  static const List<String> cityImages = [
    'assets/city_guide/Vancouver.jpg',
    'assets/city_guide/Montreal.jpg',
    'assets/city_guide/Toronto.jpg',
  ];

  /// Apple product images.
  static const List<String> appleProducts = [
    'assets/apple_home_page/iPhone.jpg',
    'assets/apple_home_page/MacBook.jpg',
    'assets/apple_home_page/Watch.jpg',
  ];
}
