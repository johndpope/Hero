import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_hero_transitions/src/types/hero_animation_type.dart';

void main() {
  // ---------------------------------------------------------------
  // 1. All animation type constructors exist and produce the
  //    expected concrete subtypes.
  // ---------------------------------------------------------------
  group('All animation types exist', () {
    test('push creates HeroAnimationTypePush', () {
      const type = HeroAnimationType.push(direction: HeroAnimationDirection.left);
      expect(type, isA<HeroAnimationTypePush>());
    });

    test('pull creates HeroAnimationTypePull', () {
      const type = HeroAnimationType.pull(direction: HeroAnimationDirection.left);
      expect(type, isA<HeroAnimationTypePull>());
    });

    test('cover creates HeroAnimationTypeCover', () {
      const type = HeroAnimationType.cover(direction: HeroAnimationDirection.left);
      expect(type, isA<HeroAnimationTypeCover>());
    });

    test('uncover creates HeroAnimationTypeUncover', () {
      const type = HeroAnimationType.uncover(direction: HeroAnimationDirection.left);
      expect(type, isA<HeroAnimationTypeUncover>());
    });

    test('slide creates HeroAnimationTypeSlide', () {
      const type = HeroAnimationType.slide(direction: HeroAnimationDirection.left);
      expect(type, isA<HeroAnimationTypeSlide>());
    });

    test('zoomSlide creates HeroAnimationTypeZoomSlide', () {
      const type = HeroAnimationType.zoomSlide(direction: HeroAnimationDirection.left);
      expect(type, isA<HeroAnimationTypeZoomSlide>());
    });

    test('pageIn creates HeroAnimationTypePageIn', () {
      const type = HeroAnimationType.pageIn(direction: HeroAnimationDirection.left);
      expect(type, isA<HeroAnimationTypePageIn>());
    });

    test('pageOut creates HeroAnimationTypePageOut', () {
      const type = HeroAnimationType.pageOut(direction: HeroAnimationDirection.left);
      expect(type, isA<HeroAnimationTypePageOut>());
    });

    test('fade creates HeroAnimationTypeFade', () {
      const type = HeroAnimationType.fade();
      expect(type, isA<HeroAnimationTypeFade>());
    });

    test('zoom creates HeroAnimationTypeZoom', () {
      const type = HeroAnimationType.zoom();
      expect(type, isA<HeroAnimationTypeZoom>());
    });

    test('zoomOut creates HeroAnimationTypeZoomOut', () {
      const type = HeroAnimationType.zoomOut();
      expect(type, isA<HeroAnimationTypeZoomOut>());
    });

    test('selectBy creates HeroAnimationTypeSelectBy', () {
      const type = HeroAnimationType.selectBy(
        presenting: HeroAnimationType.fade(),
        dismissing: HeroAnimationType.zoom(),
      );
      expect(type, isA<HeroAnimationTypeSelectBy>());
    });

    test('none creates HeroAnimationTypeNone', () {
      const type = HeroAnimationType.none();
      expect(type, isA<HeroAnimationTypeNone>());
    });

    test('auto creates HeroAnimationTypeAuto', () {
      const type = HeroAnimationType.auto();
      expect(type, isA<HeroAnimationTypeAuto>());
    });
  });

  // ---------------------------------------------------------------
  // 2. reversed() method returns the correct opposite type and
  //    direction for every animation type.
  // ---------------------------------------------------------------
  group('reversed() method', () {
    test('push.reversed() returns pull with opposite direction', () {
      const push = HeroAnimationType.push(direction: HeroAnimationDirection.left);
      final reversed = push.reversed();
      expect(reversed, isA<HeroAnimationTypePull>());
      expect((reversed as HeroAnimationTypePull).direction, HeroAnimationDirection.right);
    });

    test('pull.reversed() returns push with opposite direction', () {
      const pull = HeroAnimationType.pull(direction: HeroAnimationDirection.left);
      final reversed = pull.reversed();
      expect(reversed, isA<HeroAnimationTypePush>());
      expect((reversed as HeroAnimationTypePush).direction, HeroAnimationDirection.right);
    });

    test('cover.reversed() returns uncover with opposite direction', () {
      const cover = HeroAnimationType.cover(direction: HeroAnimationDirection.up);
      final reversed = cover.reversed();
      expect(reversed, isA<HeroAnimationTypeUncover>());
      expect((reversed as HeroAnimationTypeUncover).direction, HeroAnimationDirection.down);
    });

    test('uncover.reversed() returns cover with opposite direction', () {
      const uncover = HeroAnimationType.uncover(direction: HeroAnimationDirection.down);
      final reversed = uncover.reversed();
      expect(reversed, isA<HeroAnimationTypeCover>());
      expect((reversed as HeroAnimationTypeCover).direction, HeroAnimationDirection.up);
    });

    test('slide.reversed() returns slide with opposite direction', () {
      const slide = HeroAnimationType.slide(direction: HeroAnimationDirection.right);
      final reversed = slide.reversed();
      expect(reversed, isA<HeroAnimationTypeSlide>());
      expect((reversed as HeroAnimationTypeSlide).direction, HeroAnimationDirection.left);
    });

    test('zoomSlide.reversed() returns zoomSlide with opposite direction', () {
      const zoomSlide = HeroAnimationType.zoomSlide(direction: HeroAnimationDirection.up);
      final reversed = zoomSlide.reversed();
      expect(reversed, isA<HeroAnimationTypeZoomSlide>());
      expect((reversed as HeroAnimationTypeZoomSlide).direction, HeroAnimationDirection.down);
    });

    test('pageIn.reversed() returns pageOut with opposite direction', () {
      const pageIn = HeroAnimationType.pageIn(direction: HeroAnimationDirection.left);
      final reversed = pageIn.reversed();
      expect(reversed, isA<HeroAnimationTypePageOut>());
      expect((reversed as HeroAnimationTypePageOut).direction, HeroAnimationDirection.right);
    });

    test('pageOut.reversed() returns pageIn with opposite direction', () {
      const pageOut = HeroAnimationType.pageOut(direction: HeroAnimationDirection.right);
      final reversed = pageOut.reversed();
      expect(reversed, isA<HeroAnimationTypePageIn>());
      expect((reversed as HeroAnimationTypePageIn).direction, HeroAnimationDirection.left);
    });

    test('fade.reversed() returns fade', () {
      const fade = HeroAnimationType.fade();
      final reversed = fade.reversed();
      expect(reversed, isA<HeroAnimationTypeFade>());
    });

    test('zoom.reversed() returns zoomOut', () {
      const zoom = HeroAnimationType.zoom();
      final reversed = zoom.reversed();
      expect(reversed, isA<HeroAnimationTypeZoomOut>());
    });

    test('zoomOut.reversed() returns zoom', () {
      const zoomOut = HeroAnimationType.zoomOut();
      final reversed = zoomOut.reversed();
      expect(reversed, isA<HeroAnimationTypeZoom>());
    });

    test('none.reversed() returns none', () {
      const none = HeroAnimationType.none();
      final reversed = none.reversed();
      expect(reversed, isA<HeroAnimationTypeNone>());
    });

    test('auto.reversed() returns auto', () {
      const auto_ = HeroAnimationType.auto();
      final reversed = auto_.reversed();
      expect(reversed, isA<HeroAnimationTypeAuto>());
    });

    test('selectBy.reversed() swaps presenting and dismissing', () {
      const selectBy = HeroAnimationType.selectBy(
        presenting: HeroAnimationType.fade(),
        dismissing: HeroAnimationType.zoom(),
      );
      final reversed = selectBy.reversed();
      expect(reversed, isA<HeroAnimationTypeSelectBy>());
      final reversedSelectBy = reversed as HeroAnimationTypeSelectBy;
      // presenting and dismissing should be swapped
      expect(reversedSelectBy.presenting, isA<HeroAnimationTypeZoom>());
      expect(reversedSelectBy.dismissing, isA<HeroAnimationTypeFade>());
    });

    test('push.reversed() works for all four directions', () {
      for (final dir in HeroAnimationDirection.values) {
        final push = HeroAnimationType.push(direction: dir);
        final reversed = push.reversed();
        expect(reversed, isA<HeroAnimationTypePull>());
        expect((reversed as HeroAnimationTypePull).direction, dir.opposite);
      }
    });

    test('double reversed() round-trips for directional types', () {
      const original = HeroAnimationType.push(direction: HeroAnimationDirection.left);
      final doubleReversed = original.reversed().reversed();
      expect(doubleReversed, isA<HeroAnimationTypePush>());
      expect(
        (doubleReversed as HeroAnimationTypePush).direction,
        HeroAnimationDirection.left,
      );
    });

    test('double reversed() round-trips for non-directional types', () {
      const zoom = HeroAnimationType.zoom();
      final doubleReversed = zoom.reversed().reversed();
      expect(doubleReversed, isA<HeroAnimationTypeZoom>());
    });
  });

  // ---------------------------------------------------------------
  // 3. HeroAnimationDirection: all 4 values and their opposite
  //    getters.
  // ---------------------------------------------------------------
  group('HeroAnimationDirection', () {
    test('has exactly 4 values', () {
      expect(HeroAnimationDirection.values.length, 4);
    });

    test('contains left, right, up, down', () {
      expect(
        HeroAnimationDirection.values,
        containsAll([
          HeroAnimationDirection.left,
          HeroAnimationDirection.right,
          HeroAnimationDirection.up,
          HeroAnimationDirection.down,
        ]),
      );
    });

    test('left.opposite is right', () {
      expect(HeroAnimationDirection.left.opposite, HeroAnimationDirection.right);
    });

    test('right.opposite is left', () {
      expect(HeroAnimationDirection.right.opposite, HeroAnimationDirection.left);
    });

    test('up.opposite is down', () {
      expect(HeroAnimationDirection.up.opposite, HeroAnimationDirection.down);
    });

    test('down.opposite is up', () {
      expect(HeroAnimationDirection.down.opposite, HeroAnimationDirection.up);
    });

    test('double opposite returns the original direction', () {
      for (final dir in HeroAnimationDirection.values) {
        expect(dir.opposite.opposite, dir);
      }
    });
  });

  // ---------------------------------------------------------------
  // 4. autoReverse factory creates a selectBy type with the
  //    correct presenting / dismissing pairing.
  // ---------------------------------------------------------------
  group('autoReverse factory', () {
    test('produces a selectBy type', () {
      final result = HeroAnimationType.autoReverse(
        presenting: const HeroAnimationType.push(direction: HeroAnimationDirection.left),
      );
      expect(result, isA<HeroAnimationTypeSelectBy>());
    });

    test('presenting field matches the input', () {
      final result = HeroAnimationType.autoReverse(
        presenting: const HeroAnimationType.push(direction: HeroAnimationDirection.left),
      );
      final selectBy = result as HeroAnimationTypeSelectBy;
      expect(selectBy.presenting, isA<HeroAnimationTypePush>());
      expect(
        (selectBy.presenting as HeroAnimationTypePush).direction,
        HeroAnimationDirection.left,
      );
    });

    test('dismissing field is the reversed presenting animation', () {
      final result = HeroAnimationType.autoReverse(
        presenting: const HeroAnimationType.push(direction: HeroAnimationDirection.left),
      );
      final selectBy = result as HeroAnimationTypeSelectBy;
      // push(left).reversed() => pull(right)
      expect(selectBy.dismissing, isA<HeroAnimationTypePull>());
      expect(
        (selectBy.dismissing as HeroAnimationTypePull).direction,
        HeroAnimationDirection.right,
      );
    });

    test('autoReverse with fade produces fade for both', () {
      final result = HeroAnimationType.autoReverse(
        presenting: const HeroAnimationType.fade(),
      );
      final selectBy = result as HeroAnimationTypeSelectBy;
      expect(selectBy.presenting, isA<HeroAnimationTypeFade>());
      expect(selectBy.dismissing, isA<HeroAnimationTypeFade>());
    });

    test('autoReverse with zoom produces zoom presenting, zoomOut dismissing', () {
      final result = HeroAnimationType.autoReverse(
        presenting: const HeroAnimationType.zoom(),
      );
      final selectBy = result as HeroAnimationTypeSelectBy;
      expect(selectBy.presenting, isA<HeroAnimationTypeZoom>());
      expect(selectBy.dismissing, isA<HeroAnimationTypeZoomOut>());
    });

    test('autoReverse with cover produces cover presenting, uncover dismissing', () {
      final result = HeroAnimationType.autoReverse(
        presenting: const HeroAnimationType.cover(direction: HeroAnimationDirection.up),
      );
      final selectBy = result as HeroAnimationTypeSelectBy;
      expect(selectBy.presenting, isA<HeroAnimationTypeCover>());
      expect(
        (selectBy.presenting as HeroAnimationTypeCover).direction,
        HeroAnimationDirection.up,
      );
      expect(selectBy.dismissing, isA<HeroAnimationTypeUncover>());
      expect(
        (selectBy.dismissing as HeroAnimationTypeUncover).direction,
        HeroAnimationDirection.down,
      );
    });
  });

  // ---------------------------------------------------------------
  // 5. label property: every type has a non-empty label string.
  // ---------------------------------------------------------------
  group('label property', () {
    test('push label is non-empty and contains direction', () {
      const type = HeroAnimationType.push(direction: HeroAnimationDirection.left);
      expect(type.label, isNotEmpty);
      expect(type.label, contains('Push'));
      expect(type.label, contains('left'));
    });

    test('pull label is non-empty and contains direction', () {
      const type = HeroAnimationType.pull(direction: HeroAnimationDirection.right);
      expect(type.label, isNotEmpty);
      expect(type.label, contains('Pull'));
      expect(type.label, contains('right'));
    });

    test('cover label is non-empty', () {
      const type = HeroAnimationType.cover(direction: HeroAnimationDirection.up);
      expect(type.label, isNotEmpty);
      expect(type.label, contains('Cover'));
    });

    test('uncover label is non-empty', () {
      const type = HeroAnimationType.uncover(direction: HeroAnimationDirection.down);
      expect(type.label, isNotEmpty);
      expect(type.label, contains('Uncover'));
    });

    test('slide label is non-empty', () {
      const type = HeroAnimationType.slide(direction: HeroAnimationDirection.left);
      expect(type.label, isNotEmpty);
      expect(type.label, contains('Slide'));
    });

    test('zoomSlide label is non-empty', () {
      const type = HeroAnimationType.zoomSlide(direction: HeroAnimationDirection.left);
      expect(type.label, isNotEmpty);
      expect(type.label, contains('Zoom Slide'));
    });

    test('pageIn label is non-empty', () {
      const type = HeroAnimationType.pageIn(direction: HeroAnimationDirection.left);
      expect(type.label, isNotEmpty);
      expect(type.label, contains('Page In'));
    });

    test('pageOut label is non-empty', () {
      const type = HeroAnimationType.pageOut(direction: HeroAnimationDirection.left);
      expect(type.label, isNotEmpty);
      expect(type.label, contains('Page Out'));
    });

    test('fade label is "Fade"', () {
      const type = HeroAnimationType.fade();
      expect(type.label, 'Fade');
    });

    test('zoom label is "Zoom"', () {
      const type = HeroAnimationType.zoom();
      expect(type.label, 'Zoom');
    });

    test('zoomOut label is "Zoom Out"', () {
      const type = HeroAnimationType.zoomOut();
      expect(type.label, 'Zoom Out');
    });

    test('none label is "None"', () {
      const type = HeroAnimationType.none();
      expect(type.label, 'None');
    });

    test('auto label is "Auto"', () {
      const type = HeroAnimationType.auto();
      expect(type.label, 'Auto');
    });

    test('selectBy label includes presenting and dismissing labels', () {
      const type = HeroAnimationType.selectBy(
        presenting: HeroAnimationType.fade(),
        dismissing: HeroAnimationType.zoom(),
      );
      expect(type.label, isNotEmpty);
      expect(type.label, contains('Fade'));
      expect(type.label, contains('Zoom'));
      expect(type.label, 'SelectBy(Fade, Zoom)');
    });

    test('every directional type has a non-empty label for each direction', () {
      for (final dir in HeroAnimationDirection.values) {
        final types = <HeroAnimationType>[
          HeroAnimationType.push(direction: dir),
          HeroAnimationType.pull(direction: dir),
          HeroAnimationType.cover(direction: dir),
          HeroAnimationType.uncover(direction: dir),
          HeroAnimationType.slide(direction: dir),
          HeroAnimationType.zoomSlide(direction: dir),
          HeroAnimationType.pageIn(direction: dir),
          HeroAnimationType.pageOut(direction: dir),
        ];
        for (final type in types) {
          expect(type.label, isNotEmpty,
              reason: '${type.runtimeType} with direction ${dir.name} should have a non-empty label');
          expect(type.label.contains(dir.name), isTrue,
              reason: '${type.runtimeType} label should contain direction name "${dir.name}"');
        }
      }
    });
  });

  // ---------------------------------------------------------------
  // 6. selectBy: presenting and dismissing fields store correctly.
  // ---------------------------------------------------------------
  group('selectBy stores fields correctly', () {
    test('presenting and dismissing are accessible', () {
      const presenting = HeroAnimationType.fade();
      const dismissing = HeroAnimationType.zoom();
      const selectBy = HeroAnimationType.selectBy(
        presenting: presenting,
        dismissing: dismissing,
      );
      final typed = selectBy as HeroAnimationTypeSelectBy;
      expect(typed.presenting, isA<HeroAnimationTypeFade>());
      expect(typed.dismissing, isA<HeroAnimationTypeZoom>());
    });

    test('selectBy can store directional types', () {
      const presenting = HeroAnimationType.push(direction: HeroAnimationDirection.left);
      const dismissing = HeroAnimationType.pull(direction: HeroAnimationDirection.right);
      const selectBy = HeroAnimationType.selectBy(
        presenting: presenting,
        dismissing: dismissing,
      );
      final typed = selectBy as HeroAnimationTypeSelectBy;
      expect(typed.presenting, isA<HeroAnimationTypePush>());
      expect(
        (typed.presenting as HeroAnimationTypePush).direction,
        HeroAnimationDirection.left,
      );
      expect(typed.dismissing, isA<HeroAnimationTypePull>());
      expect(
        (typed.dismissing as HeroAnimationTypePull).direction,
        HeroAnimationDirection.right,
      );
    });

    test('selectBy can nest another selectBy', () {
      const inner = HeroAnimationType.selectBy(
        presenting: HeroAnimationType.fade(),
        dismissing: HeroAnimationType.none(),
      );
      const outer = HeroAnimationType.selectBy(
        presenting: inner,
        dismissing: HeroAnimationType.zoom(),
      );
      final outerTyped = outer as HeroAnimationTypeSelectBy;
      expect(outerTyped.presenting, isA<HeroAnimationTypeSelectBy>());
      expect(outerTyped.dismissing, isA<HeroAnimationTypeZoom>());

      final innerTyped = outerTyped.presenting as HeroAnimationTypeSelectBy;
      expect(innerTyped.presenting, isA<HeroAnimationTypeFade>());
      expect(innerTyped.dismissing, isA<HeroAnimationTypeNone>());
    });

    test('selectBy preserves both fields after reversed()', () {
      const selectBy = HeroAnimationType.selectBy(
        presenting: HeroAnimationType.push(direction: HeroAnimationDirection.up),
        dismissing: HeroAnimationType.cover(direction: HeroAnimationDirection.down),
      );
      final reversed = selectBy.reversed() as HeroAnimationTypeSelectBy;
      // After reversing, presenting becomes the old dismissing and vice versa
      expect(reversed.presenting, isA<HeroAnimationTypeCover>());
      expect(
        (reversed.presenting as HeroAnimationTypeCover).direction,
        HeroAnimationDirection.down,
      );
      expect(reversed.dismissing, isA<HeroAnimationTypePush>());
      expect(
        (reversed.dismissing as HeroAnimationTypePush).direction,
        HeroAnimationDirection.up,
      );
    });
  });
}
