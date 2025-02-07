
import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/godiste.dart';
import 'package:flutter_mobile/models/model.dart';
import 'package:flutter_mobile/models/vozilo.dart';
import 'package:json_annotation/json_annotation.dart';
part 'product.g.dart';

@JsonSerializable()
class Product {
  int? proizvodId;
  String? naziv;
  String? sifra;
  double? cijena;
bool? Vidljivo;

  int? popust;
  String? slika;
  double? cijenaSaPopustom;
  String? originalniBroj;
  String? modelProizvoda;
  String? opis;
  int? modelId;
  int? kategorijaId;
  int? firmaAutodijelovaID;
  final FirmaAutodijelova? firmaAutoDijelova;
  int? proizvodjacId;
  final Model? model;
  int? godisteId;
  final Godiste? godiste;
  final Vozilo? vozilo;
  int? voziloId;
  String? stateMachine;

  Product(this.proizvodId, this.Vidljivo, this.voziloId,this.naziv,this.sifra,this.cijena,this.popust,this.slika,this.cijenaSaPopustom,this.originalniBroj,this.opis,this.modelId,
  this.kategorijaId,this.vozilo, this.firmaAutodijelovaID,this.proizvodjacId,this.firmaAutoDijelova,this.model,this.modelProizvoda,this.godiste,this.godisteId,
  this.stateMachine);

  factory Product.fromJson(Map<String,dynamic> json) => _$ProductFromJson(json);


  Map<String,dynamic> toJson() => _$ProductToJson(this);
}
