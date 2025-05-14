import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/klijent.dart';
import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/models/zaposlenik.dart';
import 'package:json_annotation/json_annotation.dart';

part 'korpa.g.dart';

@JsonSerializable()
class Korpa {
  int? korpaId;
  int? proizvodId;
  Product? proizvod;
  int? klijentId;
  Klijent? klijent;
  int? autoservisId;
  Autoservis? autoservis;
  int? zaposlenikId;
  Zaposlenik? zaposlenik;
  int? kolicina;
  double? ukupnaCijenaProizvoda;
  bool? vidljivo;

  Korpa(
      {this.korpaId,
      this.proizvodId,
      this.klijentId,
      this.autoservisId,
      this.zaposlenikId,
      this.kolicina,
      this.ukupnaCijenaProizvoda,
      this.autoservis,
      this.klijent,
      this.proizvod,
      this.zaposlenik,
      this.vidljivo});

  // Factory metoda za deserializaciju JSON-a u Korpa objekt
  factory Korpa.fromJson(Map<String, dynamic> json) => _$KorpaFromJson(json);

  // Metoda za serializaciju Korpa objekta u JSON
  Map<String, dynamic> toJson() => _$KorpaToJson(this);
}
