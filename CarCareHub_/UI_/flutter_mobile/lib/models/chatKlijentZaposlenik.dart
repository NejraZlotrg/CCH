import 'package:flutter_mobile/models/zaposlenik.dart';
import 'package:flutter_mobile/models/klijent.dart';
import 'package:json_annotation/json_annotation.dart';
part 'chatKlijentZaposlenik.g.dart';

@JsonSerializable()
class chatKlijentZaposlenik {
  int id;
  int klijentId;
  String klijentIme;
  int zaposlenikId;
  String zaposlenikIme;
  String? poruka;
  bool poslanoOdKlijenta;
  DateTime vrijemeSlanja;
//bool? vidljivo;

  chatKlijentZaposlenik(
      this.id,
      this.klijentId,
      this.zaposlenikId,
      this.zaposlenikIme,
      this.klijentIme,
      this.poruka,
      this.poslanoOdKlijenta,
      this.vrijemeSlanja);

  factory chatKlijentZaposlenik.fromJson(Map<String, dynamic> json) =>
      _$chatKlijentZaposlenikFromJson(json);

  Map<String, dynamic> toJson() => _$chatKlijentZaposlenikToJson(this);
}
