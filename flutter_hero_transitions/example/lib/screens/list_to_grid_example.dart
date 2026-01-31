import 'package:flutter/material.dart';
import 'package:flutter_hero_transitions/flutter_hero_transitions.dart';
import '../data/image_library.dart';
import '../widgets/example_scaffold.dart';

/// List-to-Grid Example - toggle between list and grid layouts with cascade.
class ListToGridExampleScreen extends StatefulWidget {
  const ListToGridExampleScreen({super.key});

  @override
  State<ListToGridExampleScreen> createState() => _ListToGridExampleScreenState();
}

class _ListToGridExampleScreenState extends State<ListToGridExampleScreen> {
  bool _isGrid = false;
  final int _itemCount = 20;

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
                  icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view),
                  onPressed: () => setState(() => _isGrid = !_isGrid),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isGrid ? _buildGrid() : _buildList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      key: const ValueKey('list'),
      padding: const EdgeInsets.all(8),
      itemCount: _itemCount,
      itemBuilder: (context, index) => _buildItem(index, isGrid: false),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      key: const ValueKey('grid'),
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: _itemCount,
      itemBuilder: (context, index) => _buildItem(index, isGrid: true),
    );
  }

  Widget _buildItem(int index, {required bool isGrid}) {
    final color = HSVColor.fromAHSV(1, (index * 18.0) % 360, 0.6, 0.85).toColor();

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
            height: isGrid ? null : 80,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                HeroView(
                  id: 'listGridImage_$index',
                  modifiers: [HeroModifier.arc],
                  child: Container(
                    width: isGrid ? double.infinity : 80,
                    height: isGrid ? double.infinity : 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(isGrid ? 8 : 8),
                    ),
                    child: Image.asset(
                      ImageLibrary.thumbnail(index),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: color.withOpacity(0.7),
                        child: Center(child: Text('$index', style: const TextStyle(color: Colors.white))),
                      ),
                    ),
                  ),
                ),
                if (!isGrid) ...[
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
              ],
            ),
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
