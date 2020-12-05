class Result {
  final String name;
  final String relativeDirection;
  final int distanceFromUser;

  const Result({
    this.name,
    this.relativeDirection,
    this.distanceFromUser,
  })  : assert(name != null),
        assert(relativeDirection != null),
        assert(distanceFromUser != null);

  String toStringWithLocale(String locale) {
    Map<String, String> ro = {
      "left": "în stânga",
      "right": "în dreapta",
      "front": "în față",
      "back": "în spate",
    };

    Map<String, String> en = {
      "left": "to the left",
      "right": "to the right",
      "front": "in front of you",
      "back": "behind you",
    };

    switch (locale) {
      case "ro-RO":
        return "${this.name} este ${ro[this.relativeDirection]} la ${this.distanceFromUser} de metrii";
        break;
      default: //en-US
        return "${this.name} is ${en[this.relativeDirection]} at ${this.distanceFromUser} metres";
    }
  }
}
