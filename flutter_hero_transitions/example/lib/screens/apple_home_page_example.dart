import 'package:flutter/material.dart';
import '../widgets/example_scaffold.dart';

/// Apple Home Page Example - multi-directional swipe product showcase.
class AppleHomePageScreen extends StatefulWidget {
  const AppleHomePageScreen({super.key});

  @override
  State<AppleHomePageScreen> createState() => _AppleHomePageScreenState();
}

class _AppleHomePageScreenState extends State<AppleHomePageScreen> {
  int _currentIndex = 0;

  static const List<(String, String, Color, String)> products = [
    ('iPhone', 'The best iPhone ever.', Color(0xFF1A1A1A), 'assets/apple_home_page/iphone.png'),
    ('MacBook', 'Light. Years ahead.', Color(0xFF2C2C2E), 'assets/apple_home_page/macbook.png'),
    ('Apple Watch', 'A healthy leap ahead.', Color(0xFF000000), 'assets/apple_home_page/watch.png'),
  ];

  @override
  Widget build(BuildContext context) {
    final (name, tagline, bgColor, imagePath) = products[_currentIndex];

    return ExampleScaffold(
      backgroundColor: bgColor,
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          final velocity = details.velocity.pixelsPerSecond.dx;
          if (velocity < -300 && _currentIndex < products.length - 1) {
            setState(() => _currentIndex++);
          } else if (velocity > 300 && _currentIndex > 0) {
            setState(() => _currentIndex--);
          }
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Container(
            key: ValueKey(_currentIndex),
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  imagePath,
                  height: 300,
                  errorBuilder: (_, __, ___) => Container(
                    height: 300,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        name,
                        style: const TextStyle(color: Colors.white54, fontSize: 24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tagline,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 40),
                // Page indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(products.length, (i) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _currentIndex
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                Text(
                  'Swipe left or right',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
