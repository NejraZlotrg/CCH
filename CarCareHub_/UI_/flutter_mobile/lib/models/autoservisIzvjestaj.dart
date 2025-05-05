import 'package:flutter_mobile/models/proizvodiStatistika.dart';
import 'package:json_annotation/json_annotation.dart';

part 'autoservisIzvjestaj.g.dart';

@JsonSerializable()
class AutoservisIzvjestaj {
  final int autoservisId;
  final String nazivAutoservisa;
  final double ukupanIznos;
  final int brojNarudzbi;
  final double prosjecnaCijena;
  final List<ProizvodStatistika> najpopularnijiProizvodi;
  final DateTime periodOd;
  final DateTime periodDo;

  AutoservisIzvjestaj({
    required this.autoservisId,
    required this.nazivAutoservisa,
    required this.ukupanIznos,
    required this.brojNarudzbi,
    required this.prosjecnaCijena,
    required this.najpopularnijiProizvodi,
    required this.periodOd,
    required this.periodDo,
  });

  factory AutoservisIzvjestaj.fromJson(Map<String, dynamic> json) =>
      _$AutoservisIzvjestajFromJson(json);

  Map<String, dynamic> toJson() => _$AutoservisIzvjestajToJson(this);
}
