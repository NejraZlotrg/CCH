import 'package:json_annotation/json_annotation.dart';

part 'korpa.g.dart';

@JsonSerializable()
class Korpa {
  int? korpaId;
  int? proizvodId;
  int? klijentId;
  int? autoservisId;
  int? zaposlenikId;
  int? kolicina;
  double? ukupnaCijenaProizvoda;

  // Konstruktor
  Korpa({
    this.korpaId,
    this.proizvodId,
    this.klijentId,
    this.autoservisId,
    this.zaposlenikId,
    this.kolicina,
    this.ukupnaCijenaProizvoda,
  });

  // Factory metoda za deserializaciju JSON-a u Korpa objekt
  factory Korpa.fromJson(Map<String, dynamic> json) => _$KorpaFromJson(json);

  // Metoda za serializaciju Korpa objekta u JSON
  Map<String, dynamic> toJson() => _$KorpaToJson(this);
}
