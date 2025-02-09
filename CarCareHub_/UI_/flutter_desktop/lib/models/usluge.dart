import 'package:json_annotation/json_annotation.dart';
part 'usluge.g.dart';

@JsonSerializable()
class Usluge {
   final int uslugeId;
  final String? nazivUsluge;
  final String? opis;
  final double? cijena;
bool? vidljivo;


  Usluge(this.uslugeId, this.vidljivo, this.nazivUsluge, this.opis,this.cijena);

  
  factory Usluge.fromJson(Map<String,dynamic> json) => _$UslugeFromJson(json);


  Map<String,dynamic> toJson() => _$UslugeToJson(this);
}
