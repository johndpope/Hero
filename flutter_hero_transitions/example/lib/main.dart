import 'package:flutter/material.dart';
import 'package:flutter_hero_transitions/flutter_hero_transitions.dart';
import 'screens/main_menu_screen.dart';

void main() {
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
          children: [
            child!,
            const HeroOverlay(),
          ],
        );
      },
      home: const MainMenuScreen(),
    );
  }
}
