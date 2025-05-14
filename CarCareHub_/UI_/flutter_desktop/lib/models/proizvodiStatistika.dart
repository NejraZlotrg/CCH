// ignore_for_file: file_names

class ProizvodStatistika {
  final int proizvodId;
  final String naziv;
  final int ukupnaKolicina;
  final double ukupnaVrijednost;

  ProizvodStatistika({
    required this.proizvodId,
    required this.naziv,
    required this.ukupnaKolicina,
    required this.ukupnaVrijednost,
  });

  factory ProizvodStatistika.fromJson(Map<String, dynamic> json) {
    return ProizvodStatistika(
      proizvodId: json['proizvodId'] as int,
      naziv: json['naziv'] as String,
      ukupnaKolicina: json['ukupnaKolicina'] as int,
      ukupnaVrijednost: (json['ukupnaVrijednost'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proizvodId': proizvodId,
      'naziv': naziv,
      'ukupnaKolicina': ukupnaKolicina,
      'ukupnaVrijednost': ukupnaVrijednost,
    };
  }

  @override
  String toString() {
    return 'ProizvodStatistika{'
        'proizvodId: $proizvodId, '
        'naziv: $naziv, '
        'ukupnaKolicina: $ukupnaKolicina, '
        'ukupnaVrijednost: $ukupnaVrijednost}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProizvodStatistika &&
          runtimeType == other.runtimeType &&
          proizvodId == other.proizvodId &&
          naziv == other.naziv &&
          ukupnaKolicina == other.ukupnaKolicina &&
          ukupnaVrijednost == other.ukupnaVrijednost;

  @override
  int get hashCode =>
      proizvodId.hashCode ^
      naziv.hashCode ^
      ukupnaKolicina.hashCode ^
      ukupnaVrijednost.hashCode;
}
