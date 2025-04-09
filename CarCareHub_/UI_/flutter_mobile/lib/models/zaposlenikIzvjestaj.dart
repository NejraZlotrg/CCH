import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/drzave.dart';
import 'package:flutter_mobile/models/klijent.dart';
import 'package:flutter_mobile/models/proizvodiStatistika.dart';
import 'package:flutter_mobile/models/zaposlenik.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:json_annotation/json_annotation.dart';

part 'zaposlenikIzvjestaj.g.dart';

@JsonSerializable()
class ZaposlenikIzvjestaj { 
  late final int zaposlenikId;
  late final String imePrezime;
  late final double ukupanIznos;
  late final int brojNarudzbi;
  late final double prosjecnaVrijednost;
  late final List<ProizvodStatistika> najpopularnijiProizvodi;
  late final String autoservis;

  ZaposlenikIzvjestaj({
    required this.zaposlenikId,
    required this.imePrezime,
    required this.ukupanIznos,
    required this.brojNarudzbi,
    required this.prosjecnaVrijednost,
    required this.najpopularnijiProizvodi,
    required this.autoservis,
  });


  factory ZaposlenikIzvjestaj.fromJson(Map<String, dynamic> json) => _$ZaposlenikIzvjestajFromJson(json);

  Map<String, dynamic> toJson() => _$ZaposlenikIzvjestajToJson(this);
}