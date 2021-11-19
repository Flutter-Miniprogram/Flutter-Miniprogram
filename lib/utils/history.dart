class History {
  static List<String> history = [];

  History();

  History.push(route) {
    history.add(route);
  }
}