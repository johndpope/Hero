import 'package:flutter/material.dart';
import '../types/hero_animation_type.dart';
import 'hero_transition_engine.dart';

/// iOS Hero-style transition curve: cubic-bezier(0.465, 0.840, 0.440, 1.000).
const _kHeroTransitionCurve = Cubic(0.465, 0.840, 0.440, 1.000);

/// Curve tween used to chain with position/scale/opacity tweens.
final _kCurveTween = CurveTween(curve: _kHeroTransitionCurve);

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

  /// Animation type applied when this route is covered by another route.
  /// Set by the navigator observer when a new HeroPageRoute pushes on top.
  HeroAnimationType? _coveredByAnimationType;

  HeroPageRoute({
    required this.builder,
    this.animationType = const HeroAnimationType.auto(),
    this.heroEnabled = true,
    this.interactive = true,
    this.transitionBackgroundColor,
    super.settings,
    super.fullscreenDialog,
  });

  /// Called by the navigator observer to communicate the covering route's
  /// animation type, so this route can animate its secondary (being-covered)
  /// transition correctly.
  void setCoveredByType(HeroAnimationType type) {
    _coveredByAnimationType = type;
  }

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

    // When fully settled (pushed and nothing covering), return the plain
    // opaque child. This avoids wrapping in transition widgets that can
    // interfere with hit testing after a push+pop cycle.
    if (animation.isCompleted && secondaryAnimation.isDismissed) {
      return opaqueChild;
    }

    // Determine animation direction: forward = pushing, reverse = popping.
    final isForward = animation.status == AnimationStatus.forward ||
        animation.status == AnimationStatus.completed;

    // Resolve the primary animation type (how this route enters/leaves).
    // For selectBy, pick presenting or dismissing based on direction.
    final primaryType = _resolvePrimaryType(isForward);
    final isSelectByDismiss =
        !isForward && animationType is HeroAnimationTypeSelectBy;

    // 1. Build secondary transition (when this route is covered/uncovered
    //    by another route). Uses the COVERING route's animation type.
    //    Only build when secondaryAnimation is active to avoid leaving
    //    stale overlay wrappers in the widget tree.
    Widget result;
    if (secondaryAnimation.isDismissed) {
      result = opaqueChild;
    } else {
      result = _buildSecondaryTransition(secondaryAnimation, opaqueChild);
    }

    // 2. Build primary transition (this route entering or leaving).
    //    For selectBy dismiss, use the "disappear" variant so the dismiss
    //    animation plays forward as the route animation goes 1→0.
    if (isSelectByDismiss) {
      result = _buildDisappearTransition(primaryType, animation, result);
    } else {
      result = _buildAppearTransition(primaryType, animation, result);
    }

    return result;
  }

  // ─── Type Resolution ───────────────────────────────────────────────

  /// Resolve the primary animation type, handling selectBy and auto.
  HeroAnimationType _resolvePrimaryType(bool isForward) {
    if (animationType is HeroAnimationTypeSelectBy) {
      final sb = animationType as HeroAnimationTypeSelectBy;
      return _resolveBase(isForward ? sb.presenting : sb.dismissing);
    }
    return _resolveBase(animationType);
  }

  /// Resolve the secondary (being-covered) animation type.
  /// Always uses the covering route's presenting type; Flutter reverses
  /// secondaryAnimation automatically when the covering route pops.
  HeroAnimationType _resolveSecondaryType() {
    if (_coveredByAnimationType == null) {
      return const HeroAnimationType.none();
    }
    return _resolveBase(_coveredByAnimationType!);
  }

  /// Resolve auto → push(left), selectBy → presenting type.
  HeroAnimationType _resolveBase(HeroAnimationType type) {
    if (type is HeroAnimationTypeAuto) {
      return const HeroAnimationType.push(
          direction: HeroAnimationDirection.left);
    }
    if (type is HeroAnimationTypeSelectBy) {
      return _resolveBase(type.presenting);
    }
    return type;
  }

  // ─── Offset Helpers ────────────────────────────────────────────────

  /// Fractional offset where the entering route starts (off-screen).
  /// "Push left" means content moves left → entering comes from right.
  static Offset _entryOffset(HeroAnimationDirection dir) => switch (dir) {
        HeroAnimationDirection.left => const Offset(1.0, 0.0),
        HeroAnimationDirection.right => const Offset(-1.0, 0.0),
        HeroAnimationDirection.up => const Offset(0.0, 1.0),
        HeroAnimationDirection.down => const Offset(0.0, -1.0),
      };

  /// Fractional offset where the covered route exits to (off-screen).
  static Offset _exitOffset(HeroAnimationDirection dir) => switch (dir) {
        HeroAnimationDirection.left => const Offset(-1.0, 0.0),
        HeroAnimationDirection.right => const Offset(1.0, 0.0),
        HeroAnimationDirection.up => const Offset(0.0, -1.0),
        HeroAnimationDirection.down => const Offset(0.0, 1.0),
      };

  // ─── Appear Transition (entering route, animation 0→1) ────────────

  Widget _buildAppearTransition(
    HeroAnimationType type,
    Animation<double> animation,
    Widget child,
  ) {
    return switch (type) {
      // Push: slide in from opposite direction
      HeroAnimationTypePush(direction: final dir) =>
        _slideIn(dir, animation, child),
      // Pull: slide in with dark overlay that fades out
      HeroAnimationTypePull(direction: final dir) =>
        _slideInWithOverlay(dir, animation, child),
      // Cover: new route slides in over old
      HeroAnimationTypeCover(direction: final dir) =>
        _slideIn(dir, animation, child),
      // Uncover: new route is already in place, overlay fades out
      HeroAnimationTypeUncover() =>
        _fadeOverlayAppear(animation, child),
      // Slide: both routes slide together
      HeroAnimationTypeSlide(direction: final dir) =>
        _slideIn(dir, animation, child),
      // ZoomSlide: new route slides in
      HeroAnimationTypeZoomSlide(direction: final dir) =>
        _slideIn(dir, animation, child),
      // PageIn: new route slides in
      HeroAnimationTypePageIn(direction: final dir) =>
        _slideIn(dir, animation, child),
      // PageOut: new route scales and fades in
      HeroAnimationTypePageOut() =>
        _scaleAndFadeIn(animation, child, beginScale: 0.7),
      // Fade: cross-fade
      HeroAnimationTypeFade() => _fadeIn(animation, child),
      // Zoom: scale from small + fade in
      HeroAnimationTypeZoom() =>
        _scaleAndFadeIn(animation, child, beginScale: 0.7),
      // ZoomOut: scale from large + fade in
      HeroAnimationTypeZoomOut() =>
        _scaleAndFadeIn(animation, child, beginScale: 1.3),
      // None: instant
      HeroAnimationTypeNone() => child,
      _ => child,
    };
  }

  // ─── Disappear Transition (selectBy dismiss, animation 1→0) ───────
  //
  // Used when selectBy specifies a different dismissing animation.
  // Tweens are set up so begin = off-screen state (at t=0, end of pop)
  // and end = in-place state (at t=1, start of pop).

  Widget _buildDisappearTransition(
    HeroAnimationType type,
    Animation<double> animation,
    Widget child,
  ) {
    return switch (type) {
      HeroAnimationTypePush(direction: final dir) =>
        _slideOutPrimary(dir, animation, child, withOverlay: true),
      HeroAnimationTypePull(direction: final dir) =>
        _slideOutPrimary(dir, animation, child, withOverlay: false),
      HeroAnimationTypeCover() =>
        _fadeOverlayDisappear(animation, child),
      HeroAnimationTypeUncover(direction: final dir) =>
        _slideOutPrimary(dir, animation, child, withOverlay: false),
      HeroAnimationTypeSlide(direction: final dir) =>
        _slideOutPrimary(dir, animation, child, withOverlay: false),
      HeroAnimationTypeZoomSlide() =>
        _scaleAndFadeDisappear(animation, child, endScale: 0.8),
      HeroAnimationTypePageIn() =>
        _scaleAndFadeDisappear(animation, child, endScale: 0.7),
      HeroAnimationTypePageOut(direction: final dir) =>
        _slideOutPrimary(dir, animation, child, withOverlay: false),
      HeroAnimationTypeFade() => _fadeIn(animation, child),
      HeroAnimationTypeZoom() =>
        _scaleAndFadeDisappear(animation, child, endScale: 1.3),
      HeroAnimationTypeZoomOut() =>
        _scaleAndFadeDisappear(animation, child, endScale: 0.7),
      HeroAnimationTypeNone() => child,
      _ => child,
    };
  }

  // ─── Secondary Transition (being covered, secondaryAnimation 0→1) ─

  Widget _buildSecondaryTransition(
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final type = _resolveSecondaryType();
    if (type is HeroAnimationTypeNone) return child;

    return switch (type) {
      // Push: slide out in direction + darken
      HeroAnimationTypePush(direction: final dir) =>
        _secondarySlideOut(dir, secondaryAnimation, child, withOverlay: true),
      // Pull: slide out in direction (no overlay)
      HeroAnimationTypePull(direction: final dir) =>
        _secondarySlideOut(dir, secondaryAnimation, child, withOverlay: false),
      // Cover: stay in place, just darken
      HeroAnimationTypeCover() =>
        _secondaryOverlay(secondaryAnimation, child),
      // Uncover: slide out in direction
      HeroAnimationTypeUncover(direction: final dir) =>
        _secondarySlideOut(dir, secondaryAnimation, child, withOverlay: false),
      // Slide: slide out in direction
      HeroAnimationTypeSlide(direction: final dir) =>
        _secondarySlideOut(dir, secondaryAnimation, child, withOverlay: false),
      // ZoomSlide: scale down + fade out
      HeroAnimationTypeZoomSlide() =>
        _secondaryScaleAndFade(secondaryAnimation, child, endScale: 0.8),
      // PageIn: scale down + fade out
      HeroAnimationTypePageIn() =>
        _secondaryScaleAndFade(secondaryAnimation, child, endScale: 0.7),
      // PageOut: slide out in direction
      HeroAnimationTypePageOut(direction: final dir) =>
        _secondarySlideOut(dir, secondaryAnimation, child, withOverlay: false),
      // Fade: fade out
      HeroAnimationTypeFade() => _secondaryFade(secondaryAnimation, child),
      // Zoom: scale up + fade out
      HeroAnimationTypeZoom() =>
        _secondaryScaleAndFade(secondaryAnimation, child, endScale: 1.3),
      // ZoomOut: scale down + fade out
      HeroAnimationTypeZoomOut() =>
        _secondaryScaleAndFade(secondaryAnimation, child, endScale: 0.7),
      HeroAnimationTypeNone() => child,
      _ => child,
    };
  }

  // ─── Appear Building Blocks ────────────────────────────────────────

  /// Slide in from the entry offset to center.
  Widget _slideIn(
      HeroAnimationDirection dir, Animation<double> anim, Widget child) {
    return SlideTransition(
      position: anim.drive(
        Tween<Offset>(begin: _entryOffset(dir), end: Offset.zero)
            .chain(_kCurveTween),
      ),
      child: child,
    );
  }

  /// Slide in from entry offset with a dark overlay that fades out (for Pull).
  Widget _slideInWithOverlay(
      HeroAnimationDirection dir, Animation<double> anim, Widget child) {
    return SlideTransition(
      position: anim.drive(
        Tween<Offset>(begin: _entryOffset(dir), end: Offset.zero)
            .chain(_kCurveTween),
      ),
      child: Stack(
        children: [
          child,
          FadeTransition(
            opacity: anim.drive(
              Tween<double>(begin: 0.1, end: 0.0).chain(_kCurveTween),
            ),
            child:
                const ColoredBox(color: Colors.black, child: SizedBox.expand()),
          ),
        ],
      ),
    );
  }

  /// Fade in (for Fade, or as a building block).
  Widget _fadeIn(Animation<double> anim, Widget child) {
    return FadeTransition(
      opacity: anim.drive(
        Tween<double>(begin: 0.0, end: 1.0).chain(_kCurveTween),
      ),
      child: child,
    );
  }

  /// Scale from beginScale→1.0 and fade in (for Zoom, ZoomOut, PageOut).
  Widget _scaleAndFadeIn(Animation<double> anim, Widget child,
      {required double beginScale}) {
    return ScaleTransition(
      scale: anim.drive(
        Tween<double>(begin: beginScale, end: 1.0).chain(_kCurveTween),
      ),
      child: FadeTransition(
        opacity: anim.drive(
          Tween<double>(begin: 0.0, end: 1.0).chain(_kCurveTween),
        ),
        child: child,
      ),
    );
  }

  /// Dark overlay that fades out (for Uncover entering).
  Widget _fadeOverlayAppear(Animation<double> anim, Widget child) {
    return Stack(
      children: [
        child,
        FadeTransition(
          opacity: anim.drive(
            Tween<double>(begin: 0.1, end: 0.0).chain(_kCurveTween),
          ),
          child:
              const ColoredBox(color: Colors.black, child: SizedBox.expand()),
        ),
      ],
    );
  }

  // ─── Disappear Building Blocks (selectBy dismiss) ─────────────────
  //
  // For selectBy dismiss, animation goes 1→0. Tweens: begin = off-screen
  // (at t=0, end of pop), end = in-place (at t=1, start of pop).

  /// Slide out to exit offset (animation 1→0: in-place → off-screen).
  Widget _slideOutPrimary(HeroAnimationDirection dir, Animation<double> anim,
      Widget child,
      {required bool withOverlay}) {
    return SlideTransition(
      position: anim.drive(
        Tween<Offset>(begin: _exitOffset(dir), end: Offset.zero)
            .chain(_kCurveTween),
      ),
      child: withOverlay
          ? Stack(
              children: [
                child,
                FadeTransition(
                  opacity: anim.drive(
                    Tween<double>(begin: 0.1, end: 0.0).chain(_kCurveTween),
                  ),
                  child: const ColoredBox(
                      color: Colors.black, child: SizedBox.expand()),
                ),
              ],
            )
          : child,
    );
  }

  /// Scale to endScale + fade out (animation 1→0: normal → scaled/faded).
  Widget _scaleAndFadeDisappear(Animation<double> anim, Widget child,
      {required double endScale}) {
    return ScaleTransition(
      scale: anim.drive(
        Tween<double>(begin: endScale, end: 1.0).chain(_kCurveTween),
      ),
      child: FadeTransition(
        opacity: anim.drive(
          Tween<double>(begin: 0.0, end: 1.0).chain(_kCurveTween),
        ),
        child: child,
      ),
    );
  }

  /// Dark overlay that fades in (for Cover disappearing / being revealed).
  Widget _fadeOverlayDisappear(Animation<double> anim, Widget child) {
    return Stack(
      children: [
        child,
        FadeTransition(
          opacity: anim.drive(
            Tween<double>(begin: 0.1, end: 0.0).chain(_kCurveTween),
          ),
          child:
              const ColoredBox(color: Colors.black, child: SizedBox.expand()),
        ),
      ],
    );
  }

  // ─── Secondary Building Blocks ─────────────────────────────────────
  //
  // secondaryAnimation: 0→1 when covered, 1→0 when uncovered.
  // Tweens: begin = in-place (at 0), end = off-screen/covered (at 1).

  /// Slide out in the given direction when covered.
  Widget _secondarySlideOut(HeroAnimationDirection dir,
      Animation<double> secondaryAnim, Widget child,
      {required bool withOverlay}) {
    return SlideTransition(
      position: secondaryAnim.drive(
        Tween<Offset>(begin: Offset.zero, end: _exitOffset(dir))
            .chain(_kCurveTween),
      ),
      child: withOverlay
          ? Stack(
              children: [
                child,
                FadeTransition(
                  opacity: secondaryAnim.drive(
                    Tween<double>(begin: 0.0, end: 0.1).chain(_kCurveTween),
                  ),
                  child: const ColoredBox(
                      color: Colors.black, child: SizedBox.expand()),
                ),
              ],
            )
          : child,
    );
  }

  /// Just a dark overlay when covered (no slide, for Cover).
  Widget _secondaryOverlay(Animation<double> secondaryAnim, Widget child) {
    return Stack(
      children: [
        child,
        FadeTransition(
          opacity: secondaryAnim.drive(
            Tween<double>(begin: 0.0, end: 0.1).chain(_kCurveTween),
          ),
          child:
              const ColoredBox(color: Colors.black, child: SizedBox.expand()),
        ),
      ],
    );
  }

  /// Fade out when covered (for Fade).
  Widget _secondaryFade(Animation<double> secondaryAnim, Widget child) {
    return FadeTransition(
      opacity: secondaryAnim.drive(
        Tween<double>(begin: 1.0, end: 0.0).chain(_kCurveTween),
      ),
      child: child,
    );
  }

  /// Scale + fade out when covered (for ZoomSlide, PageIn, Zoom, ZoomOut).
  Widget _secondaryScaleAndFade(Animation<double> secondaryAnim, Widget child,
      {required double endScale}) {
    return ScaleTransition(
      scale: secondaryAnim.drive(
        Tween<double>(begin: 1.0, end: endScale).chain(_kCurveTween),
      ),
      child: FadeTransition(
        opacity: secondaryAnim.drive(
          Tween<double>(begin: 1.0, end: 0.0).chain(_kCurveTween),
        ),
        child: child,
      ),
    );
  }
}
