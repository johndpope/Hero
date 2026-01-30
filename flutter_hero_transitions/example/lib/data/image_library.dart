/// Image asset paths for the example app.
class ImageLibrary {
  ImageLibrary._();

  /// Unsplash landscape images.
  static String unsplash(int index) => 'assets/Unsplash$index.jpg';

  /// Total number of unsplash images.
  static const int unsplashCount = 10;

  /// Hero logo.
  static const String heroLogo = 'assets/HeroLogo.png';

  /// City guide images.
  static const List<String> cityImages = [
    'assets/Vancouver.jpg',
    'assets/Montreal.jpg',
    'assets/Toronto.jpg',
  ];

  /// Apple product images.
  static const List<String> appleProducts = [
    'assets/iPhone.jpg',
    'assets/MacBook.jpg',
    'assets/Watch.jpg',
  ];

  /// Food images.
  static String food(int index) => 'assets/Food$index.jpg';
  static const int foodCount = 11;
}
