import 'package:flutter/material.dart';
import 'package:flutter_hero_transitions/flutter_hero_transitions.dart';
import '../data/image_library.dart';
import '../widgets/example_scaffold.dart';

/// List-to-Grid Example - toggle between list and grid layouts with hero transitions.
///
/// Mirrors the iOS Hero library's ListToGrid example where toggling between
/// list and grid triggers `hero.replaceViewController(with:)`. In Flutter,
/// this is done via `Navigator.pushReplacement` with a `HeroPageRoute`,
/// causing the HeroTransitionEngine to match views by ID and animate them
/// from their list positions to grid positions (and vice versa).
class ListToGridExampleScreen extends StatelessWidget {
  final bool isGrid;
  const ListToGridExampleScreen({super.key, this.isGrid = false});

  static const int _itemCount = 20;

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 60),
          // Toggle button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(isGrid ? Icons.view_list : Icons.grid_view),
                  onPressed: () {
                    // Replace current route with opposite layout.
                    // This triggers the hero engine via didReplace, matching
                    // HeroView IDs between the old and new routes.
                    Navigator.of(context).pushReplacement(
                      HeroPageRoute(
                        builder: (_) => ListToGridExampleScreen(isGrid: !isGrid),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: isGrid ? _buildGrid(context) : _buildList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _itemCount,
      itemBuilder: (context, index) => _buildItem(context, index, isGrid: false),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: _itemCount,
      itemBuilder: (context, index) => _buildItem(context, index, isGrid: true),
    );
  }

  Widget _buildItem(BuildContext context, int index, {required bool isGrid}) {
    final color = HSVColor.fromAHSV(1, (index * 18.0) % 360, 0.6, 0.85).toColor();

    Widget imageWidget = HeroView(
      id: 'listGridImage_$index',
      modifiers: [HeroModifier.arc],
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          ImageLibrary.thumbnail(index),
          width: isGrid ? double.infinity : 80,
          height: isGrid ? double.infinity : 80,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: isGrid ? double.infinity : 80,
            height: isGrid ? double.infinity : 80,
            color: color.withValues(alpha: 0.7),
            child: Center(child: Text('$index', style: const TextStyle(color: Colors.white))),
          ),
        ),
      ),
    );

    // Grid mode: image fills the entire cell (no Row needed)
    // List mode: Row with image thumbnail + text label
    Widget content;
    if (isGrid) {
      content = imageWidget;
    } else {
      content = Row(
        children: [
          imageWidget,
          const SizedBox(width: 16),
          Text(
            'Item $index',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: isGrid ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: HeroView(
        id: 'listGrid_$index',
        modifiers: [
          HeroModifier.fade,
          if (isGrid) HeroModifier.translate(y: 20) else HeroModifier.translate(x: -100),
        ],
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              HeroPageRoute(
                builder: (_) => _ListToGridDetailScreen(index: index, color: color),
              ),
            );
          },
          child: Container(
            height: isGrid ? double.infinity : 80,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}

class _ListToGridDetailScreen extends StatelessWidget {
  final int index;
  final Color color;
  const _ListToGridDetailScreen({required this.index, required this.color});

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: Column(
          children: [
            HeroView(
              id: 'listGridImage_$index',
              modifiers: [HeroModifier.arc],
              child: Image.asset(
                ImageLibrary.thumbnail(index),
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: double.infinity,
                  height: 300,
                  color: color,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Detail for Item $index',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
