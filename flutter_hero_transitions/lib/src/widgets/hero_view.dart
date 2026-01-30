import 'package:flutter/widgets.dart';
import '../modifiers/hero_modifier.dart';
import '../transition/hero_registry.dart';

/// Widget that annotates a child with a Hero ID and modifiers.
/// This is the primary public API for marking widgets to participate
/// in Hero transitions.
///
/// Equivalent to setting `view.hero.id` and `view.hero.modifiers` on iOS.
///
/// Example:
/// ```dart
/// HeroView(
///   id: 'ironMan',
///   modifiers: [HeroModifier.fade, HeroModifier.scale(0.8)],
///   child: Container(width: 200, height: 200, color: Colors.red),
/// )
/// ```
class HeroView extends StatefulWidget {
  /// Unique identifier for matching views across routes.
  final String id;

  /// Modifiers that control the animation of this view.
  final List<HeroModifier>? modifiers;

  /// Whether this view participates in hero transitions.
  final bool isEnabled;

  /// Whether subviews should also be scanned for HeroView widgets.
  final bool isEnabledForSubviews;

  /// The child widget to wrap.
  final Widget child;

  const HeroView({
    super.key,
    required this.id,
    this.modifiers,
    this.isEnabled = true,
    this.isEnabledForSubviews = true,
    required this.child,
  });

  @override
  State<HeroView> createState() => _HeroViewState();
}

class _HeroViewState extends State<HeroView> {
  final GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _register();
  }

  @override
  void didUpdateWidget(HeroView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id ||
        oldWidget.modifiers != widget.modifiers ||
        oldWidget.isEnabled != widget.isEnabled) {
      _unregister(oldWidget.id);
      _register();
    }
  }

  @override
  void dispose() {
    _unregister(widget.id);
    super.dispose();
  }

  void _register() {
    if (!widget.isEnabled) return;
    HeroRegistry.instance.register(
      HeroRegistration(
        id: widget.id,
        globalKey: _globalKey,
        modifiers: widget.modifiers,
        isEnabled: widget.isEnabled,
        context: context,
      ),
    );
  }

  void _unregister(String id) {
    HeroRegistry.instance.unregister(id, context);
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _globalKey,
      child: widget.child,
    );
  }
}
