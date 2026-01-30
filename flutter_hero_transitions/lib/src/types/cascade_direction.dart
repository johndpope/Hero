import 'dart:ui';

/// Direction for cascade (staggered) animations.
/// Controls the order in which child views begin animating.
sealed class CascadeDirection {
  const CascadeDirection();

  const factory CascadeDirection.topToBottom() = CascadeDirectionTopToBottom;
  const factory CascadeDirection.bottomToTop() = CascadeDirectionBottomToTop;
  const factory CascadeDirection.leftToRight() = CascadeDirectionLeftToRight;
  const factory CascadeDirection.rightToLeft() = CascadeDirectionRightToLeft;
  const factory CascadeDirection.radial({required Offset center}) = CascadeDirectionRadial;
  const factory CascadeDirection.inverseRadial({required Offset center}) = CascadeDirectionInverseRadial;

  /// Compare two positions for sorting. Returns negative if a should animate before b.
  int compare(Offset a, Offset b);
}

class CascadeDirectionTopToBottom extends CascadeDirection {
  const CascadeDirectionTopToBottom();

  @override
  int compare(Offset a, Offset b) => a.dy.compareTo(b.dy);
}

class CascadeDirectionBottomToTop extends CascadeDirection {
  const CascadeDirectionBottomToTop();

  @override
  int compare(Offset a, Offset b) => b.dy.compareTo(a.dy);
}

class CascadeDirectionLeftToRight extends CascadeDirection {
  const CascadeDirectionLeftToRight();

  @override
  int compare(Offset a, Offset b) => a.dx.compareTo(b.dx);
}

class CascadeDirectionRightToLeft extends CascadeDirection {
  const CascadeDirectionRightToLeft();

  @override
  int compare(Offset a, Offset b) => b.dx.compareTo(a.dx);
}

class CascadeDirectionRadial extends CascadeDirection {
  final Offset center;
  const CascadeDirectionRadial({required this.center});

  @override
  int compare(Offset a, Offset b) {
    final distA = (a - center).distance;
    final distB = (b - center).distance;
    return distA.compareTo(distB);
  }
}

class CascadeDirectionInverseRadial extends CascadeDirection {
  final Offset center;
  const CascadeDirectionInverseRadial({required this.center});

  @override
  int compare(Offset a, Offset b) {
    final distA = (a - center).distance;
    final distB = (b - center).distance;
    return distB.compareTo(distA);
  }
}
