import 'package:flutter/material.dart';
import 'package:flutter_hero_transitions/flutter_hero_transitions.dart';
import '../widgets/example_scaffold.dart';

/// Match In Collection - Screen 1 (Source).
/// Grid of 30 colored cells with dynamic hero IDs.
class MatchInCollectionScreen1 extends StatelessWidget {
  const MatchInCollectionScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: 30,
          itemBuilder: (context, index) {
            final color = HSVColor.fromAHSV(
              1.0,
              (index * 12.0) % 360,
              0.65,
              0.85,
            ).toColor();

            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  HeroPageRoute(
                    builder: (_) => MatchInCollectionScreen2(
                      index: index,
                      color: color,
                    ),
                  ),
                );
              },
              child: HeroView(
                id: 'cell$index',
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

/// Match In Collection - Screen 2 (Destination).
/// Centered view matching the tapped cell.
class MatchInCollectionScreen2 extends StatelessWidget {
  final int index;
  final Color color;

  const MatchInCollectionScreen2({
    super.key,
    required this.index,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: HeroView(
            id: 'cell$index',
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
