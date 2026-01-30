import 'package:flutter/widgets.dart';
import '../modifiers/hero_modifier.dart';
import '../types/hero_animation_type.dart';

/// InheritedWidget that provides Hero transition configuration
/// at the route/page level.
///
/// Equivalent to setting properties on UIViewController in iOS:
/// `hero.isEnabled`, `hero.modalAnimationType`, and HeroViewControllerDelegate.
class HeroScope extends StatefulWidget {
  /// The child widget tree.
  final Widget child;

  /// The animation type for this scope.
  final HeroAnimationType? animationType;

  /// Whether hero transitions are enabled for this scope.
  final bool isEnabled;

  /// Callback fired when this route is about to animate away TO another route.
  /// Return modifiers to apply to views during the transition.
  final List<HeroModifier> Function(Route<dynamic>? toRoute)?
      onWillStartAnimatingTo;

  /// Callback fired when another route is animating back FROM this route.
  final List<HeroModifier> Function(Route<dynamic>? fromRoute)?
      onWillStartAnimatingFrom;

  /// Callback fired when the transition completes.
  final void Function()? onDidEndAnimating;

  /// Callback fired when the transition is cancelled.
  final void Function()? onDidCancelAnimating;

  const HeroScope({
    super.key,
    required this.child,
    this.animationType,
    this.isEnabled = true,
    this.onWillStartAnimatingTo,
    this.onWillStartAnimatingFrom,
    this.onDidEndAnimating,
    this.onDidCancelAnimating,
  });

  /// Find the nearest HeroScope in the widget tree.
  static HeroScopeData? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HeroScopeData>();
  }

  @override
  State<HeroScope> createState() => _HeroScopeState();
}

class _HeroScopeState extends State<HeroScope> {
  @override
  Widget build(BuildContext context) {
    return HeroScopeData(
      animationType: widget.animationType,
      isEnabled: widget.isEnabled,
      onWillStartAnimatingTo: widget.onWillStartAnimatingTo,
      onWillStartAnimatingFrom: widget.onWillStartAnimatingFrom,
      onDidEndAnimating: widget.onDidEndAnimating,
      onDidCancelAnimating: widget.onDidCancelAnimating,
      child: widget.child,
    );
  }
}

/// InheritedWidget carrying HeroScope data.
class HeroScopeData extends InheritedWidget {
  final HeroAnimationType? animationType;
  final bool isEnabled;
  final List<HeroModifier> Function(Route<dynamic>? toRoute)?
      onWillStartAnimatingTo;
  final List<HeroModifier> Function(Route<dynamic>? fromRoute)?
      onWillStartAnimatingFrom;
  final void Function()? onDidEndAnimating;
  final void Function()? onDidCancelAnimating;

  const HeroScopeData({
    super.key,
    this.animationType,
    this.isEnabled = true,
    this.onWillStartAnimatingTo,
    this.onWillStartAnimatingFrom,
    this.onDidEndAnimating,
    this.onDidCancelAnimating,
    required super.child,
  });

  @override
  bool updateShouldNotify(HeroScopeData oldWidget) {
    return animationType != oldWidget.animationType ||
        isEnabled != oldWidget.isEnabled;
  }
}
