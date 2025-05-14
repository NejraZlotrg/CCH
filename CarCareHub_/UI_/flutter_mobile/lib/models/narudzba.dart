import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/klijent.dart';
import 'package:flutter_mobile/models/narudzba_stavke.dart';
import 'package:flutter_mobile/models/zaposlenik.dart';
import 'package:json_annotation/json_annotation.dart';

part 'narudzba.g.dart';

@JsonSerializable()
class Narudzba {
  final int narudzbaId;
  final DateTime? datumNarudzbe;
  final DateTime? datumIsporuke;
  final bool zavrsenaNarudzba;
  final double? ukupnaCijenaNarudzbe;
  bool? vidljivo;
  int? klijentId;
  Klijent? klijent;
  int? autoservisId;
  Autoservis? autoservis;
  int? zaposlenikId;
  Zaposlenik? zaposlenik;
  String? adresa;

  Narudzba(
      {required this.narudzbaId,
      this.vidljivo,
      this.datumNarudzbe,
      this.datumIsporuke,
      this.zavrsenaNarudzba = false,
      this.ukupnaCijenaNarudzbe,
      this.adresa});

  factory Narudzba.fromJson(Map<String, dynamic> json) =>
      _$NarudzbaFromJson(json);

  Map<String, dynamic> toJson() => _$NarudzbaToJson(this);
}
