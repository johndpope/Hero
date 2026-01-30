import 'package:flutter/material.dart';
import 'package:flutter_hero_transitions/flutter_hero_transitions.dart';
import '../widgets/example_scaffold.dart';

/// Built-in Transition Example - Screen 1 (Source).
/// Hot pink background. Tap to present Screen 2.
class BuiltInTransitionScreen1 extends StatelessWidget {
  const BuiltInTransitionScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      backgroundColor: const Color(0xFFFC3A5E),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context).push(
            HeroPageRoute(
              animationType: const HeroAnimationType.selectBy(
                presenting: HeroAnimationType.pull(direction: HeroAnimationDirection.left),
                dismissing: HeroAnimationType.slide(direction: HeroAnimationDirection.down),
              ),
              builder: (_) => const BuiltInTransitionScreen2(),
            ),
          );
        },
        child: const Center(
          child: Text(
            'Tap anywhere',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// Built-in Transition Example - Screen 2 (Destination).
/// Dark gray background. Tap to dismiss.
class BuiltInTransitionScreen2 extends StatelessWidget {
  const BuiltInTransitionScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      backgroundColor: const Color(0xFF555555),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: const Center(
          child: Text(
            'Tap to dismiss',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
