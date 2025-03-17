import 'package:flutter_mobile/models/drzave.dart';
import 'package:json_annotation/json_annotation.dart';

part 'izvjestajnarudzbi.g.dart';

@JsonSerializable()
class IzvjestajNarudzbi {
  int? narudzbaId;
  DateTime? datumNarudzbe;
  String? klijent;
  String? autoservis;
  String? zaposlenik;
  double? ukupnaCijena;
  bool? status;

  IzvjestajNarudzbi(
    this.narudzbaId,
    this.datumNarudzbe,
    this.klijent,
    this.autoservis,
    this.zaposlenik,
    this.ukupnaCijena,
    this.status,
  );

  factory IzvjestajNarudzbi.fromJson(Map<String, dynamic> json) => _$IzvjestajNarudzbiFromJson(json);

  Map<String, dynamic> toJson() => _$IzvjestajNarudzbiToJson(this);
}