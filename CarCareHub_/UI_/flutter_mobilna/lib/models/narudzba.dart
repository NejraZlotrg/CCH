import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/klijent.dart';
import 'package:flutter_mobile/models/narudzba_stavke.dart';
import 'package:flutter_mobile/models/zaposlenik.dart';
import 'package:json_annotation/json_annotation.dart';

part 'narudzba.g.dart';

@JsonSerializable()
class Narudzba {
  final int narudzbaId;  // Promijenjeno 'id' u 'narudzbaId'
  final DateTime? datumNarudzbe;  // Nullable DateTime
  final DateTime? datumIsporuke;  // Nullable DateTime
  final bool zavrsenaNarudzba;  // Ne nullable, default false
  final double? ukupnaCijenaNarudzbe;  // Nullable decimal type
bool? vidljivo;
  int? klijentId;
  Klijent? klijent;
  int? autoservisId;
  Autoservis? autoservis;
  int? zaposlenikId;
  Zaposlenik? zaposlenik;
  String? adresa;

  Narudzba({
    required this.narudzbaId,
    this.vidljivo,
    this.datumNarudzbe,  // Može biti null
    this.datumIsporuke,  // Može biti null
    this.zavrsenaNarudzba = false,  // Default value
    this.ukupnaCijenaNarudzbe,  // Može biti null
    this.adresa
  });

  factory Narudzba.fromJson(Map<String, dynamic> json) => _$NarudzbaFromJson(json);

  Map<String, dynamic> toJson() => _$NarudzbaToJson(this);
}
