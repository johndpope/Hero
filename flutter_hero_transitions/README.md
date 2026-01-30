# flutter_hero_transitions

A powerful, declarative library for building custom view transitions in Flutter.
This is a complete Flutter port of the [iOS Hero library](https://github.com/HeroTransitions/Hero)
with 100% example parity.

> **Important:** This package is _not_ related to Flutter's built-in `Hero` widget.
> `flutter_hero_transitions` is an independent transition system that provides
> ID-based view matching, 50+ composable modifiers, 14 built-in animation types,
> interactive gesture-driven transitions, and a plugin architecture -- all mirroring
> the iOS Hero library's API and behavior.

---

## Table of Contents

1. [Features](#features)
2. [Quick Start](#quick-start)
3. [Modifier Reference](#modifier-reference)
4. [Animation Types](#animation-types)
5. [Interactive Transitions](#interactive-transitions)
6. [Cascade Animations](#cascade-animations)
7. [Plugin System](#plugin-system)
8. [Comparison with iOS Hero](#comparison-with-ios-hero)
9. [Examples](#examples)
10. [Requirements](#requirements)
11. [License](#license)

---

## Features

- **50+ modifiers** -- position, size, opacity, transform (scale, rotate, translate, perspective), shadow, border, cornerRadius, backgroundColor, overlay, contentsRect, arc motion, spring physics, timing (duration, delay, curve), cascade, conditional, and more.
- **14 built-in animation types** -- `push`, `pull`, `cover`, `uncover`, `slide`, `zoomSlide`, `pageIn`, `pageOut`, `fade`, `zoom`, `zoomOut`, `selectBy`, `autoReverse`, and `none`.
- **ID-based view matching** -- pair widgets across screens by assigning matching string identifiers. The engine automatically animates matched pairs between routes.
- **Interactive pan-to-dismiss gestures** -- wrap any screen with `HeroInteractiveGesture` to enable swipe-to-dismiss with configurable direction, threshold, and velocity sensitivity.
- **Cascade animations** -- stagger child view animations with six direction modes: `topToBottom`, `bottomToTop`, `leftToRight`, `rightToLeft`, `radial`, and `inverseRadial`.
- **Arc motion paths** -- animate position changes along quadratic Bezier curves instead of straight lines, with configurable intensity.
- **Spring physics support** -- drive animations with spring dynamics using custom stiffness and damping parameters.
- **Plugin system with debug overlay** -- extend the transition engine with custom preprocessors and animators. Built-in `HeroDebugPlugin` provides a slider overlay for scrubbing through transition progress.
- **Conditional modifiers** -- apply modifiers only when specific conditions are met (matched, presenting, dismissing, appearing, disappearing, or a custom predicate).
- **Zero external dependencies** -- requires only the Flutter SDK.

---

## Quick Start

### 1. Add the dependency

```yaml
dependencies:
  flutter_hero_transitions:
    path: ../flutter_hero_transitions  # or publish to pub.dev
```

### 2. Wire up the observer and overlay

```dart
import 'package:flutter_hero_transitions/flutter_hero_transitions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Step A: Register the navigator observer
      navigatorObservers: [
        HeroTransitionObserver(),
      ],
      // Step B: Add the overlay above the navigator
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            const HeroOverlay(),
          ],
        );
      },
      home: const HomeScreen(),
    );
  }
}
```

### 3. Mark widgets with HeroView

```dart
// On the source screen
HeroView(
  id: 'profile-avatar',
  modifiers: [HeroModifier.fade, HeroModifier.scale(0.8)],
  child: const CircleAvatar(radius: 40, backgroundImage: AssetImage('avatar.png')),
);

// On the destination screen -- use the same id
HeroView(
  id: 'profile-avatar',
  child: Image.asset('avatar.png', width: 300, height: 300, fit: BoxFit.cover),
);
```

### 4. Navigate with HeroPageRoute

```dart
Navigator.of(context).push(
  HeroPageRoute(
    builder: (_) => const DetailScreen(),
    animationType: HeroAnimationType.push(direction: HeroAnimationDirection.left),
  ),
);
```

The engine detects the route change, finds all `HeroView` widgets with matching IDs
across the outgoing and incoming routes, computes target states from the declared
modifiers, and animates every property simultaneously in the `HeroOverlay`.

---

## Modifier Reference

All modifiers are accessed as static members of `HeroModifier`.

### Basic Modifiers

| Modifier | Signature | Description |
|---|---|---|
| `fade` | `HeroModifier.fade` | Fade the view to opacity 0 during transition. |
| `forceNonFade` | `HeroModifier.forceNonFade` | Prevent the view from fading even if it would by default. |
| `position` | `HeroModifier.position(Offset)` | Set the target position (top-left offset). |
| `size` | `HeroModifier.size(Size)` | Set the target size. |
| `opacity` | `HeroModifier.opacity(double)` | Set a specific target opacity (0.0 to 1.0). |

### Transform Modifiers

| Modifier | Signature | Description |
|---|---|---|
| `transform` | `HeroModifier.transform(Matrix4)` | Set the full 4x4 transform matrix. |
| `perspective` | `HeroModifier.perspective(double)` | Apply perspective to the transform (1/value on z-axis). |
| `scale` | `HeroModifier.scale(double)` | Scale uniformly on x and y axes. |
| `scaleXYZ` | `HeroModifier.scaleXYZ({x, y, z})` | Scale independently on each axis. |
| `translate` | `HeroModifier.translate({x, y, z})` | Translate by x, y, z offsets. |
| `translateOffset` | `HeroModifier.translateOffset(Offset, {z})` | Translate by an Offset with optional z. |
| `rotate` | `HeroModifier.rotate({x, y, z})` | Rotate on each axis in radians. |
| `rotateZ` | `HeroModifier.rotateZ(double)` | Rotate on the z-axis only (convenience). |

### Appearance Modifiers

| Modifier | Signature | Description |
|---|---|---|
| `cornerRadius` | `HeroModifier.cornerRadius(double)` | Animate the corner radius. |
| `backgroundColor` | `HeroModifier.backgroundColor(Color)` | Set the target background color. |
| `borderColor` | `HeroModifier.borderColor(Color)` | Set the target border color. |
| `borderWidth` | `HeroModifier.borderWidth(double)` | Set the target border width. |
| `zPosition` | `HeroModifier.zPosition(double)` | Control z-ordering / elevation. |
| `masksToBounds` | `HeroModifier.masksToBounds(bool)` | Whether the view clips to its bounds. |
| `overlay` | `HeroModifier.overlay({color, opacity})` | Apply a color overlay on the view. |

### Shadow Modifiers

| Modifier | Signature | Description |
|---|---|---|
| `shadowColor` | `HeroModifier.shadowColor(Color)` | Set the shadow color. |
| `shadowOpacity` | `HeroModifier.shadowOpacity(double)` | Set shadow opacity. |
| `shadowOffset` | `HeroModifier.shadowOffset(Offset)` | Set shadow offset. |
| `shadowRadius` | `HeroModifier.shadowRadius(double)` | Set shadow blur radius. |

### Contents Modifiers

| Modifier | Signature | Description |
|---|---|---|
| `contentsRect` | `HeroModifier.contentsRect(Rect)` | Set the contents rect (image cropping region). |
| `contentsScale` | `HeroModifier.contentsScale(double)` | Set the contents scale factor. |

### Timing Modifiers

| Modifier | Signature | Description |
|---|---|---|
| `duration` | `HeroModifier.duration(Duration)` | Set animation duration for this view. |
| `durationSeconds` | `HeroModifier.durationSeconds(double)` | Set duration in seconds (convenience). |
| `durationMatchLongest` | `HeroModifier.durationMatchLongest` | Match the longest animation duration in the transition. |
| `delay` | `HeroModifier.delay(Duration)` | Set animation delay for this view. |
| `delaySeconds` | `HeroModifier.delaySeconds(double)` | Set delay in seconds (convenience). |
| `curve` | `HeroModifier.curve(Curve)` | Set the animation curve (easing). |
| `spring` | `HeroModifier.spring({stiffness, damping})` | Use spring physics with custom parameters. |

### Arc Motion Modifier

| Modifier | Signature | Description |
|---|---|---|
| `arc` | `HeroModifier.arc` | Animate position along a curved arc path (intensity 1.0). |
| `arcWithIntensity` | `HeroModifier.arcWithIntensity(double)` | Arc path with custom intensity. |

### Source Modifier

| Modifier | Signature | Description |
|---|---|---|
| `source` | `HeroModifier.source({heroID})` | Transition from/to the state of the view with the given ID. |

### Cascade Modifier

| Modifier | Signature | Description |
|---|---|---|
| `cascadeDefault` | `HeroModifier.cascadeDefault` | Stagger children top-to-bottom with 20ms delta. |
| `cascade` | `HeroModifier.cascade({delta, direction, delayMatchedViews})` | Stagger children with full configuration. |

### Snapshot Type Modifiers

| Modifier | Signature | Description |
|---|---|---|
| `useOptimizedSnapshot` | `HeroModifier.useOptimizedSnapshot` | Use optimized snapshot during transition. |
| `useNormalSnapshot` | `HeroModifier.useNormalSnapshot` | Use normal snapshot. |
| `useLayerRenderSnapshot` | `HeroModifier.useLayerRenderSnapshot` | Use layer-render snapshot. |
| `useNoSnapshot` | `HeroModifier.useNoSnapshot` | Animate the actual widget (no snapshot). |

### Advanced Modifiers

| Modifier | Signature | Description |
|---|---|---|
| `beginWith` | `HeroModifier.beginWith(List<HeroModifier>)` | Apply modifiers instantly at transition start (not animated). |
| `useGlobalCoordinateSpace` | `HeroModifier.useGlobalCoordinateSpace` | Use global coordinates for position calculations. |
| `ignoreSubviewModifiers` | `HeroModifier.ignoreSubviewModifiers` | Ignore modifiers on subviews. |
| `ignoreSubviewModifiersRecursive` | `HeroModifier.ignoreSubviewModifiersRecursive({recursive})` | Ignore subview modifiers, optionally recursive. |
| `forceAnimate` | `HeroModifier.forceAnimate` | Force animation even if offscreen or unchanged. |
| `useScaleBasedSizeChange` | `HeroModifier.useScaleBasedSizeChange` | Use scale transform for size changes instead of bounds animation. |

### Conditional Modifiers

| Modifier | Signature | Description |
|---|---|---|
| `when` | `HeroModifier.when(condition, modifiers)` | Apply modifiers only when a predicate returns true. |
| `whenMatched` | `HeroModifier.whenMatched(modifiers)` | Apply only when this view has a matching pair. |
| `whenPresenting` | `HeroModifier.whenPresenting(modifiers)` | Apply only during push (presenting) transitions. |
| `whenDismissing` | `HeroModifier.whenDismissing(modifiers)` | Apply only during pop (dismissing) transitions. |
| `whenAppearing` | `HeroModifier.whenAppearing(modifiers)` | Apply only to the destination (appearing) view. |
| `whenDisappearing` | `HeroModifier.whenDisappearing(modifiers)` | Apply only to the source (disappearing) view. |

---

## Animation Types

All animation types are constructed via named constructors on `HeroAnimationType`.
Directional types accept a `HeroAnimationDirection` (`left`, `right`, `up`, `down`).

| Type | Constructor | Description |
|---|---|---|
| Auto | `HeroAnimationType.auto()` | Automatic animation based on navigation action. |
| Push | `HeroAnimationType.push(direction:)` | Both views move in the given direction; incoming view pushes outgoing view. |
| Pull | `HeroAnimationType.pull(direction:)` | Reverse of push; outgoing view pulls away to reveal incoming view. |
| Cover | `HeroAnimationType.cover(direction:)` | Incoming view slides in over the stationary outgoing view. |
| Uncover | `HeroAnimationType.uncover(direction:)` | Outgoing view slides away to uncover the stationary incoming view. |
| Slide | `HeroAnimationType.slide(direction:)` | Both views slide simultaneously in the given direction. |
| Zoom Slide | `HeroAnimationType.zoomSlide(direction:)` | Combines zoom and slide; outgoing view zooms out while incoming slides in. |
| Page In | `HeroAnimationType.pageIn(direction:)` | Page-turn style animation; incoming view flips in from the given direction. |
| Page Out | `HeroAnimationType.pageOut(direction:)` | Page-turn style animation; outgoing view flips out in the given direction. |
| Fade | `HeroAnimationType.fade()` | Cross-fade between outgoing and incoming views. |
| Zoom | `HeroAnimationType.zoom()` | Incoming view zooms in from the center. |
| Zoom Out | `HeroAnimationType.zoomOut()` | Outgoing view zooms out toward the center. |
| Select By | `HeroAnimationType.selectBy({presenting, dismissing})` | Use one animation type for presenting and a different one for dismissing. |
| Auto Reverse | `HeroAnimationType.autoReverse({presenting})` | Automatically reverse the presenting animation on dismiss. |
| None | `HeroAnimationType.none()` | No animation; views switch instantly. |

### Usage

```dart
// Push with left direction
Navigator.push(context, HeroPageRoute(
  builder: (_) => const DetailScreen(),
  animationType: HeroAnimationType.push(direction: HeroAnimationDirection.left),
));

// Fade transition
Navigator.push(context, HeroPageRoute(
  builder: (_) => const DetailScreen(),
  animationType: HeroAnimationType.fade(),
));

// Different animations for push vs pop
Navigator.push(context, HeroPageRoute(
  builder: (_) => const DetailScreen(),
  animationType: HeroAnimationType.selectBy(
    presenting: HeroAnimationType.cover(direction: HeroAnimationDirection.up),
    dismissing: HeroAnimationType.uncover(direction: HeroAnimationDirection.down),
  ),
));

// Auto-reversing (dismiss reverses the push animation)
Navigator.push(context, HeroPageRoute(
  builder: (_) => const DetailScreen(),
  animationType: HeroAnimationType.autoReverse(
    presenting: HeroAnimationType.zoomSlide(direction: HeroAnimationDirection.left),
  ),
));
```

---

## Interactive Transitions

Wrap a screen's content with `HeroInteractiveGesture` to enable gesture-driven
dismiss transitions. The user drags to control the transition progress and the
engine finishes or cancels based on the final position and velocity.

```dart
class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HeroInteractiveGesture(
      // Which directions trigger the dismiss gesture
      directions: {HeroAnimationDirection.down},
      // Progress threshold to commit the dismiss (0.0 to 1.0)
      finishThreshold: 0.5,
      // Whether fling velocity affects the finish/cancel decision
      useVelocity: true,
      velocityThreshold: 1000.0,
      // Optional: custom dismiss logic
      onDismiss: () => Navigator.of(context).pop(),
      // Optional: track progress for custom UI (e.g., dimming background)
      onProgressUpdate: (progress) {
        // progress is 0.0 (start) to 1.0 (fully dismissed)
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Detail')),
        body: Center(
          child: HeroView(
            id: 'photo',
            child: Image.asset('photo.jpg'),
          ),
        ),
      ),
    );
  }
}
```

### Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `child` | `Widget` | required | The screen content to wrap. |
| `onDismiss` | `VoidCallback?` | `null` | Called when the gesture begins dismissing. Defaults to `Navigator.pop()`. |
| `directions` | `Set<HeroAnimationDirection>` | `{down}` | Drag directions that trigger the dismiss gesture. |
| `finishThreshold` | `double` | `0.5` | Progress value above which the transition commits. |
| `useVelocity` | `bool` | `true` | Factor drag velocity into the finish/cancel decision. |
| `velocityThreshold` | `double` | `1000.0` | Velocity (px/s) that forces a finish regardless of progress. |
| `onProgressUpdate` | `void Function(double)?` | `null` | Callback with current progress during the gesture. |

---

## Cascade Animations

Cascade animations stagger the animation of child views so they do not all start
at once. This creates a ripple or wave effect across a collection of items.

### Cascade Directions

| Direction | Constructor | Description |
|---|---|---|
| Top to Bottom | `CascadeDirection.topToBottom()` | Items at the top animate first. |
| Bottom to Top | `CascadeDirection.bottomToTop()` | Items at the bottom animate first. |
| Left to Right | `CascadeDirection.leftToRight()` | Items on the left animate first. |
| Right to Left | `CascadeDirection.rightToLeft()` | Items on the right animate first. |
| Radial | `CascadeDirection.radial(center:)` | Items nearest to `center` animate first. |
| Inverse Radial | `CascadeDirection.inverseRadial(center:)` | Items farthest from `center` animate first. |

### Example

```dart
// Parent container with cascade modifier
HeroView(
  id: 'grid-container',
  modifiers: [
    HeroModifier.cascade(
      delta: const Duration(milliseconds: 30),
      direction: const CascadeDirection.topToBottom(),
      delayMatchedViews: false,
    ),
  ],
  child: GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
    itemCount: items.length,
    itemBuilder: (context, index) {
      return HeroView(
        id: 'item-$index',
        modifiers: [HeroModifier.fade, HeroModifier.scale(0.5)],
        child: ItemCard(item: items[index]),
      );
    },
  ),
);
```

```dart
// Radial cascade from the center of the screen
HeroModifier.cascade(
  delta: const Duration(milliseconds: 25),
  direction: CascadeDirection.radial(center: Offset(
    MediaQuery.of(context).size.width / 2,
    MediaQuery.of(context).size.height / 2,
  )),
)
```

---

## Plugin System

The transition engine supports plugins that can preprocess view state and/or
provide custom animation logic. A plugin extends `HeroPlugin`, which combines
the `HeroPreprocessor` and `HeroAnimatorInterface` interfaces.

### Enabling a Plugin

```dart
// Register a plugin globally
HeroPlugin.enable(() => HeroDebugPlugin());

// Disable a plugin type
HeroPlugin.disable<HeroDebugPlugin>();
```

### HeroDebugPlugin

The built-in debug plugin provides a visual overlay with a slider to scrub
through transition progress. This is useful for inspecting animation states
frame by frame.

```dart
// Enable the debug overlay
HeroDebugPlugin.isEnabled = true;

// Add the debug overlay widget to your tree
Stack(
  children: [
    child!,
    const HeroOverlay(),
    const HeroDebugOverlay(),  // slider at the bottom of the screen
  ],
)
```

### Writing a Custom Plugin

```dart
class MyCustomPlugin extends HeroPlugin {
  @override
  bool get requirePerFrameCallback => true;

  @override
  void process({
    required List<String> fromViewIDs,
    required List<String> toViewIDs,
  }) {
    // Preprocess view IDs before animation begins.
    // Modify target states, reorder views, etc.
  }

  @override
  bool canAnimate(String heroID, bool appearing) {
    // Return true if this plugin should handle animation for this view.
    return heroID.startsWith('custom-');
  }

  @override
  Duration animate({
    required List<String> fromViewIDs,
    required List<String> toViewIDs,
  }) {
    // Set up animation. Return the total duration.
    return const Duration(milliseconds: 500);
  }

  @override
  void seekTo(Duration timePassed) {
    // Called every frame if requirePerFrameCallback is true.
  }

  @override
  Duration resume({required Duration timePassed, required bool reverse}) {
    // Resume after an interactive gesture finishes or cancels.
    return const Duration(milliseconds: 300);
  }

  @override
  void clean() {
    // Release resources when the transition completes.
  }
}
```

---

## Comparison with iOS Hero

This library is a faithful Flutter port of the iOS Hero library. The following
table maps the core iOS concepts to their Flutter counterparts.

| iOS Hero | flutter_hero_transitions | Notes |
|---|---|---|
| `UIView` | `Widget` | Any Flutter widget can participate in transitions. |
| `view.hero.id` | `HeroView(id: ...)` | String identifier for matching views across routes. |
| `view.hero.modifiers` | `HeroView(modifiers: [...])` | List of `HeroModifier` instances applied in order. |
| `HeroModifier` | `HeroModifier` | Same name; same composable, functional design. |
| `UIViewController` | `Route` / screen widget | A `HeroPageRoute` replaces the UIViewController role. |
| `hero.isEnabled` | `HeroView(isEnabled: ...)` / `HeroPageRoute(heroEnabled: ...)` | Toggle hero behavior per view or per route. |
| `hero.modalAnimationType` | `HeroPageRoute(animationType: ...)` | Set the built-in animation type for the route transition. |
| `HeroDefaultAnimationType` | `HeroAnimationType` | Sealed class with the same 14 variants. |
| `Hero.shared` | `HeroTransitionEngine.shared` | Singleton engine that coordinates all transitions. |
| `HeroPlugin` (iOS) | `HeroPlugin` (Flutter) | Same interface: preprocessor + animator. |
| `HeroDebugPlugin` | `HeroDebugPlugin` + `HeroDebugOverlay` | Debug slider overlay for scrubbing transitions. |
| `UIGestureRecognizer` + `Hero.shared.update/finish/cancel` | `HeroInteractiveGesture` widget | Declarative widget wrapping interactive dismiss logic. |
| `CascadeDirection` | `CascadeDirection` | Same 6 direction modes (topToBottom, bottomToTop, leftToRight, rightToLeft, radial, inverseRadial). |
| `HeroTargetState` | `HeroTargetState` | Mutable state bag mutated by modifiers, read by animators. |
| `NavigationControllerDelegate` | `HeroTransitionObserver` (NavigatorObserver) | Intercepts push/pop/replace to trigger the engine. |

---

## Examples

The `example/` directory contains 14 screens demonstrating all major features.
Each example corresponds to an equivalent screen in the iOS Hero sample app.

| # | Screen | Description |
|---|---|---|
| 1 | **Built-In Animations** | Demonstrates push, pull, slide, fade, and zoom transitions between two screens. |
| 2 | **Match Animation** | Matches views by ID across screens so they animate continuously from source to destination. |
| 3 | **Match in Collection** | Matches individual collection cells (list items) to a detail view. |
| 4 | **App Store Card** | Interactive card expansion transition with spring physics, similar to the iOS App Store. |
| 5 | **Match Flutter Views** | Image list with matched transitions between grid thumbnails and a full-screen viewer. |
| 6 | **Navigation** | Basic push/pop navigation with a toggle to enable or disable hero transitions. |
| 7 | **Transition Selector** | Interactive picker to preview all 14 built-in animation types. |
| 8 | **List to Grid** | Switches between list and grid layouts with cascade stagger animations. |
| 9 | **City Guide** | Card list that transitions to a horizontal page-view pager with matched images. |
| 10 | **Menu** | Button-driven transitions using the `source` modifier to animate from a menu button. |
| 11 | **Image Gallery** | Photo grid with cascade and radial cascade animations on appear/dismiss. |
| 12 | **Video Player** | Interactive pan-to-dismiss gesture over a video player screen. |
| 13 | **Apple Home Page** | Multi-directional swipe showcase emulating Apple's product page transitions. |
| 14 | **TV Image Gallery** | Adapted grid layout for tablet and desktop screens with larger hit targets. |

### Running the Examples

```bash
cd flutter_hero_transitions/example
flutter run
```

---

## Requirements

| Requirement | Version |
|---|---|
| Flutter SDK | >= 3.10.0 |
| Dart SDK | >= 3.0.0, < 4.0.0 |

No external dependencies beyond the Flutter SDK.

---

## License

MIT License. See the [LICENSE](../LICENSE) file for details.
