import 'package:flutter_mobile/models/narudzba_stavke.dart';
import 'package:json_annotation/json_annotation.dart';
part 'narudzba.g.dart';

@JsonSerializable()
class Narudzba {
  final int id;
  final double ukupnaCijenaNarudzbe;
  final DateTime datumIsporuke;
  final bool zavrsenaNarudzba;

  Narudzba({
    required this.id,
    required this.ukupnaCijenaNarudzbe,
    required this.datumIsporuke,
    required this.zavrsenaNarudzba,
  });

  
  factory Narudzba.fromJson(Map<String,dynamic> json) => _$NarudzbaFromJson(json);


  Map<String,dynamic> toJson() => _$NarudzbaToJson(this);
}