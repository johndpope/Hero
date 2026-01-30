import 'package:flutter/material.dart';
import '../types/hero_animation_type.dart';

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
  bool get opaque => true;

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
    // If hero is not enabled, use a simple fade transition
    if (!heroEnabled) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    }

    // The HeroTransitionEngine handles the actual animation.
    // We provide a transparent transition so the overlay can render
    // the animated views on top.
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return child;
      },
    );
  }
}
