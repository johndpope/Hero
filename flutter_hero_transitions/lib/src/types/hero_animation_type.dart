/// Direction for built-in transition animations.
enum HeroAnimationDirection {
  left,
  right,
  up,
  down;

  /// Get the opposite direction.
  HeroAnimationDirection get opposite {
    switch (this) {
      case HeroAnimationDirection.left:
        return HeroAnimationDirection.right;
      case HeroAnimationDirection.right:
        return HeroAnimationDirection.left;
      case HeroAnimationDirection.up:
        return HeroAnimationDirection.down;
      case HeroAnimationDirection.down:
        return HeroAnimationDirection.up;
    }
  }
}

/// Built-in transition animation types.
/// Mirrors iOS HeroDefaultAnimationType exactly.
sealed class HeroAnimationType {
  const HeroAnimationType();

  /// Automatic animation based on navigation type.
  const factory HeroAnimationType.auto() = HeroAnimationTypeAuto;

  /// Push animation in a direction.
  const factory HeroAnimationType.push({required HeroAnimationDirection direction}) = HeroAnimationTypePush;

  /// Pull animation in a direction.
  const factory HeroAnimationType.pull({required HeroAnimationDirection direction}) = HeroAnimationTypePull;

  /// Cover animation in a direction (new view covers old).
  const factory HeroAnimationType.cover({required HeroAnimationDirection direction}) = HeroAnimationTypeCover;

  /// Uncover animation in a direction (old view uncovers new).
  const factory HeroAnimationType.uncover({required HeroAnimationDirection direction}) = HeroAnimationTypeUncover;

  /// Slide animation in a direction (both views slide).
  const factory HeroAnimationType.slide({required HeroAnimationDirection direction}) = HeroAnimationTypeSlide;

  /// Zoom + slide animation.
  const factory HeroAnimationType.zoomSlide({required HeroAnimationDirection direction}) = HeroAnimationTypeZoomSlide;

  /// Page-in animation (like turning a page).
  const factory HeroAnimationType.pageIn({required HeroAnimationDirection direction}) = HeroAnimationTypePageIn;

  /// Page-out animation.
  const factory HeroAnimationType.pageOut({required HeroAnimationDirection direction}) = HeroAnimationTypePageOut;

  /// Cross-fade transition.
  const factory HeroAnimationType.fade() = HeroAnimationTypeFade;

  /// Zoom-in transition.
  const factory HeroAnimationType.zoom() = HeroAnimationTypeZoom;

  /// Zoom-out transition.
  const factory HeroAnimationType.zoomOut() = HeroAnimationTypeZoomOut;

  /// Select different animations for presenting vs dismissing.
  const factory HeroAnimationType.selectBy({
    required HeroAnimationType presenting,
    required HeroAnimationType dismissing,
  }) = HeroAnimationTypeSelectBy;

  /// No animation.
  const factory HeroAnimationType.none() = HeroAnimationTypeNone;

  /// Create an auto-reversing animation pair.
  static HeroAnimationType autoReverse({required HeroAnimationType presenting}) {
    return HeroAnimationType.selectBy(
      presenting: presenting,
      dismissing: presenting.reversed(),
    );
  }

  /// Get the reversed version of this animation.
  HeroAnimationType reversed();

  /// Human-readable label for this animation type (for debug/UI).
  String get label;
}

class HeroAnimationTypeAuto extends HeroAnimationType {
  const HeroAnimationTypeAuto();

  @override
  HeroAnimationType reversed() => const HeroAnimationType.auto();

  @override
  String get label => 'Auto';
}

class HeroAnimationTypePush extends HeroAnimationType {
  final HeroAnimationDirection direction;
  const HeroAnimationTypePush({required this.direction});

  @override
  HeroAnimationType reversed() => HeroAnimationType.pull(direction: direction.opposite);

  @override
  String get label => 'Push ${direction.name}';
}

class HeroAnimationTypePull extends HeroAnimationType {
  final HeroAnimationDirection direction;
  const HeroAnimationTypePull({required this.direction});

  @override
  HeroAnimationType reversed() => HeroAnimationType.push(direction: direction.opposite);

  @override
  String get label => 'Pull ${direction.name}';
}

class HeroAnimationTypeCover extends HeroAnimationType {
  final HeroAnimationDirection direction;
  const HeroAnimationTypeCover({required this.direction});

  @override
  HeroAnimationType reversed() => HeroAnimationType.uncover(direction: direction.opposite);

  @override
  String get label => 'Cover ${direction.name}';
}

class HeroAnimationTypeUncover extends HeroAnimationType {
  final HeroAnimationDirection direction;
  const HeroAnimationTypeUncover({required this.direction});

  @override
  HeroAnimationType reversed() => HeroAnimationType.cover(direction: direction.opposite);

  @override
  String get label => 'Uncover ${direction.name}';
}

class HeroAnimationTypeSlide extends HeroAnimationType {
  final HeroAnimationDirection direction;
  const HeroAnimationTypeSlide({required this.direction});

  @override
  HeroAnimationType reversed() => HeroAnimationType.slide(direction: direction.opposite);

  @override
  String get label => 'Slide ${direction.name}';
}

class HeroAnimationTypeZoomSlide extends HeroAnimationType {
  final HeroAnimationDirection direction;
  const HeroAnimationTypeZoomSlide({required this.direction});

  @override
  HeroAnimationType reversed() => HeroAnimationType.zoomSlide(direction: direction.opposite);

  @override
  String get label => 'Zoom Slide ${direction.name}';
}

class HeroAnimationTypePageIn extends HeroAnimationType {
  final HeroAnimationDirection direction;
  const HeroAnimationTypePageIn({required this.direction});

  @override
  HeroAnimationType reversed() => HeroAnimationType.pageOut(direction: direction.opposite);

  @override
  String get label => 'Page In ${direction.name}';
}

class HeroAnimationTypePageOut extends HeroAnimationType {
  final HeroAnimationDirection direction;
  const HeroAnimationTypePageOut({required this.direction});

  @override
  HeroAnimationType reversed() => HeroAnimationType.pageIn(direction: direction.opposite);

  @override
  String get label => 'Page Out ${direction.name}';
}

class HeroAnimationTypeFade extends HeroAnimationType {
  const HeroAnimationTypeFade();

  @override
  HeroAnimationType reversed() => const HeroAnimationType.fade();

  @override
  String get label => 'Fade';
}

class HeroAnimationTypeZoom extends HeroAnimationType {
  const HeroAnimationTypeZoom();

  @override
  HeroAnimationType reversed() => const HeroAnimationType.zoomOut();

  @override
  String get label => 'Zoom';
}

class HeroAnimationTypeZoomOut extends HeroAnimationType {
  const HeroAnimationTypeZoomOut();

  @override
  HeroAnimationType reversed() => const HeroAnimationType.zoom();

  @override
  String get label => 'Zoom Out';
}

class HeroAnimationTypeSelectBy extends HeroAnimationType {
  final HeroAnimationType presenting;
  final HeroAnimationType dismissing;
  const HeroAnimationTypeSelectBy({
    required this.presenting,
    required this.dismissing,
  });

  @override
  HeroAnimationType reversed() => HeroAnimationType.selectBy(
    presenting: dismissing,
    dismissing: presenting,
  );

  @override
  String get label => 'SelectBy(${presenting.label}, ${dismissing.label})';
}

class HeroAnimationTypeNone extends HeroAnimationType {
  const HeroAnimationTypeNone();

  @override
  HeroAnimationType reversed() => const HeroAnimationType.none();

  @override
  String get label => 'None';
}
