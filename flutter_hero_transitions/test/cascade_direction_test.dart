import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_hero_transitions/src/types/cascade_direction.dart';

/// Convenience: sort a copy of [points] using [direction.compare] and return it.
List<Offset> sortedBy(CascadeDirection direction, List<Offset> points) {
  final copy = List<Offset>.from(points);
  copy.sort(direction.compare);
  return copy;
}

void main() {
  // ---------------------------------------------------------------
  // topToBottom  –  sorts by dy ascending (smallest y first)
  // ---------------------------------------------------------------
  group('CascadeDirection.topToBottom', () {
    const direction = CascadeDirection.topToBottom();

    test('sorts points by y ascending', () {
      final points = [
        const Offset(0, 300),
        const Offset(0, 100),
        const Offset(0, 200),
      ];
      final result = sortedBy(direction, points);
      expect(result, [
        const Offset(0, 100),
        const Offset(0, 200),
        const Offset(0, 300),
      ]);
    });

    test('compare returns negative when a.dy < b.dy', () {
      expect(direction.compare(const Offset(0, 10), const Offset(0, 20)),
          isNegative);
    });

    test('compare returns positive when a.dy > b.dy', () {
      expect(direction.compare(const Offset(0, 20), const Offset(0, 10)),
          isPositive);
    });

    test('compare returns zero for equal y', () {
      expect(
          direction.compare(const Offset(5, 10), const Offset(99, 10)), isZero);
    });

    test('handles negative coordinates', () {
      final points = [
        const Offset(0, 10),
        const Offset(0, -20),
        const Offset(0, -5),
      ];
      final result = sortedBy(direction, points);
      expect(result, [
        const Offset(0, -20),
        const Offset(0, -5),
        const Offset(0, 10),
      ]);
    });

    test('equal positions remain stable', () {
      final points = [
        const Offset(1, 50),
        const Offset(2, 50),
        const Offset(3, 50),
      ];
      final result = sortedBy(direction, points);
      // All have equal y so compare returns 0; Dart's sort is stable.
      expect(result, [
        const Offset(1, 50),
        const Offset(2, 50),
        const Offset(3, 50),
      ]);
    });
  });

  // ---------------------------------------------------------------
  // bottomToTop  –  sorts by dy descending (largest y first)
  // ---------------------------------------------------------------
  group('CascadeDirection.bottomToTop', () {
    const direction = CascadeDirection.bottomToTop();

    test('sorts points by y descending', () {
      final points = [
        const Offset(0, 100),
        const Offset(0, 300),
        const Offset(0, 200),
      ];
      final result = sortedBy(direction, points);
      expect(result, [
        const Offset(0, 300),
        const Offset(0, 200),
        const Offset(0, 100),
      ]);
    });

    test('compare returns negative when a.dy > b.dy (bottom first)', () {
      expect(direction.compare(const Offset(0, 20), const Offset(0, 10)),
          isNegative);
    });

    test('compare returns positive when a.dy < b.dy', () {
      expect(direction.compare(const Offset(0, 10), const Offset(0, 20)),
          isPositive);
    });

    test('compare returns zero for equal y', () {
      expect(
          direction.compare(const Offset(5, 10), const Offset(99, 10)), isZero);
    });

    test('handles negative coordinates', () {
      final points = [
        const Offset(0, -20),
        const Offset(0, 10),
        const Offset(0, -5),
      ];
      final result = sortedBy(direction, points);
      expect(result, [
        const Offset(0, 10),
        const Offset(0, -5),
        const Offset(0, -20),
      ]);
    });

    test('equal positions remain stable', () {
      final points = [
        const Offset(1, 50),
        const Offset(2, 50),
        const Offset(3, 50),
      ];
      final result = sortedBy(direction, points);
      expect(result, [
        const Offset(1, 50),
        const Offset(2, 50),
        const Offset(3, 50),
      ]);
    });
  });

  // ---------------------------------------------------------------
  // leftToRight  –  sorts by dx ascending (smallest x first)
  // ---------------------------------------------------------------
  group('CascadeDirection.leftToRight', () {
    const direction = CascadeDirection.leftToRight();

    test('sorts points by x ascending', () {
      final points = [
        const Offset(300, 0),
        const Offset(100, 0),
        const Offset(200, 0),
      ];
      final result = sortedBy(direction, points);
      expect(result, [
        const Offset(100, 0),
        const Offset(200, 0),
        const Offset(300, 0),
      ]);
    });

    test('compare returns negative when a.dx < b.dx', () {
      expect(direction.compare(const Offset(10, 0), const Offset(20, 0)),
          isNegative);
    });

    test('compare returns positive when a.dx > b.dx', () {
      expect(direction.compare(const Offset(20, 0), const Offset(10, 0)),
          isPositive);
    });

    test('compare returns zero for equal x', () {
      expect(
          direction.compare(const Offset(10, 5), const Offset(10, 99)), isZero);
    });

    test('handles negative coordinates', () {
      final points = [
        const Offset(10, 0),
        const Offset(-20, 0),
        const Offset(-5, 0),
      ];
      final result = sortedBy(direction, points);
      expect(result, [
        const Offset(-20, 0),
        const Offset(-5, 0),
        const Offset(10, 0),
      ]);
    });

    test('equal positions remain stable', () {
      final points = [
        const Offset(50, 1),
        const Offset(50, 2),
        const Offset(50, 3),
      ];
      final result = sortedBy(direction, points);
      expect(result, [
        const Offset(50, 1),
        const Offset(50, 2),
        const Offset(50, 3),
      ]);
    });
  });

  // ---------------------------------------------------------------
  // rightToLeft  –  sorts by dx descending (largest x first)
  // ---------------------------------------------------------------
  group('CascadeDirection.rightToLeft', () {
    const direction = CascadeDirection.rightToLeft();

    test('sorts points by x descending', () {
      final points = [
        const Offset(100, 0),
        const Offset(300, 0),
        const Offset(200, 0),
      ];
      final result = sortedBy(direction, points);
      expect(result, [
        const Offset(300, 0),
        const Offset(200, 0),
        const Offset(100, 0),
      ]);
    });

    test('compare returns negative when a.dx > b.dx (right first)', () {
      expect(direction.compare(const Offset(20, 0), const Offset(10, 0)),
          isNegative);
    });

    test('compare returns positive when a.dx < b.dx', () {
      expect(direction.compare(const Offset(10, 0), const Offset(20, 0)),
          isPositive);
    });

    test('compare returns zero for equal x', () {
      expect(
          direction.compare(const Offset(10, 5), const Offset(10, 99)), isZero);
    });

    test('handles negative coordinates', () {
      final points = [
        const Offset(-20, 0),
        const Offset(10, 0),
        const Offset(-5, 0),
      ];
      final result = sortedBy(direction, points);
      expect(result, [
        const Offset(10, 0),
        const Offset(-5, 0),
        const Offset(-20, 0),
      ]);
    });

    test('equal positions remain stable', () {
      final points = [
        const Offset(50, 1),
        const Offset(50, 2),
        const Offset(50, 3),
      ];
      final result = sortedBy(direction, points);
      expect(result, [
        const Offset(50, 1),
        const Offset(50, 2),
        const Offset(50, 3),
      ]);
    });
  });

  // ---------------------------------------------------------------
  // radial(center)  –  sorts by distance from center ascending
  // ---------------------------------------------------------------
  group('CascadeDirection.radial', () {
    test('sorts points by distance from center ascending', () {
      const direction =
          CascadeDirection.radial(center: Offset(100, 100));

      final points = [
        const Offset(200, 100), // distance = 100
        const Offset(100, 110), // distance = 10
        const Offset(150, 100), // distance = 50
      ];
      final result = sortedBy(direction, points);
      expect(result, [
        const Offset(100, 110), // 10
        const Offset(150, 100), // 50
        const Offset(200, 100), // 100
      ]);
    });

    test('compare returns negative when a is closer to center', () {
      const direction =
          CascadeDirection.radial(center: Offset(0, 0));
      // distance 5 vs distance 10
      expect(direction.compare(const Offset(3, 4), const Offset(6, 8)),
          isNegative);
    });

    test('compare returns positive when a is farther from center', () {
      const direction =
          CascadeDirection.radial(center: Offset(0, 0));
      expect(direction.compare(const Offset(6, 8), const Offset(3, 4)),
          isPositive);
    });

    test('compare returns zero for equidistant points', () {
      const direction =
          CascadeDirection.radial(center: Offset(0, 0));
      // (3,4) and (4,3) both have distance 5
      expect(direction.compare(const Offset(3, 4), const Offset(4, 3)), isZero);
    });

    test('handles zero center', () {
      const direction =
          CascadeDirection.radial(center: Offset.zero);

      final points = [
        const Offset(10, 0), // distance = 10
        const Offset(3, 4),  // distance = 5
        const Offset(0, 1),  // distance = 1
      ];
      final result = sortedBy(direction, points);
      expect(result, [
        const Offset(0, 1),  // 1
        const Offset(3, 4),  // 5
        const Offset(10, 0), // 10
      ]);
    });

    test('handles negative coordinates', () {
      const direction =
          CascadeDirection.radial(center: Offset.zero);

      final points = [
        const Offset(-6, -8), // distance = 10
        const Offset(-3, -4), // distance = 5
        const Offset(0, 1),   // distance = 1
      ];
      final result = sortedBy(direction, points);
      expect(result, [
        const Offset(0, 1),   // 1
        const Offset(-3, -4), // 5
        const Offset(-6, -8), // 10
      ]);
    });

    test('point at center has distance zero', () {
      const center = Offset(50, 50);
      const direction = CascadeDirection.radial(center: center);
      expect(direction.compare(center, const Offset(50, 51)), isNegative);
      expect(direction.compare(center, center), isZero);
    });

    test('sorts correctly with non-origin center', () {
      const direction =
          CascadeDirection.radial(center: Offset(50, 50));

      final points = [
        const Offset(50, 150), // distance = 100
        const Offset(50, 50),  // distance = 0
        const Offset(80, 50),  // distance = 30
      ];
      final result = sortedBy(direction, points);
      expect(result, [
        const Offset(50, 50),  // 0
        const Offset(80, 50),  // 30
        const Offset(50, 150), // 100
      ]);
    });
  });

  // ---------------------------------------------------------------
  // inverseRadial(center)  –  sorts by distance from center descending
  // ---------------------------------------------------------------
  group('CascadeDirection.inverseRadial', () {
    test('sorts points by distance from center descending', () {
      const direction =
          CascadeDirection.inverseRadial(center: Offset(100, 100));

      final points = [
        const Offset(100, 110), // distance = 10
        const Offset(200, 100), // distance = 100
        const Offset(150, 100), // distance = 50
      ];
      final result = sortedBy(direction, points);
      expect(result, [
        const Offset(200, 100), // 100
        const Offset(150, 100), // 50
        const Offset(100, 110), // 10
      ]);
    });

    test('compare returns negative when a is farther from center (farthest first)', () {
      const direction =
          CascadeDirection.inverseRadial(center: Offset(0, 0));
      // distance 10 vs distance 5
      expect(direction.compare(const Offset(6, 8), const Offset(3, 4)),
          isNegative);
    });

    test('compare returns positive when a is closer to center', () {
      const direction =
          CascadeDirection.inverseRadial(center: Offset(0, 0));
      expect(direction.compare(const Offset(3, 4), const Offset(6, 8)),
          isPositive);
    });

    test('compare returns zero for equidistant points', () {
      const direction =
          CascadeDirection.inverseRadial(center: Offset(0, 0));
      expect(direction.compare(const Offset(3, 4), const Offset(4, 3)), isZero);
    });

    test('handles zero center', () {
      const direction =
          CascadeDirection.inverseRadial(center: Offset.zero);

      final points = [
        const Offset(0, 1),  // distance = 1
        const Offset(3, 4),  // distance = 5
        const Offset(10, 0), // distance = 10
      ];
      final result = sortedBy(direction, points);
      expect(result, [
        const Offset(10, 0), // 10
        const Offset(3, 4),  // 5
        const Offset(0, 1),  // 1
      ]);
    });

    test('handles negative coordinates', () {
      const direction =
          CascadeDirection.inverseRadial(center: Offset.zero);

      final points = [
        const Offset(0, 1),   // distance = 1
        const Offset(-6, -8), // distance = 10
        const Offset(-3, -4), // distance = 5
      ];
      final result = sortedBy(direction, points);
      expect(result, [
        const Offset(-6, -8), // 10
        const Offset(-3, -4), // 5
        const Offset(0, 1),   // 1
      ]);
    });

    test('point at center has distance zero and sorts last', () {
      const center = Offset(50, 50);
      const direction = CascadeDirection.inverseRadial(center: center);
      // center vs a point 1 away -- center should come after
      expect(direction.compare(center, const Offset(50, 51)), isPositive);
      expect(direction.compare(center, center), isZero);
    });

    test('sorts correctly with non-origin center', () {
      const direction =
          CascadeDirection.inverseRadial(center: Offset(50, 50));

      final points = [
        const Offset(50, 50),  // distance = 0
        const Offset(50, 150), // distance = 100
        const Offset(80, 50),  // distance = 30
      ];
      final result = sortedBy(direction, points);
      expect(result, [
        const Offset(50, 150), // 100
        const Offset(80, 50),  // 30
        const Offset(50, 50),  // 0
      ]);
    });
  });

  // ---------------------------------------------------------------
  // radial and inverseRadial are inverses of each other
  // ---------------------------------------------------------------
  group('radial vs inverseRadial symmetry', () {
    test('radial and inverseRadial produce opposite orderings', () {
      const center = Offset(50, 50);
      const radial = CascadeDirection.radial(center: center);
      const inverse = CascadeDirection.inverseRadial(center: center);

      final points = [
        const Offset(50, 50),  // 0
        const Offset(60, 50),  // 10
        const Offset(50, 100), // 50
        const Offset(150, 50), // 100
      ];

      final radialSorted = sortedBy(radial, points);
      final inverseSorted = sortedBy(inverse, points);

      expect(radialSorted, inverseSorted.reversed.toList());
    });
  });

  // ---------------------------------------------------------------
  // Construction through sealed class factories
  // ---------------------------------------------------------------
  group('factory constructors', () {
    test('topToBottom creates CascadeDirectionTopToBottom', () {
      const d = CascadeDirection.topToBottom();
      expect(d, isA<CascadeDirectionTopToBottom>());
    });

    test('bottomToTop creates CascadeDirectionBottomToTop', () {
      const d = CascadeDirection.bottomToTop();
      expect(d, isA<CascadeDirectionBottomToTop>());
    });

    test('leftToRight creates CascadeDirectionLeftToRight', () {
      const d = CascadeDirection.leftToRight();
      expect(d, isA<CascadeDirectionLeftToRight>());
    });

    test('rightToLeft creates CascadeDirectionRightToLeft', () {
      const d = CascadeDirection.rightToLeft();
      expect(d, isA<CascadeDirectionRightToLeft>());
    });

    test('radial creates CascadeDirectionRadial', () {
      const d = CascadeDirection.radial(center: Offset.zero);
      expect(d, isA<CascadeDirectionRadial>());
    });

    test('inverseRadial creates CascadeDirectionInverseRadial', () {
      const d = CascadeDirection.inverseRadial(center: Offset.zero);
      expect(d, isA<CascadeDirectionInverseRadial>());
    });
  });
}
