/// City data model for the CityGuide example.
class City {
  final String name;
  final String description;
  final String imagePath;

  const City({
    required this.name,
    required this.description,
    required this.imagePath,
  });

  static const List<City> all = [
    City(
      name: 'Vancouver',
      description:
          'Vancouver is a bustling west coast seaport in British Columbia, '
          'among Canada\'s densest, most ethnically diverse cities. A popular '
          'filming location, it\'s surrounded by mountains, and also has '
          'thriving art, theatre and music scenes.',
      imagePath: 'assets/Vancouver.jpg',
    ),
    City(
      name: 'Montreal',
      description:
          'Montreal is the largest city in Canada\'s Quebec province. It\'s '
          'set on an island in the Saint Lawrence River and named after Mt. '
          'Royal, the triple-peaked hill at its heart. Its boroughs, many '
          'of French origin, include the cobblestoned Old Montreal.',
      imagePath: 'assets/Montreal.jpg',
    ),
    City(
      name: 'Toronto',
      description:
          'Toronto, the capital of the province of Ontario, is a major '
          'Canadian city along Lake Ontario\'s northwestern shore. It\'s a '
          'dynamic metropolis with a core of soaring skyscrapers, all dwarfed '
          'by the iconic, free-standing CN Tower.',
      imagePath: 'assets/Toronto.jpg',
    ),
  ];
}
