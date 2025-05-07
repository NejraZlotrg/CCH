import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/klijent.dart';
import 'package:json_annotation/json_annotation.dart';
part 'chatAutoservisKlijent.g.dart';

@JsonSerializable()
class chatAutoservisKlijent {
  int id;
  int klijentId;
  String klijentIme;
  int autoservisId;
  String autoservisNaziv;
  String? poruka;
  bool poslanoOdKlijenta;
  DateTime vrijemeSlanja;


  chatAutoservisKlijent(this.id,  this.klijentId,this.autoservisId, this.autoservisNaziv, this.klijentIme, 
  this.poruka,this.poslanoOdKlijenta,this.vrijemeSlanja);

  
  factory chatAutoservisKlijent.fromJson(Map<String,dynamic> json) => _$chatAutoservisKlijentFromJson(json);


  Map<String,dynamic> toJson() => _$chatAutoservisKlijentToJson(this);
}
