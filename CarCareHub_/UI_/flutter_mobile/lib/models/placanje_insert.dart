class PlacanjeInsert {
  late num ukupno;

  PlacanjeInsert({required this.ukupno});

  Map<String, dynamic> fromJson() {
    return {'ukupno': ukupno};
  }
}
