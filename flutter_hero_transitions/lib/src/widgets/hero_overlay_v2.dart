import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../transition/hero_transition_engine.dart';
import '../animator/hero_animation_entry.dart';

/// High-performance hero overlay that minimizes widget rebuilds.
///
/// Key optimizations matching iOS CoreAnimation behavior:
/// 1. Uses a single animation listener (not ValueListenableBuilder)
/// 2. Paints entry decorations (shadow, background, overlay, corner radius)
///    via PaintingContext compositing methods — proper canvas lifecycle
/// 3. Only rebuilds the widget tree when entries are added/removed
///    (transition start/end), NOT on every frame
/// 4. Snapshot widgets are built once per transition
class HeroOverlayV2 extends StatefulWidget {
  const HeroOverlayV2({super.key});

  @override
  State<HeroOverlayV2> createState() => _HeroOverlayV2State();
}

class _HeroOverlayV2State extends State<HeroOverlayV2>
    with TickerProviderStateMixin {
  List<HeroAnimationEntry> _entries = [];
  int _entryCount = 0; // Track structural changes only

  @override
  void initState() {
    super.initState();
    HeroTransitionEngine.shared.setTickerProvider(this);
    HeroTransitionEngine.shared.activeAnimations.addListener(_onAnimationsChanged);
  }

  @override
  void dispose() {
    HeroTransitionEngine.shared.activeAnimations.removeListener(_onAnimationsChanged);
    super.dispose();
  }

  void _onAnimationsChanged() {
    final newEntries = HeroTransitionEngine.shared.activeAnimations.value;
    // Only call setState when the NUMBER of entries changes (structural change)
    // Frame-by-frame value changes are handled by the render objects
    if (newEntries.length != _entryCount) {
      setState(() {
        _entries = newEntries;
        _entryCount = newEntries.length;
      });
    } else {
      // Just update the reference — render objects will repaint via
      // their own animation callback
      _entries = newEntries;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_entries.isEmpty) return const SizedBox.shrink();

    return IgnorePointer(
      ignoring: !HeroTransitionEngine.shared.isUserInteractionEnabled,
      child: _HeroAnimationLayer(
        entries: _entries,
        containerColor: HeroTransitionEngine.shared.containerColor,
        activeAnimations: HeroTransitionEngine.shared.activeAnimations,
      ),
    );
  }
}

/// A widget that paints all hero animation entries using a single
/// custom render object, avoiding per-frame widget tree rebuilds.
class _HeroAnimationLayer extends StatelessWidget {
  final List<HeroAnimationEntry> entries;
  final Color containerColor;
  final ValueNotifier<List<HeroAnimationEntry>> activeAnimations;

  const _HeroAnimationLayer({
    required this.entries,
    required this.containerColor,
    required this.activeAnimations,
  });

  @override
  Widget build(BuildContext context) {
    // Stack with snapshot widgets positioned by the render object
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background color overlay
        if ((containerColor.a * 255).round() > 0)
          Positioned.fill(
            child: ColoredBox(color: containerColor),
          ),
        // Each entry gets a lightweight animated wrapper
        for (final entry in entries)
          _AnimatedEntryWidget(
            entry: entry,
            activeAnimations: activeAnimations,
          ),
      ],
    );
  }
}

/// Per-entry widget that uses a custom RenderObject to paint
/// decorations (shadow, clip, overlay, opacity) without rebuilding
/// the widget tree. Only the RenderObject's paint method runs each frame.
class _AnimatedEntryWidget extends StatelessWidget {
  final HeroAnimationEntry entry;
  final ValueNotifier<List<HeroAnimationEntry>> activeAnimations;

  const _AnimatedEntryWidget({
    required this.entry,
    required this.activeAnimations,
  });

  @override
  Widget build(BuildContext context) {
    // Wrap the snapshot widget (built once) in a render object
    // that handles all animation painting.
    // NOTE: No RepaintBoundary here — RepaintBoundary creates a new
    // compositing layer which invalidates the parent canvas during paintChild.
    return _AnimatedEntryRenderWidget(
      entry: entry,
      activeAnimations: activeAnimations,
      // DefaultTextStyle removes yellow underlines that appear when Text
      // widgets are rendered outside a Material/Scaffold ancestor.
      child: DefaultTextStyle(
        style: const TextStyle(decoration: TextDecoration.none),
        child: SizedBox(
          width: entry.sourceRect.width,
          height: entry.sourceRect.height,
          child: entry.snapshotWidget,
        ),
      ),
    );
  }
}

/// RenderObjectWidget that creates a custom RenderBox for painting
/// animated hero entries efficiently.
class _AnimatedEntryRenderWidget extends SingleChildRenderObjectWidget {
  final HeroAnimationEntry entry;
  final ValueNotifier<List<HeroAnimationEntry>> activeAnimations;

  const _AnimatedEntryRenderWidget({
    required this.entry,
    required this.activeAnimations,
    required super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _AnimatedEntryRenderBox(
      entry: entry,
      activeAnimations: activeAnimations,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _AnimatedEntryRenderBox renderObject) {
    renderObject
      ..entry = entry
      ..activeAnimations = activeAnimations;
  }
}

/// Custom RenderBox that paints a hero animation entry.
/// Listens to the activeAnimations ValueNotifier and repaints
/// (via markNeedsPaint) on each frame — WITHOUT triggering widget rebuild.
///
/// Uses PaintingContext compositing methods (pushOpacity, pushTransform,
/// pushClipRRect) instead of raw canvas save/restore to properly handle
/// canvas lifecycle across child painting boundaries.
class _AnimatedEntryRenderBox extends RenderProxyBox {
  HeroAnimationEntry _entry;
  ValueNotifier<List<HeroAnimationEntry>> _activeAnimations;

  _AnimatedEntryRenderBox({
    required HeroAnimationEntry entry,
    required ValueNotifier<List<HeroAnimationEntry>> activeAnimations,
  })  : _entry = entry,
        _activeAnimations = activeAnimations {
    _activeAnimations.addListener(_onAnimationUpdate);
  }

  set entry(HeroAnimationEntry value) {
    if (_entry != value) {
      _entry = value;
      markNeedsPaint();
    }
  }

  set activeAnimations(ValueNotifier<List<HeroAnimationEntry>> value) {
    if (_activeAnimations != value) {
      _activeAnimations.removeListener(_onAnimationUpdate);
      _activeAnimations = value;
      _activeAnimations.addListener(_onAnimationUpdate);
    }
  }

  void _onAnimationUpdate() {
    // Just repaint — no widget rebuild, no layout
    markNeedsPaint();
  }

  @override
  void detach() {
    _activeAnimations.removeListener(_onAnimationUpdate);
    super.detach();
  }

  @override
  bool get sizedByParent => false;

  @override
  void performLayout() {
    // Size to fill parent (the Stack)
    if (constraints.hasBoundedWidth && constraints.hasBoundedHeight) {
      size = constraints.biggest;
    } else {
      size = constraints.constrain(Size(
        constraints.hasBoundedWidth ? constraints.maxWidth : 400,
        constraints.hasBoundedHeight ? constraints.maxHeight : 800,
      ));
    }
    // Layout child at source size
    if (child != null) {
      child!.layout(BoxConstraints.tight(Size(
        _entry.sourceRect.width.clamp(0, size.width),
        _entry.sourceRect.height.clamp(0, size.height),
      )), parentUsesSize: true);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final rect = _entry.currentRect;
    final opacity = _entry.currentOpacity.clamp(0.0, 1.0);

    // Skip invisible entries
    if (opacity <= 0.001 || rect.width <= 0 || rect.height <= 0) {
      return;
    }

    final entryOffset = offset + Offset(rect.left, rect.top);

    // Use PaintingContext compositing methods for correct canvas lifecycle.
    // This avoids the stale-canvas crash that occurs when paintChild()
    // creates a new compositing layer (e.g., due to RepaintBoundary).
    if (opacity < 0.999) {
      context.pushOpacity(
        entryOffset,
        (opacity * 255).round(),
        _paintWithTransform,
      );
    } else {
      _paintWithTransform(context, entryOffset);
    }
  }

  void _paintWithTransform(PaintingContext context, Offset offset) {
    // Apply transform around center of entry rect
    if (_entry.currentTransform != Matrix4.identity()) {
      final rect = _entry.currentRect;
      final xform = Matrix4.translationValues(rect.width / 2, rect.height / 2, 0)
        ..multiply(_entry.currentTransform)
        ..translate(-rect.width / 2, -rect.height / 2);
      context.pushTransform(
        needsCompositing,
        offset,
        xform,
        _paintDecorated,
      );
    } else {
      _paintDecorated(context, offset);
    }
  }

  void _paintDecorated(PaintingContext context, Offset offset) {
    final rect = _entry.currentRect;
    final cornerRadius = _entry.currentCornerRadius;
    final bounds = Rect.fromLTWH(0, 0, rect.width, rect.height);

    // 1. Paint shadow (outside clip, within transform+opacity)
    if (_entry.currentShadowOpacity > 0.001) {
      final canvas = context.canvas;
      final shadowPaint = Paint()
        ..color = _entry.currentShadowColor.withValues(
            alpha: _entry.currentShadowOpacity.clamp(0.0, 1.0))
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          _entry.currentShadowRadius * 0.5,
        );

      if (cornerRadius > 0) {
        final shadowRRect = RRect.fromRectAndRadius(
          bounds.shift(offset + _entry.currentShadowOffset),
          Radius.circular(cornerRadius),
        );
        canvas.drawRRect(shadowRRect, shadowPaint);
      } else {
        canvas.drawRect(
          bounds.shift(offset + _entry.currentShadowOffset),
          shadowPaint,
        );
      }
    }

    // 2. Paint background color
    if (_entry.currentBackgroundColor != null) {
      final canvas = context.canvas;
      final bgPaint = Paint()..color = _entry.currentBackgroundColor!;
      if (cornerRadius > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            bounds.shift(offset),
            Radius.circular(cornerRadius),
          ),
          bgPaint,
        );
      } else {
        canvas.drawRect(bounds.shift(offset), bgPaint);
      }
    }

    // 3. Paint child + overlay inside optional clip
    if (cornerRadius > 0) {
      final clipRect = bounds.shift(offset);
      final rrect = RRect.fromRectAndRadius(
        clipRect,
        Radius.circular(cornerRadius),
      );
      context.pushClipRRect(
        needsCompositing,
        Offset.zero,
        clipRect,
        rrect,
        _paintChildAndOverlay,
      );
    } else {
      _paintChildAndOverlay(context, offset);
    }
  }

  void _paintChildAndOverlay(PaintingContext context, Offset offset) {
    final rect = _entry.currentRect;

    // Paint the child (snapshot widget) scaled to current size
    if (child != null) {
      final scaleX = rect.width / _entry.sourceRect.width;
      final scaleY = rect.height / _entry.sourceRect.height;

      if ((scaleX - 1.0).abs() > 0.001 || (scaleY - 1.0).abs() > 0.001) {
        final scaleTransform = Matrix4.diagonal3Values(scaleX, scaleY, 1.0);
        context.pushTransform(
          needsCompositing,
          offset,
          scaleTransform,
          (ctx, off) => ctx.paintChild(child!, off),
        );
      } else {
        context.paintChild(child!, offset);
      }
    }

    // Paint overlay (after child, inside clip)
    if (_entry.overlayOpacity != null &&
        _entry.overlayOpacity! > 0.001 &&
        _entry.overlayColor != null) {
      final canvas = context.canvas;
      final overlayPaint = Paint()
        ..color = _entry.overlayColor!
            .withValues(alpha: _entry.overlayOpacity!.clamp(0.0, 1.0));
      canvas.drawRect(
        Rect.fromLTWH(offset.dx, offset.dy, rect.width, rect.height),
        overlayPaint,
      );
    }
  }

  @override
  bool hitTestSelf(Offset position) => false;
}
