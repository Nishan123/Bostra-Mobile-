enum ChipsOptions {
  art,
  comics,
  crafts,
  dance,
  design,
  fashion,
  film,
  food,
  games,
  journalism,
  music,
  photography,
  publishing,
  technology,
  theater;

  String get text {
    switch (this) {
      case ChipsOptions.art:
        return 'Art';
      case ChipsOptions.comics:
        return 'Comics';
      case ChipsOptions.crafts:
        return 'Crafts';
      case ChipsOptions.dance:
        return 'Dance';
      case ChipsOptions.design:
        return 'Design';
      case ChipsOptions.fashion:
        return 'Fashion';
      case ChipsOptions.film:
        return 'Film';
      case ChipsOptions.food:
        return 'Food';
      case ChipsOptions.games:
        return 'Games';
      case ChipsOptions.journalism:
        return 'Journalism';
      case ChipsOptions.music:
        return 'Music';
      case ChipsOptions.photography:
        return 'Photography';
      case ChipsOptions.publishing:
        return 'Publishing';
      case ChipsOptions.technology:
        return 'Technology';
      case ChipsOptions.theater:
        return 'Theater';
    }
  }
}
