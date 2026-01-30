import 'dart:ui';
import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';
import '../types/hero_target_state.dart';
import '../types/hero_conditional_context.dart';
import '../types/hero_coordinate_space.dart';
import '../types/hero_snapshot_type.dart';
import '../types/cascade_direction.dart';

/// A modifier that mutates a [HeroTargetState].
/// Modifiers are composable and applied in order.
///
/// Equivalent to iOS HeroModifier.
class HeroModifier {
  final void Function(HeroTargetState state) _apply;

  const HeroModifier._(this._apply);

  /// Apply this modifier to a target state.
  void apply(HeroTargetState state) => _apply(state);

  // ============================================================
  // BASIC MODIFIERS
  // ============================================================

  /// Fade the view during transition (opacity -> 0).
  static final fade = HeroModifier._((state) {
    state.opacity = 0.0;
  });

  /// Force the view to NOT fade.
  static final forceNonFade = HeroModifier._((state) {
    state.nonFade = true;
  });

  /// Set the position to animate from/to.
  static HeroModifier position(Offset position) {
    return HeroModifier._((state) {
      state.position = position;
    });
  }

  /// Set the size to animate from/to.
  static HeroModifier size(Size size) {
    return HeroModifier._((state) {
      state.size = size;
    });
  }

  // ============================================================
  // TRANSFORM MODIFIERS
  // ============================================================

  /// Set the full transform matrix.
  static HeroModifier transform(Matrix4 t) {
    return HeroModifier._((state) {
      state.transform = t;
    });
  }

  /// Set perspective on the transform.
  static HeroModifier perspective(double value) {
    return HeroModifier._((state) {
      final t = state.transform ?? Matrix4.identity();
      t.setEntry(3, 2, 1.0 / -value);
      state.transform = t;
    });
  }

  /// Scale uniformly on x and y.
  static HeroModifier scale(double xy) => scaleXYZ(x: xy, y: xy);

  /// Scale on each axis independently.
  static HeroModifier scaleXYZ({double x = 1, double y = 1, double z = 1}) {
    return HeroModifier._((state) {
      final t = state.transform ?? Matrix4.identity();
      t.scale(x, y, z);
      state.transform = t;
    });
  }

  /// Translate by x, y, z offset.
  static HeroModifier translate({double x = 0, double y = 0, double z = 0}) {
    return HeroModifier._((state) {
      final t = state.transform ?? Matrix4.identity();
      t.translate(x, y, z);
      state.transform = t;
    });
  }

  /// Translate by an Offset with optional z.
  static HeroModifier translateOffset(Offset offset, {double z = 0}) {
    return translate(x: offset.dx, y: offset.dy, z: z);
  }

  /// Rotate on each axis (in radians).
  static HeroModifier rotate({double x = 0, double y = 0, double z = 0}) {
    return HeroModifier._((state) {
      final t = state.transform ?? Matrix4.identity();
      if (x != 0) t.rotateX(x);
      if (y != 0) t.rotateY(y);
      if (z != 0) t.rotateZ(z);
      state.transform = t;
    });
  }

  /// Rotate on the z axis only (convenience).
  static HeroModifier rotateZ(double z) {
    return rotate(z: z);
  }

  // ============================================================
  // APPEARANCE MODIFIERS
  // ============================================================

  /// Set opacity to animate from/to.
  static HeroModifier opacity(double value) {
    return HeroModifier._((state) {
      state.opacity = value;
    });
  }

  /// Set corner radius.
  static HeroModifier cornerRadius(double value) {
    return HeroModifier._((state) {
      state.cornerRadius = value;
    });
  }

  /// Set background color.
  static HeroModifier backgroundColor(Color color) {
    return HeroModifier._((state) {
      state.backgroundColor = color;
    });
  }

  /// Set border color.
  static HeroModifier borderColor(Color color) {
    return HeroModifier._((state) {
      state.borderColor = color;
    });
  }

  /// Set border width.
  static HeroModifier borderWidth(double width) {
    return HeroModifier._((state) {
      state.borderWidth = width;
    });
  }

  /// Set z-position (elevation/ordering).
  static HeroModifier zPosition(double value) {
    return HeroModifier._((state) {
      state.zPosition = value;
    });
  }

  // ============================================================
  // SHADOW MODIFIERS
  // ============================================================

  /// Set shadow color.
  static HeroModifier shadowColor(Color color) {
    return HeroModifier._((state) {
      state.shadowColor = color;
    });
  }

  /// Set shadow opacity.
  static HeroModifier shadowOpacity(double value) {
    return HeroModifier._((state) {
      state.shadowOpacity = value;
    });
  }

  /// Set shadow offset.
  static HeroModifier shadowOffset(Offset offset) {
    return HeroModifier._((state) {
      state.shadowOffset = offset;
    });
  }

  /// Set shadow radius (blur).
  static HeroModifier shadowRadius(double value) {
    return HeroModifier._((state) {
      state.shadowRadius = value;
    });
  }

  /// Set whether the view clips to its bounds.
  static HeroModifier masksToBounds(bool value) {
    return HeroModifier._((state) {
      state.clipToBounds = value;
    });
  }

  // ============================================================
  // OVERLAY MODIFIER
  // ============================================================

  /// Create a color overlay on the view.
  static HeroModifier overlay({required Color color, required double opacity}) {
    return HeroModifier._((state) {
      state.overlay = HeroOverlayState(color: color, opacity: opacity);
    });
  }

  // ============================================================
  // CONTENTS MODIFIERS
  // ============================================================

  /// Set contents rect (for image cropping).
  static HeroModifier contentsRect(Rect rect) {
    return HeroModifier._((state) {
      state.contentsRect = rect;
    });
  }

  /// Set contents scale.
  static HeroModifier contentsScale(double scale) {
    return HeroModifier._((state) {
      state.contentsScale = scale;
    });
  }

  // ============================================================
  // TIMING MODIFIERS
  // ============================================================

  /// Set animation duration.
  static HeroModifier duration(Duration duration) {
    return HeroModifier._((state) {
      state.duration = duration;
    });
  }

  /// Set duration from seconds (convenience).
  static HeroModifier durationSeconds(double seconds) {
    return duration(Duration(milliseconds: (seconds * 1000).round()));
  }

  /// Match the duration of the longest animation in the transition.
  static final durationMatchLongest = HeroModifier._((state) {
    state.durationMatchLongest = true;
  });

  /// Set animation delay.
  static HeroModifier delay(Duration delay) {
    return HeroModifier._((state) {
      state.delay = delay;
    });
  }

  /// Set delay from seconds (convenience).
  static HeroModifier delaySeconds(double seconds) {
    return delay(Duration(milliseconds: (seconds * 1000).round()));
  }

  /// Set the animation curve.
  static HeroModifier curve(Curve curve) {
    return HeroModifier._((state) {
      state.curve = curve;
    });
  }

  /// Use spring animation with custom stiffness and damping.
  static HeroModifier spring({required double stiffness, required double damping}) {
    return HeroModifier._((state) {
      state.spring = HeroSpringConfig(stiffness: stiffness, damping: damping);
    });
  }

  // ============================================================
  // ARC MODIFIER
  // ============================================================

  /// Animate position along a curved arc path.
  static final arc = HeroModifier._((state) {
    state.arcIntensity = 1.0;
  });

  /// Animate position along a curved arc path with custom intensity.
  static HeroModifier arcWithIntensity(double intensity) {
    return HeroModifier._((state) {
      state.arcIntensity = intensity;
    });
  }

  // ============================================================
  // SOURCE MODIFIER
  // ============================================================

  /// Transition from/to the state of the view with matching heroID.
  static HeroModifier source({required String heroID}) {
    return HeroModifier._((state) {
      state.source = heroID;
    });
  }

  // ============================================================
  // CASCADE MODIFIER
  // ============================================================

  /// Apply cascade stagger to child views (default direction: topToBottom).
  static final cascadeDefault = HeroModifier._((state) {
    state.cascade = const HeroCascadeConfig();
  });

  /// Apply cascade stagger with custom configuration.
  static HeroModifier cascade({
    Duration delta = const Duration(milliseconds: 20),
    CascadeDirection direction = const CascadeDirection.topToBottom(),
    bool delayMatchedViews = false,
  }) {
    return HeroModifier._((state) {
      state.cascade = HeroCascadeConfig(
        delta: delta,
        direction: direction,
        delayMatchedViews: delayMatchedViews,
      );
    });
  }

  // ============================================================
  // ADVANCED MODIFIERS
  // ============================================================

  /// Apply modifiers at the start of the transition (not animated).
  static HeroModifier beginWith(List<HeroModifier> modifiers) {
    return HeroModifier._((state) {
      state.beginState ??= [];
      state.beginState!.addAll(modifiers);
    });
  }

  /// Use global coordinate space for position calculations.
  static final useGlobalCoordinateSpace = HeroModifier._((state) {
    state.coordinateSpace = HeroCoordinateSpace.global;
  });

  /// Ignore modifiers on subviews.
  static final ignoreSubviewModifiers = HeroModifier._((state) {
    state.ignoreSubviewModifiers = false; // false = not recursive
  });

  /// Ignore modifiers on subviews, optionally recursive.
  static HeroModifier ignoreSubviewModifiersRecursive({bool recursive = false}) {
    return HeroModifier._((state) {
      state.ignoreSubviewModifiers = recursive;
    });
  }

  /// Force animate this view even if offscreen or no state changes.
  static final forceAnimate = HeroModifier._((state) {
    state.forceAnimate = true;
  });

  /// Use scale-based size change instead of bounds animation.
  static final useScaleBasedSizeChange = HeroModifier._((state) {
    state.useScaleBasedSizeChange = true;
  });

  // ============================================================
  // SNAPSHOT TYPE MODIFIERS
  // ============================================================

  /// Use optimized snapshot.
  static final useOptimizedSnapshot = HeroModifier._((state) {
    state.snapshotType = HeroSnapshotType.optimized;
  });

  /// Use normal snapshot.
  static final useNormalSnapshot = HeroModifier._((state) {
    state.snapshotType = HeroSnapshotType.normal;
  });

  /// Use layer render snapshot.
  static final useLayerRenderSnapshot = HeroModifier._((state) {
    state.snapshotType = HeroSnapshotType.layerRender;
  });

  /// Don't create a snapshot; animate the actual widget.
  static final useNoSnapshot = HeroModifier._((state) {
    state.snapshotType = HeroSnapshotType.noSnapshot;
  });

  // ============================================================
  // CONDITIONAL MODIFIERS
  // ============================================================

  /// Apply modifiers only when a condition is met.
  static HeroModifier when(
    bool Function(HeroConditionalContext) condition,
    List<HeroModifier> modifiers,
  ) {
    return HeroModifier._((state) {
      state.conditionalModifiers ??= [];
      state.conditionalModifiers!.add(
        HeroConditionalModifierEntry(condition: condition, modifiers: modifiers),
      );
    });
  }

  /// Apply modifiers only when this view is matched with another.
  static HeroModifier whenMatched(List<HeroModifier> modifiers) {
    return when((ctx) => ctx.isMatched, modifiers);
  }

  /// Apply modifiers only when presenting (pushing).
  static HeroModifier whenPresenting(List<HeroModifier> modifiers) {
    return when((ctx) => ctx.isPresenting, modifiers);
  }

  /// Apply modifiers only when dismissing (popping).
  static HeroModifier whenDismissing(List<HeroModifier> modifiers) {
    return when((ctx) => !ctx.isPresenting, modifiers);
  }

  /// Apply modifiers only when appearing (destination view).
  static HeroModifier whenAppearing(List<HeroModifier> modifiers) {
    return when((ctx) => ctx.isAppearing, modifiers);
  }

  /// Apply modifiers only when disappearing (source view).
  static HeroModifier whenDisappearing(List<HeroModifier> modifiers) {
    return when((ctx) => !ctx.isAppearing, modifiers);
  }
}
