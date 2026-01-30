import 'dart:ui';
import 'package:flutter/animation.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4;
import 'cascade_direction.dart';
import 'hero_coordinate_space.dart';
import 'hero_snapshot_type.dart';
import 'hero_conditional_context.dart';

/// Configuration for spring physics animation.
class HeroSpringConfig {
  final double stiffness;
  final double damping;

  const HeroSpringConfig({required this.stiffness, required this.damping});
}

/// Configuration for cascade (staggered) animations.
class HeroCascadeConfig {
  final Duration delta;
  final CascadeDirection direction;
  final bool delayMatchedViews;

  const HeroCascadeConfig({
    this.delta = const Duration(milliseconds: 20),
    this.direction = const CascadeDirection.topToBottom(),
    this.delayMatchedViews = false,
  });
}

/// Overlay state (color + opacity).
class HeroOverlayState {
  final Color color;
  final double opacity;

  const HeroOverlayState({required this.color, required this.opacity});
}

/// Entry for a conditional modifier.
class HeroConditionalModifierEntry {
  final bool Function(HeroConditionalContext) condition;
  final List<dynamic> modifiers; // List<HeroModifier> - dynamic to avoid circular import

  const HeroConditionalModifierEntry({
    required this.condition,
    required this.modifiers,
  });
}

/// Mutable state bag representing target animation state.
/// Modifiers mutate this. Animators read from it to build tweens.
///
/// Equivalent to iOS HeroTargetState.
class HeroTargetState {
  // --- Layout ---
  Offset? position;
  Size? size;

  // --- Transform ---
  Matrix4? transform;
  double? opacity;
  double? cornerRadius;
  Color? backgroundColor;
  double? zPosition;
  Offset? anchorPoint;

  // --- Contents ---
  Rect? contentsRect;
  double? contentsScale;

  // --- Border ---
  double? borderWidth;
  Color? borderColor;

  // --- Shadow ---
  Color? shadowColor;
  double? shadowOpacity;
  Offset? shadowOffset;
  double? shadowRadius;
  bool displayShadow = true;
  bool? clipToBounds;

  // --- Overlay ---
  HeroOverlayState? overlay;

  // --- Timing ---
  HeroSpringConfig? spring;
  Duration delay = Duration.zero;
  Duration? duration;
  bool durationMatchLongest = false;
  Curve? curve;

  // --- Path ---
  double? arcIntensity;

  // --- Matching ---
  String? source;

  // --- Cascade ---
  HeroCascadeConfig? cascade;

  // --- Advanced ---
  bool? ignoreSubviewModifiers;
  HeroCoordinateSpace? coordinateSpace;
  bool? useScaleBasedSizeChange;
  HeroSnapshotType? snapshotType;

  // --- Flags ---
  bool nonFade = false;
  bool forceAnimate = false;

  // --- Conditional ---
  List<dynamic>? beginState; // List<HeroModifier>
  List<HeroConditionalModifierEntry>? conditionalModifiers;

  // --- Custom ---
  Map<String, dynamic>? custom;

  HeroTargetState();

  /// Create a [HeroTargetState] by applying a list of modifiers in order.
  factory HeroTargetState.fromModifiers(List<dynamic> modifiers) {
    final state = HeroTargetState();
    for (final modifier in modifiers) {
      modifier.apply(state);
    }
    return state;
  }

  /// Access custom data by key.
  dynamic operator [](String key) => custom?[key];

  /// Set custom data by key.
  void operator []=(String key, dynamic value) {
    custom ??= {};
    custom![key] = value;
  }
}
