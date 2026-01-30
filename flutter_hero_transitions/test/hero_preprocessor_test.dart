import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_hero_transitions/src/preprocessors/base_preprocessor.dart';
import 'package:flutter_hero_transitions/src/preprocessors/default_animation_preprocessor.dart';
import 'package:flutter_hero_transitions/src/preprocessors/conditional_preprocessor.dart';
import 'package:flutter_hero_transitions/src/preprocessors/cascade_preprocessor.dart';
import 'package:flutter_hero_transitions/src/preprocessors/ignore_subview_modifiers_preprocessor.dart';
import 'package:flutter_hero_transitions/src/preprocessors/match_preprocessor.dart';
import 'package:flutter_hero_transitions/src/preprocessors/source_preprocessor.dart';
import 'package:flutter_hero_transitions/src/transition/hero_context.dart';
import 'package:flutter_hero_transitions/src/types/hero_target_state.dart';
import 'package:flutter_hero_transitions/src/types/hero_animation_type.dart';
import 'package:flutter_hero_transitions/src/types/cascade_direction.dart';
import 'package:flutter_hero_transitions/src/modifiers/hero_modifier.dart';
import 'package:flutter_hero_transitions/src/types/hero_coordinate_space.dart';

// ---------------------------------------------------------------------------
// Test-friendly HeroContext subclass.
//
// The real HeroContext constructor iterates over HeroRegistration objects and
// calls `view.globalRect` which requires a live RenderBox in the widget tree.
// That is impractical for pure unit tests, so we inject the rect maps and
// registration-id maps directly.
// ---------------------------------------------------------------------------
class TestHeroContext extends HeroContext {
  final Map<String, Rect> _testSourceRects;
  final Map<String, Rect> _testDestRects;

  TestHeroContext._({
    required super.containerSize,
    required Map<String, Rect> sourceRects,
    required Map<String, Rect> destRects,
  })  : _testSourceRects = sourceRects,
        _testDestRects = destRects,
        super(fromViews: [], toViews: []);

  /// Factory that builds a fully wired TestHeroContext.
  ///
  /// [sourceRects] and [destRects] map heroID -> global rect.
  /// Views whose IDs appear in both maps are considered "matched".
  factory TestHeroContext({
    Size containerSize = const Size(400, 800),
    Map<String, Rect> sourceRects = const {},
    Map<String, Rect> destRects = const {},
  }) {
    final ctx = TestHeroContext._(
      containerSize: containerSize,
      sourceRects: sourceRects,
      destRects: destRects,
    );
    return ctx;
  }

  // Override the rect accessors so preprocessors can look up rects without
  // needing real RenderBox references.
  @override
  Rect? sourceRect(String heroID) => _testSourceRects[heroID];

  @override
  Rect? destRect(String heroID) => _testDestRects[heroID];

  // Override matchedIDs to be derived from the injected maps.
  @override
  Set<String> get matchedIDs {
    return _testSourceRects.keys
        .toSet()
        .intersection(_testDestRects.keys.toSet());
  }

  @override
  bool isMatched(String heroID) =>
      _testSourceRects.containsKey(heroID) &&
      _testDestRects.containsKey(heroID);

  @override
  Set<String> get sourceIDs => _testSourceRects.keys.toSet();

  @override
  Set<String> get destIDs => _testDestRects.keys.toSet();
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Convenience to run a single preprocessor against a TestHeroContext.
void runPreprocessor(
  HeroPreprocessor preprocessor, {
  required TestHeroContext context,
  required List<String> fromViewIDs,
  required List<String> toViewIDs,
}) {
  preprocessor.context = context;
  preprocessor.process(fromViewIDs: fromViewIDs, toViewIDs: toViewIDs);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
void main() {
  // ====================================================================
  // DefaultAnimationPreprocessor
  // ====================================================================
  group('DefaultAnimationPreprocessor', () {
    late TestHeroContext ctx;

    setUp(() {
      ctx = TestHeroContext(
        containerSize: const Size(400, 800),
        sourceRects: {
          'fromView': const Rect.fromLTWH(0, 0, 400, 800),
        },
        destRects: {
          'toView': const Rect.fromLTWH(0, 0, 400, 800),
        },
      );
    });

    // -- Push --------------------------------------------------------
    test('push(left) applies translate to source and beginWith to dest', () {
      final preprocessor = DefaultAnimationPreprocessor(
        animationType:
            const HeroAnimationType.push(direction: HeroAnimationDirection.left),
        isPresenting: true,
      );

      runPreprocessor(preprocessor,
          context: ctx,
          fromViewIDs: ['fromView'],
          toViewIDs: ['toView']);

      final fromState = ctx.targetStateFor('fromView');
      final toState = ctx.targetStateFor('toView');

      // Source should have a translate transform applied.
      expect(fromState.transform, isNotNull,
          reason: 'Push should apply a translate transform to source view');

      // Source should have an overlay (darkening).
      expect(fromState.overlay, isNotNull,
          reason: 'Push should apply overlay to source view');
      expect(fromState.overlay!.opacity, 0.1);

      // Destination should have beginWith set.
      expect(toState.beginState, isNotNull,
          reason: 'Push should set beginWith on destination view');
      expect(toState.beginState, isNotEmpty);
    });

    // -- Pull --------------------------------------------------------
    test('pull(right) applies translate to source, beginWith overlay to dest',
        () {
      final preprocessor = DefaultAnimationPreprocessor(
        animationType: const HeroAnimationType.pull(
            direction: HeroAnimationDirection.right),
        isPresenting: true,
      );

      runPreprocessor(preprocessor,
          context: ctx,
          fromViewIDs: ['fromView'],
          toViewIDs: ['toView']);

      final fromState = ctx.targetStateFor('fromView');
      final toState = ctx.targetStateFor('toView');

      // Source should have a translate (slides away).
      expect(fromState.transform, isNotNull);

      // Destination beginWith should contain translate + overlay.
      expect(toState.beginState, isNotNull);
      expect(toState.beginState!.length, greaterThanOrEqualTo(1));
    });

    // -- Cover -------------------------------------------------------
    test('cover(up) does NOT apply translate to source, only overlay', () {
      final preprocessor = DefaultAnimationPreprocessor(
        animationType:
            const HeroAnimationType.cover(direction: HeroAnimationDirection.up),
        isPresenting: true,
      );

      runPreprocessor(preprocessor,
          context: ctx,
          fromViewIDs: ['fromView'],
          toViewIDs: ['toView']);

      final fromState = ctx.targetStateFor('fromView');
      final toState = ctx.targetStateFor('toView');

      // Cover: old view stays but gets overlay; no translate on source.
      expect(fromState.transform, isNull,
          reason: 'Cover should not translate the source view');
      expect(fromState.overlay, isNotNull,
          reason: 'Cover should apply overlay to source');

      // New view slides in from opposite direction.
      expect(toState.beginState, isNotNull);
    });

    // -- Uncover -----------------------------------------------------
    test('uncover(down) applies translate to source, overlay beginWith to dest',
        () {
      final preprocessor = DefaultAnimationPreprocessor(
        animationType: const HeroAnimationType.uncover(
            direction: HeroAnimationDirection.down),
        isPresenting: true,
      );

      runPreprocessor(preprocessor,
          context: ctx,
          fromViewIDs: ['fromView'],
          toViewIDs: ['toView']);

      final fromState = ctx.targetStateFor('fromView');
      final toState = ctx.targetStateFor('toView');

      // Old view slides away.
      expect(fromState.transform, isNotNull);

      // New view has overlay beginWith (starts darkened, reveals).
      expect(toState.beginState, isNotNull);
    });

    // -- Slide -------------------------------------------------------
    test('slide(right) applies translate to both views', () {
      final preprocessor = DefaultAnimationPreprocessor(
        animationType: const HeroAnimationType.slide(
            direction: HeroAnimationDirection.right),
        isPresenting: true,
      );

      runPreprocessor(preprocessor,
          context: ctx,
          fromViewIDs: ['fromView'],
          toViewIDs: ['toView']);

      final fromState = ctx.targetStateFor('fromView');
      final toState = ctx.targetStateFor('toView');

      expect(fromState.transform, isNotNull,
          reason: 'Slide should translate source');
      expect(toState.beginState, isNotNull,
          reason: 'Slide should set beginWith translate on dest');
    });

    // -- Fade --------------------------------------------------------
    test('fade sets opacity to 0 on source and beginWith fade on dest', () {
      final preprocessor = DefaultAnimationPreprocessor(
        animationType: const HeroAnimationType.fade(),
        isPresenting: true,
      );

      runPreprocessor(preprocessor,
          context: ctx,
          fromViewIDs: ['fromView'],
          toViewIDs: ['toView']);

      final fromState = ctx.targetStateFor('fromView');
      final toState = ctx.targetStateFor('toView');

      expect(fromState.opacity, 0.0,
          reason: 'Fade should set source opacity to 0');
      expect(toState.beginState, isNotNull,
          reason: 'Fade should set beginWith on dest');
    });

    // -- Zoom --------------------------------------------------------
    test('zoom applies scale+fade to source and beginWith scale+fade to dest',
        () {
      final preprocessor = DefaultAnimationPreprocessor(
        animationType: const HeroAnimationType.zoom(),
        isPresenting: true,
      );

      runPreprocessor(preprocessor,
          context: ctx,
          fromViewIDs: ['fromView'],
          toViewIDs: ['toView']);

      final fromState = ctx.targetStateFor('fromView');
      final toState = ctx.targetStateFor('toView');

      // Source zooms in (scale 1.3) and fades.
      expect(fromState.transform, isNotNull);
      expect(fromState.opacity, 0.0);

      // Dest starts zoomed out and faded.
      expect(toState.beginState, isNotNull);
      expect(toState.beginState!.length, greaterThanOrEqualTo(1));
    });

    // -- ZoomOut -----------------------------------------------------
    test('zoomOut applies scale(0.7)+fade to source, scale(1.3)+fade beginWith to dest',
        () {
      final preprocessor = DefaultAnimationPreprocessor(
        animationType: const HeroAnimationType.zoomOut(),
        isPresenting: true,
      );

      runPreprocessor(preprocessor,
          context: ctx,
          fromViewIDs: ['fromView'],
          toViewIDs: ['toView']);

      final fromState = ctx.targetStateFor('fromView');
      final toState = ctx.targetStateFor('toView');

      expect(fromState.transform, isNotNull);
      expect(fromState.opacity, 0.0);
      expect(toState.beginState, isNotNull);
    });

    // -- ZoomSlide ---------------------------------------------------
    test('zoomSlide applies scale+opacity to source, translate beginWith to dest',
        () {
      final preprocessor = DefaultAnimationPreprocessor(
        animationType: const HeroAnimationType.zoomSlide(
            direction: HeroAnimationDirection.left),
        isPresenting: true,
      );

      runPreprocessor(preprocessor,
          context: ctx,
          fromViewIDs: ['fromView'],
          toViewIDs: ['toView']);

      final fromState = ctx.targetStateFor('fromView');
      final toState = ctx.targetStateFor('toView');

      // Source zooms out and fades.
      expect(fromState.transform, isNotNull);
      expect(fromState.opacity, 0.0);

      // Dest slides in.
      expect(toState.beginState, isNotNull);
    });

    // -- PageIn ------------------------------------------------------
    test('pageIn applies scale+opacity to source, translate beginWith to dest',
        () {
      final preprocessor = DefaultAnimationPreprocessor(
        animationType: const HeroAnimationType.pageIn(
            direction: HeroAnimationDirection.left),
        isPresenting: true,
      );

      runPreprocessor(preprocessor,
          context: ctx,
          fromViewIDs: ['fromView'],
          toViewIDs: ['toView']);

      final fromState = ctx.targetStateFor('fromView');
      final toState = ctx.targetStateFor('toView');

      expect(fromState.transform, isNotNull);
      expect(fromState.opacity, 0.0);
      expect(toState.beginState, isNotNull);
    });

    // -- PageOut -----------------------------------------------------
    test('pageOut applies translate to source, scale+opacity beginWith to dest',
        () {
      final preprocessor = DefaultAnimationPreprocessor(
        animationType: const HeroAnimationType.pageOut(
            direction: HeroAnimationDirection.right),
        isPresenting: true,
      );

      runPreprocessor(preprocessor,
          context: ctx,
          fromViewIDs: ['fromView'],
          toViewIDs: ['toView']);

      final fromState = ctx.targetStateFor('fromView');
      final toState = ctx.targetStateFor('toView');

      // Source slides away.
      expect(fromState.transform, isNotNull);

      // Dest starts small and invisible.
      expect(toState.beginState, isNotNull);
    });

    // -- None --------------------------------------------------------
    test('none animation type does not modify any state', () {
      final preprocessor = DefaultAnimationPreprocessor(
        animationType: const HeroAnimationType.none(),
        isPresenting: true,
      );

      runPreprocessor(preprocessor,
          context: ctx,
          fromViewIDs: ['fromView'],
          toViewIDs: ['toView']);

      final fromState = ctx.targetStateFor('fromView');
      final toState = ctx.targetStateFor('toView');

      expect(fromState.transform, isNull);
      expect(fromState.opacity, isNull);
      expect(fromState.overlay, isNull);
      expect(toState.transform, isNull);
      expect(toState.beginState, isNull);
    });

    // -- Auto --------------------------------------------------------
    test('auto animation type does not modify any state', () {
      final preprocessor = DefaultAnimationPreprocessor(
        animationType: const HeroAnimationType.auto(),
        isPresenting: true,
      );

      runPreprocessor(preprocessor,
          context: ctx,
          fromViewIDs: ['fromView'],
          toViewIDs: ['toView']);

      final fromState = ctx.targetStateFor('fromView');
      final toState = ctx.targetStateFor('toView');

      expect(fromState.transform, isNull);
      expect(toState.beginState, isNull);
    });

    // -- SelectBy ----------------------------------------------------
    test('selectBy resolves to presenting type when isPresenting is true', () {
      final preprocessor = DefaultAnimationPreprocessor(
        animationType: HeroAnimationType.selectBy(
          presenting: const HeroAnimationType.fade(),
          dismissing: const HeroAnimationType.zoom(),
        ),
        isPresenting: true,
      );

      runPreprocessor(preprocessor,
          context: ctx,
          fromViewIDs: ['fromView'],
          toViewIDs: ['toView']);

      final fromState = ctx.targetStateFor('fromView');
      // Fade was used: source should have opacity 0.
      expect(fromState.opacity, 0.0,
          reason: 'selectBy should resolve to fade when presenting');
    });

    test('selectBy resolves to dismissing type when isPresenting is false', () {
      final ctx2 = TestHeroContext(
        containerSize: const Size(400, 800),
        sourceRects: {'fromView': const Rect.fromLTWH(0, 0, 400, 800)},
        destRects: {'toView': const Rect.fromLTWH(0, 0, 400, 800)},
      );

      final preprocessor = DefaultAnimationPreprocessor(
        animationType: HeroAnimationType.selectBy(
          presenting: const HeroAnimationType.fade(),
          dismissing: const HeroAnimationType.zoom(),
        ),
        isPresenting: false,
      );

      runPreprocessor(preprocessor,
          context: ctx2,
          fromViewIDs: ['fromView'],
          toViewIDs: ['toView']);

      final fromState = ctx2.targetStateFor('fromView');
      // Zoom was used: source should have both transform (scale) and opacity.
      expect(fromState.transform, isNotNull,
          reason: 'selectBy should resolve to zoom when dismissing');
      expect(fromState.opacity, 0.0);
    });

    // -- Translate direction correctness ------------------------------
    test('push(left) source translates by -containerWidth on x axis', () {
      final preprocessor = DefaultAnimationPreprocessor(
        animationType:
            const HeroAnimationType.push(direction: HeroAnimationDirection.left),
        isPresenting: true,
      );

      runPreprocessor(preprocessor,
          context: ctx,
          fromViewIDs: ['fromView'],
          toViewIDs: ['toView']);

      final fromState = ctx.targetStateFor('fromView');
      // The transform should contain a translate by (-400, 0) for left push
      // on a 400-wide container.
      final transform = fromState.transform!;
      // Matrix4 stores translation in column 3 (indices 12, 13, 14).
      expect(transform.getTranslation().x, -400.0);
      expect(transform.getTranslation().y, 0.0);
    });

    test('push(down) source translates by +containerHeight on y axis', () {
      final preprocessor = DefaultAnimationPreprocessor(
        animationType:
            const HeroAnimationType.push(direction: HeroAnimationDirection.down),
        isPresenting: true,
      );

      runPreprocessor(preprocessor,
          context: ctx,
          fromViewIDs: ['fromView'],
          toViewIDs: ['toView']);

      final fromState = ctx.targetStateFor('fromView');
      final transform = fromState.transform!;
      expect(transform.getTranslation().x, 0.0);
      expect(transform.getTranslation().y, 800.0);
    });

    // -- ignoreSubviewModifiers flag is set by all animation types ----
    test('all directional animations set ignoreSubviewModifiers on views', () {
      final types = <HeroAnimationType>[
        const HeroAnimationType.push(direction: HeroAnimationDirection.left),
        const HeroAnimationType.pull(direction: HeroAnimationDirection.right),
        const HeroAnimationType.cover(direction: HeroAnimationDirection.up),
        const HeroAnimationType.uncover(direction: HeroAnimationDirection.down),
        const HeroAnimationType.slide(direction: HeroAnimationDirection.left),
        const HeroAnimationType.fade(),
        const HeroAnimationType.zoom(),
        const HeroAnimationType.zoomOut(),
      ];

      for (final animType in types) {
        final testCtx = TestHeroContext(
          containerSize: const Size(400, 800),
          sourceRects: {'s': const Rect.fromLTWH(0, 0, 400, 800)},
          destRects: {'d': const Rect.fromLTWH(0, 0, 400, 800)},
        );

        final p = DefaultAnimationPreprocessor(
          animationType: animType,
          isPresenting: true,
        );

        runPreprocessor(p,
            context: testCtx, fromViewIDs: ['s'], toViewIDs: ['d']);

        final fromState = testCtx.targetStateFor('s');
        final toState = testCtx.targetStateFor('d');

        expect(fromState.ignoreSubviewModifiers, isNotNull,
            reason:
                '${animType.label} should set ignoreSubviewModifiers on source');
        expect(toState.ignoreSubviewModifiers, isNotNull,
            reason:
                '${animType.label} should set ignoreSubviewModifiers on dest');
      }
    });

    // -- Null context safety -----------------------------------------
    test('does not crash when context is null', () {
      final preprocessor = DefaultAnimationPreprocessor(
        animationType:
            const HeroAnimationType.push(direction: HeroAnimationDirection.left),
        isPresenting: true,
      );
      // Do NOT set context.
      expect(
        () => preprocessor.process(
            fromViewIDs: ['a'], toViewIDs: ['b']),
        returnsNormally,
      );
    });
  });

  // ====================================================================
  // ConditionalPreprocessor
  // ====================================================================
  group('ConditionalPreprocessor', () {
    test('whenMatched fires only for matched views', () {
      final ctx = TestHeroContext(
        sourceRects: {
          'matched': const Rect.fromLTWH(10, 10, 50, 50),
          'unmatched': const Rect.fromLTWH(0, 0, 100, 100),
        },
        destRects: {
          'matched': const Rect.fromLTWH(60, 60, 50, 50),
        },
      );

      // Prepare target states with conditional modifiers.
      final matchedState = ctx.targetStateFor('matched');
      HeroModifier.whenMatched([HeroModifier.fade]).apply(matchedState);

      final unmatchedState = ctx.targetStateFor('unmatched');
      HeroModifier.whenMatched([HeroModifier.fade]).apply(unmatchedState);

      final preprocessor = ConditionalPreprocessor(isPresenting: true);
      runPreprocessor(preprocessor,
          context: ctx,
          fromViewIDs: ['matched', 'unmatched'],
          toViewIDs: ['matched']);

      // The matched view's conditional should have been evaluated and the
      // fade modifier applied, setting opacity to 0.
      expect(matchedState.opacity, 0.0,
          reason: 'whenMatched should fire for matched view');

      // The unmatched view should NOT get the fade applied.
      expect(unmatchedState.opacity, isNull,
          reason: 'whenMatched should NOT fire for unmatched view');
    });

    test('whenPresenting fires only when isPresenting is true', () {
      final ctx = TestHeroContext(
        sourceRects: {'view': const Rect.fromLTWH(0, 0, 100, 100)},
        destRects: {},
      );

      final state = ctx.targetStateFor('view');
      HeroModifier.whenPresenting([
        HeroModifier.opacity(0.5),
      ]).apply(state);

      final preprocessor = ConditionalPreprocessor(isPresenting: true);
      runPreprocessor(preprocessor,
          context: ctx, fromViewIDs: ['view'], toViewIDs: []);

      expect(state.opacity, 0.5,
          reason:
              'whenPresenting should apply modifiers when isPresenting=true');
    });

    test('whenPresenting does NOT fire when isPresenting is false', () {
      final ctx = TestHeroContext(
        sourceRects: {'view': const Rect.fromLTWH(0, 0, 100, 100)},
        destRects: {},
      );

      final state = ctx.targetStateFor('view');
      HeroModifier.whenPresenting([
        HeroModifier.opacity(0.5),
      ]).apply(state);

      final preprocessor = ConditionalPreprocessor(isPresenting: false);
      runPreprocessor(preprocessor,
          context: ctx, fromViewIDs: ['view'], toViewIDs: []);

      expect(state.opacity, isNull,
          reason:
              'whenPresenting should not apply modifiers when isPresenting=false');
    });

    test('whenDismissing fires only when isPresenting is false', () {
      final ctx = TestHeroContext(
        destRects: {'view': const Rect.fromLTWH(0, 0, 100, 100)},
        sourceRects: {},
      );

      final state = ctx.targetStateFor('view');
      HeroModifier.whenDismissing([
        HeroModifier.opacity(0.3),
      ]).apply(state);

      // Presenting = false => dismissing.
      final preprocessor = ConditionalPreprocessor(isPresenting: false);
      runPreprocessor(preprocessor,
          context: ctx, fromViewIDs: [], toViewIDs: ['view']);

      expect(state.opacity, 0.3,
          reason: 'whenDismissing should fire when isPresenting=false');
    });

    test('whenDismissing does NOT fire when isPresenting is true', () {
      final ctx = TestHeroContext(
        destRects: {'view': const Rect.fromLTWH(0, 0, 100, 100)},
        sourceRects: {},
      );

      final state = ctx.targetStateFor('view');
      HeroModifier.whenDismissing([
        HeroModifier.opacity(0.3),
      ]).apply(state);

      final preprocessor = ConditionalPreprocessor(isPresenting: true);
      runPreprocessor(preprocessor,
          context: ctx, fromViewIDs: [], toViewIDs: ['view']);

      expect(state.opacity, isNull,
          reason: 'whenDismissing should not fire when isPresenting=true');
    });

    test('whenAppearing fires for destination (toViewIDs) views', () {
      final ctx = TestHeroContext(
        sourceRects: {},
        destRects: {'dest': const Rect.fromLTWH(0, 0, 100, 100)},
      );

      final state = ctx.targetStateFor('dest');
      HeroModifier.whenAppearing([
        HeroModifier.cornerRadius(12.0),
      ]).apply(state);

      final preprocessor = ConditionalPreprocessor(isPresenting: true);
      runPreprocessor(preprocessor,
          context: ctx, fromViewIDs: [], toViewIDs: ['dest']);

      expect(state.cornerRadius, 12.0,
          reason: 'whenAppearing should fire for destination views');
    });

    test('whenDisappearing fires for source (fromViewIDs) views', () {
      final ctx = TestHeroContext(
        sourceRects: {'src': const Rect.fromLTWH(0, 0, 100, 100)},
        destRects: {},
      );

      final state = ctx.targetStateFor('src');
      HeroModifier.whenDisappearing([
        HeroModifier.cornerRadius(8.0),
      ]).apply(state);

      final preprocessor = ConditionalPreprocessor(isPresenting: true);
      runPreprocessor(preprocessor,
          context: ctx, fromViewIDs: ['src'], toViewIDs: []);

      expect(state.cornerRadius, 8.0,
          reason: 'whenDisappearing should fire for source views');
    });

    test('conditionalModifiers are cleared after processing', () {
      final ctx = TestHeroContext(
        sourceRects: {'v': const Rect.fromLTWH(0, 0, 100, 100)},
        destRects: {},
      );

      final state = ctx.targetStateFor('v');
      HeroModifier.whenPresenting([HeroModifier.fade]).apply(state);
      expect(state.conditionalModifiers, isNotNull);

      final preprocessor = ConditionalPreprocessor(isPresenting: true);
      runPreprocessor(preprocessor,
          context: ctx, fromViewIDs: ['v'], toViewIDs: []);

      expect(state.conditionalModifiers, isNull,
          reason: 'Conditionals should be cleared after processing');
    });

    test('custom when condition is evaluated correctly', () {
      final ctx = TestHeroContext(
        sourceRects: {'alpha': const Rect.fromLTWH(0, 0, 100, 100)},
        destRects: {},
      );

      final state = ctx.targetStateFor('alpha');
      // Custom condition: only apply if heroID == 'alpha'.
      HeroModifier.when(
        (c) => c.heroID == 'alpha',
        [HeroModifier.opacity(0.42)],
      ).apply(state);

      final preprocessor = ConditionalPreprocessor(isPresenting: true);
      runPreprocessor(preprocessor,
          context: ctx, fromViewIDs: ['alpha'], toViewIDs: []);

      expect(state.opacity, 0.42);
    });

    test('does not crash when context is null', () {
      final preprocessor = ConditionalPreprocessor(isPresenting: true);
      expect(
        () => preprocessor.process(
            fromViewIDs: ['a'], toViewIDs: ['b']),
        returnsNormally,
      );
    });
  });

  // ====================================================================
  // CascadePreprocessor
  // ====================================================================
  group('CascadePreprocessor', () {
    test('applies incremental delays sorted top-to-bottom', () {
      // Set up three sibling views at different y positions plus a parent
      // that has cascade config.
      final ctx = TestHeroContext(
        sourceRects: {
          'parent': const Rect.fromLTWH(0, 0, 400, 800),
          'child_top': const Rect.fromLTWH(10, 100, 80, 40),
          'child_mid': const Rect.fromLTWH(10, 300, 80, 40),
          'child_bot': const Rect.fromLTWH(10, 500, 80, 40),
        },
      );

      // Give 'parent' a cascade config.
      final parentState = ctx.targetStateFor('parent');
      HeroModifier.cascade(
        delta: const Duration(milliseconds: 30),
        direction: const CascadeDirection.topToBottom(),
      ).apply(parentState);

      // Ensure siblings have initial zero delay (default).
      ctx.targetStateFor('child_top');
      ctx.targetStateFor('child_mid');
      ctx.targetStateFor('child_bot');

      final preprocessor = CascadePreprocessor();
      runPreprocessor(
        preprocessor,
        context: ctx,
        fromViewIDs: ['parent', 'child_top', 'child_mid', 'child_bot'],
        toViewIDs: [],
      );

      final topDelay = ctx.targetStateFor('child_top').delay;
      final midDelay = ctx.targetStateFor('child_mid').delay;
      final botDelay = ctx.targetStateFor('child_bot').delay;

      // The children should be sorted by their center y position (ascending).
      // child_top center y = 120, child_mid center y = 320, child_bot center y = 520.
      // So delays should be 0*30ms, 1*30ms, 2*30ms.
      expect(topDelay.inMilliseconds, lessThan(midDelay.inMilliseconds));
      expect(midDelay.inMilliseconds, lessThan(botDelay.inMilliseconds));

      // Verify exact increments.
      expect(topDelay, Duration.zero);
      expect(midDelay, const Duration(milliseconds: 30));
      expect(botDelay, const Duration(milliseconds: 60));
    });

    test('bottomToTop reverses cascade order', () {
      final ctx = TestHeroContext(
        sourceRects: {
          'parent': const Rect.fromLTWH(0, 0, 400, 800),
          'child_top': const Rect.fromLTWH(10, 100, 80, 40),
          'child_bot': const Rect.fromLTWH(10, 500, 80, 40),
        },
      );

      final parentState = ctx.targetStateFor('parent');
      HeroModifier.cascade(
        delta: const Duration(milliseconds: 25),
        direction: const CascadeDirection.bottomToTop(),
      ).apply(parentState);

      ctx.targetStateFor('child_top');
      ctx.targetStateFor('child_bot');

      final preprocessor = CascadePreprocessor();
      runPreprocessor(
        preprocessor,
        context: ctx,
        fromViewIDs: ['parent', 'child_top', 'child_bot'],
        toViewIDs: [],
      );

      final topDelay = ctx.targetStateFor('child_top').delay;
      final botDelay = ctx.targetStateFor('child_bot').delay;

      // Bottom to top: child_bot should animate first (lower delay).
      expect(botDelay.inMilliseconds, lessThan(topDelay.inMilliseconds));
    });

    test('leftToRight cascade sorts by x position', () {
      final ctx = TestHeroContext(
        destRects: {
          'parent': const Rect.fromLTWH(0, 0, 400, 800),
          'left': const Rect.fromLTWH(10, 100, 40, 40),
          'right': const Rect.fromLTWH(300, 100, 40, 40),
        },
      );

      final parentState = ctx.targetStateFor('parent');
      HeroModifier.cascade(
        delta: const Duration(milliseconds: 20),
        direction: const CascadeDirection.leftToRight(),
      ).apply(parentState);

      ctx.targetStateFor('left');
      ctx.targetStateFor('right');

      final preprocessor = CascadePreprocessor();
      runPreprocessor(
        preprocessor,
        context: ctx,
        fromViewIDs: [],
        toViewIDs: ['parent', 'left', 'right'],
      );

      final leftDelay = ctx.targetStateFor('left').delay;
      final rightDelay = ctx.targetStateFor('right').delay;

      expect(leftDelay.inMilliseconds, lessThan(rightDelay.inMilliseconds));
    });

    test('delayMatchedViews=false skips matched views in cascade', () {
      final ctx = TestHeroContext(
        sourceRects: {
          'parent': const Rect.fromLTWH(0, 0, 400, 800),
          'matched_child': const Rect.fromLTWH(10, 200, 40, 40),
          'unmatched_child': const Rect.fromLTWH(10, 400, 40, 40),
        },
        destRects: {
          'matched_child': const Rect.fromLTWH(60, 200, 40, 40),
        },
      );

      final parentState = ctx.targetStateFor('parent');
      HeroModifier.cascade(
        delta: const Duration(milliseconds: 20),
        direction: const CascadeDirection.topToBottom(),
        delayMatchedViews: false,
      ).apply(parentState);

      ctx.targetStateFor('matched_child');
      ctx.targetStateFor('unmatched_child');

      final preprocessor = CascadePreprocessor();
      runPreprocessor(
        preprocessor,
        context: ctx,
        fromViewIDs: ['parent', 'matched_child', 'unmatched_child'],
        toViewIDs: [],
      );

      final matchedDelay = ctx.targetStateFor('matched_child').delay;

      // Matched views should not receive a cascade delay.
      expect(matchedDelay, Duration.zero,
          reason:
              'Matched views should be skipped when delayMatchedViews=false');
    });

    test('delayMatchedViews=true includes matched views in cascade', () {
      final ctx = TestHeroContext(
        sourceRects: {
          'parent': const Rect.fromLTWH(0, 0, 400, 800),
          'matched_child': const Rect.fromLTWH(10, 200, 40, 40),
          'unmatched_child': const Rect.fromLTWH(10, 400, 40, 40),
        },
        destRects: {
          'matched_child': const Rect.fromLTWH(60, 200, 40, 40),
        },
      );

      final parentState = ctx.targetStateFor('parent');
      HeroModifier.cascade(
        delta: const Duration(milliseconds: 20),
        direction: const CascadeDirection.topToBottom(),
        delayMatchedViews: true,
      ).apply(parentState);

      ctx.targetStateFor('matched_child');
      ctx.targetStateFor('unmatched_child');

      final preprocessor = CascadePreprocessor();
      runPreprocessor(
        preprocessor,
        context: ctx,
        fromViewIDs: ['parent', 'matched_child', 'unmatched_child'],
        toViewIDs: [],
      );

      final matchedDelay = ctx.targetStateFor('matched_child').delay;
      final unmatchedDelay = ctx.targetStateFor('unmatched_child').delay;

      // Both should have delays; matched_child is at y=200, unmatched at y=400.
      // So matched_child is first (index 0 -> 0ms) and unmatched is second (index 1 -> 20ms).
      expect(matchedDelay, Duration.zero);
      expect(unmatchedDelay, const Duration(milliseconds: 20));
    });

    test('no crash with empty sibling list', () {
      final ctx = TestHeroContext(
        sourceRects: {
          'lonely': const Rect.fromLTWH(0, 0, 400, 800),
        },
      );

      final parentState = ctx.targetStateFor('lonely');
      HeroModifier.cascadeDefault.apply(parentState);

      final preprocessor = CascadePreprocessor();
      expect(
        () => runPreprocessor(
          preprocessor,
          context: ctx,
          fromViewIDs: ['lonely'],
          toViewIDs: [],
        ),
        returnsNormally,
      );
    });

    test('does not crash when context is null', () {
      final preprocessor = CascadePreprocessor();
      expect(
        () => preprocessor.process(fromViewIDs: ['a'], toViewIDs: []),
        returnsNormally,
      );
    });
  });

  // ====================================================================
  // IgnoreSubviewModifiersPreprocessor
  // ====================================================================
  group('IgnoreSubviewModifiersPreprocessor', () {
    // The Flutter implementation of this preprocessor is a structural no-op
    // (the behavior is handled by HeroView.isEnabledForSubviews at
    // registration time). We verify it runs without errors and reads the
    // state correctly.

    test('runs without error even with ignoreSubviewModifiers set', () {
      final ctx = TestHeroContext(
        sourceRects: {'view': const Rect.fromLTWH(0, 0, 100, 100)},
      );

      final state = ctx.targetStateFor('view');
      state.ignoreSubviewModifiers = true;

      final preprocessor = IgnoreSubviewModifiersPreprocessor();
      expect(
        () => runPreprocessor(preprocessor,
            context: ctx, fromViewIDs: ['view'], toViewIDs: []),
        returnsNormally,
      );
    });

    test('runs without error when ignoreSubviewModifiers is null', () {
      final ctx = TestHeroContext(
        sourceRects: {'view': const Rect.fromLTWH(0, 0, 100, 100)},
      );

      ctx.targetStateFor('view'); // default: ignoreSubviewModifiers is null

      final preprocessor = IgnoreSubviewModifiersPreprocessor();
      expect(
        () => runPreprocessor(preprocessor,
            context: ctx, fromViewIDs: ['view'], toViewIDs: []),
        returnsNormally,
      );
    });

    test('processes both fromViewIDs and toViewIDs without error', () {
      final ctx = TestHeroContext(
        sourceRects: {'src': const Rect.fromLTWH(0, 0, 100, 100)},
        destRects: {'dst': const Rect.fromLTWH(0, 0, 100, 100)},
      );

      ctx.targetStateFor('src').ignoreSubviewModifiers = true;
      ctx.targetStateFor('dst').ignoreSubviewModifiers = false;

      final preprocessor = IgnoreSubviewModifiersPreprocessor();
      expect(
        () => runPreprocessor(preprocessor,
            context: ctx, fromViewIDs: ['src'], toViewIDs: ['dst']),
        returnsNormally,
      );
    });

    test('does not crash when context is null', () {
      final preprocessor = IgnoreSubviewModifiersPreprocessor();
      expect(
        () => preprocessor.process(fromViewIDs: ['a'], toViewIDs: ['b']),
        returnsNormally,
      );
    });
  });

  // ====================================================================
  // MatchPreprocessor
  // ====================================================================
  group('MatchPreprocessor', () {
    test('sets position and size from destination rect for matched views', () {
      final ctx = TestHeroContext(
        sourceRects: {
          'hero': const Rect.fromLTWH(10, 20, 100, 50),
        },
        destRects: {
          'hero': const Rect.fromLTWH(200, 300, 80, 120),
        },
      );

      final preprocessor = MatchPreprocessor();
      runPreprocessor(preprocessor,
          context: ctx, fromViewIDs: ['hero'], toViewIDs: ['hero']);

      final state = ctx.targetStateFor('hero');

      // The source view should animate to the destination rect's center.
      expect(state.position, const Rect.fromLTWH(200, 300, 80, 120).center);

      // The source view should animate to the destination rect's size.
      expect(state.size, const Size(80, 120));
    });

    test('does not overwrite position if already set', () {
      final ctx = TestHeroContext(
        sourceRects: {'hero': const Rect.fromLTWH(0, 0, 100, 100)},
        destRects: {'hero': const Rect.fromLTWH(200, 200, 50, 50)},
      );

      // Pre-set the position.
      final state = ctx.targetStateFor('hero');
      state.position = const Offset(999, 999);

      final preprocessor = MatchPreprocessor();
      runPreprocessor(preprocessor,
          context: ctx, fromViewIDs: ['hero'], toViewIDs: ['hero']);

      expect(state.position, const Offset(999, 999),
          reason: 'MatchPreprocessor should not overwrite existing position');
    });

    test('does not overwrite size if already set', () {
      final ctx = TestHeroContext(
        sourceRects: {'hero': const Rect.fromLTWH(0, 0, 100, 100)},
        destRects: {'hero': const Rect.fromLTWH(200, 200, 50, 50)},
      );

      final state = ctx.targetStateFor('hero');
      state.size = const Size(42, 42);

      final preprocessor = MatchPreprocessor();
      runPreprocessor(preprocessor,
          context: ctx, fromViewIDs: ['hero'], toViewIDs: ['hero']);

      expect(state.size, const Size(42, 42),
          reason: 'MatchPreprocessor should not overwrite existing size');
    });

    test('ignores unmatched views', () {
      final ctx = TestHeroContext(
        sourceRects: {'sourceOnly': const Rect.fromLTWH(0, 0, 100, 100)},
        destRects: {'destOnly': const Rect.fromLTWH(200, 200, 50, 50)},
      );

      final preprocessor = MatchPreprocessor();
      runPreprocessor(preprocessor,
          context: ctx,
          fromViewIDs: ['sourceOnly'],
          toViewIDs: ['destOnly']);

      // No target state should have been created for either.
      expect(ctx['sourceOnly'], isNull,
          reason:
              'Unmatched source should not receive position/size from match');
      expect(ctx['destOnly'], isNull,
          reason:
              'Unmatched dest should not receive position/size from match');
    });

    test('handles multiple matched views', () {
      final ctx = TestHeroContext(
        sourceRects: {
          'a': const Rect.fromLTWH(0, 0, 100, 100),
          'b': const Rect.fromLTWH(50, 50, 60, 60),
        },
        destRects: {
          'a': const Rect.fromLTWH(200, 200, 80, 80),
          'b': const Rect.fromLTWH(300, 300, 40, 40),
        },
      );

      final preprocessor = MatchPreprocessor();
      runPreprocessor(preprocessor,
          context: ctx,
          fromViewIDs: ['a', 'b'],
          toViewIDs: ['a', 'b']);

      final stateA = ctx.targetStateFor('a');
      final stateB = ctx.targetStateFor('b');

      expect(stateA.position, const Rect.fromLTWH(200, 200, 80, 80).center);
      expect(stateA.size, const Size(80, 80));

      expect(stateB.position, const Rect.fromLTWH(300, 300, 40, 40).center);
      expect(stateB.size, const Size(40, 40));
    });

    test('does not crash when context is null', () {
      final preprocessor = MatchPreprocessor();
      expect(
        () => preprocessor.process(fromViewIDs: ['a'], toViewIDs: ['b']),
        returnsNormally,
      );
    });
  });

  // ====================================================================
  // SourcePreprocessor
  // ====================================================================
  group('SourcePreprocessor', () {
    test('sets position and size from source heroID rect', () {
      final ctx = TestHeroContext(
        sourceRects: {
          'sourceView': const Rect.fromLTWH(50, 100, 120, 60),
        },
        destRects: {
          'targetView': const Rect.fromLTWH(0, 0, 400, 800),
        },
      );

      // targetView uses sourceView as its source.
      final state = ctx.targetStateFor('targetView');
      state.source = 'sourceView';

      final preprocessor = SourcePreprocessor();
      runPreprocessor(preprocessor,
          context: ctx,
          fromViewIDs: ['sourceView'],
          toViewIDs: ['targetView']);

      expect(state.position,
          const Rect.fromLTWH(50, 100, 120, 60).center,
          reason: 'Should set position to source rect center');
      expect(state.size, const Size(120, 60),
          reason: 'Should set size to source rect size');
    });

    test('does not overwrite position if already set', () {
      final ctx = TestHeroContext(
        sourceRects: {
          'sourceView': const Rect.fromLTWH(50, 100, 120, 60),
        },
        destRects: {
          'targetView': const Rect.fromLTWH(0, 0, 400, 800),
        },
      );

      final state = ctx.targetStateFor('targetView');
      state.source = 'sourceView';
      state.position = const Offset(1, 1);

      final preprocessor = SourcePreprocessor();
      runPreprocessor(preprocessor,
          context: ctx,
          fromViewIDs: ['sourceView'],
          toViewIDs: ['targetView']);

      expect(state.position, const Offset(1, 1),
          reason: 'Should not overwrite existing position');
    });

    test('does not overwrite size if already set', () {
      final ctx = TestHeroContext(
        sourceRects: {
          'sourceView': const Rect.fromLTWH(50, 100, 120, 60),
        },
        destRects: {
          'targetView': const Rect.fromLTWH(0, 0, 400, 800),
        },
      );

      final state = ctx.targetStateFor('targetView');
      state.source = 'sourceView';
      state.size = const Size(7, 7);

      final preprocessor = SourcePreprocessor();
      runPreprocessor(preprocessor,
          context: ctx,
          fromViewIDs: ['sourceView'],
          toViewIDs: ['targetView']);

      expect(state.size, const Size(7, 7),
          reason: 'Should not overwrite existing size');
    });

    test('initializes beginState list when source is found', () {
      final ctx = TestHeroContext(
        sourceRects: {
          'src': const Rect.fromLTWH(10, 10, 40, 40),
        },
        destRects: {
          'tgt': const Rect.fromLTWH(0, 0, 400, 800),
        },
      );

      final state = ctx.targetStateFor('tgt');
      state.source = 'src';

      final preprocessor = SourcePreprocessor();
      runPreprocessor(preprocessor,
          context: ctx, fromViewIDs: ['src'], toViewIDs: ['tgt']);

      expect(state.beginState, isNotNull,
          reason: 'beginState should be initialized');
    });

    test('falls back to destRect when sourceRect is not available', () {
      final ctx = TestHeroContext(
        sourceRects: {},
        destRects: {
          'src': const Rect.fromLTWH(10, 20, 30, 40),
          'tgt': const Rect.fromLTWH(0, 0, 400, 800),
        },
      );

      final state = ctx.targetStateFor('tgt');
      state.source = 'src';

      final preprocessor = SourcePreprocessor();
      runPreprocessor(preprocessor,
          context: ctx, fromViewIDs: [], toViewIDs: ['tgt']);

      expect(state.position, const Rect.fromLTWH(10, 20, 30, 40).center,
          reason: 'Should fall back to destRect when sourceRect is missing');
      expect(state.size, const Size(30, 40));
    });

    test('skips views without source modifier', () {
      final ctx = TestHeroContext(
        sourceRects: {
          'v1': const Rect.fromLTWH(0, 0, 100, 100),
        },
        destRects: {},
      );

      // No source set.
      ctx.targetStateFor('v1');

      final preprocessor = SourcePreprocessor();
      runPreprocessor(preprocessor,
          context: ctx, fromViewIDs: ['v1'], toViewIDs: []);

      final state = ctx.targetStateFor('v1');
      expect(state.position, isNull);
      expect(state.size, isNull);
    });

    test('skips if source heroID rect cannot be found at all', () {
      final ctx = TestHeroContext(
        sourceRects: {},
        destRects: {
          'tgt': const Rect.fromLTWH(0, 0, 100, 100),
        },
      );

      final state = ctx.targetStateFor('tgt');
      state.source = 'nonexistent';

      final preprocessor = SourcePreprocessor();
      runPreprocessor(preprocessor,
          context: ctx, fromViewIDs: [], toViewIDs: ['tgt']);

      expect(state.position, isNull);
      expect(state.size, isNull);
    });

    test('does not crash when context is null', () {
      final preprocessor = SourcePreprocessor();
      expect(
        () => preprocessor.process(fromViewIDs: ['a'], toViewIDs: ['b']),
        returnsNormally,
      );
    });
  });

  // ====================================================================
  // HeroPreprocessor base class
  // ====================================================================
  group('HeroPreprocessor (base)', () {
    test('context property starts as null', () {
      final preprocessor = IgnoreSubviewModifiersPreprocessor();
      expect(preprocessor.context, isNull);
    });

    test('context can be assigned and read back', () {
      final ctx = TestHeroContext();
      final preprocessor = IgnoreSubviewModifiersPreprocessor();
      preprocessor.context = ctx;
      expect(preprocessor.context, same(ctx));
    });
  });

  // ====================================================================
  // Integration: pipeline of multiple preprocessors
  // ====================================================================
  group('Preprocessor pipeline integration', () {
    test('running MatchPreprocessor then DefaultAnimationPreprocessor combines effects',
        () {
      final ctx = TestHeroContext(
        containerSize: const Size(400, 800),
        sourceRects: {
          'hero': const Rect.fromLTWH(10, 20, 100, 50),
          'root': const Rect.fromLTWH(0, 0, 400, 800),
        },
        destRects: {
          'hero': const Rect.fromLTWH(200, 300, 80, 120),
          'root': const Rect.fromLTWH(0, 0, 400, 800),
        },
      );

      // Step 1: MatchPreprocessor gives the matched view target position/size.
      final matchPP = MatchPreprocessor();
      runPreprocessor(matchPP,
          context: ctx,
          fromViewIDs: ['hero', 'root'],
          toViewIDs: ['hero', 'root']);

      final heroState = ctx.targetStateFor('hero');
      expect(heroState.position, isNotNull);
      expect(heroState.size, isNotNull);

      // Step 2: DefaultAnimationPreprocessor applies slide animation to root.
      final animPP = DefaultAnimationPreprocessor(
        animationType:
            const HeroAnimationType.push(direction: HeroAnimationDirection.left),
        isPresenting: true,
      );
      runPreprocessor(animPP,
          context: ctx,
          fromViewIDs: ['root'],
          toViewIDs: ['root']);

      final rootFromState = ctx.targetStateFor('root');
      expect(rootFromState.transform, isNotNull,
          reason: 'Root should get push animation transform');
    });

    test('ConditionalPreprocessor then DefaultAnimationPreprocessor is valid sequence',
        () {
      final ctx = TestHeroContext(
        containerSize: const Size(400, 800),
        sourceRects: {'s': const Rect.fromLTWH(0, 0, 400, 800)},
        destRects: {'d': const Rect.fromLTWH(0, 0, 400, 800)},
      );

      // Add conditional modifier.
      final state = ctx.targetStateFor('s');
      HeroModifier.whenPresenting([
        HeroModifier.opacity(0.5),
      ]).apply(state);

      // Step 1: Evaluate conditionals.
      final condPP = ConditionalPreprocessor(isPresenting: true);
      runPreprocessor(condPP,
          context: ctx, fromViewIDs: ['s'], toViewIDs: ['d']);
      expect(state.opacity, 0.5);

      // Step 2: Apply default animation.
      final animPP = DefaultAnimationPreprocessor(
        animationType: const HeroAnimationType.fade(),
        isPresenting: true,
      );
      runPreprocessor(animPP,
          context: ctx, fromViewIDs: ['s'], toViewIDs: ['d']);

      // Fade overwrites opacity to 0.
      expect(state.opacity, 0.0);
    });
  });

  // ====================================================================
  // TestHeroContext itself
  // ====================================================================
  group('TestHeroContext', () {
    test('matchedIDs returns intersection of source and dest IDs', () {
      final ctx = TestHeroContext(
        sourceRects: {
          'a': Rect.zero,
          'b': Rect.zero,
        },
        destRects: {
          'b': Rect.zero,
          'c': Rect.zero,
        },
      );

      expect(ctx.matchedIDs, {'b'});
    });

    test('isMatched returns true for matched, false for unmatched', () {
      final ctx = TestHeroContext(
        sourceRects: {'x': Rect.zero},
        destRects: {'x': Rect.zero, 'y': Rect.zero},
      );

      expect(ctx.isMatched('x'), isTrue);
      expect(ctx.isMatched('y'), isFalse);
    });

    test('targetStateFor creates and caches target states', () {
      final ctx = TestHeroContext();
      final state1 = ctx.targetStateFor('id');
      final state2 = ctx.targetStateFor('id');
      expect(state1, same(state2),
          reason: 'targetStateFor should return the same instance');
    });

    test('operator [] returns null for unknown IDs', () {
      final ctx = TestHeroContext();
      expect(ctx['unknown'], isNull);
    });

    test('operator []= sets and retrieves target state', () {
      final ctx = TestHeroContext();
      final state = HeroTargetState();
      ctx['myID'] = state;
      expect(ctx['myID'], same(state));
    });

    test('operator []= with null removes target state', () {
      final ctx = TestHeroContext();
      ctx['myID'] = HeroTargetState();
      ctx['myID'] = null;
      expect(ctx['myID'], isNull);
    });
  });

  // ====================================================================
  // HeroAnimationType structural tests
  // ====================================================================
  group('HeroAnimationType', () {
    test('reversed returns correct opposite type', () {
      expect(
        const HeroAnimationType.push(direction: HeroAnimationDirection.left)
            .reversed(),
        isA<HeroAnimationTypePull>(),
      );
      expect(
        const HeroAnimationType.zoom().reversed(),
        isA<HeroAnimationTypeZoomOut>(),
      );
      expect(
        const HeroAnimationType.fade().reversed(),
        isA<HeroAnimationTypeFade>(),
      );
      expect(
        const HeroAnimationType.none().reversed(),
        isA<HeroAnimationTypeNone>(),
      );
    });

    test('autoReverse creates selectBy with reversed dismissing', () {
      final result = HeroAnimationType.autoReverse(
        presenting:
            const HeroAnimationType.push(direction: HeroAnimationDirection.left),
      );

      expect(result, isA<HeroAnimationTypeSelectBy>());
      final selectBy = result as HeroAnimationTypeSelectBy;
      expect(selectBy.presenting, isA<HeroAnimationTypePush>());
      expect(selectBy.dismissing, isA<HeroAnimationTypePull>());
    });

    test('each type has a non-empty label', () {
      final types = <HeroAnimationType>[
        const HeroAnimationType.auto(),
        const HeroAnimationType.push(direction: HeroAnimationDirection.left),
        const HeroAnimationType.pull(direction: HeroAnimationDirection.right),
        const HeroAnimationType.cover(direction: HeroAnimationDirection.up),
        const HeroAnimationType.uncover(direction: HeroAnimationDirection.down),
        const HeroAnimationType.slide(direction: HeroAnimationDirection.left),
        const HeroAnimationType.zoomSlide(
            direction: HeroAnimationDirection.right),
        const HeroAnimationType.pageIn(direction: HeroAnimationDirection.left),
        const HeroAnimationType.pageOut(direction: HeroAnimationDirection.up),
        const HeroAnimationType.fade(),
        const HeroAnimationType.zoom(),
        const HeroAnimationType.zoomOut(),
        const HeroAnimationType.none(),
      ];

      for (final t in types) {
        expect(t.label, isNotEmpty, reason: '${t.runtimeType} should have a label');
      }
    });
  });

  // ====================================================================
  // CascadeDirection structural tests
  // ====================================================================
  group('CascadeDirection', () {
    test('topToBottom compares by ascending dy', () {
      const dir = CascadeDirection.topToBottom();
      expect(dir.compare(const Offset(0, 10), const Offset(0, 20)),
          lessThan(0));
      expect(dir.compare(const Offset(0, 20), const Offset(0, 10)),
          greaterThan(0));
    });

    test('bottomToTop compares by descending dy', () {
      const dir = CascadeDirection.bottomToTop();
      expect(dir.compare(const Offset(0, 10), const Offset(0, 20)),
          greaterThan(0));
    });

    test('leftToRight compares by ascending dx', () {
      const dir = CascadeDirection.leftToRight();
      expect(dir.compare(const Offset(10, 0), const Offset(20, 0)),
          lessThan(0));
    });

    test('rightToLeft compares by descending dx', () {
      const dir = CascadeDirection.rightToLeft();
      expect(dir.compare(const Offset(10, 0), const Offset(20, 0)),
          greaterThan(0));
    });

    test('radial compares by distance from center', () {
      const dir = CascadeDirection.radial(center: Offset.zero);
      // (10, 0) is closer to origin than (20, 0).
      expect(dir.compare(const Offset(10, 0), const Offset(20, 0)),
          lessThan(0));
    });

    test('inverseRadial compares by inverse distance from center', () {
      const dir = CascadeDirection.inverseRadial(center: Offset.zero);
      // (20, 0) is farther from origin, so should sort first in inverse.
      expect(dir.compare(const Offset(10, 0), const Offset(20, 0)),
          greaterThan(0));
    });
  });

  // ====================================================================
  // HeroModifier structural tests
  // ====================================================================
  group('HeroModifier', () {
    test('fade sets opacity to 0', () {
      final state = HeroTargetState();
      HeroModifier.fade.apply(state);
      expect(state.opacity, 0.0);
    });

    test('scale sets transform with scale', () {
      final state = HeroTargetState();
      HeroModifier.scale(2.0).apply(state);
      expect(state.transform, isNotNull);
      // Diagonal of a 2x uniform scale should be 2, 2, 1.
      final storage = state.transform!.storage;
      expect(storage[0], 2.0); // scaleX
      expect(storage[5], 2.0); // scaleY
    });

    test('translate sets transform with translation', () {
      final state = HeroTargetState();
      HeroModifier.translate(x: 100, y: 200).apply(state);
      expect(state.transform, isNotNull);
      expect(state.transform!.getTranslation().x, 100.0);
      expect(state.transform!.getTranslation().y, 200.0);
    });

    test('opacity sets state opacity', () {
      final state = HeroTargetState();
      HeroModifier.opacity(0.5).apply(state);
      expect(state.opacity, 0.5);
    });

    test('cornerRadius sets state cornerRadius', () {
      final state = HeroTargetState();
      HeroModifier.cornerRadius(16.0).apply(state);
      expect(state.cornerRadius, 16.0);
    });

    test('overlay sets color and opacity', () {
      final state = HeroTargetState();
      HeroModifier.overlay(
        color: const Color(0xFF000000),
        opacity: 0.3,
      ).apply(state);
      expect(state.overlay, isNotNull);
      expect(state.overlay!.color, const Color(0xFF000000));
      expect(state.overlay!.opacity, 0.3);
    });

    test('delay sets state delay', () {
      final state = HeroTargetState();
      HeroModifier.delay(const Duration(milliseconds: 100)).apply(state);
      expect(state.delay, const Duration(milliseconds: 100));
    });

    test('duration sets state duration', () {
      final state = HeroTargetState();
      HeroModifier.duration(const Duration(milliseconds: 500)).apply(state);
      expect(state.duration, const Duration(milliseconds: 500));
    });

    test('beginWith appends to beginState list', () {
      final state = HeroTargetState();
      HeroModifier.beginWith([HeroModifier.fade]).apply(state);
      expect(state.beginState, isNotNull);
      expect(state.beginState!.length, 1);

      // Apply again to verify it appends.
      HeroModifier.beginWith([HeroModifier.opacity(0.5)]).apply(state);
      expect(state.beginState!.length, 2);
    });

    test('source sets source heroID', () {
      final state = HeroTargetState();
      HeroModifier.source(heroID: 'other').apply(state);
      expect(state.source, 'other');
    });

    test('forceAnimate sets flag', () {
      final state = HeroTargetState();
      HeroModifier.forceAnimate.apply(state);
      expect(state.forceAnimate, isTrue);
    });

    test('useGlobalCoordinateSpace sets coordinateSpace', () {
      final state = HeroTargetState();
      HeroModifier.useGlobalCoordinateSpace.apply(state);
      expect(state.coordinateSpace, HeroCoordinateSpace.global);
    });

    test('cascade sets cascade config', () {
      final state = HeroTargetState();
      HeroModifier.cascade(
        delta: const Duration(milliseconds: 50),
        direction: const CascadeDirection.leftToRight(),
        delayMatchedViews: true,
      ).apply(state);
      expect(state.cascade, isNotNull);
      expect(state.cascade!.delta, const Duration(milliseconds: 50));
      expect(state.cascade!.delayMatchedViews, isTrue);
    });

    test('when stores conditional modifier entry', () {
      final state = HeroTargetState();
      HeroModifier.when(
        (c) => c.isMatched,
        [HeroModifier.fade],
      ).apply(state);
      expect(state.conditionalModifiers, isNotNull);
      expect(state.conditionalModifiers!.length, 1);
    });
  });
}
