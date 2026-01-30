import 'package:flutter/widgets.dart';
import '../modifiers/hero_modifier.dart';

/// Registration data for a single HeroView widget.
class HeroRegistration {
  /// The hero ID string.
  final String id;

  /// GlobalKey used to find the RenderBox for position/size measurement.
  final GlobalKey globalKey;

  /// Modifiers attached to this view.
  final List<HeroModifier>? modifiers;

  /// Whether this view is enabled for hero transitions.
  final bool isEnabled;

  /// The BuildContext of the HeroView widget.
  final BuildContext context;

  /// The Route this view belongs to (resolved lazily).
  Route<dynamic>? _route;

  HeroRegistration({
    required this.id,
    required this.globalKey,
    this.modifiers,
    this.isEnabled = true,
    required this.context,
  });

  /// Get the route this view belongs to.
  Route<dynamic>? get route {
    _route ??= ModalRoute.of(context);
    return _route;
  }

  /// Get the RenderBox for this view (may be null if not laid out).
  RenderBox? get renderBox {
    final ctx = globalKey.currentContext;
    if (ctx == null) return null;
    final renderObj = ctx.findRenderObject();
    if (renderObj is RenderBox && renderObj.hasSize) return renderObj;
    return null;
  }

  /// Get the global rect (position + size in screen coordinates).
  Rect? get globalRect {
    final box = renderBox;
    if (box == null) return null;
    final topLeft = box.localToGlobal(Offset.zero);
    return topLeft & box.size;
  }
}

/// Singleton registry that holds all active HeroView registrations.
/// The transition engine queries this to find source and destination views.
class HeroRegistry {
  HeroRegistry._();
  static final HeroRegistry instance = HeroRegistry._();

  /// All active registrations, keyed by hero ID.
  /// Multiple registrations can exist for the same ID (different routes).
  final Map<String, List<HeroRegistration>> _registrations = {};

  /// Register a HeroView.
  void register(HeroRegistration registration) {
    _registrations.putIfAbsent(registration.id, () => []);
    _registrations[registration.id]!.add(registration);
  }

  /// Unregister a HeroView by ID and context.
  void unregister(String id, BuildContext context) {
    final list = _registrations[id];
    if (list == null) return;
    list.removeWhere((r) => r.context == context);
    if (list.isEmpty) {
      _registrations.remove(id);
    }
  }

  /// Get all registrations for a specific route.
  List<HeroRegistration> viewsForRoute(Route<dynamic>? route) {
    if (route == null) return [];
    final result = <HeroRegistration>[];
    for (final list in _registrations.values) {
      for (final reg in list) {
        if (reg.isEnabled && reg.route == route) {
          result.add(reg);
        }
      }
    }
    return result;
  }

  /// Get a specific registration by ID and route.
  HeroRegistration? find(String id, Route<dynamic>? route) {
    final list = _registrations[id];
    if (list == null) return null;
    for (final reg in list) {
      if (reg.route == route) return reg;
    }
    return null;
  }

  /// Get all registered hero IDs.
  Set<String> get allIDs => _registrations.keys.toSet();

  /// Clear all registrations (for testing).
  void clear() => _registrations.clear();
}
