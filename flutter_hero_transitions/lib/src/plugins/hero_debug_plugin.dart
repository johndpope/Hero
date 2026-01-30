import 'package:flutter/material.dart';
import 'hero_plugin.dart';

/// Debug plugin that provides a visual overlay for inspecting transitions.
/// Shows a slider to scrub through animation progress.
///
/// Equivalent to iOS HeroDebugPlugin.
///
/// Enable with:
/// ```dart
/// HeroDebugPlugin.isEnabled = true;
/// ```
class HeroDebugPlugin extends HeroPlugin {
  static bool isEnabled = false;

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
    // In debug mode, the transition waits indefinitely for user input
    return const Duration(days: 999);
  }
}

/// Debug overlay widget that shows transition controls.
/// Add this to your widget tree when debugging.
class HeroDebugOverlay extends StatefulWidget {
  const HeroDebugOverlay({super.key});

  @override
  State<HeroDebugOverlay> createState() => _HeroDebugOverlayState();
}

class _HeroDebugOverlayState extends State<HeroDebugOverlay> {
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    if (!HeroDebugPlugin.isEnabled) return const SizedBox.shrink();

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        color: Colors.black87,
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Hero Debug',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Slider(
                value: _progress,
                onChanged: (value) {
                  setState(() => _progress = value);
                  // engine?.update(value);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() => _progress = 0.0);
                    },
                    child: const Text('Reset', style: TextStyle(color: Colors.white)),
                  ),
                  TextButton(
                    onPressed: () {
                      // engine?.finish();
                    },
                    child: const Text('Done', style: TextStyle(color: Colors.white)),
                  ),
                  TextButton(
                    onPressed: () {
                      // engine?.cancel();
                    },
                    child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
