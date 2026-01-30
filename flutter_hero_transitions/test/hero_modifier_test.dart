import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';

import 'package:flutter_hero_transitions/src/modifiers/hero_modifier.dart';
import 'package:flutter_hero_transitions/src/types/hero_target_state.dart';
import 'package:flutter_hero_transitions/src/types/hero_conditional_context.dart';
import 'package:flutter_hero_transitions/src/types/hero_coordinate_space.dart';
import 'package:flutter_hero_transitions/src/types/hero_snapshot_type.dart';
import 'package:flutter_hero_transitions/src/types/cascade_direction.dart';

void main() {
  late HeroTargetState state;

  setUp(() {
    state = HeroTargetState();
  });

  // ================================================================
  // 1. BASIC MODIFIERS
  // ================================================================
  group('Basic modifiers', () {
    test('fade sets opacity to 0', () {
      HeroModifier.fade.apply(state);
      expect(state.opacity, 0.0);
    });

    test('forceNonFade sets nonFade flag to true', () {
      expect(state.nonFade, isFalse);
      HeroModifier.forceNonFade.apply(state);
      expect(state.nonFade, isTrue);
    });

    test('position sets the target position', () {
      const offset = Offset(100.0, 200.0);
      HeroModifier.position(offset).apply(state);
      expect(state.position, offset);
    });

    test('position with zero offset', () {
      HeroModifier.position(Offset.zero).apply(state);
      expect(state.position, Offset.zero);
    });

    test('position with negative coordinates', () {
      const offset = Offset(-50.0, -75.0);
      HeroModifier.position(offset).apply(state);
      expect(state.position, offset);
    });

    test('size sets the target size', () {
      const sz = Size(300.0, 400.0);
      HeroModifier.size(sz).apply(state);
      expect(state.size, sz);
    });

    test('size with zero dimensions', () {
      HeroModifier.size(Size.zero).apply(state);
      expect(state.size, Size.zero);
    });
  });

  // ================================================================
  // 2. TRANSFORM MODIFIERS
  // ================================================================
  group('Transform modifiers', () {
    test('transform sets the full matrix', () {
      final matrix = Matrix4.rotationZ(0.5);
      HeroModifier.transform(matrix).apply(state);
      expect(state.transform, matrix);
    });

    test('transform with identity matrix', () {
      final identity = Matrix4.identity();
      HeroModifier.transform(identity).apply(state);
      expect(state.transform, identity);
    });

    test('perspective sets entry(3,2) on the transform', () {
      HeroModifier.perspective(500.0).apply(state);
      expect(state.transform, isNotNull);
      expect(state.transform!.entry(3, 2), closeTo(1.0 / -500.0, 1e-10));
    });

    test('perspective uses existing transform if present', () {
      final existing = Matrix4.identity()..scale(2.0, 2.0);
      state.transform = existing;
      HeroModifier.perspective(1000.0).apply(state);
      // The same object should be mutated in place.
      expect(state.transform!.entry(3, 2), closeTo(1.0 / -1000.0, 1e-10));
      // The scale should still be present.
      expect(state.transform!.entry(0, 0), closeTo(2.0, 1e-10));
    });

    test('scale applies uniform scale', () {
      HeroModifier.scale(2.0).apply(state);
      expect(state.transform, isNotNull);
      expect(state.transform!.entry(0, 0), closeTo(2.0, 1e-10));
      expect(state.transform!.entry(1, 1), closeTo(2.0, 1e-10));
      // z should remain 1.0 (no z-scaling).
      expect(state.transform!.entry(2, 2), closeTo(1.0, 1e-10));
    });

    test('scale with fractional value', () {
      HeroModifier.scale(0.5).apply(state);
      expect(state.transform, isNotNull);
      expect(state.transform!.entry(0, 0), closeTo(0.5, 1e-10));
      expect(state.transform!.entry(1, 1), closeTo(0.5, 1e-10));
    });

    test('scaleXYZ applies independent axis scaling', () {
      HeroModifier.scaleXYZ(x: 2.0, y: 3.0, z: 4.0).apply(state);
      expect(state.transform, isNotNull);
      expect(state.transform!.entry(0, 0), closeTo(2.0, 1e-10));
      expect(state.transform!.entry(1, 1), closeTo(3.0, 1e-10));
      expect(state.transform!.entry(2, 2), closeTo(4.0, 1e-10));
    });

    test('scaleXYZ defaults to identity when no args', () {
      HeroModifier.scaleXYZ().apply(state);
      expect(state.transform, isNotNull);
      // All diagonal entries should remain 1.0.
      expect(state.transform!.entry(0, 0), closeTo(1.0, 1e-10));
      expect(state.transform!.entry(1, 1), closeTo(1.0, 1e-10));
      expect(state.transform!.entry(2, 2), closeTo(1.0, 1e-10));
    });

    test('translate sets translation values', () {
      HeroModifier.translate(x: 10.0, y: 20.0, z: 30.0).apply(state);
      expect(state.transform, isNotNull);
      // Translation is stored in the 4th column.
      expect(state.transform!.entry(0, 3), closeTo(10.0, 1e-10));
      expect(state.transform!.entry(1, 3), closeTo(20.0, 1e-10));
      expect(state.transform!.entry(2, 3), closeTo(30.0, 1e-10));
    });

    test('translate with default values produces identity-like transform', () {
      HeroModifier.translate().apply(state);
      expect(state.transform, isNotNull);
      expect(state.transform!.entry(0, 3), closeTo(0.0, 1e-10));
      expect(state.transform!.entry(1, 3), closeTo(0.0, 1e-10));
      expect(state.transform!.entry(2, 3), closeTo(0.0, 1e-10));
    });

    test('translateOffset sets translation from Offset', () {
      HeroModifier.translateOffset(const Offset(5.0, 15.0), z: 25.0)
          .apply(state);
      expect(state.transform, isNotNull);
      expect(state.transform!.entry(0, 3), closeTo(5.0, 1e-10));
      expect(state.transform!.entry(1, 3), closeTo(15.0, 1e-10));
      expect(state.transform!.entry(2, 3), closeTo(25.0, 1e-10));
    });

    test('translateOffset with zero offset', () {
      HeroModifier.translateOffset(Offset.zero).apply(state);
      expect(state.transform, isNotNull);
      expect(state.transform!.entry(0, 3), closeTo(0.0, 1e-10));
      expect(state.transform!.entry(1, 3), closeTo(0.0, 1e-10));
    });

    test('rotate applies x-axis rotation', () {
      HeroModifier.rotate(x: math.pi / 4).apply(state);
      expect(state.transform, isNotNull);
      // For x-rotation by pi/4, entry(1,1) = cos(pi/4).
      expect(state.transform!.entry(1, 1), closeTo(math.cos(math.pi / 4), 1e-10));
      expect(state.transform!.entry(1, 2), closeTo(-math.sin(math.pi / 4), 1e-10));
    });

    test('rotate applies y-axis rotation', () {
      HeroModifier.rotate(y: math.pi / 3).apply(state);
      expect(state.transform, isNotNull);
      expect(state.transform!.entry(0, 0), closeTo(math.cos(math.pi / 3), 1e-10));
    });

    test('rotate applies z-axis rotation', () {
      HeroModifier.rotate(z: math.pi / 6).apply(state);
      expect(state.transform, isNotNull);
      expect(state.transform!.entry(0, 0), closeTo(math.cos(math.pi / 6), 1e-10));
      expect(state.transform!.entry(0, 1), closeTo(-math.sin(math.pi / 6), 1e-10));
    });

    test('rotate with all axes produces combined rotation', () {
      HeroModifier.rotate(x: 0.1, y: 0.2, z: 0.3).apply(state);
      expect(state.transform, isNotNull);
      // Just verify it's not identity - exact values depend on multiplication order.
      expect(state.transform, isNot(equals(Matrix4.identity())));
    });

    test('rotate with zero values keeps identity', () {
      HeroModifier.rotate().apply(state);
      expect(state.transform, isNotNull);
      // No rotations applied, should remain identity.
      for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
          expect(
            state.transform!.entry(i, j),
            closeTo(i == j ? 1.0 : 0.0, 1e-10),
          );
        }
      }
    });

    test('rotateZ is convenience for rotate(z:)', () {
      final stateA = HeroTargetState();
      final stateB = HeroTargetState();
      HeroModifier.rotateZ(math.pi / 4).apply(stateA);
      HeroModifier.rotate(z: math.pi / 4).apply(stateB);
      for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
          expect(
            stateA.transform!.entry(i, j),
            closeTo(stateB.transform!.entry(i, j), 1e-10),
          );
        }
      }
    });

    test('transform modifiers compose on existing transform', () {
      HeroModifier.translate(x: 10.0).apply(state);
      HeroModifier.scaleXYZ(x: 2.0, y: 2.0).apply(state);
      expect(state.transform, isNotNull);
      // After translate(10,0,0) then scale(2,2,1):
      // translation column is also scaled.
      expect(state.transform!.entry(0, 0), closeTo(2.0, 1e-10));
      expect(state.transform!.entry(0, 3), closeTo(10.0, 1e-10));
    });
  });

  // ================================================================
  // 3. APPEARANCE MODIFIERS
  // ================================================================
  group('Appearance modifiers', () {
    test('opacity sets the opacity value', () {
      HeroModifier.opacity(0.5).apply(state);
      expect(state.opacity, 0.5);
    });

    test('opacity with 0', () {
      HeroModifier.opacity(0.0).apply(state);
      expect(state.opacity, 0.0);
    });

    test('opacity with 1', () {
      HeroModifier.opacity(1.0).apply(state);
      expect(state.opacity, 1.0);
    });

    test('cornerRadius sets the corner radius', () {
      HeroModifier.cornerRadius(16.0).apply(state);
      expect(state.cornerRadius, 16.0);
    });

    test('cornerRadius with zero', () {
      HeroModifier.cornerRadius(0.0).apply(state);
      expect(state.cornerRadius, 0.0);
    });

    test('backgroundColor sets the background color', () {
      const color = Color(0xFF00FF00);
      HeroModifier.backgroundColor(color).apply(state);
      expect(state.backgroundColor, color);
    });

    test('backgroundColor with transparent color', () {
      const color = Color(0x00000000);
      HeroModifier.backgroundColor(color).apply(state);
      expect(state.backgroundColor, color);
    });

    test('borderColor sets the border color', () {
      const color = Color(0xFFFF0000);
      HeroModifier.borderColor(color).apply(state);
      expect(state.borderColor, color);
    });

    test('borderWidth sets the border width', () {
      HeroModifier.borderWidth(2.5).apply(state);
      expect(state.borderWidth, 2.5);
    });

    test('borderWidth with zero', () {
      HeroModifier.borderWidth(0.0).apply(state);
      expect(state.borderWidth, 0.0);
    });

    test('zPosition sets the z position', () {
      HeroModifier.zPosition(10.0).apply(state);
      expect(state.zPosition, 10.0);
    });

    test('zPosition with negative value', () {
      HeroModifier.zPosition(-5.0).apply(state);
      expect(state.zPosition, -5.0);
    });

    test('shadowColor sets the shadow color', () {
      const color = Color(0x80000000);
      HeroModifier.shadowColor(color).apply(state);
      expect(state.shadowColor, color);
    });

    test('shadowOpacity sets the shadow opacity', () {
      HeroModifier.shadowOpacity(0.75).apply(state);
      expect(state.shadowOpacity, 0.75);
    });

    test('shadowOpacity with zero', () {
      HeroModifier.shadowOpacity(0.0).apply(state);
      expect(state.shadowOpacity, 0.0);
    });

    test('shadowOffset sets the shadow offset', () {
      const offset = Offset(4.0, 8.0);
      HeroModifier.shadowOffset(offset).apply(state);
      expect(state.shadowOffset, offset);
    });

    test('shadowOffset with zero offset', () {
      HeroModifier.shadowOffset(Offset.zero).apply(state);
      expect(state.shadowOffset, Offset.zero);
    });

    test('shadowRadius sets the shadow radius', () {
      HeroModifier.shadowRadius(12.0).apply(state);
      expect(state.shadowRadius, 12.0);
    });

    test('shadowRadius with zero', () {
      HeroModifier.shadowRadius(0.0).apply(state);
      expect(state.shadowRadius, 0.0);
    });

    test('masksToBounds sets clipToBounds to true', () {
      HeroModifier.masksToBounds(true).apply(state);
      expect(state.clipToBounds, isTrue);
    });

    test('masksToBounds sets clipToBounds to false', () {
      HeroModifier.masksToBounds(false).apply(state);
      expect(state.clipToBounds, isFalse);
    });

    test('overlay sets overlay state with color and opacity', () {
      const color = Color(0xFF0000FF);
      HeroModifier.overlay(color: color, opacity: 0.3).apply(state);
      expect(state.overlay, isNotNull);
      expect(state.overlay!.color, color);
      expect(state.overlay!.opacity, 0.3);
    });

    test('overlay with zero opacity', () {
      const color = Color(0xFF000000);
      HeroModifier.overlay(color: color, opacity: 0.0).apply(state);
      expect(state.overlay, isNotNull);
      expect(state.overlay!.opacity, 0.0);
    });

    test('overlay with full opacity', () {
      const color = Color(0xFFFFFFFF);
      HeroModifier.overlay(color: color, opacity: 1.0).apply(state);
      expect(state.overlay, isNotNull);
      expect(state.overlay!.opacity, 1.0);
      expect(state.overlay!.color, const Color(0xFFFFFFFF));
    });
  });

  // ================================================================
  // 3b. CONTENTS MODIFIERS
  // ================================================================
  group('Contents modifiers', () {
    test('contentsRect sets the contents rect', () {
      const rect = Rect.fromLTWH(0.0, 0.0, 0.5, 0.5);
      HeroModifier.contentsRect(rect).apply(state);
      expect(state.contentsRect, rect);
    });

    test('contentsScale sets the contents scale', () {
      HeroModifier.contentsScale(2.0).apply(state);
      expect(state.contentsScale, 2.0);
    });

    test('contentsScale with 1.0', () {
      HeroModifier.contentsScale(1.0).apply(state);
      expect(state.contentsScale, 1.0);
    });
  });

  // ================================================================
  // 4. TIMING MODIFIERS
  // ================================================================
  group('Timing modifiers', () {
    test('duration sets the animation duration', () {
      const dur = Duration(milliseconds: 500);
      HeroModifier.duration(dur).apply(state);
      expect(state.duration, dur);
    });

    test('duration with zero', () {
      HeroModifier.duration(Duration.zero).apply(state);
      expect(state.duration, Duration.zero);
    });

    test('duration with seconds', () {
      const dur = Duration(seconds: 2);
      HeroModifier.duration(dur).apply(state);
      expect(state.duration, const Duration(seconds: 2));
    });

    test('durationSeconds converts seconds to Duration', () {
      HeroModifier.durationSeconds(1.5).apply(state);
      expect(state.duration, const Duration(milliseconds: 1500));
    });

    test('durationSeconds with zero', () {
      HeroModifier.durationSeconds(0.0).apply(state);
      expect(state.duration, Duration.zero);
    });

    test('durationSeconds with fractional seconds', () {
      HeroModifier.durationSeconds(0.25).apply(state);
      expect(state.duration, const Duration(milliseconds: 250));
    });

    test('durationMatchLongest sets the flag', () {
      expect(state.durationMatchLongest, isFalse);
      HeroModifier.durationMatchLongest.apply(state);
      expect(state.durationMatchLongest, isTrue);
    });

    test('delay sets the animation delay', () {
      const del = Duration(milliseconds: 200);
      HeroModifier.delay(del).apply(state);
      expect(state.delay, del);
    });

    test('delay with zero', () {
      HeroModifier.delay(Duration.zero).apply(state);
      expect(state.delay, Duration.zero);
    });

    test('delaySeconds converts seconds to Duration', () {
      HeroModifier.delaySeconds(0.5).apply(state);
      expect(state.delay, const Duration(milliseconds: 500));
    });

    test('delaySeconds with zero', () {
      HeroModifier.delaySeconds(0.0).apply(state);
      expect(state.delay, Duration.zero);
    });

    test('curve sets the animation curve', () {
      HeroModifier.curve(Curves.easeInOut).apply(state);
      expect(state.curve, Curves.easeInOut);
    });

    test('curve with linear', () {
      HeroModifier.curve(Curves.linear).apply(state);
      expect(state.curve, Curves.linear);
    });

    test('curve with bounce', () {
      HeroModifier.curve(Curves.bounceOut).apply(state);
      expect(state.curve, Curves.bounceOut);
    });

    test('spring sets spring config', () {
      HeroModifier.spring(stiffness: 100.0, dampingRatio: 15.0).apply(state);
      expect(state.spring, isNotNull);
      expect(state.spring!.stiffness, 100.0);
      expect(state.spring!.dampingRatio, 15.0);
    });

    test('spring with high stiffness and low damping', () {
      HeroModifier.spring(stiffness: 500.0, dampingRatio: 5.0).apply(state);
      expect(state.spring!.stiffness, 500.0);
      expect(state.spring!.dampingRatio, 5.0);
    });
  });

  // ================================================================
  // 5. ADVANCED MODIFIERS
  // ================================================================
  group('Advanced modifiers', () {
    test('source sets the source heroID', () {
      HeroModifier.source(heroID: 'card_1').apply(state);
      expect(state.source, 'card_1');
    });

    test('source with empty string', () {
      HeroModifier.source(heroID: '').apply(state);
      expect(state.source, '');
    });

    test('arc sets arcIntensity to 1.0', () {
      HeroModifier.arc.apply(state);
      expect(state.arcIntensity, 1.0);
    });

    test('arcWithIntensity sets custom arc intensity', () {
      HeroModifier.arcWithIntensity(0.5).apply(state);
      expect(state.arcIntensity, 0.5);
    });

    test('arcWithIntensity with zero', () {
      HeroModifier.arcWithIntensity(0.0).apply(state);
      expect(state.arcIntensity, 0.0);
    });

    test('arcWithIntensity with high value', () {
      HeroModifier.arcWithIntensity(2.0).apply(state);
      expect(state.arcIntensity, 2.0);
    });

    test('cascadeDefault sets cascade with default config', () {
      HeroModifier.cascadeDefault.apply(state);
      expect(state.cascade, isNotNull);
      expect(state.cascade!.delta, const Duration(milliseconds: 20));
      expect(state.cascade!.direction, isA<CascadeDirectionTopToBottom>());
      expect(state.cascade!.delayMatchedViews, isFalse);
    });

    test('cascade sets custom cascade config', () {
      HeroModifier.cascade(
        delta: const Duration(milliseconds: 50),
        direction: const CascadeDirection.bottomToTop(),
        delayMatchedViews: true,
      ).apply(state);
      expect(state.cascade, isNotNull);
      expect(state.cascade!.delta, const Duration(milliseconds: 50));
      expect(state.cascade!.direction, isA<CascadeDirectionBottomToTop>());
      expect(state.cascade!.delayMatchedViews, isTrue);
    });

    test('cascade with leftToRight direction', () {
      HeroModifier.cascade(
        direction: const CascadeDirection.leftToRight(),
      ).apply(state);
      expect(state.cascade!.direction, isA<CascadeDirectionLeftToRight>());
    });

    test('cascade with rightToLeft direction', () {
      HeroModifier.cascade(
        direction: const CascadeDirection.rightToLeft(),
      ).apply(state);
      expect(state.cascade!.direction, isA<CascadeDirectionRightToLeft>());
    });

    test('cascade with radial direction', () {
      HeroModifier.cascade(
        direction: const CascadeDirection.radial(center: Offset(100, 100)),
      ).apply(state);
      expect(state.cascade!.direction, isA<CascadeDirectionRadial>());
      final radial = state.cascade!.direction as CascadeDirectionRadial;
      expect(radial.center, const Offset(100, 100));
    });

    test('cascade with inverseRadial direction', () {
      HeroModifier.cascade(
        direction: const CascadeDirection.inverseRadial(center: Offset(50, 50)),
      ).apply(state);
      expect(state.cascade!.direction, isA<CascadeDirectionInverseRadial>());
      final inverseRadial =
          state.cascade!.direction as CascadeDirectionInverseRadial;
      expect(inverseRadial.center, const Offset(50, 50));
    });

    test('beginWith stores modifier list in beginState', () {
      final modifiers = [HeroModifier.fade, HeroModifier.forceNonFade];
      HeroModifier.beginWith(modifiers).apply(state);
      expect(state.beginState, isNotNull);
      expect(state.beginState!.length, 2);
    });

    test('beginWith appends to existing beginState', () {
      HeroModifier.beginWith([HeroModifier.fade]).apply(state);
      HeroModifier.beginWith([HeroModifier.forceNonFade]).apply(state);
      expect(state.beginState!.length, 2);
    });

    test('beginWith with empty list', () {
      HeroModifier.beginWith([]).apply(state);
      expect(state.beginState, isNotNull);
      expect(state.beginState!.length, 0);
    });

    test('useGlobalCoordinateSpace sets coordinate space to global', () {
      HeroModifier.useGlobalCoordinateSpace.apply(state);
      expect(state.coordinateSpace, HeroCoordinateSpace.global);
    });

    test('ignoreSubviewModifiers sets to false (non-recursive)', () {
      HeroModifier.ignoreSubviewModifiers.apply(state);
      expect(state.ignoreSubviewModifiers, isFalse);
    });

    test('ignoreSubviewModifiersRecursive with recursive false', () {
      HeroModifier.ignoreSubviewModifiersRecursive(recursive: false)
          .apply(state);
      expect(state.ignoreSubviewModifiers, isFalse);
    });

    test('ignoreSubviewModifiersRecursive with recursive true', () {
      HeroModifier.ignoreSubviewModifiersRecursive(recursive: true)
          .apply(state);
      expect(state.ignoreSubviewModifiers, isTrue);
    });

    test('forceAnimate sets the forceAnimate flag', () {
      expect(state.forceAnimate, isFalse);
      HeroModifier.forceAnimate.apply(state);
      expect(state.forceAnimate, isTrue);
    });

    test('useScaleBasedSizeChange sets the flag', () {
      HeroModifier.useScaleBasedSizeChange.apply(state);
      expect(state.useScaleBasedSizeChange, isTrue);
    });
  });

  // ================================================================
  // 5b. SNAPSHOT TYPE MODIFIERS
  // ================================================================
  group('Snapshot type modifiers', () {
    test('useOptimizedSnapshot sets snapshot type to optimized', () {
      HeroModifier.useOptimizedSnapshot.apply(state);
      expect(state.snapshotType, HeroSnapshotType.optimized);
    });

    test('useNormalSnapshot sets snapshot type to normal', () {
      HeroModifier.useNormalSnapshot.apply(state);
      expect(state.snapshotType, HeroSnapshotType.normal);
    });

    test('useLayerRenderSnapshot sets snapshot type to layerRender', () {
      HeroModifier.useLayerRenderSnapshot.apply(state);
      expect(state.snapshotType, HeroSnapshotType.layerRender);
    });

    test('useNoSnapshot sets snapshot type to noSnapshot', () {
      HeroModifier.useNoSnapshot.apply(state);
      expect(state.snapshotType, HeroSnapshotType.noSnapshot);
    });

    test('snapshot type can be overridden by later modifier', () {
      HeroModifier.useOptimizedSnapshot.apply(state);
      expect(state.snapshotType, HeroSnapshotType.optimized);
      HeroModifier.useNoSnapshot.apply(state);
      expect(state.snapshotType, HeroSnapshotType.noSnapshot);
    });
  });

  // ================================================================
  // 6. CONDITIONAL MODIFIERS
  // ================================================================
  group('Conditional modifiers', () {
    test('when adds a conditional modifier entry', () {
      HeroModifier.when(
        (ctx) => ctx.isMatched,
        [HeroModifier.fade],
      ).apply(state);
      expect(state.conditionalModifiers, isNotNull);
      expect(state.conditionalModifiers!.length, 1);
      expect(state.conditionalModifiers!.first.modifiers.length, 1);
    });

    test('when condition evaluates correctly for isMatched = true', () {
      HeroModifier.when(
        (ctx) => ctx.isMatched,
        [HeroModifier.fade],
      ).apply(state);

      final entry = state.conditionalModifiers!.first;
      const matchedCtx = HeroConditionalContext(
        heroID: 'test',
        isAppearing: true,
        isPresenting: true,
        isMatched: true,
      );
      expect(entry.condition(matchedCtx), isTrue);
    });

    test('when condition evaluates correctly for isMatched = false', () {
      HeroModifier.when(
        (ctx) => ctx.isMatched,
        [HeroModifier.fade],
      ).apply(state);

      final entry = state.conditionalModifiers!.first;
      const unmatchedCtx = HeroConditionalContext(
        heroID: 'test',
        isAppearing: true,
        isPresenting: true,
        isMatched: false,
      );
      expect(entry.condition(unmatchedCtx), isFalse);
    });

    test('when accumulates multiple conditional entries', () {
      HeroModifier.when(
        (ctx) => ctx.isMatched,
        [HeroModifier.fade],
      ).apply(state);
      HeroModifier.when(
        (ctx) => ctx.isPresenting,
        [HeroModifier.forceNonFade],
      ).apply(state);
      expect(state.conditionalModifiers!.length, 2);
    });

    test('whenMatched evaluates true when context isMatched', () {
      HeroModifier.whenMatched([HeroModifier.fade]).apply(state);
      final entry = state.conditionalModifiers!.first;

      const matched = HeroConditionalContext(
        heroID: 'id',
        isAppearing: true,
        isPresenting: true,
        isMatched: true,
      );
      const unmatched = HeroConditionalContext(
        heroID: 'id',
        isAppearing: true,
        isPresenting: true,
        isMatched: false,
      );
      expect(entry.condition(matched), isTrue);
      expect(entry.condition(unmatched), isFalse);
    });

    test('whenMatched stores the modifiers', () {
      HeroModifier.whenMatched(
        [HeroModifier.fade, HeroModifier.forceNonFade],
      ).apply(state);
      expect(state.conditionalModifiers!.first.modifiers.length, 2);
    });

    test('whenPresenting evaluates true when context isPresenting', () {
      HeroModifier.whenPresenting([HeroModifier.fade]).apply(state);
      final entry = state.conditionalModifiers!.first;

      const presenting = HeroConditionalContext(
        heroID: 'id',
        isAppearing: true,
        isPresenting: true,
        isMatched: false,
      );
      const dismissing = HeroConditionalContext(
        heroID: 'id',
        isAppearing: true,
        isPresenting: false,
        isMatched: false,
      );
      expect(entry.condition(presenting), isTrue);
      expect(entry.condition(dismissing), isFalse);
    });

    test('whenDismissing evaluates true when context is NOT presenting', () {
      HeroModifier.whenDismissing([HeroModifier.fade]).apply(state);
      final entry = state.conditionalModifiers!.first;

      const presenting = HeroConditionalContext(
        heroID: 'id',
        isAppearing: true,
        isPresenting: true,
        isMatched: false,
      );
      const dismissing = HeroConditionalContext(
        heroID: 'id',
        isAppearing: true,
        isPresenting: false,
        isMatched: false,
      );
      expect(entry.condition(presenting), isFalse);
      expect(entry.condition(dismissing), isTrue);
    });

    test('whenAppearing evaluates true when context isAppearing', () {
      HeroModifier.whenAppearing([HeroModifier.fade]).apply(state);
      final entry = state.conditionalModifiers!.first;

      const appearing = HeroConditionalContext(
        heroID: 'id',
        isAppearing: true,
        isPresenting: true,
        isMatched: false,
      );
      const disappearing = HeroConditionalContext(
        heroID: 'id',
        isAppearing: false,
        isPresenting: true,
        isMatched: false,
      );
      expect(entry.condition(appearing), isTrue);
      expect(entry.condition(disappearing), isFalse);
    });

    test('whenDisappearing evaluates true when context is NOT appearing', () {
      HeroModifier.whenDisappearing([HeroModifier.fade]).apply(state);
      final entry = state.conditionalModifiers!.first;

      const appearing = HeroConditionalContext(
        heroID: 'id',
        isAppearing: true,
        isPresenting: true,
        isMatched: false,
      );
      const disappearing = HeroConditionalContext(
        heroID: 'id',
        isAppearing: false,
        isPresenting: true,
        isMatched: false,
      );
      expect(entry.condition(appearing), isFalse);
      expect(entry.condition(disappearing), isTrue);
    });

    test('whenAppearing and whenDisappearing are complementary', () {
      final stateA = HeroTargetState();
      final stateB = HeroTargetState();

      HeroModifier.whenAppearing([HeroModifier.fade]).apply(stateA);
      HeroModifier.whenDisappearing([HeroModifier.fade]).apply(stateB);

      const ctx = HeroConditionalContext(
        heroID: 'id',
        isAppearing: true,
        isPresenting: true,
        isMatched: true,
      );

      final condA = stateA.conditionalModifiers!.first.condition;
      final condB = stateB.conditionalModifiers!.first.condition;

      // Exactly one should be true for any given context.
      expect(condA(ctx), isNot(equals(condB(ctx))));
    });

    test('whenPresenting and whenDismissing are complementary', () {
      final stateA = HeroTargetState();
      final stateB = HeroTargetState();

      HeroModifier.whenPresenting([HeroModifier.fade]).apply(stateA);
      HeroModifier.whenDismissing([HeroModifier.fade]).apply(stateB);

      const ctx = HeroConditionalContext(
        heroID: 'id',
        isAppearing: true,
        isPresenting: true,
        isMatched: true,
      );

      final condA = stateA.conditionalModifiers!.first.condition;
      final condB = stateB.conditionalModifiers!.first.condition;

      expect(condA(ctx), isNot(equals(condB(ctx))));
    });
  });

  // ================================================================
  // 7. COMPOSITION & EDGE CASES
  // ================================================================
  group('Modifier composition', () {
    test('multiple modifiers can be applied sequentially', () {
      HeroModifier.fade.apply(state);
      HeroModifier.position(const Offset(50, 100)).apply(state);
      HeroModifier.size(const Size(200, 300)).apply(state);
      HeroModifier.cornerRadius(8.0).apply(state);
      HeroModifier.duration(const Duration(milliseconds: 300)).apply(state);

      expect(state.opacity, 0.0);
      expect(state.position, const Offset(50, 100));
      expect(state.size, const Size(200, 300));
      expect(state.cornerRadius, 8.0);
      expect(state.duration, const Duration(milliseconds: 300));
    });

    test('later modifier overwrites earlier one for the same property', () {
      HeroModifier.opacity(0.3).apply(state);
      expect(state.opacity, 0.3);

      HeroModifier.opacity(0.8).apply(state);
      expect(state.opacity, 0.8);
    });

    test('fade then opacity overwrite each other', () {
      HeroModifier.fade.apply(state);
      expect(state.opacity, 0.0);

      HeroModifier.opacity(0.5).apply(state);
      expect(state.opacity, 0.5);
    });

    test('position can be overwritten', () {
      HeroModifier.position(const Offset(10, 20)).apply(state);
      HeroModifier.position(const Offset(30, 40)).apply(state);
      expect(state.position, const Offset(30, 40));
    });

    test('size can be overwritten', () {
      HeroModifier.size(const Size(100, 200)).apply(state);
      HeroModifier.size(const Size(300, 400)).apply(state);
      expect(state.size, const Size(300, 400));
    });

    test('curve can be overwritten', () {
      HeroModifier.curve(Curves.linear).apply(state);
      HeroModifier.curve(Curves.easeIn).apply(state);
      expect(state.curve, Curves.easeIn);
    });

    test('duration can be overwritten', () {
      HeroModifier.duration(const Duration(milliseconds: 100)).apply(state);
      HeroModifier.duration(const Duration(milliseconds: 500)).apply(state);
      expect(state.duration, const Duration(milliseconds: 500));
    });

    test('source can be overwritten', () {
      HeroModifier.source(heroID: 'a').apply(state);
      HeroModifier.source(heroID: 'b').apply(state);
      expect(state.source, 'b');
    });

    test('all shadow properties can be set together', () {
      HeroModifier.shadowColor(const Color(0xFF000000)).apply(state);
      HeroModifier.shadowOpacity(0.5).apply(state);
      HeroModifier.shadowOffset(const Offset(2, 4)).apply(state);
      HeroModifier.shadowRadius(8.0).apply(state);

      expect(state.shadowColor, const Color(0xFF000000));
      expect(state.shadowOpacity, 0.5);
      expect(state.shadowOffset, const Offset(2, 4));
      expect(state.shadowRadius, 8.0);
    });

    test('all border properties can be set together', () {
      HeroModifier.borderColor(const Color(0xFFFF0000)).apply(state);
      HeroModifier.borderWidth(3.0).apply(state);

      expect(state.borderColor, const Color(0xFFFF0000));
      expect(state.borderWidth, 3.0);
    });

    test('timing modifiers can all coexist', () {
      HeroModifier.duration(const Duration(milliseconds: 400)).apply(state);
      HeroModifier.delay(const Duration(milliseconds: 100)).apply(state);
      HeroModifier.curve(Curves.easeOut).apply(state);
      HeroModifier.spring(stiffness: 200, dampingRatio: 20).apply(state);

      expect(state.duration, const Duration(milliseconds: 400));
      expect(state.delay, const Duration(milliseconds: 100));
      expect(state.curve, Curves.easeOut);
      expect(state.spring, isNotNull);
      expect(state.spring!.stiffness, 200.0);
      expect(state.spring!.dampingRatio, 20.0);
    });
  });

  // ================================================================
  // 8. DEFAULT STATE VALUES
  // ================================================================
  group('HeroTargetState defaults', () {
    test('newly created state has expected defaults', () {
      final freshState = HeroTargetState();

      expect(freshState.position, isNull);
      expect(freshState.size, isNull);
      expect(freshState.transform, isNull);
      expect(freshState.opacity, isNull);
      expect(freshState.cornerRadius, isNull);
      expect(freshState.backgroundColor, isNull);
      expect(freshState.zPosition, isNull);
      expect(freshState.anchorPoint, isNull);
      expect(freshState.contentsRect, isNull);
      expect(freshState.contentsScale, isNull);
      expect(freshState.borderWidth, isNull);
      expect(freshState.borderColor, isNull);
      expect(freshState.shadowColor, isNull);
      expect(freshState.shadowOpacity, isNull);
      expect(freshState.shadowOffset, isNull);
      expect(freshState.shadowRadius, isNull);
      expect(freshState.displayShadow, isTrue);
      expect(freshState.clipToBounds, isNull);
      expect(freshState.overlay, isNull);
      expect(freshState.spring, isNull);
      expect(freshState.delay, Duration.zero);
      expect(freshState.duration, isNull);
      expect(freshState.durationMatchLongest, isFalse);
      expect(freshState.curve, isNull);
      expect(freshState.arcIntensity, isNull);
      expect(freshState.source, isNull);
      expect(freshState.cascade, isNull);
      expect(freshState.ignoreSubviewModifiers, isNull);
      expect(freshState.coordinateSpace, isNull);
      expect(freshState.useScaleBasedSizeChange, isNull);
      expect(freshState.snapshotType, isNull);
      expect(freshState.nonFade, isFalse);
      expect(freshState.forceAnimate, isFalse);
      expect(freshState.beginState, isNull);
      expect(freshState.conditionalModifiers, isNull);
      expect(freshState.custom, isNull);
    });

    test('custom data can be set and read via bracket operators', () {
      state['myKey'] = 42;
      expect(state['myKey'], 42);
    });

    test('custom data returns null for unset keys', () {
      expect(state['nonExistentKey'], isNull);
    });

    test('custom data supports multiple keys', () {
      state['key1'] = 'hello';
      state['key2'] = 3.14;
      state['key3'] = true;

      expect(state['key1'], 'hello');
      expect(state['key2'], 3.14);
      expect(state['key3'], isTrue);
    });
  });

  // ================================================================
  // 9. CASCADE DIRECTION COMPARISONS
  // ================================================================
  group('CascadeDirection comparisons', () {
    test('topToBottom sorts by dy ascending', () {
      const dir = CascadeDirection.topToBottom();
      expect(dir.compare(const Offset(0, 10), const Offset(0, 20)), isNegative);
      expect(dir.compare(const Offset(0, 20), const Offset(0, 10)), isPositive);
      expect(dir.compare(const Offset(0, 10), const Offset(0, 10)), isZero);
    });

    test('bottomToTop sorts by dy descending', () {
      const dir = CascadeDirection.bottomToTop();
      expect(dir.compare(const Offset(0, 20), const Offset(0, 10)), isNegative);
      expect(dir.compare(const Offset(0, 10), const Offset(0, 20)), isPositive);
    });

    test('leftToRight sorts by dx ascending', () {
      const dir = CascadeDirection.leftToRight();
      expect(dir.compare(const Offset(10, 0), const Offset(20, 0)), isNegative);
      expect(dir.compare(const Offset(20, 0), const Offset(10, 0)), isPositive);
    });

    test('rightToLeft sorts by dx descending', () {
      const dir = CascadeDirection.rightToLeft();
      expect(dir.compare(const Offset(20, 0), const Offset(10, 0)), isNegative);
      expect(dir.compare(const Offset(10, 0), const Offset(20, 0)), isPositive);
    });

    test('radial sorts by distance from center ascending', () {
      const dir = CascadeDirection.radial(center: Offset.zero);
      // (1,0) distance = 1, (2,0) distance = 2
      expect(
        dir.compare(const Offset(1, 0), const Offset(2, 0)),
        isNegative,
      );
      expect(
        dir.compare(const Offset(2, 0), const Offset(1, 0)),
        isPositive,
      );
    });

    test('inverseRadial sorts by distance from center descending', () {
      const dir = CascadeDirection.inverseRadial(center: Offset.zero);
      // (2,0) distance = 2, (1,0) distance = 1; inverse means further first.
      expect(
        dir.compare(const Offset(2, 0), const Offset(1, 0)),
        isNegative,
      );
      expect(
        dir.compare(const Offset(1, 0), const Offset(2, 0)),
        isPositive,
      );
    });
  });
}
