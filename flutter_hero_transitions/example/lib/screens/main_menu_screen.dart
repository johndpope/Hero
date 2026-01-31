import 'package:flutter/material.dart';
import 'package:flutter_hero_transitions/flutter_hero_transitions.dart';
import 'built_in_transition_example.dart';
import 'match_example.dart';
import 'match_in_collection_example.dart';
import 'app_store_card_example.dart';
import 'match_flutter_example.dart';
import 'navigation_example.dart';
import 'built_in_transition_selector.dart';
import 'list_to_grid_example.dart';
import 'city_guide_example.dart';
import 'menu_example.dart';
import 'image_gallery_example.dart';
import 'video_player_example.dart';
import 'apple_home_page_example.dart';
import 'tv_image_gallery_example.dart';

/// Main menu listing all example screens.
/// Equivalent to iOS MainViewController.
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Image.asset(
                      'assets/HeroLogo.png',
                      height: 80,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.auto_awesome,
                        size: 80,
                        color: Color(0xFFFC3A5E),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Hero Transitions',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Flutter Port - 100% iOS Parity',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Debug mode toggle
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          HeroDebugPlugin.isEnabled =
                              !HeroDebugPlugin.isEnabled;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: HeroDebugPlugin.isEnabled
                              ? const Color(0xFFFC3A5E)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bug_report,
                              size: 18,
                              color: HeroDebugPlugin.isEnabled
                                  ? Colors.white
                                  : Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              HeroDebugPlugin.isEnabled
                                  ? 'Debug ON'
                                  : 'Debug OFF',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: HeroDebugPlugin.isEnabled
                                    ? Colors.white
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Modern Examples Section
            _SectionHeader(title: 'Modern Examples'),
            SliverList(
              delegate: SliverChildListDelegate([
                _ExampleTile(
                  index: 1,
                  title: 'Built-In Animations',
                  subtitle: 'Push, pull, slide, fade, zoom transitions',
                  onTap: () => _navigate(context, const BuiltInTransitionScreen1()),
                ),
                _ExampleTile(
                  index: 2,
                  title: 'Match Animation',
                  subtitle: 'Match views by ID across screens',
                  onTap: () => _navigate(context, const MatchExampleScreen1()),
                ),
                _ExampleTile(
                  index: 3,
                  title: 'Match in Collection',
                  subtitle: 'Match collection cells to detail views',
                  onTap: () => _navigate(context, const MatchInCollectionScreen1()),
                ),
                _ExampleTile(
                  index: 4,
                  title: 'App Store Card',
                  subtitle: 'Interactive card transition with spring physics',
                  onTap: () => _navigate(context, const AppStoreScreen1()),
                ),
                _ExampleTile(
                  index: 5,
                  title: 'Match Flutter Views',
                  subtitle: 'Image list with matched transitions',
                  onTap: () => _navigate(context, const MatchFlutterExampleScreen()),
                ),
              ]),
            ),

            // Legacy Examples Section
            _SectionHeader(title: 'Legacy Examples'),
            SliverList(
              delegate: SliverChildListDelegate([
                _ExampleTile(
                  index: 6,
                  title: 'Navigation',
                  subtitle: 'Push/pop with hero toggle',
                  onTap: () => _navigate(context, const NavigationExampleScreen()),
                ),
                _ExampleTile(
                  index: 7,
                  title: 'Transition Selector',
                  subtitle: 'All 14 built-in animation types',
                  onTap: () => _navigate(context, const BuiltInTransitionSelectorScreen()),
                ),
                _ExampleTile(
                  index: 8,
                  title: 'List to Grid',
                  subtitle: 'Layout switching with cascade animations',
                  onTap: () => _navigate(context, const ListToGridExampleScreen()),
                ),
                _ExampleTile(
                  index: 9,
                  title: 'City Guide',
                  subtitle: 'Card list to page view pager',
                  onTap: () => _navigate(context, const CityGuideScreen()),
                ),
                _ExampleTile(
                  index: 10,
                  title: 'Menu',
                  subtitle: 'Button-driven source transitions',
                  onTap: () => _navigate(context, const MenuExampleScreen()),
                ),
                _ExampleTile(
                  index: 11,
                  title: 'Image Gallery',
                  subtitle: 'Grid with cascade and radial animations',
                  onTap: () => _navigate(context, const ImageGalleryScreen()),
                ),
                _ExampleTile(
                  index: 12,
                  title: 'Video Player',
                  subtitle: 'Interactive dismiss with video',
                  onTap: () => _navigate(context, const VideoPlayerExampleScreen()),
                ),
                _ExampleTile(
                  index: 13,
                  title: 'Apple Home Page',
                  subtitle: 'Multi-directional swipe product showcase',
                  onTap: () => _navigate(context, const AppleHomePageScreen()),
                ),
              ]),
            ),

            // Tablet/Desktop Section
            _SectionHeader(title: 'Tablet / Desktop'),
            SliverList(
              delegate: SliverChildListDelegate([
                _ExampleTile(
                  index: 14,
                  title: 'TV Image Gallery',
                  subtitle: 'Adapted grid for larger screens',
                  onTap: () => _navigate(context, const TvImageGalleryScreen()),
                ),
              ]),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      HeroPageRoute(builder: (_) => screen),
    );
  }
}


class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[500],
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _ExampleTile extends StatelessWidget {
  final int index;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ExampleTile({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: HSVColor.fromAHSV(1, (index * 25.0) % 360, 0.7, 0.85).toColor(),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            '$index',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
