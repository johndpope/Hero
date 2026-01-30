import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4;

import 'package:flutter_hero_transitions/src/types/hero_target_state.dart';
import 'package:flutter_hero_transitions/src/types/cascade_direction.dart';
import 'package:flutter_hero_transitions/src/types/hero_coordinate_space.dart';
import 'package:flutter_hero_transitions/src/types/hero_snapshot_type.dart';
import 'package:flutter_hero_transitions/src/types/hero_conditional_context.dart';
import 'package:flutter_hero_transitions/src/modifiers/hero_modifier.dart';

void main() {
  // ================================================================
  // 1. Default construction: all properties start as null / defaults
  // ================================================================
  group('Default construction', () {
    late HeroTargetState state;

    setUp(() {
      state = HeroTargetState();
    });

    test('layout properties default to null', () {
      expect(state.position, isNull);
      expect(state.size, isNull);
    });

    test('transform properties default to null', () {
      expect(state.transform, isNull);
      expect(state.opacity, isNull);
      expect(state.cornerRadius, isNull);
      expect(state.backgroundColor, isNull);
      expect(state.zPosition, isNull);
      expect(state.anchorPoint, isNull);
    });

    test('contents properties default to null', () {
      expect(state.contentsRect, isNull);
      expect(state.contentsScale, isNull);
    });

    test('border properties default to null', () {
      expect(state.borderWidth, isNull);
      expect(state.borderColor, isNull);
    });

    test('shadow properties default to null or true for displayShadow', () {
      expect(state.shadowColor, isNull);
      expect(state.shadowOpacity, isNull);
      expect(state.shadowOffset, isNull);
      expect(state.shadowRadius, isNull);
      expect(state.displayShadow, isTrue);
      expect(state.clipToBounds, isNull);
    });

    test('overlay defaults to null', () {
      expect(state.overlay, isNull);
    });

    test('timing properties default to null / zero / false', () {
      expect(state.spring, isNull);
      expect(state.delay, equals(Duration.zero));
      expect(state.duration, isNull);
      expect(state.durationMatchLongest, isFalse);
      expect(state.curve, isNull);
    });

    test('arc intensity defaults to null', () {
      expect(state.arcIntensity, isNull);
    });

    test('source defaults to null', () {
      expect(state.source, isNull);
    });

    test('cascade defaults to null', () {
      expect(state.cascade, isNull);
    });

    test('advanced properties default to null', () {
      expect(state.ignoreSubviewModifiers, isNull);
      expect(state.coordinateSpace, isNull);
      expect(state.useScaleBasedSizeChange, isNull);
      expect(state.snapshotType, isNull);
    });

    test('flags default to false', () {
      expect(state.nonFade, isFalse);
      expect(state.forceAnimate, isFalse);
    });

    test('conditional and begin state default to null', () {
      expect(state.beginState, isNull);
      expect(state.conditionalModifiers, isNull);
    });

    test('custom map defaults to null', () {
      expect(state.custom, isNull);
    });
  });

  // ================================================================
  // 2. Property setting: set each property and verify stored value
  // ================================================================
  group('Property setting', () {
    late HeroTargetState state;

    setUp(() {
      state = HeroTargetState();
    });

    test('position can be set and read', () {
      state.position = const Offset(10, 20);
      expect(state.position, equals(const Offset(10, 20)));
    });

    test('size can be set and read', () {
      state.size = const Size(100, 200);
      expect(state.size, equals(const Size(100, 200)));
    });

    test('transform can be set and read', () {
      final t = Matrix4.identity()..rotateZ(0.5);
      state.transform = t;
      expect(state.transform, same(t));
    });

    test('opacity can be set and read', () {
      state.opacity = 0.5;
      expect(state.opacity, equals(0.5));
    });

    test('cornerRadius can be set and read', () {
      state.cornerRadius = 12.0;
      expect(state.cornerRadius, equals(12.0));
    });

    test('backgroundColor can be set and read', () {
      state.backgroundColor = const Color(0xFFFF0000);
      expect(state.backgroundColor, equals(const Color(0xFFFF0000)));
    });

    test('zPosition can be set and read', () {
      state.zPosition = 5.0;
      expect(state.zPosition, equals(5.0));
    });

    test('anchorPoint can be set and read', () {
      state.anchorPoint = const Offset(0.5, 0.5);
      expect(state.anchorPoint, equals(const Offset(0.5, 0.5)));
    });

    test('contentsRect can be set and read', () {
      state.contentsRect = const Rect.fromLTWH(0, 0, 100, 100);
      expect(state.contentsRect, equals(const Rect.fromLTWH(0, 0, 100, 100)));
    });

    test('contentsScale can be set and read', () {
      state.contentsScale = 2.0;
      expect(state.contentsScale, equals(2.0));
    });

    test('borderWidth can be set and read', () {
      state.borderWidth = 3.0;
      expect(state.borderWidth, equals(3.0));
    });

    test('borderColor can be set and read', () {
      state.borderColor = const Color(0xFF00FF00);
      expect(state.borderColor, equals(const Color(0xFF00FF00)));
    });

    test('shadow properties can be set and read', () {
      state.shadowColor = const Color(0xFF000000);
      state.shadowOpacity = 0.8;
      state.shadowOffset = const Offset(2, 4);
      state.shadowRadius = 6.0;
      state.displayShadow = false;
      state.clipToBounds = true;

      expect(state.shadowColor, equals(const Color(0xFF000000)));
      expect(state.shadowOpacity, equals(0.8));
      expect(state.shadowOffset, equals(const Offset(2, 4)));
      expect(state.shadowRadius, equals(6.0));
      expect(state.displayShadow, isFalse);
      expect(state.clipToBounds, isTrue);
    });

    test('overlay can be set and read', () {
      state.overlay = const HeroOverlayState(
        color: Color(0xFF0000FF),
        opacity: 0.6,
      );
      expect(state.overlay, isNotNull);
      expect(state.overlay!.color, equals(const Color(0xFF0000FF)));
      expect(state.overlay!.opacity, equals(0.6));
    });

    test('timing properties can be set and read', () {
      state.duration = const Duration(milliseconds: 300);
      state.delay = const Duration(milliseconds: 100);
      state.durationMatchLongest = true;
      state.curve = Curves.easeInOut;

      expect(state.duration, equals(const Duration(milliseconds: 300)));
      expect(state.delay, equals(const Duration(milliseconds: 100)));
      expect(state.durationMatchLongest, isTrue);
      expect(state.curve, equals(Curves.easeInOut));
    });

    test('spring can be set and read', () {
      state.spring = const HeroSpringConfig(stiffness: 200, dampingRatio: 15);
      expect(state.spring, isNotNull);
      expect(state.spring!.stiffness, equals(200));
      expect(state.spring!.dampingRatio, equals(15));
    });

    test('arcIntensity can be set and read', () {
      state.arcIntensity = 0.75;
      expect(state.arcIntensity, equals(0.75));
    });

    test('source can be set and read', () {
      state.source = 'heroCard';
      expect(state.source, equals('heroCard'));
    });

    test('flags can be set and read', () {
      state.nonFade = true;
      state.forceAnimate = true;
      expect(state.nonFade, isTrue);
      expect(state.forceAnimate, isTrue);
    });

    test('custom data via operator[] and operator[]=', () {
      expect(state['myKey'], isNull);
      state['myKey'] = 42;
      expect(state['myKey'], equals(42));
      expect(state.custom, isNotNull);
      expect(state.custom!['myKey'], equals(42));
    });

    test('custom map is lazily created on first write', () {
      expect(state.custom, isNull);
      state['first'] = 'value';
      expect(state.custom, isNotNull);
      expect(state.custom!.length, equals(1));
    });

    test('coordinateSpace can be set and read', () {
      state.coordinateSpace = HeroCoordinateSpace.global;
      expect(state.coordinateSpace, equals(HeroCoordinateSpace.global));
    });

    test('snapshotType can be set and read', () {
      state.snapshotType = HeroSnapshotType.layerRender;
      expect(state.snapshotType, equals(HeroSnapshotType.layerRender));
    });

    test('useScaleBasedSizeChange can be set and read', () {
      state.useScaleBasedSizeChange = true;
      expect(state.useScaleBasedSizeChange, isTrue);
    });

    test('ignoreSubviewModifiers can be set and read', () {
      state.ignoreSubviewModifiers = true;
      expect(state.ignoreSubviewModifiers, isTrue);
    });
  });

  // ================================================================
  // 3. Construction from modifiers: fromModifiers applies all in order
  // ================================================================
  group('Construction from modifiers', () {
    test('fromModifiers with empty list returns default state', () {
      final state = HeroTargetState.fromModifiers([]);
      expect(state.opacity, isNull);
      expect(state.position, isNull);
      expect(state.size, isNull);
      expect(state.transform, isNull);
    });

    test('fromModifiers applies a single modifier', () {
      final state = HeroTargetState.fromModifiers([HeroModifier.fade]);
      expect(state.opacity, equals(0.0));
    });

    test('fromModifiers applies multiple modifiers in order', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.opacity(0.5),
        HeroModifier.position(const Offset(100, 200)),
        HeroModifier.size(const Size(50, 60)),
      ]);
      expect(state.opacity, equals(0.5));
      expect(state.position, equals(const Offset(100, 200)));
      expect(state.size, equals(const Size(50, 60)));
    });

    test('fromModifiers last-write-wins for same property', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.opacity(0.3),
        HeroModifier.opacity(0.9),
      ]);
      expect(state.opacity, equals(0.9));
    });

    test('fromModifiers applies transform modifiers cumulatively', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.scale(2.0),
        HeroModifier.translate(x: 10, y: 20),
      ]);
      expect(state.transform, isNotNull);
      // scale(2) then translate(10,20): transform accumulates
      // The matrix should not be identity
      expect(state.transform, isNot(equals(Matrix4.identity())));
    });

    test('fromModifiers applies arc modifier', () {
      final state = HeroTargetState.fromModifiers([HeroModifier.arc]);
      expect(state.arcIntensity, equals(1.0));
    });

    test('fromModifiers applies forceAnimate modifier', () {
      final state = HeroTargetState.fromModifiers([HeroModifier.forceAnimate]);
      expect(state.forceAnimate, isTrue);
    });

    test('fromModifiers applies forceNonFade modifier', () {
      final state = HeroTargetState.fromModifiers([HeroModifier.forceNonFade]);
      expect(state.nonFade, isTrue);
    });
  });

  // ================================================================
  // 4. Helper classes
  // ================================================================
  group('HeroSpringConfig', () {
    test('stores stiffness and damping', () {
      const config = HeroSpringConfig(stiffness: 300, dampingRatio: 20);
      expect(config.stiffness, equals(300));
      expect(config.dampingRatio, equals(20));
    });

    test('supports const construction', () {
      const a = HeroSpringConfig(stiffness: 100, dampingRatio: 10);
      const b = HeroSpringConfig(stiffness: 100, dampingRatio: 10);
      // const instances with same values are identical
      expect(identical(a, b), isTrue);
    });
  });

  group('HeroCascadeConfig', () {
    test('has sensible defaults', () {
      const config = HeroCascadeConfig();
      expect(config.delta, equals(const Duration(milliseconds: 20)));
      expect(config.direction, isA<CascadeDirectionTopToBottom>());
      expect(config.delayMatchedViews, isFalse);
    });

    test('custom values are stored correctly', () {
      const config = HeroCascadeConfig(
        delta: Duration(milliseconds: 50),
        direction: CascadeDirection.bottomToTop(),
        delayMatchedViews: true,
      );
      expect(config.delta, equals(const Duration(milliseconds: 50)));
      expect(config.direction, isA<CascadeDirectionBottomToTop>());
      expect(config.delayMatchedViews, isTrue);
    });

    test('supports const construction', () {
      const a = HeroCascadeConfig();
      const b = HeroCascadeConfig();
      expect(identical(a, b), isTrue);
    });
  });

  group('HeroOverlayState', () {
    test('stores color and opacity', () {
      const overlay = HeroOverlayState(
        color: Color(0xFFFF0000),
        opacity: 0.5,
      );
      expect(overlay.color, equals(const Color(0xFFFF0000)));
      expect(overlay.opacity, equals(0.5));
    });

    test('supports const construction', () {
      const a = HeroOverlayState(color: Color(0xFF000000), opacity: 1.0);
      const b = HeroOverlayState(color: Color(0xFF000000), opacity: 1.0);
      expect(identical(a, b), isTrue);
    });
  });

  group('HeroConditionalModifierEntry', () {
    test('stores condition and modifiers', () {
      bool wasCalled = false;
      final entry = HeroConditionalModifierEntry(
        condition: (ctx) {
          wasCalled = true;
          return ctx.isMatched;
        },
        modifiers: [HeroModifier.fade],
      );

      expect(entry.modifiers, hasLength(1));

      // Verify the condition function works
      final ctx = HeroConditionalContext(
        heroID: 'test',
        isAppearing: true,
        isPresenting: true,
        isMatched: true,
      );
      final result = entry.condition(ctx);
      expect(wasCalled, isTrue);
      expect(result, isTrue);
    });

    test('condition returns false for non-matched context', () {
      final entry = HeroConditionalModifierEntry(
        condition: (ctx) => ctx.isMatched,
        modifiers: [HeroModifier.opacity(0.0)],
      );

      final ctx = HeroConditionalContext(
        heroID: 'test',
        isAppearing: true,
        isPresenting: true,
        isMatched: false,
      );
      expect(entry.condition(ctx), isFalse);
    });

    test('can hold multiple modifiers', () {
      final entry = HeroConditionalModifierEntry(
        condition: (ctx) => true,
        modifiers: [
          HeroModifier.fade,
          HeroModifier.scale(2.0),
          HeroModifier.cornerRadius(8.0),
        ],
      );
      expect(entry.modifiers, hasLength(3));
    });
  });

  group('CascadeDirection', () {
    test('topToBottom compares by dy ascending', () {
      const dir = CascadeDirection.topToBottom();
      expect(dir.compare(const Offset(0, 10), const Offset(0, 20)), isNegative);
      expect(dir.compare(const Offset(0, 20), const Offset(0, 10)), isPositive);
      expect(dir.compare(const Offset(0, 10), const Offset(0, 10)), isZero);
    });

    test('bottomToTop compares by dy descending', () {
      const dir = CascadeDirection.bottomToTop();
      expect(dir.compare(const Offset(0, 10), const Offset(0, 20)), isPositive);
      expect(dir.compare(const Offset(0, 20), const Offset(0, 10)), isNegative);
    });

    test('leftToRight compares by dx ascending', () {
      const dir = CascadeDirection.leftToRight();
      expect(dir.compare(const Offset(10, 0), const Offset(20, 0)), isNegative);
      expect(dir.compare(const Offset(20, 0), const Offset(10, 0)), isPositive);
    });

    test('rightToLeft compares by dx descending', () {
      const dir = CascadeDirection.rightToLeft();
      expect(dir.compare(const Offset(10, 0), const Offset(20, 0)), isPositive);
      expect(dir.compare(const Offset(20, 0), const Offset(10, 0)), isNegative);
    });

    test('radial compares by distance from center ascending', () {
      const dir = CascadeDirection.radial(center: Offset.zero);
      // (3,4) distance=5, (6,8) distance=10
      expect(
        dir.compare(const Offset(3, 4), const Offset(6, 8)),
        isNegative,
      );
      expect(
        dir.compare(const Offset(6, 8), const Offset(3, 4)),
        isPositive,
      );
    });

    test('inverseRadial compares by distance from center descending', () {
      const dir = CascadeDirection.inverseRadial(center: Offset.zero);
      // (3,4) distance=5, (6,8) distance=10
      expect(
        dir.compare(const Offset(3, 4), const Offset(6, 8)),
        isPositive,
      );
      expect(
        dir.compare(const Offset(6, 8), const Offset(3, 4)),
        isNegative,
      );
    });
  });

  // ================================================================
  // 5. Multiple modifier composition
  // ================================================================
  group('Multiple modifier composition', () {
    test('appearance modifiers compose correctly', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.opacity(0.7),
        HeroModifier.cornerRadius(16.0),
        HeroModifier.backgroundColor(const Color(0xFF00FF00)),
        HeroModifier.borderColor(const Color(0xFFFF0000)),
        HeroModifier.borderWidth(2.0),
        HeroModifier.zPosition(10.0),
      ]);

      expect(state.opacity, equals(0.7));
      expect(state.cornerRadius, equals(16.0));
      expect(state.backgroundColor, equals(const Color(0xFF00FF00)));
      expect(state.borderColor, equals(const Color(0xFFFF0000)));
      expect(state.borderWidth, equals(2.0));
      expect(state.zPosition, equals(10.0));
    });

    test('shadow modifiers compose correctly', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.shadowColor(const Color(0xFF000000)),
        HeroModifier.shadowOpacity(0.5),
        HeroModifier.shadowOffset(const Offset(2, 4)),
        HeroModifier.shadowRadius(8.0),
        HeroModifier.masksToBounds(true),
      ]);

      expect(state.shadowColor, equals(const Color(0xFF000000)));
      expect(state.shadowOpacity, equals(0.5));
      expect(state.shadowOffset, equals(const Offset(2, 4)));
      expect(state.shadowRadius, equals(8.0));
      expect(state.clipToBounds, isTrue);
    });

    test('timing modifiers compose correctly', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.duration(const Duration(milliseconds: 500)),
        HeroModifier.delay(const Duration(milliseconds: 100)),
        HeroModifier.curve(Curves.easeOut),
      ]);

      expect(state.duration, equals(const Duration(milliseconds: 500)));
      expect(state.delay, equals(const Duration(milliseconds: 100)));
      expect(state.curve, equals(Curves.easeOut));
    });

    test('durationSeconds convenience creates correct duration', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.durationSeconds(1.5),
      ]);
      expect(state.duration, equals(const Duration(milliseconds: 1500)));
    });

    test('delaySeconds convenience creates correct duration', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.delaySeconds(0.25),
      ]);
      expect(state.delay, equals(const Duration(milliseconds: 250)));
    });

    test('durationMatchLongest modifier sets flag', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.durationMatchLongest,
      ]);
      expect(state.durationMatchLongest, isTrue);
    });

    test('spring modifier sets config', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.spring(stiffness: 250, dampingRatio: 18),
      ]);
      expect(state.spring, isNotNull);
      expect(state.spring!.stiffness, equals(250));
      expect(state.spring!.dampingRatio, equals(18));
    });

    test('overlay modifier sets state', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.overlay(color: const Color(0xFF0000FF), opacity: 0.4),
      ]);
      expect(state.overlay, isNotNull);
      expect(state.overlay!.color, equals(const Color(0xFF0000FF)));
      expect(state.overlay!.opacity, equals(0.4));
    });

    test('contents modifiers compose correctly', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.contentsRect(const Rect.fromLTWH(10, 10, 80, 80)),
        HeroModifier.contentsScale(3.0),
      ]);
      expect(state.contentsRect, equals(const Rect.fromLTWH(10, 10, 80, 80)));
      expect(state.contentsScale, equals(3.0));
    });

    test('source modifier sets heroID', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.source(heroID: 'cardImage'),
      ]);
      expect(state.source, equals('cardImage'));
    });

    test('cascade modifier with custom config', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.cascade(
          delta: const Duration(milliseconds: 40),
          direction: const CascadeDirection.leftToRight(),
          delayMatchedViews: true,
        ),
      ]);
      expect(state.cascade, isNotNull);
      expect(state.cascade!.delta, equals(const Duration(milliseconds: 40)));
      expect(state.cascade!.direction, isA<CascadeDirectionLeftToRight>());
      expect(state.cascade!.delayMatchedViews, isTrue);
    });

    test('cascadeDefault sets default cascade config', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.cascadeDefault,
      ]);
      expect(state.cascade, isNotNull);
      expect(state.cascade!.delta, equals(const Duration(milliseconds: 20)));
      expect(state.cascade!.direction, isA<CascadeDirectionTopToBottom>());
      expect(state.cascade!.delayMatchedViews, isFalse);
    });

    test('transform modifiers compose: scale then rotate', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.scale(2.0),
        HeroModifier.rotateZ(math.pi / 4),
      ]);
      expect(state.transform, isNotNull);

      // Manually build expected transform
      final expected = Matrix4.identity()
        ..scale(2.0, 2.0, 1.0)
        ..rotateZ(math.pi / 4);

      for (int i = 0; i < 16; i++) {
        expect(
          state.transform!.storage[i],
          closeTo(expected.storage[i], 1e-10),
          reason: 'matrix element $i mismatch',
        );
      }
    });

    test('perspective modifier sets entry(3,2)', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.perspective(500),
      ]);
      expect(state.transform, isNotNull);
      expect(state.transform!.entry(3, 2), closeTo(1.0 / -500.0, 1e-10));
    });

    test('translateOffset modifier works', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.translateOffset(const Offset(30, 40), z: 5),
      ]);
      expect(state.transform, isNotNull);

      final expected = Matrix4.identity()..translate(30.0, 40.0, 5.0);
      for (int i = 0; i < 16; i++) {
        expect(
          state.transform!.storage[i],
          closeTo(expected.storage[i], 1e-10),
          reason: 'matrix element $i mismatch',
        );
      }
    });

    test('scaleXYZ modifier works with independent axes', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.scaleXYZ(x: 1.5, y: 2.0, z: 0.5),
      ]);
      expect(state.transform, isNotNull);

      final expected = Matrix4.identity()..scale(1.5, 2.0, 0.5);
      for (int i = 0; i < 16; i++) {
        expect(
          state.transform!.storage[i],
          closeTo(expected.storage[i], 1e-10),
          reason: 'matrix element $i mismatch',
        );
      }
    });

    test('rotate modifier applies rotation on multiple axes', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.rotate(x: 0.1, y: 0.2, z: 0.3),
      ]);
      expect(state.transform, isNotNull);

      final expected = Matrix4.identity()
        ..rotateX(0.1)
        ..rotateY(0.2)
        ..rotateZ(0.3);
      for (int i = 0; i < 16; i++) {
        expect(
          state.transform!.storage[i],
          closeTo(expected.storage[i], 1e-10),
          reason: 'matrix element $i mismatch',
        );
      }
    });

    test('arcWithIntensity sets custom intensity', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.arcWithIntensity(0.6),
      ]);
      expect(state.arcIntensity, equals(0.6));
    });

    test('advanced modifiers compose correctly', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.useGlobalCoordinateSpace,
        HeroModifier.ignoreSubviewModifiers,
        HeroModifier.forceAnimate,
        HeroModifier.useScaleBasedSizeChange,
      ]);

      expect(state.coordinateSpace, equals(HeroCoordinateSpace.global));
      expect(state.ignoreSubviewModifiers, isFalse); // false = not recursive
      expect(state.forceAnimate, isTrue);
      expect(state.useScaleBasedSizeChange, isTrue);
    });

    test('ignoreSubviewModifiersRecursive sets true', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.ignoreSubviewModifiersRecursive(recursive: true),
      ]);
      expect(state.ignoreSubviewModifiers, isTrue);
    });

    test('snapshot type modifiers set correct enum values', () {
      var state = HeroTargetState.fromModifiers([HeroModifier.useOptimizedSnapshot]);
      expect(state.snapshotType, equals(HeroSnapshotType.optimized));

      state = HeroTargetState.fromModifiers([HeroModifier.useNormalSnapshot]);
      expect(state.snapshotType, equals(HeroSnapshotType.normal));

      state = HeroTargetState.fromModifiers([HeroModifier.useLayerRenderSnapshot]);
      expect(state.snapshotType, equals(HeroSnapshotType.layerRender));

      state = HeroTargetState.fromModifiers([HeroModifier.useNoSnapshot]);
      expect(state.snapshotType, equals(HeroSnapshotType.noSnapshot));
    });

    test('conditional modifier (when) populates conditionalModifiers list', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.when(
          (ctx) => ctx.isPresenting,
          [HeroModifier.fade],
        ),
      ]);
      expect(state.conditionalModifiers, isNotNull);
      expect(state.conditionalModifiers, hasLength(1));
      expect(state.conditionalModifiers![0].modifiers, hasLength(1));
    });

    test('whenMatched populates conditionalModifiers', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.whenMatched([HeroModifier.scale(0.5)]),
      ]);
      expect(state.conditionalModifiers, isNotNull);
      expect(state.conditionalModifiers, hasLength(1));

      // Verify the condition evaluates correctly
      final matched = HeroConditionalContext(
        heroID: 'a',
        isAppearing: true,
        isPresenting: true,
        isMatched: true,
      );
      final unmatched = HeroConditionalContext(
        heroID: 'a',
        isAppearing: true,
        isPresenting: true,
        isMatched: false,
      );
      expect(state.conditionalModifiers![0].condition(matched), isTrue);
      expect(state.conditionalModifiers![0].condition(unmatched), isFalse);
    });

    test('whenPresenting and whenDismissing conditions work', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.whenPresenting([HeroModifier.fade]),
        HeroModifier.whenDismissing([HeroModifier.scale(0.5)]),
      ]);
      expect(state.conditionalModifiers, hasLength(2));

      final presenting = HeroConditionalContext(
        heroID: 'x',
        isAppearing: true,
        isPresenting: true,
        isMatched: false,
      );
      final dismissing = HeroConditionalContext(
        heroID: 'x',
        isAppearing: true,
        isPresenting: false,
        isMatched: false,
      );

      // First entry: whenPresenting
      expect(state.conditionalModifiers![0].condition(presenting), isTrue);
      expect(state.conditionalModifiers![0].condition(dismissing), isFalse);

      // Second entry: whenDismissing
      expect(state.conditionalModifiers![1].condition(presenting), isFalse);
      expect(state.conditionalModifiers![1].condition(dismissing), isTrue);
    });

    test('whenAppearing and whenDisappearing conditions work', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.whenAppearing([HeroModifier.fade]),
        HeroModifier.whenDisappearing([HeroModifier.scale(0.5)]),
      ]);
      expect(state.conditionalModifiers, hasLength(2));

      final appearing = HeroConditionalContext(
        heroID: 'y',
        isAppearing: true,
        isPresenting: true,
        isMatched: false,
      );
      final disappearing = HeroConditionalContext(
        heroID: 'y',
        isAppearing: false,
        isPresenting: true,
        isMatched: false,
      );

      // First entry: whenAppearing
      expect(state.conditionalModifiers![0].condition(appearing), isTrue);
      expect(state.conditionalModifiers![0].condition(disappearing), isFalse);

      // Second entry: whenDisappearing
      expect(state.conditionalModifiers![1].condition(appearing), isFalse);
      expect(state.conditionalModifiers![1].condition(disappearing), isTrue);
    });

    test('full composition scenario: layout + appearance + timing + transform', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.position(const Offset(50, 100)),
        HeroModifier.size(const Size(200, 300)),
        HeroModifier.opacity(0.8),
        HeroModifier.cornerRadius(12.0),
        HeroModifier.backgroundColor(const Color(0xFFABCDEF)),
        HeroModifier.scale(1.5),
        HeroModifier.translate(x: 10),
        HeroModifier.duration(const Duration(milliseconds: 400)),
        HeroModifier.delay(const Duration(milliseconds: 50)),
        HeroModifier.curve(Curves.bounceIn),
        HeroModifier.arc,
        HeroModifier.source(heroID: 'card'),
        HeroModifier.forceAnimate,
      ]);

      expect(state.position, equals(const Offset(50, 100)));
      expect(state.size, equals(const Size(200, 300)));
      expect(state.opacity, equals(0.8));
      expect(state.cornerRadius, equals(12.0));
      expect(state.backgroundColor, equals(const Color(0xFFABCDEF)));
      expect(state.transform, isNotNull);
      expect(state.duration, equals(const Duration(milliseconds: 400)));
      expect(state.delay, equals(const Duration(milliseconds: 50)));
      expect(state.curve, equals(Curves.bounceIn));
      expect(state.arcIntensity, equals(1.0));
      expect(state.source, equals('card'));
      expect(state.forceAnimate, isTrue);
    });
  });

  // ================================================================
  // 6. beginState handling: beginWith populates beginState
  // ================================================================
  group('beginState handling', () {
    test('beginWith adds modifiers to beginState list', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.beginWith([
          HeroModifier.fade,
          HeroModifier.scale(0.5),
        ]),
      ]);

      expect(state.beginState, isNotNull);
      expect(state.beginState, hasLength(2));
    });

    test('beginWith modifiers do not affect main state properties', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.beginWith([
          HeroModifier.opacity(0.0),
          HeroModifier.position(const Offset(999, 999)),
        ]),
      ]);

      // The main state should not have these values set;
      // they are stored in beginState for later application.
      expect(state.opacity, isNull);
      expect(state.position, isNull);
      expect(state.beginState, hasLength(2));
    });

    test('beginWith modifiers can be applied to a separate state', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.beginWith([
          HeroModifier.opacity(0.0),
          HeroModifier.scale(0.5),
        ]),
      ]);

      // Simulate applying beginState to a separate state object
      final beginTarget = HeroTargetState();
      for (final mod in state.beginState!) {
        (mod as HeroModifier).apply(beginTarget);
      }

      expect(beginTarget.opacity, equals(0.0));
      expect(beginTarget.transform, isNotNull);
    });

    test('multiple beginWith calls accumulate modifiers', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.beginWith([HeroModifier.fade]),
        HeroModifier.beginWith([HeroModifier.scale(2.0)]),
      ]);

      expect(state.beginState, isNotNull);
      expect(state.beginState, hasLength(2));
    });

    test('beginWith combined with regular modifiers', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.opacity(0.8),
        HeroModifier.beginWith([HeroModifier.opacity(0.0)]),
        HeroModifier.cornerRadius(10.0),
      ]);

      // Regular modifiers affect state directly
      expect(state.opacity, equals(0.8));
      expect(state.cornerRadius, equals(10.0));

      // beginWith modifiers are stored separately
      expect(state.beginState, isNotNull);
      expect(state.beginState, hasLength(1));

      // The begin modifier should set opacity to 0 when applied
      final beginTarget = HeroTargetState();
      (state.beginState![0] as HeroModifier).apply(beginTarget);
      expect(beginTarget.opacity, equals(0.0));
    });

    test('beginWith with empty list does not crash', () {
      final state = HeroTargetState.fromModifiers([
        HeroModifier.beginWith([]),
      ]);
      expect(state.beginState, isNotNull);
      expect(state.beginState, isEmpty);
    });
  });
}
