// ignore_for_file: file_names

import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/drzave.dart';
import 'package:flutter_mobile/models/klijent.dart';
import 'package:flutter_mobile/models/proizvodiStatistika.dart';
import 'package:flutter_mobile/models/zaposlenik.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:json_annotation/json_annotation.dart';

part 'klijentIzvjestaj.g.dart';

@JsonSerializable()
class KlijentIzvjestaj {
  final int klijentId;
  final String imePrezime;
  final double ukupanIznos;
  final int brojNarudzbi;
  final double prosjecnaVrijednost;
  final List<ProizvodStatistika> najpopularnijiProizvodi;

  KlijentIzvjestaj({
    required this.klijentId,
    required this.imePrezime,
    required this.ukupanIznos,
    required this.brojNarudzbi,
    required this.prosjecnaVrijednost,
    required this.najpopularnijiProizvodi,
  });

  factory KlijentIzvjestaj.fromJson(Map<String, dynamic> json) =>
      _$KlijentIzvjestajFromJson(json);

  Map<String, dynamic> toJson() => _$KlijentIzvjestajToJson(this);
}
