class PlacanjeInsert {
  late num ukupno;

  PlacanjeInsert({required ukupno});

  Map<String, dynamic> fromJson() {
    return {'ukupno': ukupno};
  }
}
