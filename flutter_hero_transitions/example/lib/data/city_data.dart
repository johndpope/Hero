/// City data model for the CityGuide example.
/// Matches iOS City.swift exactly.
class City {
  final String name;
  final String shortDescription;
  final String description;
  final String imagePath;

  const City({
    required this.name,
    required this.shortDescription,
    required this.description,
    required this.imagePath,
  });

  static const List<City> all = [
    City(
      name: 'Vancouver',
      shortDescription: 'City in British Columbia',
      description:
          'Vancouver, a bustling west coast seaport in British Columbia, is '
          'among Canada\'s densest, most ethnically diverse cities. A popular '
          'filming location, it\'s surrounded by mountains, and also has '
          'thriving art, theatre and music scenes. Vancouver Art Gallery is '
          'known for its works by regional artists, while the Museum of '
          'Anthropology houses preeminent First Nations collections.',
      imagePath: 'assets/city_guide/vancouver.jpeg',
    ),
    City(
      name: 'Toronto',
      shortDescription: 'City in Ontario',
      description:
          'Toronto, the capital of the province of Ontario, is a major '
          'Canadian city along Lake Ontario\'s northwestern shore. It\'s a '
          'dynamic metropolis with a core of soaring skyscrapers, all dwarfed '
          'by the iconic, free-standing CN Tower. Toronto also has many green '
          'spaces, from the orderly oval of Queen\'s Park to 400-acre High '
          'Park and its trails, sports facilities and zoo.',
      imagePath: 'assets/city_guide/toronto.jpeg',
    ),
    City(
      name: 'Montreal',
      shortDescription: 'City in Québec',
      description:
          'Montréal is the largest city in Canada\'s Québec province. It\'s '
          'set on an island in the Saint Lawrence River and named after Mt. '
          'Royal, the triple-peaked hill at its heart. Its boroughs, many of '
          'which were once independent cities, include neighbourhoods ranging '
          'from cobblestoned, French colonial Vieux-Montréal – with the Gothic '
          'Revival Notre-Dame Basilica at its centre – to bohemian Plateau.',
      imagePath: 'assets/city_guide/montreal.jpeg',
    ),
  ];
}
