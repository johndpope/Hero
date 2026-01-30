import 'package:flutter/material.dart';
import 'package:flutter_hero_transitions/flutter_hero_transitions.dart';
import '../widgets/example_scaffold.dart';

/// Navigation Example - Toggle Hero on/off for navigation transitions.
class NavigationExampleScreen extends StatefulWidget {
  const NavigationExampleScreen({super.key});

  @override
  State<NavigationExampleScreen> createState() => _NavigationExampleScreenState();
}

class _NavigationExampleScreenState extends State<NavigationExampleScreen> {
  bool _heroEnabled = true;

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Navigation Example',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Hero Enabled', style: TextStyle(fontSize: 17)),
                const SizedBox(width: 12),
                Switch(
                  value: _heroEnabled,
                  onChanged: (v) => setState(() => _heroEnabled = v),
                ),
              ],
            ),
            const SizedBox(height: 30),
            HeroView(
              id: 'navBox',
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFFC3A5E),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  HeroPageRoute(
                    heroEnabled: _heroEnabled,
                    builder: (_) => const _NavigationDetailScreen(),
                  ),
                );
              },
              child: const Text('Push Next Screen'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationDetailScreen extends StatelessWidget {
  const _NavigationDetailScreen();

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      backgroundColor: const Color(0xFF333333),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HeroView(
              id: 'navBox',
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFFC3A5E),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Detail Screen',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
