import 'package:flutter/widgets.dart';
import 'hero_transition_engine.dart';
import 'hero_page_route.dart';

/// Navigator observer that intercepts route changes and triggers
/// the Hero transition engine.
///
/// Add this to your MaterialApp's `navigatorObservers` list.
///
/// Example:
/// ```dart
/// MaterialApp(
///   navigatorObservers: [HeroTransitionObserver()],
///   ...
/// )
/// ```
class HeroTransitionObserver extends NavigatorObserver {
  final HeroTransitionEngine engine;

  HeroTransitionObserver({HeroTransitionEngine? engine})
      : engine = engine ?? HeroTransitionEngine.shared;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is HeroPageRoute && route.heroEnabled) {
      // Tell the previous route what animation type is covering it,
      // so it can animate its secondary (being-covered) transition correctly.
      if (previousRoute is HeroPageRoute) {
        previousRoute.setCoveredByType(route.animationType);
      }
      engine.notifyTransition(
        fromRoute: previousRoute,
        toRoute: route,
        isPresenting: true,
        animationType: route.animationType,
      );
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is HeroPageRoute && route.heroEnabled) {
      engine.notifyTransition(
        fromRoute: route,
        toRoute: previousRoute,
        isPresenting: false,
        animationType: route.animationType,
      );
    } else if (previousRoute is HeroPageRoute && previousRoute.heroEnabled) {
      engine.notifyTransition(
        fromRoute: route,
        toRoute: previousRoute,
        isPresenting: false,
        animationType: previousRoute.animationType,
      );
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute is HeroPageRoute && newRoute.heroEnabled) {
      engine.notifyTransition(
        fromRoute: oldRoute,
        toRoute: newRoute,
        isPresenting: true,
        animationType: newRoute.animationType,
      );
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // No animation for remove
  }
}
