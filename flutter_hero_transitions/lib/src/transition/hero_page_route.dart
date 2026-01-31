import 'package:flutter/material.dart';
import '../types/hero_animation_type.dart';
import '../animator/hero_animation_entry.dart';
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
    // Wrap child in an opaque background to prevent source route bleed-through.
    // HeroPageRoute uses opaque: false to keep the source route painted during
    // transitions, but when no transition is active the destination must block
    // the source from showing through.
    final bg = transitionBackgroundColor ??
        Theme.of(context).scaffoldBackgroundColor;
    final opaqueChild = ColoredBox(color: bg, child: child);

    // If hero is not enabled, use a simple fade transition
    if (!heroEnabled) {
      return FadeTransition(
        opacity: animation,
        child: opaqueChild,
      );
    }

    // The HeroTransitionEngine handles the actual animation via overlay.
    // During a hero transition, hide only the "upper" route so the source
    // page stays visible underneath and the overlay proxy renders on top.
    //
    // Upper route = destination (toRoute) during push, source (fromRoute)
    // during pop. This matches iOS behavior where the transitioning view
    // controller is invisible — only the overlay's snapshots are visible.
    return ValueListenableBuilder<List<HeroAnimationEntry>>(
      valueListenable: HeroTransitionEngine.shared.activeAnimations,
      builder: (context, entries, _) {
        if (entries.isEmpty) {
          return opaqueChild;
        }

        final engine = HeroTransitionEngine.shared;
        final isUpperRoute = engine.isPresenting
            ? (engine.toRoute == this)
            : (engine.fromRoute == this);

        return Opacity(
          opacity: isUpperRoute ? 0.0 : 1.0,
          child: opaqueChild,
        );
      },
    );
  }
}
