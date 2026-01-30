import 'package:flutter/material.dart';
import 'package:flutter_hero_transitions/flutter_hero_transitions.dart';
import '../widgets/example_scaffold.dart';

/// Match Example - Screen 1 (Source).
/// Two colored views with Hero IDs "ironMan" and "batMan".
class MatchExampleScreen1 extends StatelessWidget {
  const MatchExampleScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context).push(
            HeroPageRoute(builder: (_) => const MatchExampleScreen2()),
          );
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HeroView(
                id: 'batMan',
                child: Container(
                  width: 200,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF555555),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              HeroView(
                id: 'ironMan',
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFC3A5E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Match Example - Screen 2 (Destination).
/// Red view expands to full screen, black view repositioned.
class MatchExampleScreen2 extends StatelessWidget {
  const MatchExampleScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          children: [
            // Red view - full screen
            HeroView(
              id: 'ironMan',
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFFFC3A5E),
              ),
            ),
            // Black view - repositioned to top
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: HeroView(
                  id: 'batMan',
                  child: Container(
                    width: 250,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF555555),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
            // Background view with translate modifier
            HeroView(
              id: 'matchBackground',
              modifiers: [
                HeroModifier.translate(y: 500),
                HeroModifier.useGlobalCoordinateSpace,
              ],
              child: Container(
                margin: const EdgeInsets.only(top: 200, left: 40, right: 40),
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'This view animates up from the bottom using '
                      '.translate(y: 500) and .useGlobalCoordinateSpace',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
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
