import 'package:flutter/material.dart';
import 'package:flutter_hero_transitions/flutter_hero_transitions.dart';

/// Base scaffold for all example screens.
/// Provides a back button with Hero ID "back button".
/// Equivalent to iOS ExampleBaseViewController.
class ExampleScaffold extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final bool showBackButton;
  final VoidCallback? onBack;

  const ExampleScaffold({
    super.key,
    required this.child,
    this.backgroundColor,
    this.showBackButton = true,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          child,
          if (showBackButton)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 20,
              child: HeroView(
                id: 'back_button',
                child: GestureDetector(
                  onTap: () {
                    if (onBack != null) {
                      onBack!();
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
