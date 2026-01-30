import 'dart:ui';
import 'base_preprocessor.dart';
import '../types/hero_animation_type.dart';
import '../modifiers/hero_modifier.dart';

/// Preprocessor #3: Convert HeroAnimationType (push/pull/cover/etc.)
/// into concrete translate/scale/overlay modifiers on root views.
///
/// This is the heart of the built-in animation system.
class DefaultAnimationPreprocessor extends HeroPreprocessor {
  final HeroAnimationType animationType;
  final bool isPresenting;

  DefaultAnimationPreprocessor({
    required this.animationType,
    required this.isPresenting,
  });

  @override
  void process({
    required List<String> fromViewIDs,
    required List<String> toViewIDs,
  }) {
    if (context == null) return;

    // Resolve selectBy based on presenting/dismissing
    final resolvedType = _resolveAnimationType(animationType);
    if (resolvedType is HeroAnimationTypeNone ||
        resolvedType is HeroAnimationTypeAuto) {
      return;
    }

    final containerSize = context!.containerSize;

    // Apply modifiers to the FROM (source) root view and TO (dest) root view
    // based on the animation type.
    _applyAnimationType(
      resolvedType,
      containerSize: containerSize,
      fromViewIDs: fromViewIDs,
      toViewIDs: toViewIDs,
    );
  }

  HeroAnimationType _resolveAnimationType(HeroAnimationType type) {
    if (type is HeroAnimationTypeSelectBy) {
      return isPresenting ? type.presenting : type.dismissing;
    }
    return type;
  }

  void _applyAnimationType(
    HeroAnimationType type, {
    required Size containerSize,
    required List<String> fromViewIDs,
    required List<String> toViewIDs,
  }) {
    switch (type) {
      case HeroAnimationTypePush(direction: final dir):
        _applyPush(dir, containerSize, fromViewIDs, toViewIDs);
      case HeroAnimationTypePull(direction: final dir):
        _applyPull(dir, containerSize, fromViewIDs, toViewIDs);
      case HeroAnimationTypeCover(direction: final dir):
        _applyCover(dir, containerSize, fromViewIDs, toViewIDs);
      case HeroAnimationTypeUncover(direction: final dir):
        _applyUncover(dir, containerSize, fromViewIDs, toViewIDs);
      case HeroAnimationTypeSlide(direction: final dir):
        _applySlide(dir, containerSize, fromViewIDs, toViewIDs);
      case HeroAnimationTypeZoomSlide(direction: final dir):
        _applyZoomSlide(dir, containerSize, fromViewIDs, toViewIDs);
      case HeroAnimationTypePageIn(direction: final dir):
        _applyPageIn(dir, containerSize, fromViewIDs, toViewIDs);
      case HeroAnimationTypePageOut(direction: final dir):
        _applyPageOut(dir, containerSize, fromViewIDs, toViewIDs);
      case HeroAnimationTypeFade():
        _applyFade(fromViewIDs, toViewIDs);
      case HeroAnimationTypeZoom():
        _applyZoom(fromViewIDs, toViewIDs);
      case HeroAnimationTypeZoomOut():
        _applyZoomOut(fromViewIDs, toViewIDs);
      default:
        break;
    }
  }

  Offset _translationForDirection(HeroAnimationDirection dir, Size size) {
    switch (dir) {
      case HeroAnimationDirection.left:
        return Offset(-size.width, 0);
      case HeroAnimationDirection.right:
        return Offset(size.width, 0);
      case HeroAnimationDirection.up:
        return Offset(0, -size.height);
      case HeroAnimationDirection.down:
        return Offset(0, size.height);
    }
  }

  void _applyModifiersToIDs(List<String> ids, List<HeroModifier> modifiers) {
    for (final id in ids) {
      final state = context!.targetStateFor(id);
      for (final mod in modifiers) {
        mod.apply(state);
      }
    }
  }

  // --- Push: both views slide, source gets darkened ---
  void _applyPush(HeroAnimationDirection dir, Size size,
      List<String> fromIDs, List<String> toIDs) {
    final t = _translationForDirection(dir, size);
    // Source view moves in the direction
    _applyModifiersToIDs(fromIDs, [
      HeroModifier.translate(x: t.dx, y: t.dy),
      HeroModifier.overlay(color: const Color(0xFF000000), opacity: 0.1),
      HeroModifier.ignoreSubviewModifiers,
    ]);
    // Destination view comes from opposite direction
    _applyModifiersToIDs(toIDs, [
      HeroModifier.beginWith([
        HeroModifier.translate(x: -t.dx, y: -t.dy),
      ]),
      HeroModifier.ignoreSubviewModifiers,
    ]);
  }

  // --- Pull: reverse of push ---
  void _applyPull(HeroAnimationDirection dir, Size size,
      List<String> fromIDs, List<String> toIDs) {
    final t = _translationForDirection(dir, size);
    _applyModifiersToIDs(fromIDs, [
      HeroModifier.translate(x: t.dx, y: t.dy),
      HeroModifier.ignoreSubviewModifiers,
    ]);
    _applyModifiersToIDs(toIDs, [
      HeroModifier.beginWith([
        HeroModifier.translate(x: -t.dx, y: -t.dy),
        HeroModifier.overlay(color: const Color(0xFF000000), opacity: 0.1),
      ]),
      HeroModifier.ignoreSubviewModifiers,
    ]);
  }

  // --- Cover: new view slides in over old view (old stays) ---
  void _applyCover(HeroAnimationDirection dir, Size size,
      List<String> fromIDs, List<String> toIDs) {
    final t = _translationForDirection(dir, size);
    _applyModifiersToIDs(fromIDs, [
      HeroModifier.overlay(color: const Color(0xFF000000), opacity: 0.1),
      HeroModifier.ignoreSubviewModifiers,
    ]);
    _applyModifiersToIDs(toIDs, [
      HeroModifier.beginWith([
        HeroModifier.translate(x: -t.dx, y: -t.dy),
      ]),
      HeroModifier.ignoreSubviewModifiers,
    ]);
  }

  // --- Uncover: old view slides away revealing new view ---
  void _applyUncover(HeroAnimationDirection dir, Size size,
      List<String> fromIDs, List<String> toIDs) {
    final t = _translationForDirection(dir, size);
    _applyModifiersToIDs(fromIDs, [
      HeroModifier.translate(x: t.dx, y: t.dy),
      HeroModifier.ignoreSubviewModifiers,
    ]);
    _applyModifiersToIDs(toIDs, [
      HeroModifier.beginWith([
        HeroModifier.overlay(color: const Color(0xFF000000), opacity: 0.1),
      ]),
      HeroModifier.ignoreSubviewModifiers,
    ]);
  }

  // --- Slide: both views slide in the same direction ---
  void _applySlide(HeroAnimationDirection dir, Size size,
      List<String> fromIDs, List<String> toIDs) {
    final t = _translationForDirection(dir, size);
    _applyModifiersToIDs(fromIDs, [
      HeroModifier.translate(x: t.dx, y: t.dy),
      HeroModifier.ignoreSubviewModifiers,
    ]);
    _applyModifiersToIDs(toIDs, [
      HeroModifier.beginWith([
        HeroModifier.translate(x: -t.dx, y: -t.dy),
      ]),
      HeroModifier.ignoreSubviewModifiers,
    ]);
  }

  // --- Zoom Slide: old view zooms out while new slides in ---
  void _applyZoomSlide(HeroAnimationDirection dir, Size size,
      List<String> fromIDs, List<String> toIDs) {
    final t = _translationForDirection(dir, size);
    _applyModifiersToIDs(fromIDs, [
      HeroModifier.scale(0.8),
      HeroModifier.opacity(0.0),
      HeroModifier.ignoreSubviewModifiers,
    ]);
    _applyModifiersToIDs(toIDs, [
      HeroModifier.beginWith([
        HeroModifier.translate(x: -t.dx, y: -t.dy),
      ]),
      HeroModifier.ignoreSubviewModifiers,
    ]);
  }

  // --- Page In: 3D page turn effect ---
  void _applyPageIn(HeroAnimationDirection dir, Size size,
      List<String> fromIDs, List<String> toIDs) {
    final t = _translationForDirection(dir, size);
    _applyModifiersToIDs(fromIDs, [
      HeroModifier.scale(0.7),
      HeroModifier.opacity(0.0),
      HeroModifier.ignoreSubviewModifiers,
    ]);
    _applyModifiersToIDs(toIDs, [
      HeroModifier.beginWith([
        HeroModifier.translate(x: -t.dx, y: -t.dy),
      ]),
      HeroModifier.ignoreSubviewModifiers,
    ]);
  }

  // --- Page Out: 3D page turn out effect ---
  void _applyPageOut(HeroAnimationDirection dir, Size size,
      List<String> fromIDs, List<String> toIDs) {
    final t = _translationForDirection(dir, size);
    _applyModifiersToIDs(fromIDs, [
      HeroModifier.translate(x: t.dx, y: t.dy),
      HeroModifier.ignoreSubviewModifiers,
    ]);
    _applyModifiersToIDs(toIDs, [
      HeroModifier.beginWith([
        HeroModifier.scale(0.7),
        HeroModifier.opacity(0.0),
      ]),
      HeroModifier.ignoreSubviewModifiers,
    ]);
  }

  // --- Fade: cross-fade between views ---
  void _applyFade(List<String> fromIDs, List<String> toIDs) {
    _applyModifiersToIDs(fromIDs, [
      HeroModifier.fade,
      HeroModifier.ignoreSubviewModifiers,
    ]);
    _applyModifiersToIDs(toIDs, [
      HeroModifier.beginWith([HeroModifier.fade]),
      HeroModifier.ignoreSubviewModifiers,
    ]);
  }

  // --- Zoom: source zooms in, destination fades in ---
  void _applyZoom(List<String> fromIDs, List<String> toIDs) {
    _applyModifiersToIDs(fromIDs, [
      HeroModifier.scale(1.3),
      HeroModifier.fade,
      HeroModifier.ignoreSubviewModifiers,
    ]);
    _applyModifiersToIDs(toIDs, [
      HeroModifier.beginWith([
        HeroModifier.scale(0.7),
        HeroModifier.fade,
      ]),
      HeroModifier.ignoreSubviewModifiers,
    ]);
  }

  // --- Zoom Out: opposite of zoom ---
  void _applyZoomOut(List<String> fromIDs, List<String> toIDs) {
    _applyModifiersToIDs(fromIDs, [
      HeroModifier.scale(0.7),
      HeroModifier.fade,
      HeroModifier.ignoreSubviewModifiers,
    ]);
    _applyModifiersToIDs(toIDs, [
      HeroModifier.beginWith([
        HeroModifier.scale(1.3),
        HeroModifier.fade,
      ]),
      HeroModifier.ignoreSubviewModifiers,
    ]);
  }
}
