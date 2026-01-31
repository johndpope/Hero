import 'package:flutter/material.dart';
import '../types/hero_animation_type.dart';
import 'hero_transition_engine.dart';

/// Custom page route that integrates with the Hero transition engine.
/// This replaces Flutter's default page transition.
///
/// Equivalent to configuring `hero.isEnabled` and `hero.modalAnimationType`
/// on an iOS UIViewController.
class HeroPageRoute<T> extends PageRoute<T> {
  /// Builder for the page content.
  final WidgetBuilder builder;

  /// The animation type for this transition.
  final HeroAnimationType animationType;

  /// Whether hero transitions are enabled for this route.
  final bool heroEnabled;

  /// Whether this route supports interactive (gesture-driven) transitions.
  final bool interactive;

  /// Optional background color during transition.
  final Color? transitionBackgroundColor;

  HeroPageRoute({
    required this.builder,
    this.animationType = const HeroAnimationType.auto(),
    this.heroEnabled = true,
    this.interactive = true,
    this.transitionBackgroundColor,
    super.settings,
    super.fullscreenDialog,
  });

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 375);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 375);

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Wrap child in an opaque background so the destination blocks the source
    // route from showing through when settled (opaque: false keeps source painted).
    final bg = transitionBackgroundColor ??
        Theme.of(context).scaffoldBackgroundColor;
    final opaqueChild = ColoredBox(color: bg, child: child);

    if (!heroEnabled) {
      return FadeTransition(opacity: animation, child: opaqueChild);
    }

    // Cross-fade routes during hero transitions to match iOS Hero behavior.
    // In iOS Hero, both view controllers cross-dissolve while the overlay
    // animates matched hero views on top. We replicate this using Flutter's
    // built-in route animations:
    //
    //   animation:          0→1 when this route enters, 1→0 when it exits
    //   secondaryAnimation: 0→1 when another route pushes on top of this one
    //
    // Combined effect:
    //   Destination route: fades in  (0→1) on push, fades out (1→0) on pop
    //   Source route:      fades out (1→0) on push, fades in  (0→1) on pop
    //
    // This eliminates ghosting where original hero views remain visible at
    // their source positions while overlay copies morph to the destination.
    final fadeOut = Tween<double>(begin: 1.0, end: 0.0)
        .animate(secondaryAnimation);

    return FadeTransition(
      opacity: animation,
      child: FadeTransition(
        opacity: fadeOut,
        child: opaqueChild,
      ),
    );
  }
}
