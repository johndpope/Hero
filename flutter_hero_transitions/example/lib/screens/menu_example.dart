import 'package:flutter/material.dart';
import 'package:flutter_hero_transitions/flutter_hero_transitions.dart';
import '../widgets/example_scaffold.dart';

/// Menu Example - button-driven transitions with source modifier.
class MenuExampleScreen extends StatelessWidget {
  const MenuExampleScreen({super.key});

  static const List<(IconData, String, Color)> menuItems = [
    (Icons.audiotrack, 'Music', Color(0xFFE91E63)),
    (Icons.chat, 'Chat', Color(0xFF2196F3)),
    (Icons.photo, 'Photos', Color(0xFF4CAF50)),
    (Icons.movie, 'Videos', Color(0xFFFF9800)),
    (Icons.settings, 'Settings', Color(0xFF9C27B0)),
    (Icons.star, 'Favorites', Color(0xFFFFEB3B)),
  ];

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 80),
        child: GridView.builder(
          padding: const EdgeInsets.all(30),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
          ),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final (icon, label, color) = menuItems[index];
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  HeroPageRoute(
                    animationType: const HeroAnimationType.none(),
                    builder: (_) => _MenuDetailScreen(
                      icon: icon,
                      label: label,
                      color: color,
                      heroId: 'menu_$index',
                    ),
                  ),
                );
              },
              child: HeroView(
                id: 'menu_$index',
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 40, color: Colors.white),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MenuDetailScreen extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String heroId;

  const _MenuDetailScreen({
    required this.icon,
    required this.label,
    required this.color,
    required this.heroId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HeroView(
                id: heroId,
                modifiers: [HeroModifier.durationMatchLongest],
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 60, color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),
              HeroView(
                id: '${heroId}_label',
                modifiers: [
                  HeroModifier.fade,
                  HeroModifier.translate(y: 50),
                ],
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tap to dismiss',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
