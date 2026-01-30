import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_hero_transitions/src/animator/arc_tween.dart';

/// Matcher that checks whether an [Offset] is component-wise close to
/// [expected] within the given [epsilon].
Matcher offsetCloseTo(Offset expected, double epsilon) {
  return predicate<Offset>(
    (actual) =>
        (actual.dx - expected.dx).abs() <= epsilon &&
        (actual.dy - expected.dy).abs() <= epsilon,
    'an Offset close to $expected (within $epsilon)',
  );
}

void main() {
  // ---------------------------------------------------------------
  // 1. Linear path (intensity 0)
  // ---------------------------------------------------------------
  group('Linear path (intensity 0)', () {
    test('interpolates linearly between begin and end', () {
      final tween = ArcTween(
        begin: const Offset(0, 0),
        end: const Offset(100, 200),
        intensity: 0,
      );

      // At several t values the result must lie on the straight line
      for (final t in [0.0, 0.25, 0.5, 0.75, 1.0]) {
        final result = tween.lerp(t);
        final expected = Offset(100 * t, 200 * t);
        expect(result.dx, closeTo(expected.dx, 1e-6),
            reason: 'dx at t=$t');
        expect(result.dy, closeTo(expected.dy, 1e-6),
            reason: 'dy at t=$t');
      }
    });

    test('intermediate points lie exactly on the straight line', () {
      final tween = ArcTween(
        begin: const Offset(10, 20),
        end: const Offset(110, 220),
        intensity: 0,
      );

      final mid = tween.lerp(0.5);
      expect(mid.dx, closeTo(60, 1e-6));
      expect(mid.dy, closeTo(120, 1e-6));
    });
  });

  // ---------------------------------------------------------------
  // 2. Arc path (default intensity)
  // ---------------------------------------------------------------
  group('Arc path (default intensity)', () {
    test('intermediate points deviate from the linear path', () {
      final begin = const Offset(0, 0);
      final end = const Offset(200, 200);

      final arcTween = ArcTween(begin: begin, end: end); // intensity = 1.0
      final linearMid = Offset.lerp(begin, end, 0.5)!;
      final arcMid = arcTween.lerp(0.5);

      // The arc midpoint must NOT be the same as the linear midpoint.
      final dx = (arcMid.dx - linearMid.dx).abs();
      final dy = (arcMid.dy - linearMid.dy).abs();
      expect(dx + dy, greaterThan(1e-3),
          reason: 'Arc midpoint should differ from linear midpoint');
    });

    test('midpoint with intensity 1 deviates more than intensity 0.5', () {
      final begin = const Offset(0, 0);
      final end = const Offset(200, 200);
      final linearMid = Offset.lerp(begin, end, 0.5)!;

      final arcHalf = ArcTween(begin: begin, end: end, intensity: 0.5);
      final arcFull = ArcTween(begin: begin, end: end, intensity: 1.0);

      final deviationHalf = (arcHalf.lerp(0.5) - linearMid).distance;
      final deviationFull = (arcFull.lerp(0.5) - linearMid).distance;

      expect(deviationFull, greaterThan(deviationHalf));
    });
  });

  // ---------------------------------------------------------------
  // 3. t=0 returns begin
  // ---------------------------------------------------------------
  group('t=0 returns begin', () {
    test('with default intensity', () {
      final tween = ArcTween(
        begin: const Offset(42, 84),
        end: const Offset(200, 300),
      );
      final result = tween.lerp(0);
      expect(result.dx, closeTo(42, 1e-6));
      expect(result.dy, closeTo(84, 1e-6));
    });

    test('with intensity 0', () {
      final tween = ArcTween(
        begin: const Offset(42, 84),
        end: const Offset(200, 300),
        intensity: 0,
      );
      final result = tween.lerp(0);
      expect(result.dx, closeTo(42, 1e-6));
      expect(result.dy, closeTo(84, 1e-6));
    });

    test('with negative intensity', () {
      final tween = ArcTween(
        begin: const Offset(42, 84),
        end: const Offset(200, 300),
        intensity: -1.0,
      );
      final result = tween.lerp(0);
      expect(result.dx, closeTo(42, 1e-6));
      expect(result.dy, closeTo(84, 1e-6));
    });
  });

  // ---------------------------------------------------------------
  // 4. t=1 returns end
  // ---------------------------------------------------------------
  group('t=1 returns end', () {
    test('with default intensity', () {
      final tween = ArcTween(
        begin: const Offset(10, 20),
        end: const Offset(300, 400),
      );
      final result = tween.lerp(1);
      expect(result.dx, closeTo(300, 1e-6));
      expect(result.dy, closeTo(400, 1e-6));
    });

    test('with intensity 0', () {
      final tween = ArcTween(
        begin: const Offset(10, 20),
        end: const Offset(300, 400),
        intensity: 0,
      );
      final result = tween.lerp(1);
      expect(result.dx, closeTo(300, 1e-6));
      expect(result.dy, closeTo(400, 1e-6));
    });

    test('with intensity -1', () {
      final tween = ArcTween(
        begin: const Offset(10, 20),
        end: const Offset(300, 400),
        intensity: -1.0,
      );
      final result = tween.lerp(1);
      expect(result.dx, closeTo(300, 1e-6));
      expect(result.dy, closeTo(400, 1e-6));
    });
  });

  // ---------------------------------------------------------------
  // 5. Symmetry: A->B with positive intensity mirrors B->A
  // ---------------------------------------------------------------
  group('Symmetry', () {
    test('A->B at t and B->A at (1-t) produce the same point', () {
      final a = const Offset(0, 0);
      final b = const Offset(200, 300);

      final forward = ArcTween(begin: a, end: b, intensity: 1.0);
      final reverse = ArcTween(begin: b, end: a, intensity: 1.0);

      for (final t in [0.0, 0.1, 0.25, 0.5, 0.75, 0.9, 1.0]) {
        final fwd = forward.lerp(t);
        final rev = reverse.lerp(1 - t);
        expect(fwd.dx, closeTo(rev.dx, 1e-6),
            reason: 'dx symmetry at t=$t');
        expect(fwd.dy, closeTo(rev.dy, 1e-6),
            reason: 'dy symmetry at t=$t');
      }
    });

    test('symmetry holds for different intensities', () {
      final a = const Offset(50, 100);
      final b = const Offset(250, 400);

      for (final intensity in [0.0, 0.5, 2.0]) {
        final forward = ArcTween(begin: a, end: b, intensity: intensity);
        final reverse = ArcTween(begin: b, end: a, intensity: intensity);

        for (final t in [0.25, 0.5, 0.75]) {
          final fwd = forward.lerp(t);
          final rev = reverse.lerp(1 - t);
          expect(fwd.dx, closeTo(rev.dx, 1e-6),
              reason: 'dx symmetry at t=$t, intensity=$intensity');
          expect(fwd.dy, closeTo(rev.dy, 1e-6),
              reason: 'dy symmetry at t=$t, intensity=$intensity');
        }
      }
    });
  });

  // ---------------------------------------------------------------
  // 6. Same begin and end
  // ---------------------------------------------------------------
  group('Same begin and end', () {
    test('all t values return the same point', () {
      final point = const Offset(77, 33);
      final tween = ArcTween(begin: point, end: point);

      for (final t in [0.0, 0.25, 0.5, 0.75, 1.0]) {
        final result = tween.lerp(t);
        expect(result.dx, closeTo(77, 1e-6), reason: 'dx at t=$t');
        expect(result.dy, closeTo(33, 1e-6), reason: 'dy at t=$t');
      }
    });

    test('with different intensities all return the same point', () {
      final point = const Offset(100, 200);

      for (final intensity in [0.0, 0.5, 1.0, -1.0]) {
        final tween =
            ArcTween(begin: point, end: point, intensity: intensity);
        final mid = tween.lerp(0.5);
        expect(mid.dx, closeTo(100, 1e-6),
            reason: 'dx at intensity=$intensity');
        expect(mid.dy, closeTo(200, 1e-6),
            reason: 'dy at intensity=$intensity');
      }
    });
  });

  // ---------------------------------------------------------------
  // 7. Various intensities
  // ---------------------------------------------------------------
  group('Various intensities', () {
    final begin = const Offset(0, 0);
    final end = const Offset(200, 200);
    final linearMid = Offset.lerp(begin, end, 0.5)!;

    test('intensity 0.5 produces moderate arc', () {
      final tween = ArcTween(begin: begin, end: end, intensity: 0.5);
      final mid = tween.lerp(0.5);
      final deviation = (mid - linearMid).distance;
      expect(deviation, greaterThan(0),
          reason: 'Should deviate from straight line');
    });

    test('intensity 1.0 produces full arc', () {
      final tween = ArcTween(begin: begin, end: end, intensity: 1.0);
      final mid = tween.lerp(0.5);
      final deviation = (mid - linearMid).distance;
      expect(deviation, greaterThan(0),
          reason: 'Should deviate from straight line');
    });

    test('intensity -1.0 produces arc on the opposite side', () {
      final tween = ArcTween(begin: begin, end: end, intensity: -1.0);
      final mid = tween.lerp(0.5);
      final deviation = (mid - linearMid).distance;
      expect(deviation, greaterThan(0),
          reason: 'Negative intensity should also deviate');
    });

    test('positive and negative intensity produce arcs on opposite sides', () {
      final positive =
          ArcTween(begin: begin, end: end, intensity: 1.0).lerp(0.5);
      final negative =
          ArcTween(begin: begin, end: end, intensity: -1.0).lerp(0.5);

      // Both deviate from the midpoint, but in opposite directions.
      // The midpoint of positive and negative arcs should be the linear mid.
      final avgDx = (positive.dx + negative.dx) / 2;
      final avgDy = (positive.dy + negative.dy) / 2;
      expect(avgDx, closeTo(linearMid.dx, 1e-6));
      expect(avgDy, closeTo(linearMid.dy, 1e-6));
    });

    test('higher intensity produces larger deviation', () {
      final dev05 =
          (ArcTween(begin: begin, end: end, intensity: 0.5).lerp(0.5) -
                  linearMid)
              .distance;
      final dev10 =
          (ArcTween(begin: begin, end: end, intensity: 1.0).lerp(0.5) -
                  linearMid)
              .distance;
      final dev20 =
          (ArcTween(begin: begin, end: end, intensity: 2.0).lerp(0.5) -
                  linearMid)
              .distance;

      expect(dev10, greaterThan(dev05));
      expect(dev20, greaterThan(dev10));
    });

    test('intensity 0 gives linear interpolation for diagonal movement', () {
      final tween = ArcTween(begin: begin, end: end, intensity: 0);
      for (final t in [0.0, 0.25, 0.5, 0.75, 1.0]) {
        final result = tween.lerp(t);
        final expected = Offset.lerp(begin, end, t)!;
        expect(result.dx, closeTo(expected.dx, 1e-6),
            reason: 'dx at t=$t');
        expect(result.dy, closeTo(expected.dy, 1e-6),
            reason: 'dy at t=$t');
      }
    });
  });

  // ---------------------------------------------------------------
  // 8. Horizontal movement (same y)
  // ---------------------------------------------------------------
  group('Horizontal movement', () {
    test('falls back to linear interpolation when dy < 1', () {
      final tween = ArcTween(
        begin: const Offset(0, 100),
        end: const Offset(200, 100),
      );

      // Since dy difference is 0 (< 1), should fall back to Offset.lerp
      for (final t in [0.0, 0.25, 0.5, 0.75, 1.0]) {
        final result = tween.lerp(t);
        final expected = Offset.lerp(
          const Offset(0, 100),
          const Offset(200, 100),
          t,
        )!;
        expect(result.dx, closeTo(expected.dx, 1e-6),
            reason: 'dx at t=$t');
        expect(result.dy, closeTo(expected.dy, 1e-6),
            reason: 'dy at t=$t');
      }
    });

    test('y stays constant throughout horizontal animation', () {
      final tween = ArcTween(
        begin: const Offset(50, 75),
        end: const Offset(300, 75),
      );

      for (final t in [0.0, 0.1, 0.5, 0.9, 1.0]) {
        final result = tween.lerp(t);
        expect(result.dy, closeTo(75, 1e-6),
            reason: 'y should remain 75 at t=$t');
      }
    });

    test('x moves linearly for horizontal movement', () {
      final tween = ArcTween(
        begin: const Offset(0, 50),
        end: const Offset(100, 50),
      );

      expect(tween.lerp(0.5).dx, closeTo(50, 1e-6));
      expect(tween.lerp(0.25).dx, closeTo(25, 1e-6));
    });
  });

  // ---------------------------------------------------------------
  // 9. Vertical movement (same x)
  // ---------------------------------------------------------------
  group('Vertical movement', () {
    test('falls back to linear interpolation when dx < 1', () {
      final tween = ArcTween(
        begin: const Offset(100, 0),
        end: const Offset(100, 200),
      );

      for (final t in [0.0, 0.25, 0.5, 0.75, 1.0]) {
        final result = tween.lerp(t);
        final expected = Offset.lerp(
          const Offset(100, 0),
          const Offset(100, 200),
          t,
        )!;
        expect(result.dx, closeTo(expected.dx, 1e-6),
            reason: 'dx at t=$t');
        expect(result.dy, closeTo(expected.dy, 1e-6),
            reason: 'dy at t=$t');
      }
    });

    test('x stays constant throughout vertical animation', () {
      final tween = ArcTween(
        begin: const Offset(60, 10),
        end: const Offset(60, 400),
      );

      for (final t in [0.0, 0.2, 0.5, 0.8, 1.0]) {
        final result = tween.lerp(t);
        expect(result.dx, closeTo(60, 1e-6),
            reason: 'x should remain 60 at t=$t');
      }
    });

    test('y moves linearly for vertical movement', () {
      final tween = ArcTween(
        begin: const Offset(50, 0),
        end: const Offset(50, 100),
      );

      expect(tween.lerp(0.5).dy, closeTo(50, 1e-6));
      expect(tween.lerp(0.25).dy, closeTo(25, 1e-6));
    });
  });

  // ---------------------------------------------------------------
  // 10. Diagonal movement
  // ---------------------------------------------------------------
  group('Diagonal movement', () {
    test('produces curved path with default intensity', () {
      final begin = const Offset(0, 0);
      final end = const Offset(300, 400);
      final tween = ArcTween(begin: begin, end: end);

      // Collect several intermediate points
      final points = <Offset>[];
      for (double t = 0; t <= 1.0; t += 0.1) {
        points.add(tween.lerp(t));
      }

      // Verify endpoints
      expect(points.first, offsetCloseTo(begin, 1e-6));
      expect(tween.lerp(1.0), offsetCloseTo(end, 1e-6));

      // Check that at least one intermediate point deviates from line
      final linearMid = Offset.lerp(begin, end, 0.5)!;
      final arcMid = tween.lerp(0.5);
      final deviation = (arcMid - linearMid).distance;
      expect(deviation, greaterThan(1.0),
          reason: 'Diagonal arc should deviate from straight line');
    });

    test('control point shifts based on relative y positions', () {
      // When from.dy > to.dy, control goes to (to.dx, from.dy)
      final downToUp = ArcTween(
        begin: const Offset(0, 300),
        end: const Offset(300, 0),
      );

      // When from.dy <= to.dy, control goes to (from.dx, to.dy)
      final upToDown = ArcTween(
        begin: const Offset(0, 0),
        end: const Offset(300, 300),
      );

      final midDown = downToUp.lerp(0.5);
      final midUp = upToDown.lerp(0.5);

      // Both should deviate from straight line
      final linearMidDown =
          Offset.lerp(const Offset(0, 300), const Offset(300, 0), 0.5)!;
      final linearMidUp =
          Offset.lerp(const Offset(0, 0), const Offset(300, 300), 0.5)!;

      expect((midDown - linearMidDown).distance, greaterThan(1.0));
      expect((midUp - linearMidUp).distance, greaterThan(1.0));
    });

    test('path is continuous (no jumps between adjacent t values)', () {
      final tween = ArcTween(
        begin: const Offset(10, 20),
        end: const Offset(310, 420),
      );

      Offset previous = tween.lerp(0);
      const steps = 100;
      for (int i = 1; i <= steps; i++) {
        final t = i / steps;
        final current = tween.lerp(t);
        final jump = (current - previous).distance;

        // Maximum reasonable step is the total distance divided by steps,
        // with some tolerance for curvature
        final totalDistance =
            (const Offset(310, 420) - const Offset(10, 20)).distance;
        final maxStep = totalDistance / steps * 3; // generous tolerance
        expect(jump, lessThan(maxStep),
            reason:
                'Jump between t=${(i - 1) / steps} and t=$t should be smooth');

        previous = current;
      }
    });

    test('quadratic Bezier formula produces correct values at t=0.5', () {
      // Manually verify the Bezier calculation for a known case
      final begin = const Offset(0, 0);
      final end = const Offset(200, 200);

      // from.dy <= to.dy, so maxControl = Offset(from.dx, to.dy) = (0, 200)
      // midpoint = (100, 100)
      // control = midpoint + (maxControl - midpoint) * 1.0
      //         = (100,100) + ((0,200) - (100,100)) * 1.0
      //         = (100,100) + (-100, 100)
      //         = (0, 200)
      // expectedControl = (0, 200)
      // B(0.5) = 0.25 * P0 + 0.5 * P1 + 0.25 * P2
      //        = 0.25*(0,0) + 0.5*(0,200) + 0.25*(200,200)
      //        = (0,0) + (0,100) + (50,50)
      //        = (50, 150)
      final tween = ArcTween(begin: begin, end: end, intensity: 1.0);
      final mid = tween.lerp(0.5);

      expect(mid.dx, closeTo(50, 1e-6));
      expect(mid.dy, closeTo(150, 1e-6));
    });
  });
}
