import 'package:json_annotation/json_annotation.dart';
part 'narudzba.g.dart';

@JsonSerializable()
class Narudzba {
  int narudzbaId;
  DateTime? datumNarudzbe;
  DateTime? datumIsporuke;
  bool? zavrsenaNarudzba;
  int? popustId;
  double? ukupnaCijenaNarudzbe;

  Narudzba({
    required this.narudzbaId,
    required this.datumNarudzbe,
    required this.datumIsporuke,
    required this.zavrsenaNarudzba,
    required this.popustId,
    required this.ukupnaCijenaNarudzbe,
  });

  
  factory Narudzba.fromJson(Map<String,dynamic> json) => _$NarudzbaFromJson(json);


  Map<String,dynamic> toJson() => _$NarudzbaToJson(this);
}