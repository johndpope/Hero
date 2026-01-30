import 'package:flutter/material.dart';
import 'package:flutter_hero_transitions/flutter_hero_transitions.dart';
import '../widgets/example_scaffold.dart';
import '../data/city_data.dart';

/// City Guide Example - card list to page view pager.
class CityGuideScreen extends StatelessWidget {
  const CityGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      child: ListView.builder(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 60,
          bottom: 40,
        ),
        itemCount: City.all.length,
        itemBuilder: (context, index) {
          final city = City.all[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                id: 'city_${city.name}',
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          city.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: HSVColor.fromAHSV(1, (index * 120.0), 0.5, 0.7).toColor(),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: Text(
                            city.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CityDetailScreen extends StatelessWidget {
  final int initialIndex;
  const _CityDetailScreen({required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      child: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: City.all.length,
        itemBuilder: (context, index) {
          final city = City.all[index];
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 60),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: HeroView(
                    id: 'city_${city.name}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        city.imagePath,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: double.infinity,
                          height: 250,
                          color: HSVColor.fromAHSV(1, (index * 120.0), 0.5, 0.7).toColor(),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city.name,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        city.description,
                        style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
