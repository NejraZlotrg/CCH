import 'package:json_annotation/json_annotation.dart';
part 'usluge.g.dart';

@JsonSerializable()
class Usluge {
  int? uslugeId;
  String? nazivUsluge;
  String? opis;
  int? cijena;


  Usluge(this.uslugeId, this.nazivUsluge, this.opis,this.cijena);

  
  factory Usluge.fromJson(Map<String,dynamic> json) => _$UslugeFromJson(json);


  Map<String,dynamic> toJson() => _$UslugeToJson(this);
}
