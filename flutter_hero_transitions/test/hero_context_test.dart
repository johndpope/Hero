import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_hero_transitions/src/transition/hero_context.dart';
import 'package:flutter_hero_transitions/src/transition/hero_registry.dart';
import 'package:flutter_hero_transitions/src/types/hero_target_state.dart';
import 'package:flutter_hero_transitions/src/modifiers/hero_modifier.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds [GlobalKey]s for every ID in [ids] and returns a map from ID to key.
Map<String, GlobalKey> _buildKeys(List<String> ids) {
  return {for (final id in ids) id: GlobalKey(debugLabel: 'hero_$id')};
}

/// Creates a widget tree that contains *two* sets of keyed [SizedBox] widgets
/// laid out side-by-side in a [Row]. Both sets are alive at the same time so
/// their [RenderBox]es exist simultaneously -- which is necessary because
/// [HeroContext._processViews] calls [HeroRegistration.globalRect] during
/// construction.
Widget _buildDualApp({
  required Map<String, GlobalKey> srcKeys,
  required Map<String, GlobalKey> dstKeys,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Source column
          Column(
            children: [
              for (final entry in srcKeys.entries)
                SizedBox(key: entry.value, width: 100, height: 50),
            ],
          ),
          // Destination column
          Column(
            children: [
              for (final entry in dstKeys.entries)
                SizedBox(key: entry.value, width: 100, height: 50),
            ],
          ),
        ],
      ),
    ),
  );
}

/// Creates a widget tree with a single set of keyed widgets.
Widget _buildSingleApp(Map<String, GlobalKey> keys) {
  return MaterialApp(
    home: Scaffold(
      body: Column(
        children: [
          for (final entry in keys.entries)
            SizedBox(key: entry.value, width: 100, height: 50),
        ],
      ),
    ),
  );
}

/// Creates [HeroRegistration] instances from a key map. Each registration uses
/// the [BuildContext] from its own [GlobalKey].
List<HeroRegistration> _registrations(Map<String, GlobalKey> keys) {
  return keys.entries.map((e) {
    return HeroRegistration(
      id: e.key,
      globalKey: e.value,
      context: e.value.currentContext!,
    );
  }).toList();
}

/// Convenience: pump a dual widget tree, build registrations, and construct a
/// [HeroContext] in one shot.
Future<_PreparedContext> _prepare(
  WidgetTester tester, {
  required List<String> srcIDs,
  required List<String> dstIDs,
}) async {
  final srcKeys = _buildKeys(srcIDs);
  final dstKeys = _buildKeys(dstIDs);

  await tester.pumpWidget(_buildDualApp(srcKeys: srcKeys, dstKeys: dstKeys));
  await tester.pumpAndSettle();

  final srcRegs = _registrations(srcKeys);
  final dstRegs = _registrations(dstKeys);

  final heroCtx = HeroContext(
    containerSize: tester.view.physicalSize / tester.view.devicePixelRatio,
    fromViews: srcRegs,
    toViews: dstRegs,
  );

  return _PreparedContext(
    heroCtx: heroCtx,
    srcRegs: srcRegs,
    dstRegs: dstRegs,
    srcKeys: srcKeys,
    dstKeys: dstKeys,
  );
}

class _PreparedContext {
  final HeroContext heroCtx;
  final List<HeroRegistration> srcRegs;
  final List<HeroRegistration> dstRegs;
  final Map<String, GlobalKey> srcKeys;
  final Map<String, GlobalKey> dstKeys;

  _PreparedContext({
    required this.heroCtx,
    required this.srcRegs,
    required this.dstRegs,
    required this.srcKeys,
    required this.dstKeys,
  });
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ================================================================
  // GROUP 1 -- Construction & matchedIDs
  // ================================================================
  group('Construction and matchedIDs', () {
    testWidgets('matchedIDs returns IDs present in both source and destination',
        (tester) async {
      final p = await _prepare(
        tester,
        srcIDs: ['alpha', 'beta', 'gamma'],
        dstIDs: ['beta', 'gamma', 'delta'],
      );

      expect(p.heroCtx.matchedIDs, equals({'beta', 'gamma'}));
    });

    testWidgets('matchedIDs is empty when no IDs overlap', (tester) async {
      final p = await _prepare(
        tester,
        srcIDs: ['a', 'b'],
        dstIDs: ['c', 'd'],
      );

      expect(p.heroCtx.matchedIDs, isEmpty);
    });

    testWidgets('matchedIDs contains all IDs when sets are identical',
        (tester) async {
      final p = await _prepare(
        tester,
        srcIDs: ['x', 'y'],
        dstIDs: ['x', 'y'],
      );

      expect(p.heroCtx.matchedIDs, equals({'x', 'y'}));
    });

    testWidgets('constructs successfully with empty lists', (tester) async {
      // No widgets to pump; just pass empty lists.
      final heroCtx = HeroContext(
        containerSize: const Size(800, 600),
        fromViews: [],
        toViews: [],
      );

      expect(heroCtx.matchedIDs, isEmpty);
      expect(heroCtx.sourceIDs, isEmpty);
      expect(heroCtx.destIDs, isEmpty);
    });
  });

  // ================================================================
  // GROUP 2 -- unmatchedSourceIDs
  // ================================================================
  group('unmatchedSourceIDs', () {
    testWidgets('returns IDs only in source', (tester) async {
      final p = await _prepare(
        tester,
        srcIDs: ['s1', 's2', 'shared'],
        dstIDs: ['shared', 'd1'],
      );

      expect(p.heroCtx.unmatchedSourceIDs, equals({'s1', 's2'}));
    });

    testWidgets('is empty when all source IDs are also in destination',
        (tester) async {
      final p = await _prepare(
        tester,
        srcIDs: ['a'],
        dstIDs: ['a', 'b'],
      );

      expect(p.heroCtx.unmatchedSourceIDs, isEmpty);
    });

    testWidgets('equals sourceIDs when destination is empty', (tester) async {
      final keys = _buildKeys(['p', 'q']);
      await tester.pumpWidget(_buildSingleApp(keys));
      await tester.pumpAndSettle();

      final heroCtx = HeroContext(
        containerSize: tester.view.physicalSize / tester.view.devicePixelRatio,
        fromViews: _registrations(keys),
        toViews: [],
      );

      expect(heroCtx.unmatchedSourceIDs, equals({'p', 'q'}));
    });
  });

  // ================================================================
  // GROUP 3 -- unmatchedDestIDs
  // ================================================================
  group('unmatchedDestIDs', () {
    testWidgets('returns IDs only in destination', (tester) async {
      final p = await _prepare(
        tester,
        srcIDs: ['shared'],
        dstIDs: ['shared', 'd1', 'd2'],
      );

      expect(p.heroCtx.unmatchedDestIDs, equals({'d1', 'd2'}));
    });

    testWidgets('is empty when all dest IDs are also in source',
        (tester) async {
      final p = await _prepare(
        tester,
        srcIDs: ['a', 'b'],
        dstIDs: ['a'],
      );

      expect(p.heroCtx.unmatchedDestIDs, isEmpty);
    });

    testWidgets('equals destIDs when source is empty', (tester) async {
      final keys = _buildKeys(['r', 's']);
      await tester.pumpWidget(_buildSingleApp(keys));
      await tester.pumpAndSettle();

      final heroCtx = HeroContext(
        containerSize: tester.view.physicalSize / tester.view.devicePixelRatio,
        fromViews: [],
        toViews: _registrations(keys),
      );

      expect(heroCtx.unmatchedDestIDs, equals({'r', 's'}));
    });
  });

  // ================================================================
  // GROUP 4 -- sourceView / destinationView
  // ================================================================
  group('sourceView and destinationView', () {
    testWidgets('sourceView returns registration for a source ID',
        (tester) async {
      final p = await _prepare(
        tester,
        srcIDs: ['hero1'],
        dstIDs: ['hero1'],
      );

      expect(p.heroCtx.sourceView('hero1'), isNotNull);
      expect(p.heroCtx.sourceView('hero1')!.id, equals('hero1'));
    });

    testWidgets('destinationView returns registration for a dest ID',
        (tester) async {
      final p = await _prepare(
        tester,
        srcIDs: ['hero1'],
        dstIDs: ['hero1'],
      );

      expect(p.heroCtx.destinationView('hero1'), isNotNull);
      expect(p.heroCtx.destinationView('hero1')!.id, equals('hero1'));
    });

    testWidgets('sourceView and destinationView return different objects',
        (tester) async {
      final p = await _prepare(
        tester,
        srcIDs: ['hero1'],
        dstIDs: ['hero1'],
      );

      final src = p.heroCtx.sourceView('hero1');
      final dst = p.heroCtx.destinationView('hero1');

      expect(src, isNotNull);
      expect(dst, isNotNull);
      // They share the same ID but are different registration objects.
      expect(identical(src, dst), isFalse);
    });

    testWidgets('returns null for unknown ID', (tester) async {
      final p = await _prepare(
        tester,
        srcIDs: ['a'],
        dstIDs: ['b'],
      );

      expect(p.heroCtx.sourceView('unknown'), isNull);
      expect(p.heroCtx.destinationView('unknown'), isNull);
    });

    testWidgets('sourceView returns null for a dest-only ID', (tester) async {
      final p = await _prepare(
        tester,
        srcIDs: ['onlySrc'],
        dstIDs: ['onlyDst'],
      );

      expect(p.heroCtx.sourceView('onlyDst'), isNull);
    });

    testWidgets('destinationView returns null for a src-only ID',
        (tester) async {
      final p = await _prepare(
        tester,
        srcIDs: ['onlySrc'],
        dstIDs: ['onlyDst'],
      );

      expect(p.heroCtx.destinationView('onlySrc'), isNull);
    });
  });

  // ================================================================
  // GROUP 5 -- pairedView
  // ================================================================
  group('pairedView', () {
    testWidgets(
        'pairedView of a source registration returns destination registration',
        (tester) async {
      final p = await _prepare(
        tester,
        srcIDs: ['hero1'],
        dstIDs: ['hero1'],
      );

      final srcReg = p.heroCtx.sourceView('hero1')!;
      final dstReg = p.heroCtx.destinationView('hero1')!;

      expect(p.heroCtx.pairedView(srcReg), same(dstReg));
    });

    testWidgets(
        'pairedView of a destination registration returns source registration',
        (tester) async {
      final p = await _prepare(
        tester,
        srcIDs: ['hero1'],
        dstIDs: ['hero1'],
      );

      final srcReg = p.heroCtx.sourceView('hero1')!;
      final dstReg = p.heroCtx.destinationView('hero1')!;

      expect(p.heroCtx.pairedView(dstReg), same(srcReg));
    });

    testWidgets('pairedView returns null for an unmatched source registration',
        (tester) async {
      final p = await _prepare(
        tester,
        srcIDs: ['onlySource'],
        dstIDs: ['onlyDest'],
      );

      final srcReg = p.heroCtx.sourceView('onlySource')!;
      expect(p.heroCtx.pairedView(srcReg), isNull);
    });

    testWidgets('pairedView returns null for an unmatched dest registration',
        (tester) async {
      final p = await _prepare(
        tester,
        srcIDs: ['onlySource'],
        dstIDs: ['onlyDest'],
      );

      final dstReg = p.heroCtx.destinationView('onlyDest')!;
      expect(p.heroCtx.pairedView(dstReg), isNull);
    });

    testWidgets(
        'pairedView returns null for a registration not in this context',
        (tester) async {
      final p = await _prepare(
        tester,
        srcIDs: ['a'],
        dstIDs: ['a'],
      );

      // Create an unrelated registration with the same ID but a different
      // object identity.
      final strayKey = GlobalKey(debugLabel: 'stray_a');
      // We need a live BuildContext for the stray registration. Build a
      // separate widget just for this purpose.
      final strayKeys = {'a': strayKey};
      await tester.pumpWidget(_buildSingleApp(strayKeys));
      await tester.pumpAndSettle();
      final strayReg = HeroRegistration(
        id: 'a',
        globalKey: strayKey,
        context: strayKey.currentContext!,
      );

      // The context was rebuilt so p.heroCtx's internal maps still hold the old
      // registrations. The stray is a completely different object.
      expect(p.heroCtx.pairedView(strayReg), isNull);
    });
  });

  // ================================================================
  // GROUP 6 -- Target state management (operator []/[]=)
  // ================================================================
  group('Target state management', () {
    testWidgets('operator[] returns null for unset hero ID', (tester) async {
      final heroCtx = HeroContext(
        containerSize: const Size(800, 600),
        fromViews: [],
        toViews: [],
      );

      expect(heroCtx['anyID'], isNull);
    });

    testWidgets('operator[]= stores and retrieves a target state',
        (tester) async {
      final heroCtx = HeroContext(
        containerSize: const Size(800, 600),
        fromViews: [],
        toViews: [],
      );

      final state = HeroTargetState()..opacity = 0.5;
      heroCtx['h'] = state;

      expect(heroCtx['h'], same(state));
      expect(heroCtx['h']!.opacity, equals(0.5));
    });

    testWidgets('operator[]= with null removes the target state',
        (tester) async {
      final heroCtx = HeroContext(
        containerSize: const Size(800, 600),
        fromViews: [],
        toViews: [],
      );

      heroCtx['h'] = HeroTargetState();
      expect(heroCtx['h'], isNotNull);

      heroCtx['h'] = null;
      expect(heroCtx['h'], isNull);
    });

    testWidgets('targetStateFor creates a state if absent', (tester) async {
      final heroCtx = HeroContext(
        containerSize: const Size(800, 600),
        fromViews: [],
        toViews: [],
      );

      expect(heroCtx['newID'], isNull);
      final created = heroCtx.targetStateFor('newID');
      expect(created, isA<HeroTargetState>());
      // Subsequent call returns the same instance.
      expect(heroCtx.targetStateFor('newID'), same(created));
      // Also accessible via operator[].
      expect(heroCtx['newID'], same(created));
    });

    testWidgets('targetStateFor returns existing state if already set',
        (tester) async {
      final heroCtx = HeroContext(
        containerSize: const Size(800, 600),
        fromViews: [],
        toViews: [],
      );

      final preset = HeroTargetState()..opacity = 0.42;
      heroCtx['existingID'] = preset;

      final fetched = heroCtx.targetStateFor('existingID');
      expect(fetched, same(preset));
    });

    testWidgets('different hero IDs have independent target states',
        (tester) async {
      final heroCtx = HeroContext(
        containerSize: const Size(800, 600),
        fromViews: [],
        toViews: [],
      );

      heroCtx['a'] = HeroTargetState()..opacity = 0.1;
      heroCtx['b'] = HeroTargetState()..opacity = 0.9;

      expect(heroCtx['a']!.opacity, equals(0.1));
      expect(heroCtx['b']!.opacity, equals(0.9));
    });
  });

  // ================================================================
  // GROUP 7 -- applyModifiers
  // ================================================================
  group('applyModifiers', () {
    testWidgets('applies a single modifier to the target state',
        (tester) async {
      final heroCtx = HeroContext(
        containerSize: const Size(800, 600),
        fromViews: [],
        toViews: [],
      );

      heroCtx.applyModifiers('m1', [HeroModifier.fade]);

      final state = heroCtx['m1']!;
      expect(state.opacity, equals(0.0));
    });

    testWidgets('applies multiple modifiers in order', (tester) async {
      final heroCtx = HeroContext(
        containerSize: const Size(800, 600),
        fromViews: [],
        toViews: [],
      );

      heroCtx.applyModifiers('m1', [
        HeroModifier.opacity(0.8),
        HeroModifier.position(const Offset(10, 20)),
        HeroModifier.size(const Size(200, 300)),
        HeroModifier.cornerRadius(12.0),
      ]);

      final state = heroCtx['m1']!;
      expect(state.opacity, equals(0.8));
      expect(state.position, equals(const Offset(10, 20)));
      expect(state.size, equals(const Size(200, 300)));
      expect(state.cornerRadius, equals(12.0));
    });

    testWidgets('later modifiers overwrite earlier ones for the same field',
        (tester) async {
      final heroCtx = HeroContext(
        containerSize: const Size(800, 600),
        fromViews: [],
        toViews: [],
      );

      heroCtx.applyModifiers('m1', [
        HeroModifier.opacity(0.1),
        HeroModifier.opacity(0.9), // should win
      ]);

      expect(heroCtx['m1']!.opacity, equals(0.9));
    });

    testWidgets('applyModifiers with empty list still creates a target state',
        (tester) async {
      final heroCtx = HeroContext(
        containerSize: const Size(800, 600),
        fromViews: [],
        toViews: [],
      );

      heroCtx.applyModifiers('m1', []);

      // targetStateFor is called internally, so a state should exist.
      expect(heroCtx['m1'], isNotNull);
    });

    testWidgets(
        'applyModifiers for a hero ID not in any registration still works',
        (tester) async {
      final keys = _buildKeys(['a']);
      await tester.pumpWidget(_buildSingleApp(keys));
      await tester.pumpAndSettle();

      final heroCtx = HeroContext(
        containerSize: const Size(800, 600),
        fromViews: _registrations(keys),
        toViews: [],
      );

      // 'zzz' is not registered, but applyModifiers should not throw.
      heroCtx.applyModifiers('zzz', [HeroModifier.fade]);
      expect(heroCtx['zzz']!.opacity, equals(0.0));
    });

    testWidgets('applyModifiers accumulates across multiple calls',
        (tester) async {
      final heroCtx = HeroContext(
        containerSize: const Size(800, 600),
        fromViews: [],
        toViews: [],
      );

      heroCtx.applyModifiers('m1', [HeroModifier.opacity(0.5)]);
      heroCtx.applyModifiers('m1', [HeroModifier.cornerRadius(8.0)]);

      final state = heroCtx['m1']!;
      expect(state.opacity, equals(0.5));
      expect(state.cornerRadius, equals(8.0));
    });

    testWidgets('multiple modifier kinds compose correctly', (tester) async {
      final heroCtx = HeroContext(
        containerSize: const Size(800, 600),
        fromViews: [],
        toViews: [],
      );

      heroCtx.applyModifiers('compose', [
        HeroModifier.fade,
        HeroModifier.forceAnimate,
        HeroModifier.cornerRadius(8.0),
        HeroModifier.backgroundColor(const Color(0xFFFF0000)),
        HeroModifier.delay(const Duration(milliseconds: 100)),
        HeroModifier.spring(stiffness: 300, damping: 30),
      ]);

      final state = heroCtx['compose']!;
      expect(state.opacity, equals(0.0));
      expect(state.forceAnimate, isTrue);
      expect(state.cornerRadius, equals(8.0));
      expect(state.backgroundColor, equals(const Color(0xFFFF0000)));
      expect(state.delay, equals(const Duration(milliseconds: 100)));
      expect(state.spring, isNotNull);
      expect(state.spring!.stiffness, equals(300));
      expect(state.spring!.damping, equals(30));
    });
  });

  // ================================================================
  // GROUP 8 -- sourceRect / destRect
  // ================================================================
  group('sourceRect and destRect', () {
    testWidgets('sourceRect returns non-null rect for registered source view',
        (tester) async {
      final keys = _buildKeys(['r1']);
      await tester.pumpWidget(_buildSingleApp(keys));
      await tester.pumpAndSettle();

      final heroCtx = HeroContext(
        containerSize: tester.view.physicalSize / tester.view.devicePixelRatio,
        fromViews: _registrations(keys),
        toViews: [],
      );

      final rect = heroCtx.sourceRect('r1');
      expect(rect, isNotNull);
      expect(rect!.width, equals(100.0));
      expect(rect.height, equals(50.0));
    });

    testWidgets('destRect returns non-null rect for registered dest view',
        (tester) async {
      final keys = _buildKeys(['r1']);
      await tester.pumpWidget(_buildSingleApp(keys));
      await tester.pumpAndSettle();

      final heroCtx = HeroContext(
        containerSize: tester.view.physicalSize / tester.view.devicePixelRatio,
        fromViews: [],
        toViews: _registrations(keys),
      );

      final rect = heroCtx.destRect('r1');
      expect(rect, isNotNull);
      expect(rect!.width, equals(100.0));
      expect(rect.height, equals(50.0));
    });

    testWidgets('sourceRect and destRect return null for unknown ID',
        (tester) async {
      final heroCtx = HeroContext(
        containerSize: const Size(800, 600),
        fromViews: [],
        toViews: [],
      );

      expect(heroCtx.sourceRect('missing'), isNull);
      expect(heroCtx.destRect('missing'), isNull);
    });
  });

  // ================================================================
  // GROUP 9 -- Convenience ID accessors (sourceIDs, destIDs, allIDs, isMatched)
  // ================================================================
  group('Convenience ID accessors', () {
    testWidgets('sourceIDs returns all source hero IDs', (tester) async {
      final p = await _prepare(
        tester,
        srcIDs: ['a', 'b', 'c'],
        dstIDs: ['b', 'd'],
      );

      expect(p.heroCtx.sourceIDs, equals({'a', 'b', 'c'}));
    });

    testWidgets('destIDs returns all destination hero IDs', (tester) async {
      final p = await _prepare(
        tester,
        srcIDs: ['a', 'b', 'c'],
        dstIDs: ['b', 'd'],
      );

      expect(p.heroCtx.destIDs, equals({'b', 'd'}));
    });

    testWidgets('allIDs returns union of source and destination',
        (tester) async {
      final p = await _prepare(
        tester,
        srcIDs: ['a', 'b'],
        dstIDs: ['b', 'c'],
      );

      expect(p.heroCtx.allIDs, equals({'a', 'b', 'c'}));
    });

    testWidgets('isMatched returns true for matched, false for unmatched',
        (tester) async {
      final p = await _prepare(
        tester,
        srcIDs: ['shared', 'onlySrc'],
        dstIDs: ['shared', 'onlyDst'],
      );

      expect(p.heroCtx.isMatched('shared'), isTrue);
      expect(p.heroCtx.isMatched('onlySrc'), isFalse);
      expect(p.heroCtx.isMatched('onlyDst'), isFalse);
      expect(p.heroCtx.isMatched('nonexistent'), isFalse);
    });
  });

  // ================================================================
  // GROUP 10 -- Edge cases
  // ================================================================
  group('Edge cases', () {
    testWidgets('empty source and destination lists produce empty sets',
        (tester) async {
      final heroCtx = HeroContext(
        containerSize: const Size(800, 600),
        fromViews: [],
        toViews: [],
      );

      expect(heroCtx.matchedIDs, isEmpty);
      expect(heroCtx.unmatchedSourceIDs, isEmpty);
      expect(heroCtx.unmatchedDestIDs, isEmpty);
      expect(heroCtx.sourceIDs, isEmpty);
      expect(heroCtx.destIDs, isEmpty);
      expect(heroCtx.allIDs, isEmpty);
    });

    testWidgets('containerSize is stored correctly', (tester) async {
      const size = Size(1920, 1080);
      final heroCtx = HeroContext(
        containerSize: size,
        fromViews: [],
        toViews: [],
      );

      expect(heroCtx.containerSize, equals(size));
    });

    testWidgets('fromViews and toViews lists are accessible', (tester) async {
      final keys = _buildKeys(['v']);
      await tester.pumpWidget(_buildSingleApp(keys));
      await tester.pumpAndSettle();

      final regs = _registrations(keys);
      final heroCtx = HeroContext(
        containerSize: const Size(800, 600),
        fromViews: regs,
        toViews: [],
      );

      expect(heroCtx.fromViews, same(regs));
      expect(heroCtx.toViews, isEmpty);
    });
  });
}
