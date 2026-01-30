import 'dart:ui';
import 'package:flutter/widgets.dart';
import '../types/hero_target_state.dart';
import '../modifiers/hero_modifier.dart';
import 'hero_registry.dart';

/// Context object that holds all transition data during an active transition.
/// Manages source/destination view mappings, target states, and matched IDs.
///
/// Equivalent to iOS HeroContext.
class HeroContext {
  /// The size of the transition container (screen size).
  final Size containerSize;

  /// Source (from) view registrations.
  final List<HeroRegistration> fromViews;

  /// Destination (to) view registrations.
  final List<HeroRegistration> toViews;

  /// Maps hero ID -> source view registration.
  final Map<String, HeroRegistration> _heroIDToSourceView = {};

  /// Maps hero ID -> destination view registration.
  final Map<String, HeroRegistration> _heroIDToDestView = {};

  /// Target states for each hero ID (written by preprocessors, read by animators).
  final Map<String, HeroTargetState> _targetStates = {};

  /// Global rects for each hero ID (cached from RenderBox).
  final Map<String, Rect> _sourceRects = {};
  final Map<String, Rect> _destRects = {};

  HeroContext({
    required this.containerSize,
    required this.fromViews,
    required this.toViews,
  }) {
    _processViews(fromViews, _heroIDToSourceView, _sourceRects);
    _processViews(toViews, _heroIDToDestView, _destRects);
  }

  void _processViews(
    List<HeroRegistration> views,
    Map<String, HeroRegistration> idMap,
    Map<String, Rect> rectMap,
  ) {
    for (final view in views) {
      final rect = view.globalRect;
      if (rect != null) {
        // Check if view is within screen bounds (or we'll check forceAnimate later)
        final screenRect = Offset.zero & containerSize;
        if (rect.overlaps(screenRect) || rect.width == 0 || rect.height == 0) {
          idMap[view.id] = view;
          rectMap[view.id] = rect;
        }
      }
    }
  }

  /// Get the source registration for a hero ID.
  HeroRegistration? sourceView(String heroID) => _heroIDToSourceView[heroID];

  /// Get the destination registration for a hero ID.
  HeroRegistration? destinationView(String heroID) => _heroIDToDestView[heroID];

  /// Find the paired view (source <-> destination) for a registration.
  HeroRegistration? pairedView(HeroRegistration view) {
    if (_heroIDToSourceView[view.id] == view) {
      return _heroIDToDestView[view.id];
    }
    if (_heroIDToDestView[view.id] == view) {
      return _heroIDToSourceView[view.id];
    }
    return null;
  }

  /// Get the global rect for a source view.
  Rect? sourceRect(String heroID) => _sourceRects[heroID];

  /// Get the global rect for a destination view.
  Rect? destRect(String heroID) => _destRects[heroID];

  /// Get/set target state for a hero ID.
  HeroTargetState? operator [](String heroID) => _targetStates[heroID];
  void operator []=(String heroID, HeroTargetState? state) {
    if (state == null) {
      _targetStates.remove(heroID);
    } else {
      _targetStates[heroID] = state;
    }
  }

  /// Get or create a target state for a hero ID.
  HeroTargetState targetStateFor(String heroID) {
    return _targetStates.putIfAbsent(heroID, () => HeroTargetState());
  }

  /// Apply modifiers to a hero ID's target state.
  void applyModifiers(String heroID, List<HeroModifier> modifiers) {
    final state = targetStateFor(heroID);
    for (final modifier in modifiers) {
      modifier.apply(state);
    }
  }

  /// Get all matched hero IDs (present in both source and destination).
  Set<String> get matchedIDs {
    return _heroIDToSourceView.keys
        .toSet()
        .intersection(_heroIDToDestView.keys.toSet());
  }

  /// Get all unmatched source view IDs.
  Set<String> get unmatchedSourceIDs {
    return _heroIDToSourceView.keys
        .toSet()
        .difference(_heroIDToDestView.keys.toSet());
  }

  /// Get all unmatched destination view IDs.
  Set<String> get unmatchedDestIDs {
    return _heroIDToDestView.keys
        .toSet()
        .difference(_heroIDToSourceView.keys.toSet());
  }

  /// Get all source hero IDs.
  Set<String> get sourceIDs => _heroIDToSourceView.keys.toSet();

  /// Get all destination hero IDs.
  Set<String> get destIDs => _heroIDToDestView.keys.toSet();

  /// Get all hero IDs (union of source and destination).
  Set<String> get allIDs => sourceIDs.union(destIDs);

  /// Check if a hero ID is matched.
  bool isMatched(String heroID) =>
      _heroIDToSourceView.containsKey(heroID) &&
      _heroIDToDestView.containsKey(heroID);
}
