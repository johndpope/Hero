import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'hero_plugin.dart';
import '../transition/hero_transition_engine.dart';
import '../animator/hero_animation_entry.dart';
import '../animator/arc_tween.dart';
import '../types/hero_transition_state.dart';
import '../widgets/hero_overlay_v2.dart';

/// Debug plugin that provides a visual overlay for inspecting Hero transitions.
///
/// Features:
/// - Slider to scrub through animation progress
/// - "Done" button to finish/cancel based on progress threshold
/// - "Show Arcs" button to visualize arc motion paths
/// - "3D View" button for perspective layer separation with pan/pinch gestures
///
/// Equivalent to iOS HeroDebugPlugin + HeroDebugView.
///
/// Enable with:
/// ```dart
/// HeroDebugPlugin.isEnabled = true;
/// ```
///
/// Then use [HeroDebugWrapper] instead of [HeroOverlayV2]:
/// ```dart
/// builder: (context, child) {
///   return Stack(
///     fit: StackFit.expand,
///     children: [
///       child!,
///       const HeroDebugWrapper(),
///     ],
///   );
/// },
/// ```
class HeroDebugPlugin extends HeroPlugin {
  /// Whether the debug plugin is enabled.
  static bool isEnabled = false;

  /// Whether the current transition has arc tweens.
  static final ValueNotifier<bool> hasArcs = ValueNotifier(false);

  /// Whether 3D perspective mode is active.
  static final ValueNotifier<bool> is3DActive = ValueNotifier(false);

  /// Whether arc visualization is active.
  static final ValueNotifier<bool> showArcsActive = ValueNotifier(false);

  /// 3D perspective transform applied to the overlay container.
  static final ValueNotifier<Matrix4> perspectiveTransform =
      ValueNotifier(Matrix4.identity());

  /// Background color shown when 3D mode is active.
  static final ValueNotifier<Color> debugContainerColor =
      ValueNotifier(const Color(0x00000000));

  @override
  bool get requirePerFrameCallback => true;

  @override
  bool canAnimate(String heroID, bool appearing) => isEnabled;

  @override
  Duration animate({
    required List<String> fromViewIDs,
    required List<String> toViewIDs,
  }) {
    if (!isEnabled) return Duration.zero;
    return const Duration(days: 999);
  }

  @override
  void clean() {
    hasArcs.value = false;
    is3DActive.value = false;
    showArcsActive.value = false;
    perspectiveTransform.value = Matrix4.identity();
    debugContainerColor.value = const Color(0x00000000);
  }

  /// Check active animations for arc tweens.
  static void _checkForArcs() {
    final entries = HeroTransitionEngine.shared.activeAnimations.value;
    bool found = false;
    for (final entry in entries) {
      if (entry.targetState.arcIntensity != null &&
          entry.targetState.arcIntensity! > 0) {
        found = true;
        break;
      }
    }
    hasArcs.value = found;
  }
}

// ---------------------------------------------------------------------------
// HeroDebugWrapper
// ---------------------------------------------------------------------------

/// Wrapper widget that combines [HeroOverlayV2] with debug controls.
///
/// Use this instead of [HeroOverlayV2] directly when the debug plugin
/// may be used. It handles 3D perspective transforms and the debug toolbar.
///
/// ```dart
/// builder: (context, child) {
///   return Stack(
///     fit: StackFit.expand,
///     children: [
///       child!,
///       const HeroDebugWrapper(),
///     ],
///   );
/// },
/// ```
class HeroDebugWrapper extends StatefulWidget {
  const HeroDebugWrapper({super.key});

  @override
  State<HeroDebugWrapper> createState() => _HeroDebugWrapperState();
}

class _HeroDebugWrapperState extends State<HeroDebugWrapper> {
  @override
  void initState() {
    super.initState();
    // Register the debug interactive hook on the engine.
    // When debug is enabled, this forces transitions into interactive mode.
    HeroTransitionEngine.shared.forceInteractiveHook =
        () => HeroDebugPlugin.isEnabled;
  }

  @override
  void dispose() {
    HeroTransitionEngine.shared.forceInteractiveHook = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Debug background (shows when 3D mode is active, BEHIND the transform)
        ValueListenableBuilder<Color>(
          valueListenable: HeroDebugPlugin.debugContainerColor,
          builder: (context, bgColor, _) {
            if (bgColor.a == 0) return const SizedBox.shrink();
            return ColoredBox(color: bgColor);
          },
        ),
        // 2. Overlay with optional 3D perspective transform
        ValueListenableBuilder<Matrix4>(
          valueListenable: HeroDebugPlugin.perspectiveTransform,
          builder: (context, transform, child) {
            if (transform == Matrix4.identity()) return child!;
            return Transform(
              transform: transform,
              alignment: Alignment.center,
              // Wrap overlay in a white background so the 3D plane
              // is visible. Without this, the overlay (transparent by
              // default) would be invisible when rotated in 3D.
              child: ColoredBox(
                color: const Color(0xFFFFFFFF),
                child: child,
              ),
            );
          },
          child: const HeroOverlayV2(),
        ),
        // 3. Debug controls overlay (on top of everything)
        const HeroDebugOverlay(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// HeroDebugOverlay
// ---------------------------------------------------------------------------

/// Debug overlay widget that shows transition scrub controls.
///
/// This is the controls-only widget. For a complete solution with 3D
/// perspective support, use [HeroDebugWrapper] instead.
class HeroDebugOverlay extends StatefulWidget {
  const HeroDebugOverlay({super.key});

  @override
  State<HeroDebugOverlay> createState() => _HeroDebugOverlayState();
}

class _HeroDebugOverlayState extends State<HeroDebugOverlay>
    with SingleTickerProviderStateMixin {
  final _engine = HeroTransitionEngine.shared;
  double _sliderValue = 0.0;
  bool _isVisible = false;
  bool _finishing = false;
  bool _is3D = false;
  bool _showArcs = false;

  // 3D perspective gesture state (matching iOS HeroDebugView defaults)
  double _rotation = math.pi / 6;
  double _scale = 0.6;
  Offset _translation = Offset.zero;
  double _startRotation = 0;
  double _startScale = 1;
  Offset _startTranslation = Offset.zero;
  Offset _gestureStartFocalPoint = Offset.zero;

  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _engine.addListener(_onEngineStateChanged);
  }

  @override
  void dispose() {
    _engine.removeListener(_onEngineStateChanged);
    _slideController.dispose();
    super.dispose();
  }

  void _onEngineStateChanged() {
    if (!mounted) return;
    final state = _engine.state;

    if (state == HeroTransitionState.animating &&
        HeroDebugPlugin.isEnabled &&
        _engine.debugForceInteractive) {
      if (!_isVisible) {
        // First time showing controls for this transition.
        HeroDebugPlugin._checkForArcs();
        setState(() {
          _isVisible = true;
          _finishing = false;
          _sliderValue = _engine.isPresenting ? 0.0 : 1.0;
        });
        _slideController.forward();
      } else {
        // Controls already visible (e.g., rapid navigation after Done).
        // The previous transition's _finishing flag or stale _sliderValue
        // may still be set. Reset them so the slider works for the new
        // transition.
        setState(() {
          _finishing = false;
          _sliderValue = _engine.isPresenting ? 0.0 : 1.0;
        });
        HeroDebugPlugin._checkForArcs();
      }
    } else if (state == HeroTransitionState.possible && _isVisible) {
      // Transition ended — hide controls
      _slideController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _isVisible = false;
            _finishing = false;
            _is3D = false;
            _showArcs = false;
          });
          // Reset 3D state
          _rotation = math.pi / 6;
          _scale = 0.6;
          _translation = Offset.zero;
          HeroDebugPlugin.is3DActive.value = false;
          HeroDebugPlugin.showArcsActive.value = false;
          HeroDebugPlugin.perspectiveTransform.value = Matrix4.identity();
          HeroDebugPlugin.debugContainerColor.value =
              const Color(0x00000000);
        }
      });
    }
  }

  // --- Slider ---

  void _onSliderChanged(double value) {
    if (_finishing) return;
    setState(() => _sliderValue = value);
    // Map slider direction based on presenting/dismissing (iOS parity)
    final seekValue = _engine.isPresenting ? value : 1.0 - value;
    _engine.update(seekValue);
  }

  // --- Done button ---

  void _onDone() {
    if (_finishing) return;
    _finishing = true;

    // Disable 3D mode before finishing
    if (_is3D) {
      _toggle3D();
    }

    final seekValue =
        _engine.isPresenting ? _sliderValue : 1.0 - _sliderValue;
    if (seekValue > 0.5) {
      _engine.finish();
    } else {
      _engine.cancel();
    }
  }

  // --- 3D View ---

  void _toggle3D() {
    setState(() {
      _is3D = !_is3D;
      HeroDebugPlugin.is3DActive.value = _is3D;
    });
    if (_is3D) {
      // Reset gesture state to defaults when entering 3D mode
      _rotation = math.pi / 6;
      _scale = 0.6;
      _translation = Offset.zero;
      _apply3DTransform();
      // Light gray background matching iOS (UIColor(white: 0.85, alpha: 1.0))
      HeroDebugPlugin.debugContainerColor.value =
          const Color(0xFFD9D9D9);
    } else {
      HeroDebugPlugin.perspectiveTransform.value = Matrix4.identity();
      HeroDebugPlugin.debugContainerColor.value =
          const Color(0x00000000);
    }
  }

  void _apply3DTransform() {
    // Matching iOS: CATransform3DIdentity with m34 = -1/4000,
    // then translate, scale, rotateY
    final transform = Matrix4.identity()
      ..setEntry(3, 2, -1.0 / 4000.0) // perspective (m34)
      ..translate(_translation.dx, _translation.dy, 0.0)
      ..scale(_scale, _scale, 1.0)
      ..rotateY(_rotation);
    HeroDebugPlugin.perspectiveTransform.value = transform;
  }

  // --- Show Arcs ---

  void _toggleShowArcs() {
    setState(() {
      _showArcs = !_showArcs;
      HeroDebugPlugin.showArcsActive.value = _showArcs;
    });
  }

  // --- 3D Gesture Handlers ---
  // iOS uses pan (1 finger → rotation) and pinch (2 fingers → scale+translate)
  // Flutter's Scale gesture handles both.

  void _onScaleStart(ScaleStartDetails details) {
    if (!_is3D) return;
    _startRotation = _rotation;
    _startScale = _scale;
    _startTranslation = _translation;
    _gestureStartFocalPoint = details.focalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (!_is3D) return;

    if (details.pointerCount >= 2) {
      // Pinch: scale + translate (matching iOS pinchGR behavior)
      _scale = (_startScale * details.scale).clamp(0.2, 1.0);
      _translation =
          _startTranslation + details.focalPoint - _gestureStartFocalPoint;
    } else {
      // Single finger pan: Y-axis rotation (matching iOS panGR)
      final cumulativeDelta =
          details.focalPoint - _gestureStartFocalPoint;
      _rotation = _startRotation + cumulativeDelta.dx / 150;
      // Wrap at ±π (matching iOS behavior)
      if (_rotation > math.pi) _rotation -= 2 * math.pi;
      if (_rotation < -math.pi) _rotation += 2 * math.pi;
    }
    _apply3DTransform();
  }

  // --- Build ---

  @override
  Widget build(BuildContext context) {
    if (!HeroDebugPlugin.isEnabled) return const SizedBox.shrink();
    if (!_isVisible && !_slideController.isAnimating) {
      return const SizedBox.shrink();
    }

    return Stack(
      // Clip.none so the toolbar's hit-test area isn't clipped during
      // the slide-in animation (Transform.translate pushes it off-screen
      // temporarily; Clip.hardEdge would block touches even after it
      // animates back into bounds if the framework caches the clip).
      clipBehavior: Clip.none,
      children: [
        // Arc path visualization (behind everything, IgnorePointer)
        if (_showArcs)
          Positioned.fill(
            child: IgnorePointer(
              child: ValueListenableBuilder<List<HeroAnimationEntry>>(
                valueListenable: _engine.activeAnimations,
                builder: (context, entries, _) {
                  return CustomPaint(
                    painter: _ArcPathPainter(entries: entries),
                  );
                },
              ),
            ),
          ),

        // 3D gesture area (full screen, opaque — captures all gestures
        // to prevent them from reaching the underlying route content.
        // The toolbar is placed AFTER this in the Stack, so it still
        // receives touch events due to Stack hit-test ordering.)
        if (_is3D)
          Positioned.fill(
            child: GestureDetector(
              onScaleStart: _onScaleStart,
              onScaleUpdate: _onScaleUpdate,
              behavior: HitTestBehavior.opaque,
            ),
          ),

        // Bottom toolbar (highest touch priority in Stack)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedBuilder(
            animation: _slideController,
            builder: (context, child) {
              final safeBottom = MediaQuery.of(context).padding.bottom;
              final toolbarHeight = 72.0 + safeBottom;
              final offset =
                  (1.0 - _slideController.value) * (toolbarHeight + 8);
              return Transform.translate(
                offset: Offset(0, offset),
                child: child,
              );
            },
            child: _buildToolbar(context),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(
        // Matching iOS: white 95% opacity with shadow
        color: const Color(0xF2FFFFFF),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            blurRadius: 5,
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: safeBottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Button row (matching iOS layout: Done | Show Arcs | 3D View)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 10, right: 10),
            child: SizedBox(
              height: 24,
              child: Row(
                children: [
                  _ToolbarButton(
                    label: 'Done',
                    isActive: false,
                    onTap: _onDone,
                  ),
                  const Spacer(),
                  ValueListenableBuilder<bool>(
                    valueListenable: HeroDebugPlugin.hasArcs,
                    builder: (context, hasArcs, _) {
                      if (!hasArcs) return const SizedBox.shrink();
                      return _ToolbarButton(
                        label: 'Show Arcs',
                        isActive: _showArcs,
                        onTap: _toggleShowArcs,
                      );
                    },
                  ),
                  const Spacer(),
                  _ToolbarButton(
                    label: '3D View',
                    isActive: _is3D,
                    onTap: _toggle3D,
                  ),
                ],
              ),
            ),
          ),
          // Slider (0.0 to 1.0) — Custom gesture-based slider.
          // Uses raw GestureDetector to avoid Material/CupertinoSlider
          // Overlay dependency (the debug overlay sits above the Navigator
          // in the widget tree, so no Overlay ancestor exists).
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              height: 44,
              child: _DebugSlider(
                value: _sliderValue,
                onChanged: _onSliderChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private helper widgets
// ---------------------------------------------------------------------------

/// Toolbar button matching iOS system button style.
class _ToolbarButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Text(
          label,
          style: TextStyle(
            // iOS system blue (#007AFF)
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : const Color(0xFF007AFF),
            fontSize: 15,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom debug slider (no Material/Overlay dependency)
// ---------------------------------------------------------------------------

/// Minimal slider widget that uses raw GestureDetector for drag handling.
/// Avoids Material `Slider` and `CupertinoSlider` which both require an
/// `Overlay` ancestor — unavailable in the MaterialApp builder where the
/// debug overlay lives.
///
/// Visually matches iOS UISlider: thin track with round white thumb.
class _DebugSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _DebugSlider({
    required this.value,
    required this.onChanged,
  });

  void _handleDrag(Offset localPosition, double trackWidth) {
    // 14px thumb radius on each side as inset
    const thumbRadius = 14.0;
    final usableWidth = trackWidth - thumbRadius * 2;
    final newValue =
        ((localPosition.dx - thumbRadius) / usableWidth).clamp(0.0, 1.0);
    onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (details) {
            _handleDrag(details.localPosition, trackWidth);
          },
          onHorizontalDragUpdate: (details) {
            _handleDrag(details.localPosition, trackWidth);
          },
          onTapDown: (details) {
            _handleDrag(details.localPosition, trackWidth);
          },
          child: CustomPaint(
            size: Size(trackWidth, constraints.maxHeight),
            painter: _DebugSliderPainter(value: value),
          ),
        );
      },
    );
  }
}

/// Painter for the custom debug slider.
/// Draws a thin track with active/inactive segments and a white thumb.
class _DebugSliderPainter extends CustomPainter {
  final double value;

  _DebugSliderPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    const thumbRadius = 14.0;
    const trackHeight = 2.0;
    final centerY = size.height / 2;
    final usableWidth = size.width - thumbRadius * 2;
    final thumbX = thumbRadius + usableWidth * value;

    // Inactive track (full width)
    final inactiveTrackPaint = Paint()
      ..color = const Color(0xFFB0B0B0)
      ..strokeWidth = trackHeight
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(thumbRadius, centerY),
      Offset(size.width - thumbRadius, centerY),
      inactiveTrackPaint,
    );

    // Active track (from left to thumb)
    if (value > 0.001) {
      final activeTrackPaint = Paint()
        ..color = const Color(0xFF007AFF)
        ..strokeWidth = trackHeight
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(thumbRadius, centerY),
        Offset(thumbX, centerY),
        activeTrackPaint,
      );
    }

    // Thumb (white circle with shadow)
    final shadowPaint = Paint()
      ..color = const Color(0x40000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    canvas.drawCircle(Offset(thumbX, centerY), thumbRadius, shadowPaint);

    final thumbPaint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawCircle(Offset(thumbX, centerY), thumbRadius - 0.5, thumbPaint);

    // Subtle border on thumb
    final borderPaint = Paint()
      ..color = const Color(0x20000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawCircle(Offset(thumbX, centerY), thumbRadius - 0.5, borderPaint);
  }

  @override
  bool shouldRepaint(_DebugSliderPainter oldDelegate) {
    return value != oldDelegate.value;
  }
}

// ---------------------------------------------------------------------------
// Arc path painter
// ---------------------------------------------------------------------------

/// Paints arc motion paths for entries with arc tweens.
/// Shows the quadratic Bezier curve that elements follow during transition.
class _ArcPathPainter extends CustomPainter {
  final List<HeroAnimationEntry> entries;

  _ArcPathPainter({required this.entries});

  @override
  void paint(Canvas canvas, Size size) {
    final pathPaint = Paint()
      ..color = const Color(0xFF0000FF) // blue stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final dotPaint = Paint()
      ..color = const Color(0xFF0000FF)
      ..style = PaintingStyle.fill;

    for (final entry in entries) {
      if (entry.targetState.arcIntensity == null ||
          entry.targetState.arcIntensity! <= 0) {
        continue;
      }

      // Recreate the arc tween matching the entry's configuration
      final arcTween = ArcTween(
        begin: entry.sourceRect.center,
        end: entry.targetRect.center,
        intensity: entry.targetState.arcIntensity!,
      );

      // Sample the arc path at many points for smooth rendering
      final path = Path();
      const steps = 60;
      for (int i = 0; i <= steps; i++) {
        final t = i / steps;
        final point = arcTween.lerp(t);
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }

      canvas.drawPath(path, pathPaint);

      // Draw start and end dots
      canvas.drawCircle(entry.sourceRect.center, 4, dotPaint);
      canvas.drawCircle(entry.targetRect.center, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_ArcPathPainter oldDelegate) {
    return !identical(entries, oldDelegate.entries);
  }
}
