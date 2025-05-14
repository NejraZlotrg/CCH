// ignore_for_file: file_names

import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/drzave.dart';
import 'package:flutter_mobile/models/klijent.dart';
import 'package:flutter_mobile/models/zaposlenik.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:json_annotation/json_annotation.dart';

part 'izvjestajnarudzbi.g.dart';

@JsonSerializable()
class IzvjestajNarudzbi {
  int? narudzbaId;
  DateTime? datumNarudzbe;
  Klijent? klijent;
  Autoservis? autoservis;
  Zaposlenik? zaposlenik;
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

  factory IzvjestajNarudzbi.fromJson(Map<String, dynamic> json) =>
      _$IzvjestajNarudzbiFromJson(json);

  Map<String, dynamic> toJson() => _$IzvjestajNarudzbiToJson(this);
}
