import 'package:flutter/material.dart';
import 'package:flutter_hero_transitions/flutter_hero_transitions.dart';
import '../widgets/example_scaffold.dart';

/// Built-in Transition Selector - all 14 animation types.
class BuiltInTransitionSelectorScreen extends StatelessWidget {
  const BuiltInTransitionSelectorScreen({super.key});

  static final List<(String, HeroAnimationType)> animations = [
    ('Push Left', const HeroAnimationType.push(direction: HeroAnimationDirection.left)),
    ('Pull Left', const HeroAnimationType.pull(direction: HeroAnimationDirection.left)),
    ('Slide Left', const HeroAnimationType.slide(direction: HeroAnimationDirection.left)),
    ('Zoom Slide Left', const HeroAnimationType.zoomSlide(direction: HeroAnimationDirection.left)),
    ('Cover Up', const HeroAnimationType.cover(direction: HeroAnimationDirection.up)),
    ('Uncover Up', const HeroAnimationType.uncover(direction: HeroAnimationDirection.up)),
    ('Page In Left', const HeroAnimationType.pageIn(direction: HeroAnimationDirection.left)),
    ('Page Out Left', const HeroAnimationType.pageOut(direction: HeroAnimationDirection.left)),
    ('Fade', const HeroAnimationType.fade()),
    ('Zoom', const HeroAnimationType.zoom()),
    ('Zoom Out', const HeroAnimationType.zoomOut()),
    ('None', const HeroAnimationType.none()),
    ('SelectBy (Pull/Slide)', HeroAnimationType.selectBy(
      presenting: const HeroAnimationType.pull(direction: HeroAnimationDirection.left),
      dismissing: const HeroAnimationType.slide(direction: HeroAnimationDirection.down),
    )),
    ('Auto Reverse (Page In)', HeroAnimationType.autoReverse(
      presenting: const HeroAnimationType.pageIn(direction: HeroAnimationDirection.left),
    )),
  ];

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      child: ListView.builder(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 60,
          bottom: 40,
        ),
        itemCount: animations.length,
        itemBuilder: (context, index) {
          final (label, type) = animations[index];
          return ListTile(
            title: Text(label),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                HeroPageRoute(
                  animationType: type,
                  builder: (_) => _TransitionDestinationScreen(
                    animationLabel: label,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _TransitionDestinationScreen extends StatelessWidget {
  final String animationLabel;
  const _TransitionDestinationScreen({required this.animationLabel});

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      backgroundColor: const Color(0xFF555555),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                animationLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
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
