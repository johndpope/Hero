import 'package:flutter/material.dart';
import 'package:flutter_hero_transitions/flutter_hero_transitions.dart';
import '../data/city_data.dart';

/// iOS storyboard background color: RGB(0.917, 0.951, 0.981)
const _kBgColor = Color.fromRGBO(234, 242, 250, 1);

/// iOS storyboard text color: RGB(0.255, 0.286, 0.310)
const _kTextColor = Color.fromRGBO(65, 73, 79, 1);

/// City Guide Example — Screen 1 (List with horizontal card scroll).
///
/// Matches iOS CityGuideViewController storyboard layout exactly:
///   - Down chevron dismiss button (heroID "back")
///   - "Adventure awaits" header (Avenir Next Regular 32pt)
///   - "in CANADA" text
///   - "POPULAR DESTINATIONS" section header
///   - Horizontal scrolling collection of city cards (200×298pt)
class CityGuideScreen extends StatelessWidget {
  const CityGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _kBgColor,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: topPadding + 64),
              // "Adventure awaits" label
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: HeroView(
                  id: 'adventure_text',
                  modifiers: [
                    HeroModifier.fade,
                    HeroModifier.translate(y: -150),
                  ],
                  child: const Text(
                    'Adventure awaits',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                      color: _kTextColor,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // "in CANADA" label
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: HeroView(
                  id: 'canada_text',
                  modifiers: [
                    HeroModifier.fade,
                    HeroModifier.translate(y: -150),
                  ],
                  child: Row(
                    children: [
                      const Text(
                        'in  ',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w400,
                          color: _kTextColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      HeroView(
                        id: 'canada',
                        modifiers: [
                          HeroModifier.fade,
                          HeroModifier.translate(y: -150),
                        ],
                        child: const Text(
                          'CANADA',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // "POPULAR DESTINATIONS" section header
              Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 16),
                child: HeroView(
                  id: 'destinations',
                  modifiers: [
                    HeroModifier.fade,
                    HeroModifier.translate(y: -150),
                  ],
                  child: const Text(
                    'POPULAR DESTINATIONS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: _kTextColor,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
              // Horizontal scrolling city cards — iOS: height 348, items 200×298
              SizedBox(
                height: 348,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(24),
                  itemCount: City.all.length,
                  itemBuilder: (context, index) {
                    final city = City.all[index];
                    return Padding(
                      padding: EdgeInsets.only(right: index < City.all.length - 1 ? 10 : 0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            HeroPageRoute(
                              builder: (_) => _CityDetailScreen(
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                        child: HeroView(
                          id: city.name,
                          child: _CityCard(city: city, useShortDescription: true),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Down chevron dismiss button — iOS: 48×48, cornerRadius 24
          Positioned(
            top: topPadding + 8,
            left: 4,
            child: HeroView(
              id: 'back',
              modifiers: [
                HeroModifier.fade,
                HeroModifier.translate(y: -150),
              ],
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey[600],
                      size: 28,
                    ),
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

/// City Guide Example — Screen 2 (Full-screen paging detail).
///
/// Matches iOS CityViewController storyboard layout exactly:
///   - Full-screen horizontal paging collection view
///   - Each page: full-screen city image + 50% black overlay
///   - City name (31pt white) at center - 70pt vertical offset
///   - Full description (17pt off-white) below name
///   - Down chevron dismiss button (heroID "back")
class _CityDetailScreen extends StatelessWidget {
  final int initialIndex;
  const _CityDetailScreen({required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full-screen horizontal paging
          PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: City.all.length,
            itemBuilder: (context, index) {
              final city = City.all[index];
              return HeroView(
                id: city.name,
                child: _CityCard(city: city, useShortDescription: false),
              );
            },
          ),
          // Down chevron dismiss button
          Positioned(
            top: topPadding + 8,
            left: 4,
            child: HeroView(
              id: 'back',
              modifiers: [
                HeroModifier.fade,
                HeroModifier.translate(y: -150),
              ],
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey[400],
                      size: 28,
                    ),
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

/// Reusable city card used in both list and detail screens.
///
/// iOS CityCell storyboard layout:
///   List mode (useShortDescription: true):  200×298, cornerRadius 4
///     - Full-bleed image, city name 20pt white, short description 12pt off-white
///   Detail mode (useShortDescription: false): full-screen
///     - Full-bleed image, 50% black overlay, name 31pt white, full description 17pt off-white
class _CityCard extends StatelessWidget {
  final City city;
  final bool useShortDescription;

  const _CityCard({
    required this.city,
    required this.useShortDescription,
  });

  @override
  Widget build(BuildContext context) {
    if (useShortDescription) {
      // --- List card: 200×298, small text, rounded corners ---
      return Container(
        width: 200,
        height: 298,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.3),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                city.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: _colorForCity(city.name),
                ),
              ),
              // City name — iOS: 20pt, white, bottom-left with 24pt left margin
              Positioned(
                left: 24,
                bottom: 44,
                child: Text(
                  city.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              // Short description — iOS: 12pt, off-white
              Positioned(
                left: 24,
                bottom: 20,
                child: Text(
                  city.shortDescription,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color.fromRGBO(249, 249, 249, 1),
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // --- Detail card: full-screen, dark overlay ---
    return Stack(
      fit: StackFit.expand,
      children: [
        // Full-bleed image
        Image.asset(
          city.imagePath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: _colorForCity(city.name),
          ),
        ),
        // 50% black overlay — iOS storyboard: alpha 0.5, black
        Container(color: Colors.black.withOpacity(0.5)),
        // City name + description — iOS: name at centerY - 70
        Positioned(
          left: 24,
          right: 24,
          top: 0,
          bottom: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.translate(
                offset: const Offset(0, -70),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.name,
                      style: const TextStyle(
                        fontSize: 31,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      city.description,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(249, 249, 249, 1),
                        decoration: TextDecoration.none,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _colorForCity(String name) {
    switch (name) {
      case 'Vancouver':
        return const Color(0xFF8B4C3B);
      case 'Toronto':
        return const Color(0xFF3B4B8B);
      case 'Montreal':
        return const Color(0xFF3B7B3B);
      default:
        return Colors.grey;
    }
  }
}
