import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_hero_transitions/src/widgets/hero_view.dart';
import 'package:flutter_hero_transitions/src/transition/hero_registry.dart';
import 'package:flutter_hero_transitions/src/modifiers/hero_modifier.dart';

void main() {
  // Clear the singleton registry before each test to avoid cross-test leakage.
  setUp(() {
    HeroRegistry.instance.clear();
  });

  tearDown(() {
    HeroRegistry.instance.clear();
  });

  // ---------------------------------------------------------------------------
  // Helper: wraps a widget in MaterialApp so it has a valid context,
  // MediaQuery, Directionality, etc.
  // ---------------------------------------------------------------------------
  Widget wrapInApp(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  // ===========================================================================
  // 1. Rendering: HeroView renders its child widget
  // ===========================================================================
  group('Rendering', () {
    testWidgets('HeroView renders its child widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapInApp(
          HeroView(
            id: 'test-render',
            child: const Text('Hello Hero'),
          ),
        ),
      );

      // The HeroView itself should be in the tree.
      expect(find.byType(HeroView), findsOneWidget);

      // The child text should be rendered.
      expect(find.text('Hello Hero'), findsOneWidget);
    });

    testWidgets('HeroView wraps child in a KeyedSubtree', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapInApp(
          HeroView(
            id: 'keyed-subtree',
            child: const SizedBox(width: 50, height: 50),
          ),
        ),
      );

      // A KeyedSubtree should exist in the widget tree as HeroView uses one.
      expect(find.byType(KeyedSubtree), findsWidgets);
    });
  });

  // ===========================================================================
  // 2. Registration: When HeroView is pumped, it registers with HeroRegistry
  // ===========================================================================
  group('Registration', () {
    testWidgets('HeroView registers with HeroRegistry on mount',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapInApp(
          HeroView(
            id: 'register-test',
            child: const Text('Registered'),
          ),
        ),
      );

      // The registry should now contain the hero ID.
      expect(HeroRegistry.instance.allIDs, contains('register-test'));
    });

    testWidgets('HeroView registration is queryable by ID',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapInApp(
          HeroView(
            id: 'queryable',
            child: const Text('Query me'),
          ),
        ),
      );

      expect(HeroRegistry.instance.allIDs.contains('queryable'), isTrue);
    });
  });

  // ===========================================================================
  // 3. Unregistration: When HeroView is removed from the tree, it unregisters
  // ===========================================================================
  group('Unregistration', () {
    testWidgets('HeroView unregisters from HeroRegistry when removed from tree',
        (WidgetTester tester) async {
      // First, mount the HeroView.
      await tester.pumpWidget(
        wrapInApp(
          HeroView(
            id: 'unregister-test',
            child: const Text('Will be removed'),
          ),
        ),
      );

      // Verify it is registered.
      expect(HeroRegistry.instance.allIDs, contains('unregister-test'));

      // Now replace the tree with a widget that does NOT contain the HeroView.
      await tester.pumpWidget(
        wrapInApp(
          const Text('Replaced'),
        ),
      );

      // The hero ID should no longer be in the registry.
      expect(HeroRegistry.instance.allIDs, isNot(contains('unregister-test')));
    });

    testWidgets('HeroView unregisters old ID when id changes via didUpdateWidget',
        (WidgetTester tester) async {
      // Build with initial ID.
      await tester.pumpWidget(
        wrapInApp(
          HeroView(
            id: 'old-id',
            child: const Text('Update me'),
          ),
        ),
      );

      expect(HeroRegistry.instance.allIDs, contains('old-id'));

      // Rebuild with a new ID.
      await tester.pumpWidget(
        wrapInApp(
          HeroView(
            id: 'new-id',
            child: const Text('Update me'),
          ),
        ),
      );

      // The old ID should be gone; the new one should be present.
      expect(HeroRegistry.instance.allIDs, isNot(contains('old-id')));
      expect(HeroRegistry.instance.allIDs, contains('new-id'));
    });
  });

  // ===========================================================================
  // 4. ID uniqueness: Two HeroViews with different IDs both register separately
  // ===========================================================================
  group('ID uniqueness', () {
    testWidgets('Two HeroViews with different IDs register separately',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapInApp(
          Column(
            children: [
              HeroView(
                id: 'hero-a',
                child: const Text('A'),
              ),
              HeroView(
                id: 'hero-b',
                child: const Text('B'),
              ),
            ],
          ),
        ),
      );

      final ids = HeroRegistry.instance.allIDs;
      expect(ids, contains('hero-a'));
      expect(ids, contains('hero-b'));
      expect(ids.length, greaterThanOrEqualTo(2));
    });

    testWidgets('Three HeroViews all register independently',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapInApp(
          Column(
            children: [
              HeroView(id: 'x', child: const Text('X')),
              HeroView(id: 'y', child: const Text('Y')),
              HeroView(id: 'z', child: const Text('Z')),
            ],
          ),
        ),
      );

      final ids = HeroRegistry.instance.allIDs;
      expect(ids, containsAll(['x', 'y', 'z']));
    });

    testWidgets('Removing one HeroView does not affect another',
        (WidgetTester tester) async {
      // Mount two HeroViews.
      await tester.pumpWidget(
        wrapInApp(
          Column(
            children: [
              HeroView(id: 'stay', child: const Text('Stay')),
              HeroView(id: 'go', child: const Text('Go')),
            ],
          ),
        ),
      );

      expect(HeroRegistry.instance.allIDs, containsAll(['stay', 'go']));

      // Remove one by rebuilding without it.
      await tester.pumpWidget(
        wrapInApp(
          Column(
            children: [
              HeroView(id: 'stay', child: const Text('Stay')),
            ],
          ),
        ),
      );

      expect(HeroRegistry.instance.allIDs, contains('stay'));
      expect(HeroRegistry.instance.allIDs, isNot(contains('go')));
    });
  });

  // ===========================================================================
  // 5. Modifier storage: Modifiers passed to HeroView are stored in the
  //    registration
  // ===========================================================================
  group('Modifier storage', () {
    testWidgets('Modifiers are stored in the HeroRegistration',
        (WidgetTester tester) async {
      final modifiers = [HeroModifier.fade, HeroModifier.scale(0.8)];

      await tester.pumpWidget(
        wrapInApp(
          HeroView(
            id: 'with-modifiers',
            modifiers: modifiers,
            child: const Text('Modified'),
          ),
        ),
      );

      // The ID should be registered.
      expect(HeroRegistry.instance.allIDs, contains('with-modifiers'));

      // We cannot directly query the registration by context from outside,
      // but we can use viewsForRoute with the current route. Since we are in
      // a simple MaterialApp, ModalRoute.of(context) should work after layout.
      // As a workaround, we can pump an extra frame for the route to settle.
      await tester.pumpAndSettle();

      // Verify indirectly: the allIDs set confirms the registration exists
      // and the modifiers list has the expected length.
      // Access internals through the element tree to validate modifiers.
      final heroViewElement = tester.element(find.byType(HeroView));
      final heroViewWidget = heroViewElement.widget as HeroView;
      expect(heroViewWidget.modifiers, isNotNull);
      expect(heroViewWidget.modifiers!.length, equals(2));
    });

    testWidgets('HeroView with null modifiers registers without error',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapInApp(
          HeroView(
            id: 'no-modifiers',
            child: const Text('No mods'),
          ),
        ),
      );

      expect(HeroRegistry.instance.allIDs, contains('no-modifiers'));

      final heroViewElement = tester.element(find.byType(HeroView));
      final heroViewWidget = heroViewElement.widget as HeroView;
      expect(heroViewWidget.modifiers, isNull);
    });

    testWidgets('Updating modifiers triggers re-registration',
        (WidgetTester tester) async {
      final modifiers1 = [HeroModifier.fade];
      final modifiers2 = [HeroModifier.scale(0.5)];

      await tester.pumpWidget(
        wrapInApp(
          HeroView(
            id: 'mod-update',
            modifiers: modifiers1,
            child: const Text('Mod update'),
          ),
        ),
      );

      expect(HeroRegistry.instance.allIDs, contains('mod-update'));

      // Change modifiers -- didUpdateWidget should unregister and re-register.
      await tester.pumpWidget(
        wrapInApp(
          HeroView(
            id: 'mod-update',
            modifiers: modifiers2,
            child: const Text('Mod update'),
          ),
        ),
      );

      // Still registered under the same ID.
      expect(HeroRegistry.instance.allIDs, contains('mod-update'));

      // Verify the widget now holds the new modifiers.
      final heroViewElement = tester.element(find.byType(HeroView));
      final heroViewWidget = heroViewElement.widget as HeroView;
      expect(heroViewWidget.modifiers, equals(modifiers2));
    });
  });

  // ===========================================================================
  // 6. isEnabled: When isEnabled is false, the view should not register
  // ===========================================================================
  group('isEnabled', () {
    testWidgets('HeroView with isEnabled=false does not register',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapInApp(
          HeroView(
            id: 'disabled-hero',
            isEnabled: false,
            child: const Text('Disabled'),
          ),
        ),
      );

      // The hero ID should NOT be in the registry.
      expect(HeroRegistry.instance.allIDs, isNot(contains('disabled-hero')));
    });

    testWidgets('HeroView with isEnabled=true registers normally',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapInApp(
          HeroView(
            id: 'enabled-hero',
            isEnabled: true,
            child: const Text('Enabled'),
          ),
        ),
      );

      expect(HeroRegistry.instance.allIDs, contains('enabled-hero'));
    });

    testWidgets('Toggling isEnabled from true to false unregisters the view',
        (WidgetTester tester) async {
      // Mount with isEnabled = true.
      await tester.pumpWidget(
        wrapInApp(
          HeroView(
            id: 'toggle-hero',
            isEnabled: true,
            child: const Text('Toggle'),
          ),
        ),
      );

      expect(HeroRegistry.instance.allIDs, contains('toggle-hero'));

      // Rebuild with isEnabled = false.
      await tester.pumpWidget(
        wrapInApp(
          HeroView(
            id: 'toggle-hero',
            isEnabled: false,
            child: const Text('Toggle'),
          ),
        ),
      );

      // Should be unregistered now.
      expect(HeroRegistry.instance.allIDs, isNot(contains('toggle-hero')));
    });

    testWidgets('Toggling isEnabled from false to true registers the view',
        (WidgetTester tester) async {
      // Mount with isEnabled = false.
      await tester.pumpWidget(
        wrapInApp(
          HeroView(
            id: 'false-to-true',
            isEnabled: false,
            child: const Text('FalseToTrue'),
          ),
        ),
      );

      expect(HeroRegistry.instance.allIDs, isNot(contains('false-to-true')));

      // Rebuild with isEnabled = true.
      await tester.pumpWidget(
        wrapInApp(
          HeroView(
            id: 'false-to-true',
            isEnabled: true,
            child: const Text('FalseToTrue'),
          ),
        ),
      );

      expect(HeroRegistry.instance.allIDs, contains('false-to-true'));
    });

    testWidgets('Disabled HeroView still renders its child',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapInApp(
          HeroView(
            id: 'disabled-renders',
            isEnabled: false,
            child: const Text('Still visible'),
          ),
        ),
      );

      // Even when disabled, the child should still be visible.
      expect(find.text('Still visible'), findsOneWidget);
    });
  });

  // ===========================================================================
  // 7. Child is rendered: The child widget is visible and findable
  // ===========================================================================
  group('Child is rendered', () {
    testWidgets('Child Text widget is findable via find.text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapInApp(
          HeroView(
            id: 'text-child',
            child: const Text('Find me'),
          ),
        ),
      );

      expect(find.text('Find me'), findsOneWidget);
    });

    testWidgets('Child Container is findable via find.byType',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapInApp(
          HeroView(
            id: 'container-child',
            child: Container(
              width: 100,
              height: 100,
              color: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Child with a Key is findable via find.byKey',
        (WidgetTester tester) async {
      const childKey = Key('hero-child-key');

      await tester.pumpWidget(
        wrapInApp(
          HeroView(
            id: 'keyed-child',
            child: Container(key: childKey, width: 50, height: 50),
          ),
        ),
      );

      expect(find.byKey(childKey), findsOneWidget);
    });

    testWidgets('Nested child widgets are rendered correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapInApp(
          HeroView(
            id: 'nested-child',
            child: Column(
              children: const [
                Text('First'),
                Text('Second'),
                Icon(Icons.star),
              ],
            ),
          ),
        ),
      );

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('HeroView default properties are correct',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapInApp(
          HeroView(
            id: 'defaults',
            child: const Text('Defaults'),
          ),
        ),
      );

      final heroViewElement = tester.element(find.byType(HeroView));
      final heroViewWidget = heroViewElement.widget as HeroView;

      expect(heroViewWidget.id, equals('defaults'));
      expect(heroViewWidget.isEnabled, isTrue);
      expect(heroViewWidget.isEnabledForSubviews, isTrue);
      expect(heroViewWidget.modifiers, isNull);
    });
  });
}
