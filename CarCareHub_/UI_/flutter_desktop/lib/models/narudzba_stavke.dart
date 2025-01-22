import 'package:flutter_mobile/models/narudzba.dart';
import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/models/vozilo.dart';
import 'package:json_annotation/json_annotation.dart';
part 'narudzba_stavke.g.dart'; 

@JsonSerializable()
class NarudzbaStavke {
  final int? proizvodId;
  final int? kolicina;
  final double? ukupnaCijenaProizvoda;
  final Product? proizvod;
  final Narudzba? narudzba;
  final int? narudzbaId;


  NarudzbaStavke(this.proizvodId,this.kolicina, this.ukupnaCijenaProizvoda,this.proizvod,this.narudzba,this.narudzbaId);

  
  factory NarudzbaStavke.fromJson(Map<String,dynamic> json) => _$NarudzbaStavkeFromJson(json);


  Map<String,dynamic> toJson() => _$NarudzbaStavkeToJson(this);
}