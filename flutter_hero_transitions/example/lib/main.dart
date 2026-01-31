import 'package:flutter/material.dart';
import 'package:flutter_hero_transitions/flutter_hero_transitions.dart';
import 'screens/main_menu_screen.dart';

void main() {
  // Debug plugin is off by default. Toggle it from the main menu
  // (bug icon) to inspect transitions with the scrub slider.
  HeroDebugPlugin.isEnabled = false;

  runApp(const HeroExamplesApp());
}

class HeroExamplesApp extends StatelessWidget {
  const HeroExamplesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hero Transitions Examples',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFFC3A5E),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFFC3A5E),
        brightness: Brightness.dark,
      ),
      navigatorObservers: [
        HeroTransitionObserver(),
      ],
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            child!,
            // HeroDebugWrapper combines HeroOverlayV2 with debug controls
            // (3D perspective, arc visualization, scrub slider).
            // When HeroDebugPlugin.isEnabled is false, it behaves identically
            // to a plain HeroOverlayV2.
            const HeroDebugWrapper(),
          ],
        );
      },
      home: const MainMenuScreen(),
    );
  }
}
