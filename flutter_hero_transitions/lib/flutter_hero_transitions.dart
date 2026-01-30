/// Flutter Hero Transitions - A powerful, declarative library for building
/// custom view transitions in Flutter.
///
/// Port of the iOS Hero library with 100% example parity.
library flutter_hero_transitions;

// --- Core Types ---
export 'src/types/hero_transition_state.dart';
export 'src/types/hero_animation_type.dart';
export 'src/types/hero_target_state.dart';
export 'src/types/hero_snapshot_type.dart';
export 'src/types/hero_coordinate_space.dart';
export 'src/types/hero_view_ordering_strategy.dart';
export 'src/types/cascade_direction.dart';
export 'src/types/hero_conditional_context.dart';

// --- Modifiers ---
export 'src/modifiers/hero_modifier.dart';

// --- Widgets ---
export 'src/widgets/hero_view.dart';
export 'src/widgets/hero_overlay.dart';
export 'src/widgets/hero_overlay_v2.dart'; // Optimized overlay
export 'src/widgets/hero_scope.dart';
export 'src/widgets/hero_interactive_gesture.dart';

// --- Transition ---
export 'src/transition/hero_transition_engine.dart';
export 'src/transition/hero_page_route.dart';
export 'src/transition/hero_navigator_observer.dart';
export 'src/transition/hero_context.dart';
export 'src/transition/hero_registry.dart';

// --- Animator ---
export 'src/animator/hero_default_animator.dart';
export 'src/animator/hero_animation_entry.dart';
export 'src/animator/arc_tween.dart';
export 'src/animator/hero_progress_runner.dart';
export 'src/animator/hero_spring_simulation.dart';
export 'src/animator/hero_spring_v2.dart'; // Improved spring with settling detection
export 'src/animator/hero_display_link.dart'; // CADisplayLink-style timing

// --- Plugins ---
export 'src/plugins/hero_plugin.dart';
export 'src/plugins/hero_debug_plugin.dart';

// --- Extensions ---
export 'src/extensions/rect_extensions.dart';
export 'src/extensions/offset_extensions.dart';
export 'src/extensions/matrix4_extensions.dart';
export 'src/extensions/curve_extensions.dart';
