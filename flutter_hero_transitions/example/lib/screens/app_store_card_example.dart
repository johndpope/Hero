import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_hero_transitions/flutter_hero_transitions.dart';
import '../widgets/card_view.dart';
import '../widgets/example_scaffold.dart';

/// App Store Card Example - Screen 1 (Card List).
class AppStoreScreen1 extends StatelessWidget {
  const AppStoreScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      child: ListView.builder(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 60,
          bottom: 40,
        ),
        itemCount: 10,
        itemBuilder: (context, index) {
          final cardHeroId = 'appStoreCard_$index';
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: HeroView(
              id: cardHeroId,
              modifiers: [
                HeroModifier.spring(stiffness: 250, damping: 25),
                HeroModifier.useNoSnapshot,
              ],
              child: RoundedCardWrapper(
                onTap: () {
                  Navigator.of(context).push(
                    HeroPageRoute(
                      animationType: const HeroAnimationType.none(),
                      builder: (_) => AppStoreScreen2(
                        cardIndex: index,
                        cardHeroId: cardHeroId,
                      ),
                    ),
                  );
                },
                child: CardView(imageIndex: index),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// App Store Card Example - Screen 2 (Expanded Detail).
class AppStoreScreen2 extends StatelessWidget {
  final int cardIndex;
  final String cardHeroId;

  const AppStoreScreen2({
    super.key,
    required this.cardIndex,
    required this.cardHeroId,
  });

  @override
  Widget build(BuildContext context) {
    return HeroInteractiveGesture(
      directions: const {HeroAnimationDirection.down},
      finishThreshold: 0.3,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Blur background
            HeroView(
              id: '${cardHeroId}_blur',
              modifiers: [HeroModifier.fade],
              child: Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(color: Colors.white.withOpacity(0.8)),
                ),
              ),
            ),
            // Content
            SingleChildScrollView(
              child: Column(
                children: [
                  // Expanded card
                  HeroView(
                    id: cardHeroId,
                    modifiers: [
                      HeroModifier.spring(stiffness: 250, damping: 25),
                      HeroModifier.useNoSnapshot,
                    ],
                    child: CardView(imageIndex: cardIndex),
                  ),
                  // Text content below
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'Card Details',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                          'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
                          'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris '
                          'nisi ut aliquip ex ea commodo consequat.\n\n'
                          'Duis aute irure dolor in reprehenderit in voluptate velit esse '
                          'cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat '
                          'cupidatat non proident, sunt in culpa qui officia deserunt mollit '
                          'anim id est laborum.\n\n'
                          'Sed ut perspiciatis unde omnis iste natus error sit voluptatem '
                          'accusantium doloremque laudantium, totam rem aperiam, eaque ipsa '
                          'quae ab illo inventore veritatis et quasi architecto beatae vitae '
                          'dicta sunt explicabo.',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Color(0xFF616161),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Close button
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
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
