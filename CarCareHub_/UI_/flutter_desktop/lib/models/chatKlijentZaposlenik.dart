import 'package:flutter_mobile/models/zaposlenik.dart';
import 'package:flutter_mobile/models/klijent.dart';
import 'package:json_annotation/json_annotation.dart';
part 'chatKlijentZaposlenik.g.dart';

@JsonSerializable()
class chatKlijentZaposlenik {
   final int chatKlijentZaposlenikId;
  final int? klijentId;
  final Klijent? klijent;
  final Zaposlenik? zaposlenik;
  final int? zaposlenikId;
  final String? poruka;
  final bool? poslanoOdKlijenta;
  final DateTime? vrijemeSlanja;
bool? vidljivo;

  


  chatKlijentZaposlenik(this.chatKlijentZaposlenikId, this.vidljivo, this.klijentId,this.zaposlenikId, this.zaposlenik, this.klijent, 
  this.poruka,this.poslanoOdKlijenta,this.vrijemeSlanja);

  
  factory chatKlijentZaposlenik.fromJson(Map<String,dynamic> json) => _$chatKlijentZaposlenikFromJson(json);


  Map<String,dynamic> toJson() => _$chatKlijentZaposlenikToJson(this);
}
